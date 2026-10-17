#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../helpers.bash"

ENTRY="${BATS_TEST_DIRNAME}/../../time-revamped.tmux"

setup() {
  setup_test_environment
  export SPAWN_LOG="${TEST_TMPDIR}/spawn.log"
  nohup() { printf '%s\n' "$*" >> "${SPAWN_LOG}"; }
  export -f nohup
}

teardown() {
  cleanup_test_environment
}

@test "entry - jobs mode turns a placeholder into a dispatcher call" {
  tmux set-option -gq "status-right" "[#{time_local}]"

  bash "${ENTRY}"

  [[ "$(cat "$(_mock_opt_file status-right)")" == "[#($(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/src/time.sh local)]" ]]
}

@test "entry - options mode turns a placeholder into an option read" {
  tmux set-option -gq "@time_revamped_render" "options"
  tmux set-option -gq "status-right" "[#{time_local}]"

  bash "${ENTRY}"

  [[ "$(cat "$(_mock_opt_file status-right)")" == "[#{E:@time_revamped_out_local}]" ]]
}

@test "entry - options mode starts the ticker" {
  tmux set-option -gq "@time_revamped_render" "options"
  tmux set-option -gq "status-right" "[#{time_local}]"

  bash "${ENTRY}"

  [[ "$(cat "${SPAWN_LOG}")" == *"/src/time.sh daemon" ]]
}

@test "entry - jobs mode starts no ticker" {
  tmux set-option -gq "status-right" "[#{time_local}]"

  bash "${ENTRY}"

  [ ! -f "${SPAWN_LOG}" ]
}

@test "entry - only metrics on the status line are published" {
  tmux set-option -gq "status-right" "#{time_local}"

  bash "${ENTRY}"

  [[ "$(cat "$(_mock_opt_file @time_revamped_published)")" == "local" ]]
}

@test "entry - a second run keeps metrics already turned into option reads" {
  tmux set-option -gq "@time_revamped_render" "options"
  tmux set-option -gq "status-right" "[#{E:@time_revamped_out_local}]"

  bash "${ENTRY}"

  [[ "$(cat "$(_mock_opt_file @time_revamped_published)")" == "local" ]]
}

record_bind_keys() {
  export BIND_LOG="${TEST_TMPDIR}/bind.log"
  eval "$(declare -f tmux | sed '1s/^tmux/_mock_tmux/')"
  tmux() {
    if [[ "${1}" == "bind-key" ]]; then
      printf '%s\n' "$*" >> "${BIND_LOG}"
      return 0
    fi
    _mock_tmux "$@"
  }
  export -f _mock_tmux tmux
}

@test "entry - the menu key defaults to M-t" {
  # Arrange
  record_bind_keys

  # Act
  bash "${ENTRY}"

  # Assert
  [[ "$(cat "${BIND_LOG}")" == "bind-key M-t run-shell "*"/src/time.sh menu" ]]
}

@test "entry - a menu key of off binds nothing" {
  # Arrange
  record_bind_keys
  tmux set-option -gq "@time_revamped_menu_key" "off"

  # Act
  bash "${ENTRY}"

  # Assert
  [ ! -e "${BIND_LOG}" ]
}

@test "entry - the calendar action stays unbound by default" {
  # Arrange
  record_bind_keys

  # Act
  bash "${ENTRY}"

  # Assert
  [[ "$(cat "${BIND_LOG}")" != *"calendar"* ]]
}

@test "entry - jobs mode quotes a plugin path with a space, a quote and a hash" {
  # Arrange
  local dir="${TEST_TMPDIR}/it's #x dir"
  mkdir -p "${dir}"
  cp -f "${ENTRY}" "${dir}/time-revamped.tmux"
  tmux set-option -gq "status-right" "[#{time_iso}]"

  # Act
  bash "${dir}/time-revamped.tmux"

  # Assert
  [[ "$(cat "$(_mock_opt_file status-right)")" == "[#($(cd "${TEST_TMPDIR}" && pwd)/it\\'s\\ ##x\\ dir/src/time.sh iso)]" ]]
}

@test "entry - the menu key quotes a plugin path with a space, a quote and a hash" {
  # Arrange
  record_bind_keys
  local dir="${TEST_TMPDIR}/it's #x dir"
  mkdir -p "${dir}"
  cp -f "${ENTRY}" "${dir}/time-revamped.tmux"

  # Act
  bash "${dir}/time-revamped.tmux"

  # Assert
  [[ "$(cat "${BIND_LOG}")" == "bind-key M-t run-shell $(cd "${TEST_TMPDIR}" && pwd)/it\\'s\\ ##x\\ dir/src/time.sh menu" ]]
}

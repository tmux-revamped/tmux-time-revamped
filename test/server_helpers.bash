#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/tmux_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/tmux_helpers.bash"

EPOCH_OCT_16=1792161000

screens() {
  printf 'host screen:\n'
  command tmux -S "${HOST}" capture-pane -p -t host || :
  printf 'options:\n'
  tmux show-options -g | grep time_revamped || :
  printf 'messages:\n'
  tmux show-messages | tail -n 5 || :
}

wait_for() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.1 0.2 0.2 0.5 0.5 1 1 1 2 2; do
    "$@" && return 0
    sleep "${delay}"
  done
  "$@" && return 0
  screens
  return 1
}

attached() {
  local clients
  clients=$(tmux list-clients -F x 2>/dev/null)
  [[ -n "${clients}" ]]
}

holds() {
  local now
  now=$(tmux show-option -gqv "@time_revamped_$1")
  [[ "${now}" == "$2" ]]
}

matches() {
  local now
  now=$(tmux show-option -gqv "@time_revamped_$1")
  [[ "${now}" =~ $2 ]]
}

host_shows() {
  local screen
  screen=$(command tmux -S "${HOST}" capture-pane -p -t host)
  [[ "${screen}" == *"$1"* ]]
}

host_lacks() {
  ! host_shows "$1"
}

said() {
  local messages
  messages=$(tmux show-messages)
  [[ "${messages}" == *"time-revamped: $1"* ]]
}

stand_in() {
  printf '#!/bin/sh\n{ set +x; } 2>/dev/null\n%s\n' "$2" >"${STUBS}/$1"
  chmod +x "${STUBS}/$1"
}

fixed_clock() {
  local stamp="$1" probe
  probe=$(/bin/date -d @0 +%s 2>/dev/null) || probe=""
  if [[ "${probe}" == 0 ]]; then
    stand_in date 'case "${1:-}" in
-d | -r) exec /bin/date "$@" ;;
*) exec /bin/date -d @'"${stamp}"' "$@" ;;
esac'
  else
    stand_in date 'case "${1:-}" in
-d | -r) exec /bin/date "$@" ;;
*) exec /bin/date -r '"${stamp}"' "$@" ;;
esac'
  fi
}

clipboard() {
  stand_in pbcopy 'cat >"'"${BATS_TEST_TMPDIR}"'/clipboard"'
  stand_in wl-copy 'cat >"'"${BATS_TEST_TMPDIR}"'/clipboard"'
  stand_in xclip 'cat >"'"${BATS_TEST_TMPDIR}"'/clipboard"'
}

copied() {
  local value
  value=$(cat "${BATS_TEST_TMPDIR}/clipboard" 2>/dev/null)
  [[ "${value}" =~ $1 ]]
}

setup() {
  unset BASH_ENV
  ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  STUBS="${BATS_TEST_TMPDIR}/stubs"
  export HOME="${BATS_TEST_TMPDIR}/home"
  export TZ=UTC
  mkdir -p "${HOME}" "${STUBS}"
  fixed_clock "${EPOCH_OCT_16}"
  stand_in cal 'printf "%s\n" "calendar stand-in"'
  clipboard
  PATH="${STUBS}:${PATH}"
  setup_tmux_server
  HOST="${TMUX_SOCKET}-host"
  tmux set-option -g default-command "env PS1='$ ' sh"
  tmux respawn-pane -k -t test:0.0 "env PS1='$ ' sh"
  tmux set-option -g status-interval 1
  tmux set-option -g status-left ''
  tmux set-option -g status-right-length 120
  tmux set-option -g @time_revamped_interval 1
  command tmux -S "${HOST}" -f /dev/null new-session -d -s host -x 120 -y 30 \
    "env -u TMUX TERM=xterm-256color tmux -u -S '${TMUX_SOCKET}' attach-session -t test"
  wait_for attached
}

teardown() {
  local daemon
  daemon=$(tmux show-option -gqv @time_revamped_ticker_pid 2>/dev/null) || daemon=""
  if [[ "${daemon}" =~ ^[0-9]+$ ]]; then
    pkill -P "${daemon}" 2>/dev/null || :
    kill "${daemon}" 2>/dev/null || :
  fi
  command tmux -S "${HOST}" kill-server 2>/dev/null || :
  rm -f "${HOST}"
  teardown_tmux_server
}

load_plugin() {
  local quoted
  quoted=$(printf '%s' "${1:-${ROOT}}" | sed "s/'/'\\\\''/g")
  tmux run-shell "'${quoted}/time-revamped.tmux'"
}

setting() {
  set_option "@time_revamped_$1" "$2"
}

press() {
  local key
  for key in "$@"; do
    command tmux -S "${HOST}" send-keys -t host "${key}"
  done
}

prefix_keys() {
  local table
  table=$(tmux list-keys -T prefix)
  awk '{ for (i = 1; i < NF; i++) { if ($i == "-T") { print $(i + 2); break } } }' <<<"${table}"
}

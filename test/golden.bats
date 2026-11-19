#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031

# shellcheck source=test/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

setup() {
  harness_setup
  unset KODOUGU_THEME KODOUGU_ACCENT NO_COLOR TIME_REVAMPED_THEME TIME_REVAMPED_ACCENT
  export REVAMPED_TEST_TMUX_VERSION=3.8 TZ=Asia/Tokyo
  mkdir -p "${BATS_TEST_TMPDIR}/zoneinfo"
  export REVAMPED_TEST_ZONEINFO="${BATS_TEST_TMPDIR}/zoneinfo"
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
}

stand_in() {
  printf '#!/bin/sh\n{ set +x; } 2>/dev/null\n%s\n' "$2" >"${BATS_TEST_TMPDIR}/stubs/$1"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/$1"
}

fixed_clock() {
  local stamp=1792161000 probe
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

transcript() {
  local flow="$1"
  shift
  # shellcheck disable=SC2086
  run ${REVAMPED_TEST_SHELL:-sh} "${REVAMPED_TESTS_DIR}/../bin/time-revamped" "$@"
  TRANSCRIPT="$(printf '$ time-revamped%s\n%s\nexit %s\n' "${*:+ $*}" "${output}" "${status}" | steady)"
  local system
  system="$(/usr/bin/uname -s)"
  case "${system}" in
  Darwin) system=darwin ;;
  *) system=linux ;;
  esac
  GOLDEN="${REVAMPED_TESTS_DIR}/golden/${flow}.${system}.txt"
  if [[ -n "${REVAMPED_TEST_RECORD:-}" ]]; then
    printf '%s\n' "${TRANSCRIPT}" >"${GOLDEN}"
  fi
}

steady() {
  sed -E \
    -e 's#/[^ ,]+#<path>#g' \
    -e 's/(gnu|bsd|uutils|busybox|mawk)( [0-9][0-9.]*)?$/<flavor>/' \
    -e 's/^time-revamped [0-9]+\.[0-9]+\.[0-9]+$/time-revamped <version>/'
}

@test "golden - help" {
  # Arrange
  local flow=help

  # Act
  transcript "${flow}" help

  # Assert
  diff -u "${GOLDEN}" <(printf '%s\n' "${TRANSCRIPT}")
}

@test "golden - version" {
  # Arrange
  local flow=version

  # Act
  transcript "${flow}" version

  # Assert
  diff -u "${GOLDEN}" <(printf '%s\n' "${TRANSCRIPT}")
}

@test "golden - doctor" {
  # Arrange
  local flow=doctor
  harness_hide wl-copy xclip
  stand_in cal ':'
  stand_in pbcopy ':'
  stand_in curl ':'
  tmux set-option -gq @time_revamped_timezones 'Europe/London'
  mkdir -p "${BATS_TEST_TMPDIR}/zoneinfo/Europe"
  : >"${BATS_TEST_TMPDIR}/zoneinfo/Europe/London"

  # Act
  transcript "${flow}" doctor

  # Assert
  diff -u "${GOLDEN}" <(printf '%s\n' "${TRANSCRIPT}")
}

@test "golden - card" {
  # Arrange
  local flow=card
  fixed_clock
  tmux set-option -gq @time_revamped_timezones 'America/New_York, Europe/London'
  tmux set-option -gq @time_revamped_countdown_target '2026-10-17'
  tmux set-option -gq @time_revamped_local_label 'Tokyo'

  # Act
  transcript "${flow}" card

  # Assert
  diff -u "${GOLDEN}" <(printf '%s\n' "${TRANSCRIPT}")
}

@test "golden - list" {
  # Arrange
  local flow=list
  tmux set-option -gq status-right '#{time} #{time_zones}'

  # Act
  transcript "${flow}" list

  # Assert
  diff -u "${GOLDEN}" <(printf '%s\n' "${TRANSCRIPT}")
}

@test "golden - an unknown command" {
  # Arrange
  local flow=unknown-command

  # Act
  transcript "${flow}" frobnicate

  # Assert
  diff -u "${GOLDEN}" <(printf '%s\n' "${TRANSCRIPT}")
}

@test "golden - an unknown option" {
  # Arrange
  local flow=unknown-option

  # Act
  transcript "${flow}" --frobnicate

  # Assert
  diff -u "${GOLDEN}" <(printf '%s\n' "${TRANSCRIPT}")
}

@test "golden - a bare run without a terminal" {
  # Arrange
  local flow=no-terminal

  # Act
  transcript "${flow}"

  # Assert
  diff -u "${GOLDEN}" <(printf '%s\n' "${TRANSCRIPT}")
}

#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2154

# shellcheck source=test/tmux_helpers.bash
source "${BATS_TEST_DIRNAME}/../tmux_helpers.bash"

wait_for() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.1 0.2 0.2 0.5 0.5 1 1 1 2 2; do
    "$@" && return 0
    sleep "${delay}"
  done
  "$@" && return 0
  command tmux -S "${HOST}" capture-pane -p -t host || :
  return 1
}

attached() {
  local clients
  clients=$(tmux list-clients -F x 2>/dev/null)
  [[ -n "${clients}" ]]
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
  [[ "${messages}" == *"$1"* ]]
}

clipboard() {
  local tool
  for tool in pbcopy wl-copy xclip xsel; do
    printf '#!/bin/sh\ncat >"%s"\n' "${BATS_TEST_TMPDIR}/clipboard" >"${STUBS}/${tool}"
    chmod +x "${STUBS}/${tool}"
  done
}

copied() {
  local value
  value=$(cat "${BATS_TEST_TMPDIR}/clipboard" 2>/dev/null)
  [[ "${value}" =~ $1 ]]
}

option_is() {
  local value
  value=$(tmux show-option -gqv "$1")
  [[ "${value}" =~ $2 ]]
}

in_view_mode() {
  local mode
  mode=$(tmux display-message -p -t test '#{pane_mode}')
  [[ "${mode}" == "view-mode" ]]
}

setup() {
  unset BASH_ENV
  ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  STUBS="${BATS_TEST_TMPDIR}/stubs"
  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}" "${STUBS}"
  printf '#!/bin/sh\nprintf "%%s\\n" "calendar stand-in"\n' >"${STUBS}/cal"
  chmod +x "${STUBS}/cal"
  clipboard
  PATH="${STUBS}:${PATH}"
  HOST="${TMUX_SOCKET}-host"
  setup_tmux_server
  tmux set-option -g default-command "env PS1='$ ' sh"
  tmux set-option -g @time_revamped_calendar_key F1
  tmux set-option -g @time_revamped_copy_key F2
  tmux set-option -g @time_revamped_mark_key F3
  command tmux -S "${HOST}" -f /dev/null new-session -d -s host -x 120 -y 40 \
    "env -u TMUX TERM=xterm-256color tmux -S '${TMUX_SOCKET}' attach-session -t test"
  wait_for attached
  tmux run-shell "'${ROOT}/time-revamped.tmux'"
}

teardown() {
  command tmux -S "${HOST}" kill-server 2>/dev/null || :
  rm -f "${HOST}"
  teardown_tmux_server
}

press() {
  local key
  for key in "$@"; do
    command tmux -S "${HOST}" send-keys -t host "${key}"
  done
}

menu() {
  press C-b M-t
  wait_for host_shows "Toggle 12/24h"
}

@test "keys - prefix M-t opens the menu, and h switches between the 24 and 12 hour formats" {
  # Arrange
  menu

  # Act
  press h

  # Assert
  wait_for option_is @time_revamped_time_format '^12H$'
  menu
  press h
  wait_for option_is @time_revamped_time_format '^24H$'
}

@test "keys - the menu's calendar item opens the calendar, which stays until a key" {
  # Arrange
  menu

  # Act
  press c

  # Assert
  wait_for host_shows "calendar stand-in"
  wait_for host_shows "press any key to close"
  press q
  wait_for host_lacks "press any key to close"
}

@test "keys - the menu's copy items put the ISO time and the epoch in the buffer and on the clipboard" {
  # Arrange
  local iso='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}' epoch='^[0-9]{9,}$'
  menu
  press i
  wait_for copied "${iso}"
  wait_for said "time-revamped: copied"
  menu

  # Act
  press e

  # Assert
  wait_for copied "${epoch}"
  run tmux show-buffer
  [[ "${output}" =~ ${epoch} ]]
}

@test "keys - the menu's mark item records the moment and says so" {
  # Arrange
  menu

  # Act
  press m

  # Assert
  wait_for option_is @time_revamped_mark_epoch '^[0-9]{9,}$'
  wait_for said "time-revamped: mark set"
}

@test "keys - the menu's doctor item shows the report" {
  # Arrange
  menu

  # Act
  press d

  # Assert
  wait_for in_view_mode
}

@test "keys - the calendar, copy and mark keys work when set" {
  # Arrange
  local iso='^[0-9]{4}-[0-9]{2}-[0-9]{2}T'
  press C-b F1
  wait_for host_shows "calendar stand-in"
  press q
  wait_for host_lacks "calendar stand-in"
  press C-b F2
  wait_for copied "${iso}"

  # Act
  press C-b F3

  # Assert
  wait_for option_is @time_revamped_mark_epoch '^[0-9]{9,}$'
}

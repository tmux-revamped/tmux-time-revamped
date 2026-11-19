#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/server_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/server_helpers.bash"

bats_require_minimum_version 1.5.0

loaded_with_status() {
  tmux set-option -g status-right '#{time_clock} #{time_elapsed} end'
  load_plugin
  wait_for host_shows "14:30  end"
}

menu() {
  press C-b M-t
  wait_for host_shows "Toggle 12/24h"
}

pane_is_plain() {
  local mode
  mode=$(tmux display-message -p -t test:0.0 '#{pane_in_mode}')
  [[ "${mode}" == "0" ]]
}

in_view_mode() {
  local mode
  mode=$(tmux display-message -p -t test '#{pane_mode}')
  [[ "${mode}" == "view-mode" ]]
}

@test "keys - prefix M-t opens the menu with its six items" {
  # Arrange
  loaded_with_status

  # Act
  press C-b M-t

  # Assert
  wait_for host_shows "Toggle 12/24h"
  wait_for host_shows "Calendar"
  wait_for host_shows "Copy ISO"
  wait_for host_shows "Copy epoch"
  wait_for host_shows "Set mark"
  wait_for host_shows "Doctor"
}

@test "keys - the menu's h item switches between the 24 and 12 hour formats, and the status line follows" {
  # Arrange
  loaded_with_status
  menu

  # Act
  press h

  # Assert
  wait_for holds time_format 12H
  wait_for host_shows "02:30 PM"
  menu
  press h
  wait_for holds time_format 24H
  wait_for host_shows "14:30  end"
}

@test "keys - the menu's calendar item opens the calendar, which stays until a key" {
  # Arrange
  loaded_with_status
  menu

  # Act
  press c

  # Assert
  wait_for host_shows "calendar stand-in"
  wait_for host_shows "press any key to close"
  press q
  wait_for host_lacks "press any key to close"
  pane_is_plain
}

@test "keys - the menu's copy items put the ISO time and the epoch in the buffer and on the clipboard" {
  # Arrange
  local iso='^2026-10-16T14:30:00\+00:00$' epoch="^${EPOCH_OCT_16}\$"
  loaded_with_status
  menu
  press i
  wait_for copied "${iso}"
  wait_for said "copied 2026-10-16T14:30:00+00:00"
  menu

  # Act
  press e

  # Assert
  wait_for copied "${epoch}"
  run tmux show-buffer
  [[ "${output}" == "${EPOCH_OCT_16}" ]]
}

@test "keys - the menu's mark item records the moment, says so, and starts the stopwatch" {
  # Arrange
  loaded_with_status
  menu

  # Act
  press m

  # Assert
  wait_for holds mark_epoch "${EPOCH_OCT_16}"
  wait_for said "mark set"
  wait_for host_shows "14:30 <1m end"
}

@test "keys - the menu's doctor item shows the report" {
  # Arrange
  loaded_with_status
  menu

  # Act
  press d

  # Assert
  wait_for in_view_mode
}

@test "keys - Escape closes the menu and changes nothing" {
  # Arrange
  loaded_with_status
  menu

  # Act
  press Escape

  # Assert
  wait_for host_lacks "Toggle 12/24h"
  holds time_format ""
  pane_is_plain
}

@test "keys - the calendar, copy and mark keys work when set" {
  # Arrange
  setting calendar_key F1
  setting copy_key F2
  setting mark_key F3
  loaded_with_status
  press C-b F1
  wait_for host_shows "calendar stand-in"
  press q
  wait_for host_lacks "calendar stand-in"
  press C-b F2
  wait_for copied '^2026-10-16T'

  # Act
  press C-b F3

  # Assert
  wait_for holds mark_epoch "${EPOCH_OCT_16}"
}

@test "keys - a key the person names opens the menu, and the default one then does nothing" {
  # Arrange
  setting menu_key F8
  loaded_with_status
  press C-b M-t
  host_lacks "Toggle 12/24h"

  # Act
  press C-b F8

  # Assert
  wait_for host_shows "Toggle 12/24h"
}

@test "keys - in options mode the status line reads options a daemon fills" {
  # Arrange
  setting render options
  setting timezones "Asia/Tokyo"
  tmux set-option -g status-right '#{time_clock} | #{time_zones} end'

  # Act
  load_plugin

  # Assert
  run tmux show-option -gqv status-right
  [[ "${output}" == "#{E:@time_revamped_out_clock} | #{E:@time_revamped_out_zones} end" ]]
  wait_for host_shows "14:30 | JST 23:30 end"
  run tmux show-option -gqv @time_revamped_ticker_pid
  [[ "${output}" =~ ^[0-9]+$ ]]
}

@test "keys - in options mode the h item changes the format on the daemon's next tick" {
  # Arrange
  setting render options
  tmux set-option -g status-right '#{time_clock} end'
  load_plugin
  wait_for host_shows "14:30 end"
  menu

  # Act
  press h

  # Assert
  wait_for host_shows "02:30 PM end"
}

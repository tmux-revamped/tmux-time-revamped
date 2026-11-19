#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/server_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/server_helpers.bash"

bats_require_minimum_version 1.5.0

everything() {
  local options
  options=$(tmux show-options -g)
  grep -vE '@time_revamped_(geoip_[a-z_]+|mark_epoch) ' <<<"${options}"
  tmux list-keys
}

@test "entrypoint - git tracks the entry point and the tool as executable" {
  # Arrange
  local modes

  # Act
  modes=$(git -C "${ROOT}" ls-files --stage -- time-revamped.tmux bin/time-revamped)

  # Assert
  run awk '$1 != "100755" { bad++ } END { print NR ":" bad + 0 }' <<<"${modes}"
  [[ "${output}" == "2:0" ]]
}

@test "entrypoint - loading binds the menu on M-t and turns each placeholder into its job, which shows the clock" {
  # Arrange
  local keys
  setting timezones "America/New_York, Asia/Tokyo"
  tmux set-option -g status-right '#{time} #{time_zones} end'

  # Act
  load_plugin

  # Assert
  keys=$(prefix_keys)
  run grep -c -x 'M-t' <<<"${keys}"
  [[ "${output}" == "1" ]]
  run tmux show-option -gqv status-right
  [[ "${output}" == "#('${ROOT}/bin/time-revamped' status datetime) #('${ROOT}/bin/time-revamped' status zones) end" ]]
  wait_for host_shows "2026-10-16 14:30 EDT 10:30 JST 23:30 end"
}

@test "entrypoint - loading twice changes nothing" {
  # Arrange
  local before after
  tmux set-option -g status-right '#{time_clock} end'
  load_plugin
  before=$(everything)

  # Act
  load_plugin

  # Assert
  after=$(everything)
  [[ "${before}" == "${after}" ]]
}

@test "entrypoint - the date, the week, the day of the year, the offset and the ISO time reach the status line" {
  # Arrange
  tmux set-option -g status-right '#{time_date} W#{time_week} D#{time_doy} #{time_offset} #{time_iso} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows "2026-10-16 W42 D289 UTC 2026-10-16T14:30:00+00:00 end"
}

@test "entrypoint - the epoch, the countdown, the stopwatch, the daylight saving warning and the overlap reach the status line" {
  # Arrange
  setting countdown_target 2026-10-17
  setting countdown_label Launch
  setting mark_epoch $((EPOCH_OCT_16 - 4500))
  setting dst_zone Asia/Tokyo
  setting timezones "America/New_York, Europe/London"
  tmux set-option -g status-right '#{time_epoch} #{time_until} #{time_elapsed} [#{time_dst}] #{time_overlap} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows "${EPOCH_OCT_16} Launch 9h 30m 1h 15m [] overlap 13:00-16:00 end"
}

@test "entrypoint - the local clock shows the city and the world clocks follow the options" {
  # Arrange
  setting local_label Home
  setting zone_labels NYC
  setting timezones "America/New_York"
  tmux set-option -g status-right '#{time_local}|#{time_zones} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows "Home 14:30|NYC 10:30 end"
}

@test "entrypoint - geoip fills the city in the background and a later draw shows it" {
  # Arrange
  setting local_source geoip
  stand_in curl 'printf "Lisbon\n"'
  tmux set-option -g status-right '#{time_local} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows "Lisbon 14:30 end"
  wait_for holds geoip_city Lisbon
}

@test "entrypoint - a setting given in the environment reaches the status job" {
  # Arrange
  tmux set-environment -g TIME_REVAMPED_TIME_FORMAT 12H
  tmux set-option -g status-right '#{time_clock} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows "02:30 PM end"
}

@test "entrypoint - a format with a percent sign in the environment reaches the status job whole" {
  # Arrange
  tmux set-environment -g TIME_REVAMPED_ZONE_SEPARATOR ' %s '
  setting timezones "America/New_York, Asia/Tokyo"
  tmux set-option -g status-right '#{time_zones} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows "EDT 10:30 %s JST 23:30 end"
}

@test "entrypoint - a checkout whose path holds a space, a quote, a hash and a percent sign loads, shows the clock and takes its key" {
  # Arrange
  local copy="${BATS_TEST_TMPDIR}/it's #1 50% plug in"
  mkdir -p "${copy}"
  cp -R "${ROOT}/bin" "${ROOT}/lib" "${ROOT}/time-revamped.tmux" "${copy}/"
  tmux set-option -g status-right '#{time_clock} end'
  load_plugin "${copy}"
  wait_for host_shows "14:30 end"

  # Act
  press C-b M-t

  # Assert
  wait_for host_shows "Toggle 12/24h"
}

@test "entrypoint - a default key someone else holds is left alone, and one the person names is bound" {
  # Arrange
  local table
  tmux bind-key -T prefix M-t display-message taken
  load_plugin
  table=$(tmux list-keys -T prefix)
  run grep -c 'M-t  *display-message taken' <<<"${table}"
  [[ "${output}" == "1" ]]
  run grep -c 'time-revamped' <<<"${table}"
  [[ "${output}" == "0" ]]
  tmux bind-key -T prefix x display-message taken-too
  setting menu_key x

  # Act
  load_plugin

  # Assert
  table=$(tmux list-keys -T prefix)
  run grep -c 'display-menu -T time-revamped' <<<"${table}"
  [[ "${output}" == "1" ]]
}

@test "entrypoint - a key set to off binds nothing" {
  # Arrange
  local table
  setting menu_key off

  # Act
  load_plugin

  # Assert
  table=$(tmux list-keys -T prefix)
  run grep -c 'time-revamped' <<<"${table}"
  [[ "${output}" == "0" ]]
}

@test "entrypoint - the calendar, copy and mark keys stay unbound until their options are set" {
  # Arrange
  local keys
  load_plugin
  keys=$(prefix_keys)
  run grep -c -x -e F1 -e F2 -e F3 <<<"${keys}"
  [[ "${output}" == "0" ]]
  setting calendar_key F1
  setting copy_key F2
  setting mark_key F3

  # Act
  load_plugin

  # Assert
  keys=$(prefix_keys)
  run grep -c -x -e F1 -e F2 -e F3 <<<"${keys}"
  [[ "${output}" == "3" ]]
}

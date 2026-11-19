#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/time_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/time_helpers.bash"

logged() {
  grep -qxF -- "$1" "${FAKE}/log"
}

other_owner() {
  quiet sleep 'kept=$(grep -v "^@time_revamped_ticker_pid	" "'"${FAKE}"'/vars" || :)
printf "%s\n@time_revamped_ticker_pid\tsomeone-else\n" "${kept}" | grep -v "^$" >"'"${FAKE}"'/vars.next"
mv -f "'"${FAKE}"'/vars.next" "'"${FAKE}"'/vars"'
}

settled() {
  local tries=0
  until "$@"; do
    tries=$((tries + 1))
    [[ "${tries}" -lt 200 ]] || return 1
    /bin/sleep 0.05
  done
}

menu_line() {
  local tool="$1" quoted="$1"
  printf 'bind-key -N World clock menu %s display-menu -T time-revamped Toggle 12/24h h run-shell "%s toggle-format" Calendar c run-shell "%s calendar" Copy ISO i run-shell "%s copy iso" Copy epoch e run-shell "%s copy epoch" Set mark m run-shell "%s mark" Doctor d run-shell "%s doctor"' "${2:-M-t}" "${quoted}" "${quoted}" "${quoted}" "${quoted}" "${quoted}" "${tool}"
}

@test "plan - a fresh install binds the world clock menu to M-t" {
  # Arrange
  local tool expected
  tool=$(tool_path)
  expected=$(menu_line "${tool}")

  # Act
  planned

  # Assert
  [[ "${output}" == "${expected}" ]]
}

@test "plan - a key set to off binds nothing, and a key the person names is bound whoever holds it" {
  # Arrange
  local tool expected
  tool=$(tool_path)
  expected=$(menu_line "${tool}" F8)
  option menu_key off
  planned
  [[ -z "${output}" ]]
  printf 'bind-key    -T prefix F8     display-message mine\n' >"${FAKE}/keys"
  option menu_key F8

  # Act
  planned

  # Assert
  [[ "${output}" == "${expected}" ]]
}

@test "plan - a tmux older than 3.1 gets its key without a note" {
  # Arrange
  tmux_is 3.0

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key M-t display-menu -T time-revamped "* ]]
}

@test "plan - the default key is left alone when something else holds it, and bound again when the binding is the plugin's own" {
  # Arrange
  printf 'bind-key    -T prefix M-t     display-message mine\n' >"${FAKE}/keys"
  planned 'time_revamped_plan; printf "[%s]\n" "${TIME_REVAMPED_SKIPPED}"; '
  [[ "${output}" == "[M-t]" ]]
  printf 'bind-key -r -T prefix M-t     run-shell "/old/bin/time-revamped menu"\n' >"${FAKE}/keys"

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key -N World clock menu M-t display-menu -T time-revamped "* ]]
}

@test "plan - a key bound with a backslash is read without it" {
  # Arrange
  printf 'bind-key    -T prefix \\M-t     display-message mine\n' >"${FAKE}/keys"

  # Act
  planned 'time_revamped_plan; printf "[%s]\n" "${TIME_REVAMPED_SKIPPED}"; '

  # Assert
  [[ "${output}" == "[M-t]" ]]
}

@test "plan - the calendar, copy and mark keys stay unbound until they are set" {
  # Arrange
  local tool
  tool=$(tool_path)
  option menu_key off
  option calendar_key F1
  option copy_key F2
  option mark_key F3

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "bind-key -N Calendar F1 run-shell ${tool} calendar" ]]
  [[ "${lines[1]}" == "bind-key -N Copy the ISO time F2 run-shell ${tool} copy iso" ]]
  [[ "${lines[2]}" == "bind-key -N Set the stopwatch mark F3 run-shell ${tool} mark" ]]
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "plan - each placeholder becomes a job that prints it, and the metrics in use are recorded" {
  # Arrange
  local tool
  tool=$(tool_path)
  option menu_key off
  var status-right '#{time} #{time_zones}#[default] #{time_iso}'
  var status-left '#{time_local} #S'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-left #(${tool} status local) #S" ]]
  [[ "${lines[1]}" == "set-option -gq status-right #(${tool} status datetime) #(${tool} status zones)#[default] #(${tool} status iso)" ]]
  [[ "${lines[2]}" == "set-option -gq @time_revamped_published datetime zones local iso" ]]
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "plan - every placeholder has its job" {
  # Arrange
  local tool
  tool=$(tool_path)
  option menu_key off
  var status-right '#{time_date}#{time_clock}#{time_until}#{time_elapsed}#{time_epoch}#{time_offset}#{time_week}#{time_doy}#{time_dst}#{time_overlap}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #(${tool} status date)#(${tool} status clock)#(${tool} status until)#(${tool} status elapsed)#(${tool} status epoch)#(${tool} status offset)#(${tool} status week)#(${tool} status doy)#(${tool} status dst)#(${tool} status overlap)" ]]
  [[ "${lines[1]}" == "set-option -gq @time_revamped_published date clock until elapsed epoch offset week doy dst overlap" ]]
}

@test "plan - #{time} and #{time_date} are different placeholders" {
  # Arrange
  local tool
  tool=$(tool_path)
  option menu_key off
  var status-right '#{time_date} #{time}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #(${tool} status date) #(${tool} status datetime)" ]]
}

@test "plan - a status line that ends in a semicolon keeps it, escaped, so tmux does not read it as a separator" {
  # Arrange
  local tool
  tool=$(tool_path)
  option menu_key off
  var status-right '#{time_clock};'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #(${tool} status clock)\\;" ]]
}

@test "plan - in options mode each placeholder becomes a read of the option the daemon fills" {
  # Arrange
  option menu_key off
  option render options
  var status-right '#{time_zones} | #{time}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #{E:@time_revamped_out_zones} | #{E:@time_revamped_out_datetime}" ]]
  [[ "${lines[1]}" == "set-option -gq @time_revamped_published datetime zones" ]]
}

@test "plan - a render mode the plugin does not know means jobs" {
  # Arrange
  local tool
  tool=$(tool_path)
  option menu_key off
  option render both
  var status-right '#{time_clock}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #(${tool} status clock)" ]]
}

@test "plan - a status line already rewritten is left as it is, and its metrics stay recorded" {
  # Arrange
  local tool
  tool=$(tool_path)
  option menu_key off
  option render options
  option published "datetime zones"
  var status-right '#{E:@time_revamped_out_datetime} | #{E:@time_revamped_out_zones}'
  planned
  [[ -z "${output}" ]]
  option render jobs
  option published "zones local"
  var status-right "#(${tool} status local) #(${tool} status zones)"

  # Act
  planned

  # Assert
  [[ -z "${output}" ]]
}

@test "plan - a status line with no placeholder is not written, and an old list of metrics is emptied" {
  # Arrange
  option menu_key off
  option published "zones"
  var status-right '%H:%M #{session_name} #{time_unknown}'

  # Act
  planned

  # Assert
  [[ "${output}" == 'set-option -gq @time_revamped_published ""' ]]
}

@test "plan - a setting given in the environment rides on the key and on every job" {
  # Arrange
  var status-right '#{time_zones}'

  # Act
  planned 'export TIME_REVAMPED_TIMEZONES=Asia/Tokyo; '

  # Assert
  [[ "${lines[0]}" == *"time-revamped' --timezones 'Asia/Tokyo' toggle-format\""* ]]
  [[ "${lines[1]}" == *"time-revamped' --timezones 'Asia/Tokyo' status zones)" ]]
}

@test "plan - settings given in the environment ride in the order of the settings table, and an empty one rides too" {
  # Arrange
  var status-right '#{time_zones}'

  # Act
  planned 'export TIME_REVAMPED_WORK_START=8 TIME_REVAMPED_LOCAL_LABEL= TIME_REVAMPED_TIME_FORMAT=12H TIME_REVAMPED_MENU_KEY=F8 TIME_REVAMPED_RENDER=jobs; '

  # Assert
  [[ "${lines[0]}" == "bind-key -N World clock menu F8 display-menu -T time-revamped "* ]]
  [[ "${lines[1]}" == *"time-revamped' --time-format '12H' --local-label '' --work-start '8' status zones)" ]]
}

@test "plan - a format given in the environment rides on the job with its percent signs doubled, since tmux reads the status line as a time format" {
  # Arrange
  option menu_key off
  var status-right '#{time_zones}'

  # Act
  planned 'export TIME_REVAMPED_ZONE_SEPARATOR="%s #"; '

  # Assert
  [[ "${lines[0]}" == *"time-revamped' --zone-separator '%%s ##' status zones)" ]]
}

@test "plan - apply sends everything in one tmux call and clears a daemon's claim in jobs mode" {
  # Arrange
  var status-right '#{time_clock}'

  # Act
  lib_run time 'time_revamped_apply'

  # Assert
  [[ "${status}" -eq 0 ]]
  run sends
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "bind-key -N World clock menu M-t display-menu -T time-revamped "*" ; set-option -gq status-right #("*" status clock) ; set-option -gq @time_revamped_published clock" ]]
  [[ "${lines[1]}" == "set-option -gqu @time_revamped_ticker_pid" ]]
}

@test "plan - when tmux refuses the batch each command is sent alone, and the bad one fails the run" {
  # Arrange
  local tool
  tool=$(tool_path)
  option menu_key off
  option calendar_key F99
  var status-right '#{time_clock}'
  printf '%s\n' "bind-key -N Calendar F99 run-shell ${tool} calendar" >"${FAKE}/refused"

  # Act
  lib_run time 'time_revamped_apply'

  # Assert
  [[ "${status}" -eq 1 ]]
  run sent '^set-option -gq status-right #(.* status clock)$'
  [[ "${output}" == "1" ]]
  holds published clock
}

@test "plan - in options mode apply starts the daemon, which claims the ticker and publishes until another takes over" {
  # Arrange
  option menu_key off
  option render options
  option interval 1
  var status-right '#{time_epoch}'
  other_owner

  # Act
  lib_run time 'time_revamped_apply'

  # Assert
  [[ "${status}" -eq 0 ]]
  settled holds out_epoch "${EPOCH_OCT_16}"
  settled holds ticker_pid someone-else
  run sent '^set-option -gq @time_revamped_ticker_pid [0-9][0-9]*$'
  [[ "${output}" == "1" ]]
}

@test "plan - the daemon ends when another process owns the ticker" {
  # Arrange
  option published "date"
  other_owner

  # Act
  tool daemon

  # Assert
  [[ "${status}" -eq 0 ]]
  holds out_date "2026-10-16"
  holds ticker_pid someone-else
}

@test "plan - the daemon asks geoip in its own shell, so the city lands in the batch it commits" {
  # Arrange
  option published "local"
  option local_source geoip
  quiet curl 'printf "Lisbon\n"'
  other_owner

  # Act
  tool daemon

  # Assert
  [[ "${status}" -eq 0 ]]
  holds geoip_city Lisbon
  holds out_local "#[fg=cyan]Lisbon 14:30#[default]"
}

@test "plan - the daemon publishes nothing for a name it has no value for, and writes every metric in one call" {
  # Arrange
  option published "elapsed date"
  other_owner

  # Act
  tool daemon

  # Assert
  [[ "${status}" -eq 0 ]]
  holds out_elapsed ""
  holds out_date "2026-10-16"
  run sent '^set-option -gq @time_revamped_out_elapsed  ; set-option -gq @time_revamped_out_date 2026-10-16'
  [[ "${output}" == "1" ]]
}

@test "mark - records the moment in an option and says so" {
  # Arrange
  local expected="${EPOCH_OCT_16}"

  # Act
  lib_run time 'time_revamped_mark'

  # Assert
  [[ "${status}" -eq 0 ]]
  holds mark_epoch "${expected}"
  logged "display-message time-revamped: mark set"
}

@test "mark - a tmux that refuses the write still returns 0" {
  # Arrange
  printf '%s\n' "set-option -gq @time_revamped_mark_epoch ${EPOCH_OCT_16}" "display-message time-revamped: mark set" >"${FAKE}/refused"

  # Act
  lib_run time 'time_revamped_mark'

  # Assert
  [[ "${status}" -eq 0 ]]
}

@test "copy - puts the ISO time in the tmux buffer and on the clipboard" {
  # Arrange
  quiet pbcopy 'cat >"'"${FAKE}"'/clipboard"'
  export TZ=Asia/Kolkata

  # Act
  lib_run time 'time_revamped_copy iso'

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "set-buffer -- 2026-10-16T20:00:00+05:30"
  file_is "${FAKE}/clipboard" "2026-10-16T20:00:00+05:30"
  logged "display-message time-revamped: copied 2026-10-16T20:00:00+05:30"
}

@test "copy - epoch copies the unix time, and any other kind copies the ISO time" {
  # Arrange
  quiet wl-copy 'cat >"'"${FAKE}"'/clipboard"'
  lib_run time 'time_revamped_copy other'
  logged "set-buffer -- 2026-10-16T14:30:00+00:00"

  # Act
  lib_run time 'time_revamped_copy epoch'

  # Assert
  [[ "${status}" -eq 0 ]]
  file_is "${FAKE}/clipboard" "${EPOCH_OCT_16}"
}

@test "copy - xclip fills the clipboard selection when it is the only tool" {
  # Arrange
  quiet xclip 'printf "%s\n" "$*" >"'"${FAKE}"'/xclip.args"; cat >"'"${FAKE}"'/clipboard"'

  # Act
  lib_run time 'time_revamped_copy epoch'

  # Assert
  [[ "${status}" -eq 0 ]]
  file_is "${FAKE}/xclip.args" "-selection clipboard"
  file_is "${FAKE}/clipboard" "${EPOCH_OCT_16}"
}

@test "copy - without a clipboard tool only the tmux buffer is filled" {
  # Arrange
  local expected="${EPOCH_OCT_16}"

  # Act
  lib_run time 'time_revamped_copy epoch'

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "set-buffer -- ${expected}"
}

@test "toggle - switches between 24 and 12 hour time" {
  # Arrange
  lib_run time 'time_revamped_toggle'
  holds time_format 12H

  # Act
  lib_run time 'time_revamped_toggle'

  # Assert
  [[ "${status}" -eq 0 ]]
  holds time_format 24H
}

@test "toggle - a time format of hide becomes 12H" {
  # Arrange
  option time_format hide

  # Act
  lib_run time 'time_revamped_toggle'

  # Assert
  holds time_format 12H
}

@test "calendar - opens cal in a popup that waits for a key" {
  # Arrange
  local expected
  expected='display-popup -E cal; printf "\npress any key to close"; state=$(stty -g); stty -icanon -echo min 1 time 0; dd bs=1 count=1 >/dev/null 2>&1; stty "${state}"'

  # Act
  lib_run time 'time_revamped_calendar'

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "${expected}"
}

@test "calendar - a tmux older than 3.2 says so and opens nothing" {
  # Arrange
  tmux_is 3.1

  # Act
  lib_run time 'time_revamped_calendar'

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "display-message time-revamped: tmux 3.2+ is required for the calendar popup"
  run sent '^display-popup'
  [[ "${output}" == "0" ]]
}

@test "calendar - a popup or a message tmux refuses to open leaves the key quiet" {
  # Arrange
  printf '%s\n' 'display-popup -E cal; printf "\npress any key to close"; state=$(stty -g); stty -icanon -echo min 1 time 0; dd bs=1 count=1 >/dev/null 2>&1; stty "${state}"' "display-message time-revamped: tmux 3.2+ is required for the calendar popup" >"${FAKE}/refused"
  lib_run time 'time_revamped_calendar'
  [[ "${status}" -eq 0 ]]
  tmux_is 3.1

  # Act
  lib_run time 'time_revamped_calendar'

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}

@test "menu - opens the six items with the tool quoted for a double-quoted tmux string" {
  # Arrange
  local tool
  tool=$(tool_path)

  # Act
  lib_run time 'time_revamped_menu'

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "display-menu -T time-revamped Toggle 12/24h h run-shell \"${tool} toggle-format\" Calendar c run-shell \"${tool} calendar\" Copy ISO i run-shell \"${tool} copy iso\" Copy epoch e run-shell \"${tool} copy epoch\" Set mark m run-shell \"${tool} mark\" Doctor d run-shell \"${tool} doctor\""
}

@test "menu - a tmux that refuses the menu leaves the key quiet" {
  # Arrange
  printf '%s\n' 'display-menu' >"${FAKE}/refused"

  # Act
  lib_run time 'time_revamped_menu'

  # Assert
  [[ "${status}" -eq 0 ]]
}

@test "plan - a path is quoted for a job with each hash and each percent sign doubled, and for a key with no hash left" {
  # Arrange
  local script='time_revamped_job_quote "/a b/it'"'"'s#1 50%"; time_revamped_literal "/a b/it'"'"'s#1 50%"'

  # Act
  lib_run time "${script}"

  # Assert
  [[ "${lines[0]}" == "'/a b/it'\\''s##1 50%%'" ]]
  [[ "${lines[1]}" == "'/a b/it'\\''s'\"\$(printf '%b' '\\0043')\"'1 50%'" ]]
}

@test "plan - a menu item quotes backslashes, double quotes and dollar signs for tmux" {
  # Arrange
  local script='time_revamped_tmux_string "a\b\"c\$d"'

  # Act
  lib_run time "${script}"

  # Assert
  [[ "${output}" == 'a\\b\"c\$d' ]]
}

@test "plan - a key chord table written by tmux with -r and the table name is read for its key" {
  # Arrange
  printf 'bind-key -r -T prefix Up display-message x\nbind-key    -T prefix C-b send-prefix\n' >"${FAKE}/keys"

  # Act
  lib_run time 'time_revamped_held'

  # Assert
  [[ "${output}" == "Up C-b " ]]
}

@test "plan - tmux versions compare as numbers" {
  # Arrange
  local script='time_revamped_version_ge 3.10 3.2 && printf yes; time_revamped_version_ge 3.2 3.2 && printf yes; time_revamped_version_ge 4.0 3.9 && printf yes; time_revamped_version_ge 3.1 3.2 || printf no; time_revamped_version_ge 2.9 3.2 || printf no; time_revamped_version_ge "" 3.2 || printf no; time_revamped_version_ge next 3.2 || printf no'

  # Act
  lib_run time "${script}"

  # Assert
  [[ "${output}" == "yesyesyesnononono" ]]
}

@test "plan - a version string with a suffix, a prefix or nothing parses" {
  # Arrange
  local script='time_revamped_parse_version "tmux 3.5a"; time_revamped_parse_version "tmux next-3.7"; time_revamped_parse_version "tmux master"; time_revamped_parse_version ""'

  # Act
  lib_run time "${script}"

  # Assert
  [[ "${lines[0]}" == 3.5 && "${lines[1]}" == 3.7 && "${#lines[@]}" -eq 2 ]]
}

@test "plan - a tmux that does not answer leaves the plan with no version and no notes" {
  # Arrange
  quiet tmux 'exit 1'

  # Act
  lib_run time 'time_revamped_version; printf "[%s]\n" "${TIME_REVAMPED_TMUX}"; time_revamped_setting_rows | head -n 1'

  # Assert
  [[ "${lines[0]}" == "[]" ]]
  [[ "${lines[1]}" == "menu_key	M-t" ]]
}

@test "plan - a hash in a name is doubled before tmux reads it as a format" {
  # Arrange
  local script='time_revamped_doubled "a#b##c#"; printf "%s\n" "${TIME_REVAMPED_DOUBLED}"; time_revamped_doubled "plain"; printf "%s\n" "${TIME_REVAMPED_DOUBLED}"'

  # Act
  lib_run time "${script}"

  # Assert
  [[ "${lines[0]}" == 'a##b####c##' && "${lines[1]}" == plain ]]
}

@test "plan - a setting name takes dashes or underscores and an unknown one is empty" {
  # Arrange
  local script='time_revamped_setting_name --zone-labels; time_revamped_setting_name --bogus'

  # Act
  lib_run time "${script}"

  # Assert
  [[ "${lines[0]}" == zone_labels && "${lines[1]}" == "" ]]
}

@test "plan - a plan prints as one command per line and as JSON with an empty argument kept" {
  # Arrange
  local script='time_revamped_emit set-option -gq @a ""; time_revamped_emit bind-key F1 "x;"; time_revamped_lines; time_revamped_json; time_revamped_bindings'

  # Act
  lib_run time "${script}"

  # Assert
  [[ "${lines[0]}" == 'set-option -gq @a ""' ]]
  [[ "${lines[1]}" == 'bind-key F1 x\;' ]]
  [[ "${lines[2]}" == '{"bindings":[["set-option","-gq","@a",""],["bind-key","F1","x\\;"]]}' ]]
  [[ "${lines[3]}" == 1 ]]
}

@test "plan - an empty value in the settings read from tmux leaves the default" {
  # Arrange
  option menu_key ""
  option zone_separator ""

  # Act
  lib_run time 'time_revamped_load; printf "[%s][%s]\n" "${TIME_REVAMPED_S_menu_key}" "${TIME_REVAMPED_S_zone_separator}"'

  # Assert
  [[ "${output}" == "[M-t][ ]" ]]
}

@test "plan - the environment wins over the tmux option" {
  # Arrange
  option timezones Asia/Tokyo

  # Act
  lib_run time 'export TIME_REVAMPED_TIMEZONES=Europe/London; time_revamped_load; printf "%s\n" "${TIME_REVAMPED_S_timezones}"'

  # Assert
  [[ "${output}" == Europe/London ]]
}

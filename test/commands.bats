#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/time_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/time_helpers.bash"

logged() {
  grep -qxF -- "$1" "${FAKE}/log"
}

zoneinfo() {
  mkdir -p "${BATS_TEST_TMPDIR}/zoneinfo/Europe"
  : >"${BATS_TEST_TMPDIR}/zoneinfo/Europe/London"
  : >"${BATS_TEST_TMPDIR}/zoneinfo/UTC"
  export REVAMPED_TEST_ZONEINFO="${BATS_TEST_TMPDIR}/zoneinfo"
}

@test "status - prints the clock the placeholder stands for" {
  # Arrange
  local expected="2026-10-16 14:30"

  # Act
  tool status datetime

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "${expected}" ]]
}

@test "status - epoch prints the unix time" {
  # Arrange
  now "${EPOCH_OCT_30}"

  # Act
  tool status epoch

  # Assert
  [[ "${output}" == "${EPOCH_OCT_30}" ]]
}

@test "status - a name that is no placeholder names the placeholders" {
  # Arrange
  local name=temperature

  # Act
  tool status "${name}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "time-revamped: status must be datetime, date, clock, zones, local, until, elapsed, epoch, iso, offset, week, doy, dst or overlap, got: temperature" ]]
}

@test "status - without a name is a usage error" {
  # Arrange
  local command=status

  # Act
  tool "${command}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "time-revamped: no placeholder given. run 'time-revamped help' for usage." ]]
}

@test "status - a setting on the command line wins over the tmux option" {
  # Arrange
  option timezones "Europe/London"

  # Act
  tool --timezones "Asia/Tokyo" status zones

  # Assert
  [[ "${output}" == "#[fg=blue]JST 23:30#[default]" ]]
}

@test "status - --name=value works too, and the environment beats the option" {
  # Arrange
  option timezones "Europe/London"
  export TIME_REVAMPED_TIMEZONES="Asia/Tokyo"

  # Act
  tool --compact=1 status zones

  # Assert
  [[ "${output}" == "#[fg=blue]Tok 23:30#[default]" ]]
}

@test "status - two dashes end the options" {
  # Arrange
  local command=status

  # Act
  tool -- "${command}" iso

  # Assert
  [[ "${output}" == "2026-10-16T14:30:00+00:00" ]]
}

@test "status - an option without its value is a usage error" {
  # Arrange
  local option=--timezones

  # Act
  tool "${option}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "time-revamped: option '--timezones' needs a value. run 'time-revamped help' for usage." ]]
}

@test "status - a short option that does not exist is a usage error" {
  # Arrange
  local option=-x

  # Act
  tool "${option}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "time-revamped: unknown option '-x'. run 'time-revamped help' for usage." ]]
}

@test "status - an unknown option with a value is a usage error" {
  # Arrange
  local option=--bogus=1

  # Act
  tool "${option}" status iso

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "time-revamped: unknown option '--bogus'. run 'time-revamped help' for usage." ]]
}

@test "status - a number setting that is no number is a bad value" {
  # Arrange
  local value=soon

  # Act
  tool --work-start "${value}" status clock

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "time-revamped: --work-start must be a whole number, got: soon" ]]
}

@test "status - a choice setting outside its words names them" {
  # Arrange
  local value=sideways

  # Act
  tool --date-format "${value}" status date

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "time-revamped: --date-format must be YMD, MD, DM, MDY, DMY or hide, got: sideways" ]]
}

@test "status - a switch outside 0 and 1 is a bad value" {
  # Arrange
  export TIME_REVAMPED_COMPACT=yes

  # Act
  tool status zones

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "time-revamped: --compact must be 0 or 1, got: yes" ]]
}

@test "status - the interval is minute or a whole number" {
  # Arrange
  export TIME_REVAMPED_INTERVAL=often

  # Act
  tool status clock

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "time-revamped: --interval must be minute or a whole number, got: often" ]]
}

@test "status - an interval of minute, a number and an empty value pass" {
  # Arrange
  export TIME_REVAMPED_INTERVAL=minute
  tool status clock
  [[ "${status}" -eq 0 ]]
  export TIME_REVAMPED_INTERVAL=30
  tool status clock
  [[ "${status}" -eq 0 ]]
  export TIME_REVAMPED_INTERVAL=

  # Act
  tool status clock

  # Assert
  [[ "${status}" -eq 0 ]]
}

@test "status - only the first bad value is named" {
  # Arrange
  export TIME_REVAMPED_COMPACT=yes TIME_REVAMPED_WORK_HOURS=maybe

  # Act
  tool status clock

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "time-revamped: --"*" must be 0 or 1, got: "* ]]
}

@test "status - a setting the environment holds that no kind covers is accepted" {
  # Arrange
  export TIME_REVAMPED_MORNING_COLOR="#[fg=red]"

  # Act
  tool status clock

  # Assert
  [[ "${status}" -eq 0 ]]
}

@test "list - prints the commands apply would send, one per line" {
  # Arrange
  var status-right '#{time_clock}'

  # Act
  tool list

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" == "bind-key -N World clock menu M-t display-menu -T time-revamped "* ]]
  [[ "${lines[1]}" == "set-option -gq status-right #("*" status clock)" ]]
  [[ "${lines[2]}" == "set-option -gq @time_revamped_published clock" ]]
}

@test "list - --json prints one object" {
  # Arrange
  option menu_key off
  var status-right '#{time_clock}'

  # Act
  tool list --json

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == '{"bindings":[["set-option","-gq","status-right","#('*' status clock)"],["set-option","-gq","@time_revamped_published","clock"]]}' ]]
}

@test "list - --json works only with list" {
  # Arrange
  local command=card

  # Act
  tool --json "${command}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "time-revamped: option '--json' works only with list. run 'time-revamped help' for usage." ]]
}

@test "apply - sends the plan and prints nothing" {
  # Arrange
  var status-right '#{time_clock}'

  # Act
  tool apply

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
  holds published clock
}

@test "apply - the apply command of the menu says how many keys it bound" {
  # Arrange
  export REVAMPED_TEST_GUM=1
  answers "Apply them now"

  # Act
  tool

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Applied. 1 key is bound." ]]
}

@test "apply - the menu says keys in the plural" {
  # Arrange
  export REVAMPED_TEST_GUM=1
  option calendar_key F1
  answers "Apply them now"

  # Act
  tool

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Applied. 2 keys are bound." ]]
}

@test "card - prints every figure and a closing sentence" {
  # Arrange
  option timezones "Europe/London"
  option countdown_target 2026-10-17

  # Act
  tool card

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" =~ ^Time\ +2026-10-16\ 14:30$ ]]
  [[ "${lines[1]}" =~ ^ISO\ +2026-10-16T14:30:00\+00:00$ ]]
  [[ "${output}" =~ Zones\ +BST\ 15:30 ]]
  [[ "${output}" =~ Local\ +UTC\ 14:30 ]]
  [[ "${output}" =~ Countdown\ +9h\ 30m ]]
  has_line "$(printf '%-14s %s' Stopwatch -)"
  [[ "${lines[$((${#lines[@]} - 1))]}" == "Read. It is 2026-10-16T14:30:00+00:00." ]]
}

@test "card - draws a table where gum draws" {
  # Arrange
  export REVAMPED_TEST_GUM=1

  # Act
  tool card

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Read. It is 2026-10-16T14:30:00+00:00."* ]]
}

@test "menu - the world clock menu opens from the command" {
  # Arrange
  local tool
  tool=$(bin_path)

  # Act
  tool menu

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "display-menu -T time-revamped Toggle 12/24h h run-shell \"${tool} toggle-format\" Calendar c run-shell \"${tool} calendar\" Copy ISO i run-shell \"${tool} copy iso\" Copy epoch e run-shell \"${tool} copy epoch\" Set mark m run-shell \"${tool} mark\" Doctor d run-shell \"${tool} doctor\""
}

@test "calendar - runs from the command" {
  # Arrange
  local command=calendar

  # Act
  tool "${command}"

  # Assert
  [[ "${status}" -eq 0 ]]
  run sent '^display-popup -E cal;'
  [[ "${output}" == "1" ]]
}

@test "copy - defaults to the ISO time and takes epoch" {
  # Arrange
  tool copy
  logged "set-buffer -- 2026-10-16T14:30:00+00:00"

  # Act
  tool copy epoch

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "set-buffer -- ${EPOCH_OCT_16}"
}

@test "copy - a kind other than epoch copies the ISO time" {
  # Arrange
  local kind=hex

  # Act
  tool copy "${kind}"

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "set-buffer -- 2026-10-16T14:30:00+00:00"
}

@test "mark - sets the stopwatch mark from the command" {
  # Arrange
  local command=mark

  # Act
  tool "${command}"

  # Assert
  [[ "${status}" -eq 0 ]]
  holds mark_epoch "${EPOCH_OCT_16}"
}

@test "toggle-format - switches the time format from the command" {
  # Arrange
  local command=toggle-format

  # Act
  tool "${command}"

  # Assert
  [[ "${status}" -eq 0 ]]
  holds time_format 12H
}

@test "doctor - names every source with its path and ends in the settings and keys rows" {
  # Arrange
  zoneinfo
  quiet cal ':'
  quiet pbcopy ':'
  quiet curl ':'
  option timezones "Europe/London, UTC"

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ tmux\ +ok\ +.*,\ 3\.6 ]]
  [[ "${output}" =~ popup\ +ok\ +tmux\ 3\.6\ opens\ the\ calendar\ popup ]]
  [[ "${output}" =~ cal\ +ok\ +.*,\ draws\ the\ calendar\ popup ]]
  [[ "${output}" =~ pbcopy\ +ok\ +.*,\ copies\ a\ timestamp ]]
  [[ "${output}" =~ curl\ +ok\ +.*,\ asks\ geoip ]]
  [[ "${output}" =~ zoneinfo\ +ok\ +${BATS_TEST_TMPDIR}/zoneinfo,\ holds\ the\ zone\ names ]]
  [[ "${output}" =~ timezones\ +ok\ +2\ configured ]]
  [[ "${output}" =~ settings\ +ok\ +every\ option\ holds\ a\ value\ it\ knows ]]
  [[ "${output}" =~ keys\ +ok\ +every\ key\ it\ binds\ is\ free\ or\ its\ own ]]
}

@test "doctor - warns for what is missing and still exits 0" {
  # Arrange
  tmux_is 3.1

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ popup\ +warn\ +the\ calendar\ popup\ needs\ tmux\ 3\.2\ or\ later ]]
  [[ "${output}" =~ cal\ +warn\ +without\ it\ the\ calendar\ popup\ is\ empty ]]
  [[ "${output}" =~ clipboard\ +warn\ +no\ pbcopy,\ wl-copy\ or\ xclip ]]
  [[ "${output}" =~ curl\ +warn\ +without\ it\ geoip\ is\ off ]]
}

@test "doctor - names the clipboard tool it found" {
  # Arrange
  quiet wl-copy ':'

  # Act
  tool doctor

  # Assert
  [[ "${output}" =~ wl-copy\ +ok\ +.*,\ copies\ a\ timestamp\ to\ the\ system\ clipboard ]]
}

@test "doctor - names a zone that is not in the database" {
  # Arrange
  zoneinfo
  option timezones "Europe/London Mars/Olympus Nowhere"

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ timezones\ +warn\ +unknown:\ Mars/Olympus\ Nowhere ]]
}

@test "doctor - says when no zone is configured" {
  # Arrange
  zoneinfo

  # Act
  tool doctor

  # Assert
  [[ "${output}" =~ timezones\ +ok\ +none\ configured ]]
}

@test "doctor - warns when the zone database is missing" {
  # Arrange
  export REVAMPED_TEST_ZONEINFO="${BATS_TEST_TMPDIR}/nowhere"

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ zoneinfo\ +warn\ +${BATS_TEST_TMPDIR}/nowhere\ is\ missing ]]
}

@test "doctor - names a setting value outside its list" {
  # Arrange
  option compact yes
  option render sometimes

  # Act
  tool doctor

  # Assert
  [[ "${output}" =~ settings\ +warn\ +unknown\ values:\ compact=yes\ render=sometimes ]]
}

@test "doctor - names a default key it skipped because someone else holds it" {
  # Arrange
  printf 'bind-key    -T prefix M-t     display-message mine\n' >"${FAKE}/keys"

  # Act
  tool doctor

  # Assert
  [[ "${output}" =~ keys\ +warn\ +already\ bound\ and\ left\ alone:\ M-t ]]
}

@test "doctor - exits 1 when a required tool is missing" {
  # Arrange
  without readlink

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" =~ readlink\ +missing\ +required ]]
}

@test "doctor - the table where gum draws" {
  # Arrange
  export REVAMPED_TEST_GUM=1

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Ready. Every tool time-revamped needs is here."* ]]
}

@test "the menu - Show the time now prints the card" {
  # Arrange
  export REVAMPED_TEST_GUM=1
  answers "Show the time now"

  # Act
  tool

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Read. It is "* ]]
}

@test "the menu - List the bindings prints the plan" {
  # Arrange
  export REVAMPED_TEST_GUM=1
  answers "List the bindings"

  # Act
  tool

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"bind-key -N World clock menu M-t display-menu"* ]]
}

@test "the menu - Check this machine runs doctor" {
  # Arrange
  export REVAMPED_TEST_GUM=1
  answers "Check this machine"

  # Act
  tool

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Ready. Every tool time-revamped needs is here."* ]]
}

@test "the menu - Help prints the page" {
  # Arrange
  export REVAMPED_TEST_GUM=1
  answers "Help"

  # Act
  tool

  # Assert
  [[ "${status}" -eq 0 ]]
  grep -q '^format ' "${REVAMPED_TEST_GUM_LOG}"
}

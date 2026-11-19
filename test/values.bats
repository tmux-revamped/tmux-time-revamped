#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/time_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/time_helpers.bash"

MIDNIGHT=1792108800

at_hour() {
  now $((MIDNIGHT + $1 * 3600))
}

@test "date - the default is year, month and day" {
  # Arrange
  local expected=2026-10-16

  # Act
  reading date

  # Assert
  [[ "${output}" == "${expected}" ]]
}

@test "date - MD, DM, MDY and DMY reorder the parts" {
  # Arrange
  option date_format MDY
  reading date
  local mdy="${output}"
  option date_format DMY
  reading date
  local dmy="${output}"
  option date_format MD
  reading date
  local md="${output}"
  option date_format DM

  # Act
  reading date
  local dm="${output}"

  # Assert
  [[ "${mdy}" == 10-16-2026 && "${dmy}" == 16-10-2026 && "${md}" == 10-16 && "${dm}" == 16-10 ]]
}

@test "date - hide prints nothing and an unknown format means YMD" {
  # Arrange
  option date_format hide

  # Act
  reading date
  local hidden="${output}"
  option date_format sideways
  reading date

  # Assert
  [[ -z "${hidden}" && "${output}" == 2026-10-16 ]]
}

@test "date - a date that fails prints nothing" {
  # Arrange
  quiet date 'exit 1'

  # Act
  reading date

  # Assert
  [[ -z "${output}" ]]
}

@test "clock - the default is 24 hours and 12H switches to AM and PM" {
  # Arrange
  reading clock
  local plain="${output}"
  option time_format 12H

  # Act
  reading clock

  # Assert
  [[ "${plain}" == 14:30 && "${output}" == "02:30 PM" ]]
}

@test "clock - hide prints nothing" {
  # Arrange
  option time_format hide

  # Act
  reading clock

  # Assert
  [[ -z "${output}" ]]
}

@test "datetime - joins the date and the clock with a space" {
  # Arrange
  local expected="2026-10-16 14:30"

  # Act
  reading datetime

  # Assert
  [[ "${output}" == "${expected}" ]]
}

@test "datetime - hiding one half prints the other, hiding both prints nothing" {
  # Arrange
  option date_format hide
  reading datetime
  local clock_only="${output}"
  option date_format YMD
  option time_format hide
  reading datetime
  local date_only="${output}"
  option date_format hide

  # Act
  reading datetime

  # Assert
  [[ "${clock_only}" == 14:30 && "${date_only}" == 2026-10-16 && -z "${output}" ]]
}

@test "epoch - prints the unix time" {
  # Arrange
  local expected="${EPOCH_OCT_16}"

  # Act
  reading epoch

  # Assert
  [[ "${output}" == "${expected}" ]]
}

@test "epoch - a failing date prints 0" {
  # Arrange
  quiet date 'exit 1'

  # Act
  reading epoch

  # Assert
  [[ "${output}" == 0 ]]
}

@test "iso - ends in the offset with a colon" {
  # Arrange
  export TZ=Asia/Kolkata

  # Act
  reading iso

  # Assert
  [[ "${output}" == 2026-10-16T20:00:00+05:30 ]]
}

@test "iso - prints what date gives when it has no numeric offset" {
  # Arrange
  quiet date 'printf "2026-10-16T14:30:00Z\n"'

  # Act
  reading iso

  # Assert
  [[ "${output}" == 2026-10-16T14:30:00Z ]]
}

@test "offset - UTC at zero, UTC-04:00 west of it and UTC+05:30 east of it" {
  # Arrange
  reading offset
  local zero="${output}"
  export TZ=America/New_York
  reading offset
  local west="${output}"
  export TZ=Asia/Kolkata

  # Act
  reading offset

  # Assert
  [[ "${zero}" == UTC && "${west}" == UTC-04:00 && "${output}" == UTC+05:30 ]]
}

@test "offset - a date with no offset reads as UTC" {
  # Arrange
  quiet date 'printf "nonsense\n"'

  # Act
  reading offset

  # Assert
  [[ "${output}" == UTC ]]
}

@test "week and doy - the ISO week and the day of the year without leading zeros" {
  # Arrange
  now 1767225600
  reading week
  local week="${output}"

  # Act
  reading doy

  # Assert
  [[ "${week}" == 1 && "${output}" == 1 ]]
}

@test "week and doy - October 16 is week 42 and day 289" {
  # Arrange
  local expected="42 289"
  reading week
  local week="${output}"

  # Act
  reading doy

  # Assert
  [[ "${week} ${output}" == "${expected}" ]]
}

@test "week - a date that prints no number prints nothing" {
  # Arrange
  quiet date 'printf "none\n"'

  # Act
  reading week

  # Assert
  [[ -z "${output}" ]]
}

@test "until - counts days and hours to a date and time" {
  # Arrange
  option countdown_target "2026-10-17 18:30"

  # Act
  reading until

  # Assert
  [[ "${output}" == "1d 4h" ]]
}

@test "until - counts hours and minutes, with a T and with seconds" {
  # Arrange
  option countdown_target "2026-10-16T16:45:00"

  # Act
  reading until

  # Assert
  [[ "${output}" == "2h 15m" ]]
}

@test "until - counts minutes, then says less than a minute" {
  # Arrange
  option countdown_target "2026-10-16 14:45"
  reading until
  local minutes="${output}"
  option countdown_target "2026-10-16 14:30:30"

  # Act
  reading until

  # Assert
  [[ "${minutes}" == 15m && "${output}" == "<1m" ]]
}

@test "until - a date alone counts to midnight and a label goes first" {
  # Arrange
  option countdown_target 2026-10-17
  option countdown_label Launch

  # Act
  reading until

  # Assert
  [[ "${output}" == "Launch 9h 30m" ]]
}

@test "until - a target in the past prints the done text" {
  # Arrange
  option countdown_target "2026-10-16 14:30"
  reading until
  local default="${output}"
  option countdown_done Done

  # Act
  reading until

  # Assert
  [[ "${default}" == now && "${output}" == Done ]]
}

@test "until - no target, or one that is not a date, prints nothing" {
  # Arrange
  reading until
  local none="${output}"
  option countdown_target "next friday"

  # Act
  reading until

  # Assert
  [[ -z "${none}" && -z "${output}" ]]
}

@test "until - a clock that reads nonsense prints nothing" {
  # Arrange
  option countdown_target 2026-10-17
  quiet date 'printf "nonsense\n"'

  # Act
  reading until

  # Assert
  [[ -z "${output}" ]]
}

@test "elapsed - counts from the mark in hours and minutes" {
  # Arrange
  option mark_epoch $((EPOCH_OCT_16 - 4500))

  # Act
  reading elapsed

  # Assert
  [[ "${output}" == "1h 15m" ]]
}

@test "elapsed - counts days, and a mark in the future reads as under a minute" {
  # Arrange
  option mark_epoch $((EPOCH_OCT_16 - 200000))
  reading elapsed
  local days="${output}"
  option mark_epoch $((EPOCH_OCT_16 + 500))

  # Act
  reading elapsed

  # Assert
  [[ "${days}" == "2d 7h" && "${output}" == "<1m" ]]
}

@test "elapsed - no mark, or a mark that is no number, prints nothing" {
  # Arrange
  reading elapsed
  local none="${output}"
  option mark_epoch yesterday

  # Act
  reading elapsed

  # Assert
  [[ -z "${none}" && -z "${output}" ]]
}

@test "elapsed - a clock that fails prints nothing" {
  # Arrange
  option mark_epoch 1000
  quiet date 'exit 1'

  # Act
  reading elapsed

  # Assert
  [[ -z "${output}" ]]
}

@test "zones - none configured prints nothing" {
  # Arrange
  local expected=""

  # Act
  reading zones

  # Assert
  [[ "${output}" == "${expected}" ]]
}

@test "zones - one clock is coloured by the hour and ends with the reset" {
  # Arrange
  option timezones America/New_York

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=yellow]EDT 10:30#[default]" ]]
}

@test "zones - commas and spaces both separate zones, which join with a space" {
  # Arrange
  option timezones "America/New_York,Europe/London   Asia/Tokyo"

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=yellow]EDT 10:30#[default] #[fg=cyan]BST 15:30#[default] #[fg=blue]JST 23:30#[default]" ]]
}

@test "zones - the separator goes between clocks" {
  # Arrange
  option timezones "America/New_York, Europe/London"
  option zone_separator " | "

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=yellow]EDT 10:30#[default] | #[fg=cyan]BST 15:30#[default]" ]]
}

@test "zones - compact uses initials for a two-word city and three letters otherwise" {
  # Arrange
  option timezones "America/New_York, Asia/Tokyo, America/Argentina/Buenos_Aires"
  option compact 1

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=yellow]NY 10:30#[default] #[fg=blue]Tok 23:30#[default] #[fg=yellow]BA 11:30#[default]" ]]
}

@test "zones - your labels win by position and a missing one falls back" {
  # Arrange
  option timezones "America/New_York, Europe/London, Asia/Tokyo"
  option zone_labels "  NYC , LDN"

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=yellow]NYC 10:30#[default] #[fg=cyan]LDN 15:30#[default] #[fg=blue]JST 23:30#[default]" ]]
}

@test "zones - labels win over compact too" {
  # Arrange
  option timezones "America/New_York, Asia/Tokyo"
  option zone_labels "NYC"
  option compact 1

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=yellow]NYC 10:30#[default] #[fg=blue]Tok 23:30#[default]" ]]
}

@test "zones - 12H applies to every clock" {
  # Arrange
  option timezones "Europe/London"
  option time_format 12H

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=cyan]BST 03:30 PM#[default]" ]]
}

@test "zones - hiding the clock still shows the zone entries at 24 hours" {
  # Arrange
  option timezones "Europe/London"
  option time_format hide

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=cyan]BST 15:30#[default]" ]]
}

@test "zones - the weekend colour replaces the hour colour on Saturday and Sunday" {
  # Arrange
  now "${EPOCH_OCT_17}"
  option timezones "Europe/London"

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=brightblack]BST 15:30#[default]" ]]
}

@test "zones - weekend_override 0 keeps the hour colour on the weekend" {
  # Arrange
  now "${EPOCH_OCT_17}"
  option timezones "Europe/London"
  option weekend_override 0

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=cyan]BST 15:30#[default]" ]]
}

@test "zones - morning, day, afternoon, evening and night use their own colours" {
  # Arrange
  option timezones UTC
  option morning_color "#[fg=red]"
  at_hour 8
  reading zones
  local morning="${output}"
  at_hour 12
  reading zones
  local day="${output}"
  at_hour 15
  reading zones
  local afternoon="${output}"
  at_hour 19
  reading zones
  local evening="${output}"
  at_hour 23

  # Act
  reading zones

  # Assert
  [[ "${morning}" == "#[fg=red]UTC 08:00#[default]" && "${day}" == "#[fg=green]UTC 12:00#[default]" && "${afternoon}" == "#[fg=cyan]UTC 15:00#[default]" && "${evening}" == "#[fg=magenta]UTC 19:00#[default]" && "${output}" == "#[fg=blue]UTC 23:00#[default]" ]]
}

@test "zones - a colour set on the weekend, night and day periods is used" {
  # Arrange
  option timezones UTC
  option day_color "#[fg=#a6e3a1]"
  option night_color "#[fg=#89b4fa]"
  option weekend_color "#[fg=#a6adc8]"
  at_hour 12
  reading zones
  local day="${output}"
  at_hour 3
  reading zones
  local night="${output}"
  now $((EPOCH_OCT_17 - 7200))

  # Act
  reading zones

  # Assert
  [[ "${day}" == "#[fg=#a6e3a1]UTC 12:00#[default]" && "${night}" == "#[fg=#89b4fa]UTC 03:00#[default]" && "${output}" == "#[fg=#a6adc8]UTC 12:30#[default]" ]]
}

@test "zones - an icon sits between the label and the time by default" {
  # Arrange
  option timezones UTC
  option afternoon_icon "A"

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=cyan]UTC A 14:30#[default]" ]]
}

@test "zones - icon_position before puts the icon first" {
  # Arrange
  option timezones UTC
  option afternoon_icon "A"
  option icon_position before

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=cyan]A UTC 14:30#[default]" ]]
}

@test "zones - every period has its own icon" {
  # Arrange
  option timezones UTC
  option night_icon N
  option sunrise_icon R
  option morning_icon M
  option day_icon D
  option sunset_icon S
  option evening_icon E
  option weekend_icon W
  at_hour 2
  reading zones
  local night="${output}"
  at_hour 6
  reading zones
  local sunrise="${output}"
  at_hour 9
  reading zones
  local morning="${output}"
  at_hour 13
  reading zones
  local day="${output}"
  at_hour 19
  reading zones
  local sunset="${output}"
  at_hour 21
  reading zones
  local evening="${output}"
  now "${EPOCH_OCT_17}"

  # Act
  reading zones

  # Assert
  [[ "${night}" == *"UTC N 02:00"* && "${sunrise}" == *"UTC R 06:00"* && "${morning}" == *"UTC M 09:00"* && "${day}" == *"UTC D 13:00"* && "${sunset}" == *"UTC S 19:00"* && "${evening}" == *"UTC E 21:00"* && "${output}" == *"UTC W 14:30"* ]]
}

@test "zones - the afternoon icon shows at 16:00" {
  # Arrange
  option timezones UTC
  option afternoon_icon F
  at_hour 16

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=cyan]UTC F 16:00#[default]" ]]
}

@test "zones - the reset option replaces the default style" {
  # Arrange
  option timezones UTC
  option reset "#[fg=default]"

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=cyan]UTC 14:30#[fg=default]" ]]
}

@test "zones - relative_day marks a zone on another calendar day" {
  # Arrange
  option timezones "Pacific/Auckland, America/Los_Angeles, Europe/London"
  option relative_day 1
  at_hour 2

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=cyan]NZDT 15:00#[default] #[fg=magenta]PDT 19:00#[default] -1d #[fg=blue]BST 03:00#[default]" ]]
}

@test "zones - relative_day shows +1d east of the date line" {
  # Arrange
  option timezones "Pacific/Auckland"
  option relative_day 1

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=brightblack]NZDT 03:30#[default] +1d" ]]
}

@test "zones - work_hours dims a zone outside working hours only" {
  # Arrange
  option timezones "America/New_York, Asia/Tokyo"
  option work_hours 1

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=yellow]EDT 10:30#[default] #[dim]#[fg=blue]JST 23:30#[default]" ]]
}

@test "zones - work_hours follows work_start and work_end, and dim_style none turns dimming off" {
  # Arrange
  option timezones "America/New_York"
  option work_hours 1
  option work_start 11
  option work_end 12
  reading zones
  local dimmed="${output}"
  option dim_style none

  # Act
  reading zones

  # Assert
  [[ "${dimmed}" == "#[dim]#[fg=yellow]EDT 10:30#[default]" && "${output}" == "#[fg=yellow]EDT 10:30#[default]" ]]
}

@test "zones - work hours that are no numbers fall back to nine and seventeen" {
  # Arrange
  option timezones "America/New_York"
  option work_hours 1
  option work_start soon
  option work_end later

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=yellow]EDT 10:30#[default]" ]]
}

@test "zones - the primary zone is bold, and primary_style none turns that off" {
  # Arrange
  option timezones "America/New_York, Europe/London"
  option primary 1
  reading zones
  local bold="${output}"
  option primary_style none

  # Act
  reading zones

  # Assert
  [[ "${bold}" == "#[fg=yellow]EDT 10:30#[default] #[bold]#[fg=cyan]BST 15:30#[default]" && "${output}" == "#[fg=yellow]EDT 10:30#[default] #[fg=cyan]BST 15:30#[default]" ]]
}

@test "zones - a clock that fails prints nothing" {
  # Arrange
  option timezones "America/New_York"
  quiet date 'exit 1'

  # Act
  reading zones

  # Assert
  [[ -z "${output}" ]]
}

@test "zones - a zone that gives no time is skipped and its place still counts for labels" {
  # Arrange
  option timezones "Europe/London, Asia/Tokyo"
  option zone_labels "LDN, TYO"
  quiet date 'case "${TZ:-}" in
Europe/London) exit 1 ;;
*) printf "9|%s|JST|1|2026|10|16\n" "11:11" ;;
esac'

  # Act
  reading zones

  # Assert
  [[ "${output}" == "#[fg=yellow]TYO 11:11#[default]" ]]
}

@test "local - names the city from TZ and is coloured by the hour" {
  # Arrange
  export TZ=America/Sao_Paulo

  # Act
  reading local

  # Assert
  [[ "${output}" == "#[fg=yellow]Sao Paulo 11:30#[default]" ]]
}

@test "local - local_label replaces the city" {
  # Arrange
  option local_label Home

  # Act
  reading local

  # Assert
  [[ "${output}" == "#[fg=cyan]Home 14:30#[default]" ]]
}

@test "local - without TZ the city comes from the localtime link" {
  # Arrange
  quiet readlink 'printf "/usr/share/zoneinfo/Europe/Isle_of_Man\n"'

  # Act
  reading local 'unset TZ; '

  # Assert
  [[ "${output}" == *"Isle of Man "* ]]
}

@test "local - a localtime link outside zoneinfo leaves the label empty" {
  # Arrange
  quiet readlink 'printf "/etc/elsewhere\n"'

  # Act
  reading local 'unset TZ; '

  # Assert
  [[ "${output}" =~ ^\#\[fg=[a-z]+\]\ [0-9:]{5}\#\[default\]$ ]]
}

@test "local - a missing localtime link leaves the label empty" {
  # Arrange
  quiet readlink 'exit 1'

  # Act
  reading local 'unset TZ; '

  # Assert
  [[ "${output}" =~ ^\#\[fg=[a-z]+\]\ [0-9:]{5}\#\[default\]$ ]]
}

@test "local - the weekend colour and 12H apply to the local clock" {
  # Arrange
  now "${EPOCH_OCT_17}"
  option time_format 12H

  # Act
  reading local

  # Assert
  [[ "${output}" == "#[fg=brightblack]UTC 02:30 PM#[default]" ]]
}

@test "local - hiding the clock still prints the local entry at 24 hours" {
  # Arrange
  option time_format hide

  # Act
  reading local

  # Assert
  [[ "${output}" == "#[fg=cyan]UTC 14:30#[default]" ]]
}

@test "local - a clock that fails prints nothing" {
  # Arrange
  quiet date 'exit 1'

  # Act
  reading local

  # Assert
  [[ -z "${output}" ]]
}

@test "local - weekend_override 0 keeps the hour colour" {
  # Arrange
  now "${EPOCH_OCT_17}"
  option weekend_override 0

  # Act
  reading local

  # Assert
  [[ "${output}" == "#[fg=cyan]UTC 14:30#[default]" ]]
}

@test "local - geoip asks the endpoint once and keeps the city in a tmux option" {
  # Arrange
  option local_source geoip
  quiet curl 'printf "%s\n" "$*" >>"'"${FAKE}"'/curl"; printf "Lisbon\n"'

  # Act
  reading local 'REVAMPED_CACHE_SYNC=1; '

  # Assert
  [[ "${output}" == "#[fg=cyan]Lisbon 14:30#[default]" ]]
  holds geoip_city Lisbon
  file_is "${FAKE}/curl" "-fsS --max-time 3 https://ipinfo.io/city"
}

@test "local - a stored geoip city becomes the label" {
  # Arrange
  option local_source geoip
  option geoip_city Lisbon
  option geoip_city_ts "${EPOCH_OCT_16}"
  quiet curl 'exit 1'

  # Act
  reading local

  # Assert
  [[ "${output}" == "#[fg=cyan]Lisbon 14:30#[default]" ]]
}

@test "local - an old city is asked for again, from the endpoint the person set" {
  # Arrange
  option local_source geoip
  option geoip_city Lisbon
  option geoip_city_ts $((EPOCH_OCT_16 - 4000))
  option geoip_interval 60
  option geoip_endpoint https://ipinfo.io/json
  quiet curl 'printf "%s\n" "$*" >>"'"${FAKE}"'/curl"; printf "{\"ip\":\"x\",\"city\": \"Porto\"}\n"'

  # Act
  reading local 'REVAMPED_CACHE_SYNC=1; '

  # Assert
  holds geoip_city Porto
  file_is "${FAKE}/curl" "-fsS --max-time 3 https://ipinfo.io/json"
}

@test "local - a city fresher than the interval is not asked for again" {
  # Arrange
  option local_source geoip
  option geoip_city Lisbon
  option geoip_city_ts $((EPOCH_OCT_16 - 1700))
  quiet curl 'printf "x\n" >>"'"${FAKE}"'/curl"; printf "Porto\n"'

  # Act
  reading local 'REVAMPED_CACHE_SYNC=1; '

  # Assert
  [[ ! -f "${FAKE}/curl" ]]
}

@test "local - a request already running for under 20 seconds is not repeated" {
  # Arrange
  option local_source geoip
  option geoip_city_lock 1
  option geoip_city_lock_ts $((EPOCH_OCT_16 - 5))
  quiet curl 'printf "x\n" >>"'"${FAKE}"'/curl"; printf "Porto\n"'

  # Act
  reading local 'REVAMPED_CACHE_SYNC=1; '

  # Assert
  [[ ! -f "${FAKE}/curl" ]]
}

@test "local - a request stuck for 20 seconds is repeated" {
  # Arrange
  option local_source geoip
  option geoip_city_lock 1
  option geoip_city_lock_ts $((EPOCH_OCT_16 - 30))
  quiet curl 'printf "Porto\n"'

  # Act
  reading local 'REVAMPED_CACHE_SYNC=1; '

  # Assert
  holds geoip_city Porto
}

@test "local - a lock without a time is ignored" {
  # Arrange
  option local_source geoip
  option geoip_city_lock 1
  quiet curl 'printf "Porto\n"'

  # Act
  reading local 'REVAMPED_CACHE_SYNC=1; '

  # Assert
  holds geoip_city Porto
}

@test "local - a failed request keeps the old city" {
  # Arrange
  option local_source geoip
  option geoip_city Lisbon
  option geoip_city_ts $((EPOCH_OCT_16 - 4000))
  quiet curl 'exit 22'

  # Act
  reading local 'REVAMPED_CACHE_SYNC=1; '

  # Assert
  holds geoip_city Lisbon
  holds geoip_city_ts "${EPOCH_OCT_16}"
}

@test "local - a city with characters that are not allowed is dropped" {
  # Arrange
  option local_source geoip
  quiet curl 'printf "Lis<b>on\n"'

  # Act
  reading local 'REVAMPED_CACHE_SYNC=1; '

  # Assert
  holds geoip_city ""
}

@test "local - a city of more than 64 characters is dropped" {
  # Arrange
  option local_source geoip
  quiet curl 'printf "%070d\n" 0'

  # Act
  reading local 'REVAMPED_CACHE_SYNC=1; '

  # Assert
  holds geoip_city ""
}

@test "local - a city with accents, an apostrophe and a hyphen is kept, and a carriage return is cut" {
  # Arrange
  option local_source geoip
  quiet curl 'printf "S\303\243o Jos\303\251 d'"'"'Ouro-Preto\r\nsecond line\n"'

  # Act
  reading local 'REVAMPED_CACHE_SYNC=1; '

  # Assert
  holds geoip_city "São José d'Ouro-Preto"
}

@test "local - without curl geoip falls back to the timezone" {
  # Arrange
  option local_source geoip

  # Act
  reading local

  # Assert
  [[ "${output}" == "#[fg=cyan]UTC 14:30#[default]" ]]
}

@test "local - an empty answer from geoip leaves the timezone city in use" {
  # Arrange
  option local_source geoip
  quiet curl 'printf "\n"'

  # Act
  reading local 'REVAMPED_CACHE_SYNC=1; '

  # Assert
  [[ "${output}" == "#[fg=cyan]UTC 14:30#[default]" ]]
}

@test "dst - names the days until a clock change in the watched zone" {
  # Arrange
  now "${EPOCH_OCT_30}"
  option dst_zone America/New_York

  # Act
  reading dst

  # Assert
  [[ "${output}" == "DST in 2d" ]]
}

@test "dst - the label and the horizon are settings" {
  # Arrange
  now "${EPOCH_OCT_30}"
  option dst_zone America/New_York
  option dst_label Clocks
  option dst_horizon 1
  reading dst
  local short="${output}"
  option dst_horizon 5

  # Act
  reading dst

  # Assert
  [[ -z "${short}" && "${output}" == "Clocks in 2d" ]]
}

@test "dst - a horizon that is no number means 14 days" {
  # Arrange
  now "${EPOCH_OCT_30}"
  option dst_zone America/New_York
  option dst_horizon soon

  # Act
  reading dst

  # Assert
  [[ "${output}" == "DST in 2d" ]]
}

@test "dst - without a watched zone it watches the local one" {
  # Arrange
  now "${EPOCH_OCT_30}"
  export TZ=America/New_York

  # Act
  reading dst

  # Assert
  [[ "${output}" == "DST in 2d" ]]
}

@test "dst - a zone with no change ahead prints nothing" {
  # Arrange
  option dst_zone Asia/Tokyo

  # Act
  reading dst

  # Assert
  [[ -z "${output}" ]]
}

@test "dst - a date that fails prints nothing" {
  # Arrange
  quiet date 'exit 1'

  # Act
  reading dst

  # Assert
  [[ -z "${output}" ]]
}

@test "dst - a date that cannot give an offset prints nothing" {
  # Arrange
  quiet date 'case "$*" in
"-d @0 +%s") printf "0\n" ;;
"+%s") printf "1793361600\n" ;;
*) exit 1 ;;
esac'

  # Act
  reading dst

  # Assert
  [[ -z "${output}" ]]
}

@test "dst - a BSD date is asked with -r instead of -d" {
  # Arrange
  fake_date bsd
  now "${EPOCH_OCT_30}"
  option dst_zone America/New_York

  # Act
  reading dst

  # Assert
  [[ "${output}" == "DST in 2d" ]]
}

@test "dst - a BSD date answers for the local zone too" {
  # Arrange
  fake_date bsd
  now "${EPOCH_OCT_30}"
  export TZ=America/New_York

  # Act
  reading dst

  # Assert
  [[ "${output}" == "DST in 2d" ]]
}

@test "dst - a clock change that a failing day hides is skipped" {
  # Arrange
  now "${EPOCH_OCT_30}"
  option dst_zone America/New_York
  printf '%s\n' 1793448000 >"${FAKE}/fail"

  # Act
  reading dst

  # Assert
  [[ "${output}" == "DST in 2d" ]]
}

@test "overlap - prints the window every zone shares in local time" {
  # Arrange
  option timezones "America/New_York, Europe/London"

  # Act
  reading overlap

  # Assert
  [[ "${output}" == "overlap 13:00-16:00" ]]
}

@test "overlap - says so when no hour is shared, with the label and text the person set" {
  # Arrange
  option timezones "America/New_York, Asia/Tokyo"
  reading overlap
  local plain="${output}"
  option overlap_label Meet
  option overlap_none none

  # Act
  reading overlap

  # Assert
  [[ "${plain}" == "overlap no overlap" && "${output}" == "Meet none" ]]
}

@test "overlap - a window that crosses midnight is named with its start and end" {
  # Arrange
  option timezones "Pacific/Honolulu, Pacific/Auckland"

  # Act
  reading overlap

  # Assert
  [[ "${output}" == "overlap 20:00-03:00" ]]
}

@test "overlap - every hour shared prints the same hour twice" {
  # Arrange
  option timezones "UTC"
  option work_start 0
  option work_end 24

  # Act
  reading overlap

  # Assert
  [[ "${output}" == "overlap 00:00-00:00" ]]
}

@test "overlap - the window is shown in the local zone and follows the working hours" {
  # Arrange
  option timezones "America/New_York, Europe/London"
  option work_start 9
  option work_end 21
  export TZ=America/Sao_Paulo

  # Act
  reading overlap

  # Assert
  [[ "${output}" == "overlap 10:00-17:00" ]]
}

@test "overlap - work hours that are no numbers mean nine to seventeen" {
  # Arrange
  option timezones "America/New_York, Europe/London"
  option work_start soon
  option work_end later

  # Act
  reading overlap

  # Assert
  [[ "${output}" == "overlap 13:00-16:00" ]]
}

@test "overlap - no zones prints nothing" {
  # Arrange
  local expected=""

  # Act
  reading overlap

  # Assert
  [[ "${output}" == "${expected}" ]]
}

@test "overlap - a date that fails prints nothing" {
  # Arrange
  option timezones "America/New_York"
  quiet date 'exit 1'

  # Act
  reading overlap

  # Assert
  [[ -z "${output}" ]]
}

@test "overlap - a zone whose offset cannot be read prints nothing" {
  # Arrange
  option timezones "America/New_York"
  quiet date 'case "$*" in
"-d @0 +%s") printf "0\n" ;;
"+%s") printf "1792161000\n" ;;
*) printf "garbage\n" ;;
esac'

  # Act
  reading overlap

  # Assert
  [[ -z "${output}" ]]
}

@test "overlap - a BSD date gives the same window" {
  # Arrange
  fake_date bsd
  option timezones "America/New_York, Europe/London"

  # Act
  reading overlap

  # Assert
  [[ "${output}" == "overlap 13:00-16:00" ]]
}

@test "values - every figure prints the same under a locale with a decimal comma" {
  # Arrange
  option timezones "Europe/London"
  option time_format 12H
  option countdown_target 2026-10-17
  option mark_epoch $((EPOCH_OCT_16 - 4500))
  reading zones
  local zones="${output}"
  reading until
  local until="${output}"
  reading elapsed
  local elapsed="${output}"
  local comma='exec 2>/dev/null; LC_ALL=pt_BR.UTF-8; export LC_ALL; '
  reading zones "${comma}"
  local zones_comma="${output}"
  reading until "${comma}"
  local until_comma="${output}"
  reading elapsed "${comma}"
  local elapsed_comma="${output}"

  # Act
  reading week "${comma}"

  # Assert
  [[ "${zones_comma} ${until_comma} ${elapsed_comma} ${output}" == "${zones} ${until} ${elapsed} 42" ]]
  [[ "${zones} ${until} ${elapsed}" == "#[fg=cyan]BST 03:30 PM#[default] 9h 30m 1h 15m" ]]
}

@test "values - overlap is the case a name that is no other metric falls to" {
  # Arrange
  option timezones "America/New_York, Europe/London"

  # Act
  lib_run time 'time_revamped_load; time_revamped_value overlap; printf "%s\n" "${TIME_REVAMPED_OUT}"'

  # Assert
  [[ "${output}" == "overlap 13:00-16:00" ]]
}

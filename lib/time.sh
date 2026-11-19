#!/bin/sh

[ -n "${TIME_REVAMPED_TIME_LOADED:-}" ] && return 0
TIME_REVAMPED_TIME_LOADED=1

# shellcheck source=SCRIPTDIR/state.sh
. "${REVAMPED_LIB:?}/state.sh"
# shellcheck source=SCRIPTDIR/platform.sh
. "${REVAMPED_LIB}/platform.sh"
# shellcheck source=SCRIPTDIR/command.sh
. "${REVAMPED_LIB}/command.sh"
# shellcheck source=SCRIPTDIR/cache.sh
. "${REVAMPED_LIB}/cache.sh"
# shellcheck source=SCRIPTDIR/publish.sh
. "${REVAMPED_LIB}/publish.sh"
# shellcheck source=SCRIPTDIR/ticker.sh
. "${REVAMPED_LIB}/ticker.sh"

time_revamped_format() {
  printf '%s\n' "${TIME_REVAMPED_SETTINGS}" | awk -F '\t' -v live="${TIME_REVAMPED_LIVE}" '{ printf "%s#{@time_revamped_%s}", (NR > 1 ? "\t" : ""), $1 } END { count = split(live, name, " "); for (i = 1; i <= count; i++) { printf "\t#{@time_revamped_%s}", name[i] } }'
}

time_revamped_resolve() {
  env | TIME_REVAMPED_ROWS="${TIME_REVAMPED_SETTINGS}" TIME_REVAMPED_VALUES="$1" awk -v live="${TIME_REVAMPED_LIVE}" '
    BEGIN {
      count = split(ENVIRON["TIME_REVAMPED_ROWS"], rows, "\n")
      split(ENVIRON["TIME_REVAMPED_VALUES"], given, "\t")
      for (i = 1; i <= count; i++) {
        at = index(rows[i], "\t")
        if (at == 0) { at = length(rows[i]) + 1 }
        name[i] = substr(rows[i], 1, at - 1)
        value[i] = (given[i] != "") ? given[i] : substr(rows[i], at + 1)
        want["TIME_REVAMPED_" toupper(name[i])] = i
      }
    }
    {
      at = index($0, "=")
      key = substr($0, 1, at - 1)
      if (key in want) {
        value[want[key]] = substr($0, at + 1)
      }
    }
    END {
      for (i = 1; i <= count; i++) { print name[i] "\t" value[i] }
      extra = split(live, state, " ")
      for (i = 1; i <= extra; i++) { print state[i] "\t" given[count + i] }
    }
  '
}

time_revamped_setting_rows() {
  time_revamped_setting_rows_format=$(time_revamped_format)
  time_revamped_setting_rows_live=$(tmux display-message -p "${time_revamped_setting_rows_format}" 2>/dev/null) || time_revamped_setting_rows_live=""
  time_revamped_resolve "${time_revamped_setting_rows_live}"
}

time_revamped_load() {
  time_revamped_load_values=$(time_revamped_setting_rows)
  while IFS='	' read -r time_revamped_load_name time_revamped_load_value; do
    IFS= read -r "TIME_REVAMPED_S_${time_revamped_load_name}" <<EOF
${time_revamped_load_value}
EOF
  done <<EOF
${time_revamped_load_values}
EOF
}
time_revamped_parse_version() {
  printf '%s\n' "$1" | sed -En 's/^tmux[ -]([a-z]+-)?([0-9]+\.[0-9]+).*/\2/p'
}

time_revamped_version_ge() {
  case "$1:$2" in
  *[!0-9.:]* | :* | *:) return 1 ;;
  *) ;;
  esac
  time_revamped_version_ge_have="${1%%.*}"
  time_revamped_version_ge_want="${2%%.*}"
  [ "${time_revamped_version_ge_have}" -gt "${time_revamped_version_ge_want}" ] && return 0
  [ "${time_revamped_version_ge_have}" -eq "${time_revamped_version_ge_want}" ] || return 1
  time_revamped_version_ge_have="${1#*.}"
  time_revamped_version_ge_want="${2#*.}"
  [ "${time_revamped_version_ge_have%%.*}" -ge "${time_revamped_version_ge_want%%.*}" ]
}

time_revamped_emit() {
  for time_revamped_emit_arg in "$@"; do
    case "${time_revamped_emit_arg}" in
    *\;) time_revamped_emit_arg="${time_revamped_emit_arg%;}\\;" ;;
    *) ;;
    esac
    TIME_REVAMPED_PLAN="${TIME_REVAMPED_PLAN}${time_revamped_emit_arg:-${TIME_REVAMPED_EMPTY}}
"
  done
  TIME_REVAMPED_PLAN="${TIME_REVAMPED_PLAN}
"
}
time_revamped_literal() {
  printf '%s\n' "$1" | sed -e "s/'/'\\\\''/g" -e "s/#/'\"\$(printf '%b' '\\\\0043')\"'/g" -e "1s/^/'/" -e "\$s/\$/'/"
}

time_revamped_send() {
  set --
  time_revamped_send_sep=""
  while IFS= read -r time_revamped_send_line; do
    if [ -z "${time_revamped_send_line}" ]; then
      [ "$#" -eq 0 ] || time_revamped_send_sep=";"
      continue
    fi
    [ -z "${time_revamped_send_sep}" ] || set -- "$@" "${time_revamped_send_sep}"
    time_revamped_send_sep=""
    [ "${time_revamped_send_line}" != "${TIME_REVAMPED_EMPTY}" ] || time_revamped_send_line=""
    set -- "$@" "${time_revamped_send_line}"
  done <<PLAN
${TIME_REVAMPED_PLAN}
PLAN
  [ "$#" -gt 0 ] || return 0
  tmux "$@" 2>/dev/null
}

time_revamped_send_each() {
  time_revamped_send_each_status=0
  set --
  while IFS= read -r time_revamped_send_each_line; do
    if [ -n "${time_revamped_send_each_line}" ]; then
      [ "${time_revamped_send_each_line}" != "${TIME_REVAMPED_EMPTY}" ] || time_revamped_send_each_line=""
      set -- "$@" "${time_revamped_send_each_line}"
      continue
    fi
    [ "$#" -gt 0 ] || continue
    tmux "$@" || time_revamped_send_each_status=1
    set --
  done <<PLAN
${TIME_REVAMPED_PLAN}
PLAN
  return "${time_revamped_send_each_status}"
}

time_revamped_deliver() {
  ! time_revamped_send || return 0
  time_revamped_send_each
}

time_revamped_lines() {
  printf '%s' "${TIME_REVAMPED_PLAN}" | awk -v empty="${TIME_REVAMPED_EMPTY}" '$0 == empty { $0 = "\"\"" } $0 == "" && line != "" { print line; line = ""; next } $0 == "" { next } { line = (line == "" ? $0 : line " " $0) } END { if (line != "") { print line } }'
}

time_revamped_json() {
  printf '%s' "${TIME_REVAMPED_PLAN}" | awk -v empty="${TIME_REVAMPED_EMPTY}" '
    function quote(s,    out, i, c) {
      out = ""
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\\") { out = out "\\\\" } else if (c == "\"") { out = out "\\\"" } else { out = out c }
      }
      return "\"" out "\""
    }
    /^$/ { if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" } args = ""; next }
    $0 == empty { $0 = "" }
    { args = args (args == "" ? "" : ",") quote($0) }
    END {
      if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" }
      print "{\"bindings\":[" rows "]}"
    }
  '
}

time_revamped_bindings() {
  printf '%s' "${TIME_REVAMPED_PLAN}" | awk 'previous == "" && $0 == "bind-key" { count++ } { previous = $0 } END { print count + 0 }'
}

time_revamped_setting_name() {
  time_revamped_setting_name_raw=$(printf '%s\n' "${1#--}" | tr '-' '_')
  case " ${TIME_REVAMPED_NAMES} " in
  *" ${time_revamped_setting_name_raw} "*) printf '%s\n' "${time_revamped_setting_name_raw}" ;;
  *) printf '\n' ;;
  esac
}

time_revamped_bind() {
  case "$1" in
  "" | off) return 0 ;;
  *) ;;
  esac
  time_revamped_bind_key="$1" time_revamped_bind_note="$2"
  shift 2
  set -- "${time_revamped_bind_key}" "$@"
  [ "${TIME_REVAMPED_NOTES}" != 1 ] || set -- -N "${time_revamped_bind_note}" "$@"
  time_revamped_emit bind-key "$@"
}

time_revamped_job_quote() {
  printf '%s\n' "$1" | sed -e "s/'/'\\\\''/g" -e 's/#/##/g' -e 's/%/%%/g' -e "1s/^/'/" -e "\$s/\$/'/"
}

time_revamped_carried() {
  time_revamped_carried_set=$(env | sed -n 's/^TIME_REVAMPED_\([A-Z_]*\)=\(.*\)$/\1 \2/p')
  [ -n "${time_revamped_carried_set}" ] || return 0
  printf '%s\n' "${time_revamped_carried_set}" | TIME_REVAMPED_WANTED="${TIME_REVAMPED_CARRIED}" awk '
    BEGIN { count = split(ENVIRON["TIME_REVAMPED_WANTED"], name, " "); for (i = 1; i <= count; i++) { wanted[toupper(name[i])] = i } }
    {
      key = $1
      if (!(key in wanted)) { next }
      given[wanted[key]] = 1
      value[wanted[key]] = substr($0, length(key) + 2)
    }
    END {
      for (i = 1; i <= count; i++) {
        if (!given[i]) { continue }
        flag = name[i]
        gsub(/_/, "-", flag)
        print flag "\t" value[i]
      }
    }
  '
}
time_revamped_tools() {
  time_revamped_tools_path="${REVAMPED_LIB%/lib}/bin/time-revamped"
  TIME_REVAMPED_TOOL=$(time_revamped_literal "${time_revamped_tools_path}")
  TIME_REVAMPED_JOB=$(time_revamped_job_quote "${time_revamped_tools_path}")
  time_revamped_tools_rows=$(time_revamped_carried)
  while IFS='	' read -r time_revamped_tools_flag time_revamped_tools_value; do
    [ -n "${time_revamped_tools_flag}" ] || continue
    TIME_REVAMPED_TOOL="${TIME_REVAMPED_TOOL} --${time_revamped_tools_flag} $(time_revamped_literal "${time_revamped_tools_value}")"
    TIME_REVAMPED_JOB="${TIME_REVAMPED_JOB} --${time_revamped_tools_flag} $(time_revamped_job_quote "${time_revamped_tools_value}")"
  done <<EOF
${time_revamped_tools_rows}
EOF
}

time_revamped_held() {
  tmux list-keys -T prefix 2>/dev/null | awk '
    {
      at = 2
      if ($at == "-r") { at++ }
      if ($at == "-T") { at += 2 }
      key = $at
      if (key ~ /^\\./) { key = substr(key, 2) }
      rest = ""
      for (i = at + 1; i <= NF; i++) { rest = rest " " $i }
      if (index(rest, "time-revamped") == 0) { printf "%s ", key }
    }
  '
}
time_revamped_doubled() {
  time_revamped_doubled_rest="$1" time_revamped_doubled_hash='#' TIME_REVAMPED_DOUBLED=""
  while [ "${time_revamped_doubled_rest}" != "${time_revamped_doubled_rest#*"${time_revamped_doubled_hash}"}" ]; do
    TIME_REVAMPED_DOUBLED="${TIME_REVAMPED_DOUBLED}${time_revamped_doubled_rest%%"${time_revamped_doubled_hash}"*}${time_revamped_doubled_hash}${time_revamped_doubled_hash}"
    time_revamped_doubled_rest="${time_revamped_doubled_rest#*"${time_revamped_doubled_hash}"}"
  done
  TIME_REVAMPED_DOUBLED="${TIME_REVAMPED_DOUBLED}${time_revamped_doubled_rest}"
}

time_revamped_now() {
  TIME_REVAMPED_NOW=$(date +%s 2>/dev/null) || TIME_REVAMPED_NOW=0
}

time_revamped_version() {
  time_revamped_version_raw=$(tmux -V 2>/dev/null) || time_revamped_version_raw=""
  TIME_REVAMPED_TMUX=$(time_revamped_parse_version "${time_revamped_version_raw}")
}

time_revamped_number() {
  TIME_REVAMPED_NUMBER="$1"
  revamped_cache_is_number "$1" || TIME_REVAMPED_NUMBER="$2"
}

time_revamped_tmux_string() {
  printf '%s\n' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\$/g'
}

time_revamped_int() {
  TIME_REVAMPED_NUMBER=0
  case "$1" in
  '' | *[!0-9]*) return 1 ;;
  *) ;;
  esac
  time_revamped_int_digits="${1#"${1%%[!0]*}"}"
  TIME_REVAMPED_NUMBER="${time_revamped_int_digits:-0}"
}

time_revamped_words() {
  printf '%s\n' "$1" | awk '{ count = split($0, word, /[, ]+/); for (i = 1; i <= count; i++) { if (word[i] != "") { print word[i] } } }'
}

time_revamped_pattern_date() {
  case "${TIME_REVAMPED_S_date_format}" in
  MD) TIME_REVAMPED_PATTERN='%m-%d' ;;
  DM) TIME_REVAMPED_PATTERN='%d-%m' ;;
  MDY) TIME_REVAMPED_PATTERN='%m-%d-%Y' ;;
  DMY) TIME_REVAMPED_PATTERN='%d-%m-%Y' ;;
  hide) TIME_REVAMPED_PATTERN='' ;;
  *) TIME_REVAMPED_PATTERN='%Y-%m-%d' ;;
  esac
}

time_revamped_pattern_time() {
  case "${TIME_REVAMPED_S_time_format}" in
  12H) TIME_REVAMPED_PATTERN='%I:%M %p' ;;
  hide) TIME_REVAMPED_PATTERN='' ;;
  *) TIME_REVAMPED_PATTERN='%H:%M' ;;
  esac
}

time_revamped_stamp() {
  TIME_REVAMPED_OUT=$(LC_ALL=C date +"$1" 2>/dev/null) || TIME_REVAMPED_OUT=""
}

time_revamped_stamp_zone() {
  TIME_REVAMPED_OUT=$(LC_ALL=C TZ="$2" date +"$1" 2>/dev/null) || TIME_REVAMPED_OUT=""
}

time_revamped_value_date() {
  time_revamped_pattern_date
  TIME_REVAMPED_OUT=""
  [ -z "${TIME_REVAMPED_PATTERN}" ] || time_revamped_stamp "${TIME_REVAMPED_PATTERN}"
}

time_revamped_value_clock() {
  time_revamped_pattern_time
  TIME_REVAMPED_OUT=""
  [ -z "${TIME_REVAMPED_PATTERN}" ] || time_revamped_stamp "${TIME_REVAMPED_PATTERN}"
}

time_revamped_value_datetime() {
  time_revamped_pattern_date
  time_revamped_value_datetime_date="${TIME_REVAMPED_PATTERN}"
  time_revamped_pattern_time
  time_revamped_value_datetime_time="${TIME_REVAMPED_PATTERN}"
  time_revamped_value_datetime_both="${time_revamped_value_datetime_date}${time_revamped_value_datetime_date:+${time_revamped_value_datetime_time:+ }}${time_revamped_value_datetime_time}"
  TIME_REVAMPED_OUT=""
  [ -z "${time_revamped_value_datetime_both}" ] || time_revamped_stamp "${time_revamped_value_datetime_both}"
}

time_revamped_value_epoch() {
  TIME_REVAMPED_OUT=$(LC_ALL=C date +%s 2>/dev/null) || TIME_REVAMPED_OUT=0
}

time_revamped_value_iso() {
  time_revamped_stamp '%Y-%m-%dT%H:%M:%S%z'
  case "${TIME_REVAMPED_OUT}" in
  *[+-][0-9][0-9][0-9][0-9])
    time_revamped_value_iso_head="${TIME_REVAMPED_OUT%??}"
    TIME_REVAMPED_OUT="${time_revamped_value_iso_head}:${TIME_REVAMPED_OUT#"${time_revamped_value_iso_head}"}"
    ;;
  *) ;;
  esac
}

time_revamped_minutes() {
  TIME_REVAMPED_NUMBER=0
  case "$1" in
  [+-][0-9][0-9][0-9][0-9]) ;;
  *) return 1 ;;
  esac
  time_revamped_minutes_digits="${1#?}"
  time_revamped_int "${time_revamped_minutes_digits%??}"
  time_revamped_minutes_hours="${TIME_REVAMPED_NUMBER}"
  time_revamped_int "${time_revamped_minutes_digits#??}"
  TIME_REVAMPED_NUMBER=$((time_revamped_minutes_hours * 60 + TIME_REVAMPED_NUMBER))
  case "$1" in
  -*) TIME_REVAMPED_NUMBER=$((0 - TIME_REVAMPED_NUMBER)) ;;
  *) ;;
  esac
}

time_revamped_value_offset() {
  time_revamped_stamp %z
  time_revamped_minutes "${TIME_REVAMPED_OUT}" || :
  time_revamped_value_offset_total="${TIME_REVAMPED_NUMBER}"
  TIME_REVAMPED_OUT=UTC
  [ "${time_revamped_value_offset_total}" -ne 0 ] || return 0
  time_revamped_value_offset_sign=+
  if [ "${time_revamped_value_offset_total}" -lt 0 ]; then
    time_revamped_value_offset_sign=-
    time_revamped_value_offset_total=$((0 - time_revamped_value_offset_total))
  fi
  TIME_REVAMPED_OUT=$(printf 'UTC%s%02d:%02d' "${time_revamped_value_offset_sign}" "$((time_revamped_value_offset_total / 60))" "$((time_revamped_value_offset_total % 60))")
}

time_revamped_value_count() {
  time_revamped_stamp "$1"
  time_revamped_int "${TIME_REVAMPED_OUT}" || TIME_REVAMPED_OUT=""
  [ -z "${TIME_REVAMPED_OUT}" ] || TIME_REVAMPED_OUT="${TIME_REVAMPED_NUMBER}"
}

time_revamped_days() {
  time_revamped_int "$1"
  time_revamped_days_year="${TIME_REVAMPED_NUMBER}"
  time_revamped_int "$2"
  time_revamped_days_month="${TIME_REVAMPED_NUMBER}"
  time_revamped_int "$3"
  time_revamped_days_day="${TIME_REVAMPED_NUMBER}"
  [ "${time_revamped_days_month}" -gt 2 ] || time_revamped_days_year=$((time_revamped_days_year - 1))
  time_revamped_days_era=$((time_revamped_days_year / 400))
  time_revamped_days_yoe=$((time_revamped_days_year - time_revamped_days_era * 400))
  time_revamped_days_mp=$(((time_revamped_days_month + 9) % 12))
  time_revamped_days_doy=$(((153 * time_revamped_days_mp + 2) / 5 + time_revamped_days_day - 1))
  time_revamped_days_doe=$((time_revamped_days_yoe * 365 + time_revamped_days_yoe / 4 - time_revamped_days_yoe / 100 + time_revamped_days_doy))
  TIME_REVAMPED_NUMBER=$((time_revamped_days_era * 146097 + time_revamped_days_doe - 719468))
}

time_revamped_epoch_of() {
  TIME_REVAMPED_EPOCH=""
  time_revamped_epoch_of_text="$1"
  case "${time_revamped_epoch_of_text}" in
  *T*) time_revamped_epoch_of_text="${time_revamped_epoch_of_text%%T*} ${time_revamped_epoch_of_text#*T}" ;;
  *) ;;
  esac
  time_revamped_epoch_of_clock="00:00:00"
  case "${time_revamped_epoch_of_text}" in
  [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
  [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]) time_revamped_epoch_of_clock="${time_revamped_epoch_of_text#* }:00" ;;
  [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9]) time_revamped_epoch_of_clock="${time_revamped_epoch_of_text#* }" ;;
  *) return 1 ;;
  esac
  time_revamped_epoch_of_date="${time_revamped_epoch_of_text%% *}"
  time_revamped_epoch_of_rest="${time_revamped_epoch_of_date#*-}"
  time_revamped_days "${time_revamped_epoch_of_date%%-*}" "${time_revamped_epoch_of_rest%%-*}" "${time_revamped_epoch_of_rest#*-}"
  time_revamped_epoch_of_days="${TIME_REVAMPED_NUMBER}"
  time_revamped_int "${time_revamped_epoch_of_clock%%:*}"
  time_revamped_epoch_of_hours="${TIME_REVAMPED_NUMBER}"
  time_revamped_epoch_of_rest="${time_revamped_epoch_of_clock#*:}"
  time_revamped_int "${time_revamped_epoch_of_rest%%:*}"
  time_revamped_epoch_of_minutes="${TIME_REVAMPED_NUMBER}"
  time_revamped_int "${time_revamped_epoch_of_rest#*:}"
  TIME_REVAMPED_EPOCH=$((time_revamped_epoch_of_days * 86400 + time_revamped_epoch_of_hours * 3600 + time_revamped_epoch_of_minutes * 60 + TIME_REVAMPED_NUMBER))
}

time_revamped_duration() {
  time_revamped_duration_days=$(($1 / 86400))
  time_revamped_duration_hours=$(($1 % 86400 / 3600))
  time_revamped_duration_minutes=$(($1 % 3600 / 60))
  if [ "${time_revamped_duration_days}" -gt 0 ]; then
    TIME_REVAMPED_OUT="${time_revamped_duration_days}d ${time_revamped_duration_hours}h"
  elif [ "${time_revamped_duration_hours}" -gt 0 ]; then
    TIME_REVAMPED_OUT="${time_revamped_duration_hours}h ${time_revamped_duration_minutes}m"
  elif [ "${time_revamped_duration_minutes}" -gt 0 ]; then
    TIME_REVAMPED_OUT="${time_revamped_duration_minutes}m"
  else
    TIME_REVAMPED_OUT='<1m'
  fi
}

time_revamped_value_until() {
  TIME_REVAMPED_OUT=""
  [ -n "${TIME_REVAMPED_S_countdown_target}" ] || return 0
  time_revamped_epoch_of "${TIME_REVAMPED_S_countdown_target}" || return 0
  time_revamped_value_until_target="${TIME_REVAMPED_EPOCH}"
  time_revamped_stamp '%Y-%m-%d %H:%M:%S'
  time_revamped_epoch_of "${TIME_REVAMPED_OUT}" || {
    TIME_REVAMPED_OUT=""
    return 0
  }
  time_revamped_value_until_left=$((time_revamped_value_until_target - TIME_REVAMPED_EPOCH))
  if [ "${time_revamped_value_until_left}" -le 0 ]; then
    TIME_REVAMPED_OUT="${TIME_REVAMPED_S_countdown_done}"
  else
    time_revamped_duration "${time_revamped_value_until_left}"
  fi
  [ -z "${TIME_REVAMPED_S_countdown_label}" ] || TIME_REVAMPED_OUT="${TIME_REVAMPED_S_countdown_label} ${TIME_REVAMPED_OUT}"
}

time_revamped_value_elapsed() {
  TIME_REVAMPED_OUT=""
  revamped_cache_is_number "${TIME_REVAMPED_S_mark_epoch}" || return 0
  time_revamped_now
  [ "${TIME_REVAMPED_NOW}" -gt 0 ] || return 0
  time_revamped_value_elapsed_left=$((TIME_REVAMPED_NOW - TIME_REVAMPED_S_mark_epoch))
  [ "${time_revamped_value_elapsed_left}" -ge 0 ] || time_revamped_value_elapsed_left=0
  time_revamped_duration "${time_revamped_value_elapsed_left}"
}

time_revamped_date_gnu() {
  if [ -z "${TIME_REVAMPED_DATE_GNU}" ]; then
    TIME_REVAMPED_DATE_GNU=0
    time_revamped_date_gnu_probe=$(LC_ALL=C date -d @0 +%s 2>/dev/null) || time_revamped_date_gnu_probe=""
    [ "${time_revamped_date_gnu_probe}" != 0 ] || TIME_REVAMPED_DATE_GNU=1
  fi
  [ "${TIME_REVAMPED_DATE_GNU}" = 1 ]
}

time_revamped_offset_gnu() {
  if [ -n "$1" ]; then
    LC_ALL=C TZ="$1" date -d "@$2" +%z 2>/dev/null
  else
    LC_ALL=C date -d "@$2" +%z 2>/dev/null
  fi
}

time_revamped_offset_bsd() {
  if [ -n "$1" ]; then
    LC_ALL=C TZ="$1" date -r "$2" +%z 2>/dev/null
  else
    LC_ALL=C date -r "$2" +%z 2>/dev/null
  fi
}

time_revamped_offset_at() {
  TIME_REVAMPED_OUT=""
  if time_revamped_date_gnu; then
    TIME_REVAMPED_OUT=$(time_revamped_offset_gnu "$1" "$2") || TIME_REVAMPED_OUT=""
  else
    TIME_REVAMPED_OUT=$(time_revamped_offset_bsd "$1" "$2") || TIME_REVAMPED_OUT=""
  fi
}

time_revamped_value_dst() {
  TIME_REVAMPED_OUT=""
  time_revamped_number "${TIME_REVAMPED_S_dst_horizon}" "${TIME_REVAMPED_DEFAULT_HORIZON}"
  time_revamped_value_dst_horizon="${TIME_REVAMPED_NUMBER}"
  time_revamped_now
  [ "${TIME_REVAMPED_NOW}" -gt 0 ] || return 0
  time_revamped_value_dst_now="${TIME_REVAMPED_NOW}"
  time_revamped_offset_at "${TIME_REVAMPED_S_dst_zone}" "${time_revamped_value_dst_now}"
  [ -n "${TIME_REVAMPED_OUT}" ] || return 0
  time_revamped_value_dst_base="${TIME_REVAMPED_OUT}"
  time_revamped_value_dst_day=1
  while [ "${time_revamped_value_dst_day}" -le "${time_revamped_value_dst_horizon}" ]; do
    time_revamped_offset_at "${TIME_REVAMPED_S_dst_zone}" "$((time_revamped_value_dst_now + time_revamped_value_dst_day * 86400))"
    if [ -n "${TIME_REVAMPED_OUT}" ] && [ "${TIME_REVAMPED_OUT}" != "${time_revamped_value_dst_base}" ]; then
      TIME_REVAMPED_OUT="${TIME_REVAMPED_S_dst_label} in ${time_revamped_value_dst_day}d"
      return 0
    fi
    time_revamped_value_dst_day=$((time_revamped_value_dst_day + 1))
  done
  TIME_REVAMPED_OUT=""
}

time_revamped_overlap_window() {
  LC_ALL=C awk -v offsets="$1" -v start="$2" -v end="$3" -v here="$4" '
    BEGIN {
      count = split(offsets, offset, " ")
      for (h = 0; h < 24; h++) {
        all = 1
        for (i = 1; i <= count; i++) {
          here_hour = (((h * 60 + offset[i]) % 1440) + 1440) % 1440
          hour = int(here_hour / 60)
          if (hour < start || hour >= end) { all = 0; break }
        }
        mask[h] = all
        ones += all
      }
      if (ones == 0) { print "none"; exit }
      first = 0
      length_all = 24
      if (ones < 24) {
        best = 0; first = -1; run = 0; begin = 0
        for (i = 0; i < 48; i++) {
          if (mask[i % 24] == 1) {
            if (run == 0) { begin = i % 24 }
            run++
            if (run > best) { best = run; first = begin }
          } else { run = 0 }
        }
        if (best > 24) { best = 24 }
        length_all = best
      }
      stop = first + length_all
      printf "%02d:00-%02d:00\n", int(((((first * 60 + here) % 1440) + 1440) % 1440) / 60), int(((((stop * 60 + here) % 1440) + 1440) % 1440) / 60)
    }
  '
}

time_revamped_overlap_offsets() {
  time_revamped_overlap_offsets_list=""
  time_revamped_overlap_offsets_zones=$(time_revamped_words "${TIME_REVAMPED_S_timezones}")
  while IFS= read -r time_revamped_overlap_offsets_zone; do
    [ -n "${time_revamped_overlap_offsets_zone}" ] || continue
    time_revamped_offset_at "${time_revamped_overlap_offsets_zone}" "$1"
    time_revamped_minutes "${TIME_REVAMPED_OUT}" || return 1
    time_revamped_overlap_offsets_list="${time_revamped_overlap_offsets_list} ${TIME_REVAMPED_NUMBER}"
  done <<EOF
${time_revamped_overlap_offsets_zones}
EOF
}

time_revamped_value_overlap() {
  TIME_REVAMPED_OUT=""
  [ -n "${TIME_REVAMPED_S_timezones}" ] || return 0
  time_revamped_number "${TIME_REVAMPED_S_work_start}" "${TIME_REVAMPED_DEFAULT_START}"
  time_revamped_value_overlap_start="${TIME_REVAMPED_NUMBER}"
  time_revamped_number "${TIME_REVAMPED_S_work_end}" "${TIME_REVAMPED_DEFAULT_END}"
  time_revamped_value_overlap_end="${TIME_REVAMPED_NUMBER}"
  time_revamped_now
  [ "${TIME_REVAMPED_NOW}" -gt 0 ] || return 0
  time_revamped_overlap_offsets "${TIME_REVAMPED_NOW}" || {
    TIME_REVAMPED_OUT=""
    return 0
  }
  time_revamped_offset_at "" "${TIME_REVAMPED_NOW}"
  time_revamped_minutes "${TIME_REVAMPED_OUT}" || :
  time_revamped_value_overlap_window=$(time_revamped_overlap_window "${time_revamped_overlap_offsets_list}" "${time_revamped_value_overlap_start}" "${time_revamped_value_overlap_end}" "${TIME_REVAMPED_NUMBER}")
  case "${time_revamped_value_overlap_window}" in
  none) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_overlap_label} ${TIME_REVAMPED_S_overlap_none}" ;;
  *) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_overlap_label} ${time_revamped_value_overlap_window}" ;;
  esac
}

time_revamped_period() {
  time_revamped_period_hour="$1"
  if [ "$2" = 1 ]; then
    TIME_REVAMPED_PERIOD=weekend
  elif [ "${time_revamped_period_hour}" -ge 22 ] || [ "${time_revamped_period_hour}" -lt 5 ]; then
    TIME_REVAMPED_PERIOD=night
  elif [ "${time_revamped_period_hour}" -lt 12 ]; then
    TIME_REVAMPED_PERIOD=morning
  elif [ "${time_revamped_period_hour}" -lt 14 ]; then
    TIME_REVAMPED_PERIOD=day
  elif [ "${time_revamped_period_hour}" -lt 18 ]; then
    TIME_REVAMPED_PERIOD=afternoon
  else
    TIME_REVAMPED_PERIOD=evening
  fi
}

time_revamped_color() {
  time_revamped_period "$1" "$2"
  case "${TIME_REVAMPED_PERIOD}" in
  weekend) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_weekend_color}" ;;
  night) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_night_color}" ;;
  morning) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_morning_color}" ;;
  day) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_day_color}" ;;
  afternoon) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_afternoon_color}" ;;
  *) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_evening_color}" ;;
  esac
}

time_revamped_icon_name() {
  if [ "$2" = 1 ]; then
    TIME_REVAMPED_PERIOD=weekend
  elif [ "$1" -ge 22 ] || [ "$1" -lt 5 ]; then
    TIME_REVAMPED_PERIOD=night
  elif [ "$1" -lt 8 ]; then
    TIME_REVAMPED_PERIOD=sunrise
  elif [ "$1" -lt 12 ]; then
    TIME_REVAMPED_PERIOD=morning
  elif [ "$1" -lt 14 ]; then
    TIME_REVAMPED_PERIOD=day
  elif [ "$1" -lt 18 ]; then
    TIME_REVAMPED_PERIOD=afternoon
  elif [ "$1" -lt 20 ]; then
    TIME_REVAMPED_PERIOD=sunset
  else
    TIME_REVAMPED_PERIOD=evening
  fi
}

time_revamped_icon() {
  time_revamped_icon_name "$1" "$2"
  case "${TIME_REVAMPED_PERIOD}" in
  weekend) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_weekend_icon}" ;;
  night) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_night_icon}" ;;
  sunrise) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_sunrise_icon}" ;;
  morning) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_morning_icon}" ;;
  day) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_day_icon}" ;;
  afternoon) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_afternoon_icon}" ;;
  sunset) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_sunset_icon}" ;;
  *) TIME_REVAMPED_OUT="${TIME_REVAMPED_S_evening_icon}" ;;
  esac
}

time_revamped_entry() {
  time_revamped_color "$3" "$4"
  time_revamped_entry_color="${TIME_REVAMPED_OUT}"
  time_revamped_icon "$3" "$4"
  if [ -z "${TIME_REVAMPED_OUT}" ]; then
    TIME_REVAMPED_OUT="${time_revamped_entry_color}$1 $2${TIME_REVAMPED_S_reset}"
  elif [ "${TIME_REVAMPED_S_icon_position}" = before ]; then
    TIME_REVAMPED_OUT="${time_revamped_entry_color}${TIME_REVAMPED_OUT} $1 $2${TIME_REVAMPED_S_reset}"
  else
    TIME_REVAMPED_OUT="${time_revamped_entry_color}$1 ${TIME_REVAMPED_OUT} $2${TIME_REVAMPED_S_reset}"
  fi
}

time_revamped_decorate() {
  time_revamped_decorate_out="$1"
  [ -z "$2" ] || time_revamped_decorate_out="${time_revamped_decorate_out} $2"
  if [ "$4" = 0 ] && [ "${TIME_REVAMPED_S_dim_style}" != none ]; then
    time_revamped_decorate_out="${TIME_REVAMPED_S_dim_style}${time_revamped_decorate_out}"
  fi
  if [ "$3" = 1 ] && [ "${TIME_REVAMPED_S_primary_style}" != none ]; then
    time_revamped_decorate_out="${TIME_REVAMPED_S_primary_style}${time_revamped_decorate_out}"
  fi
  TIME_REVAMPED_OUT="${time_revamped_decorate_out}"
}

time_revamped_badge() {
  TIME_REVAMPED_OUT=""
  revamped_cache_is_number "$1" || return 0
  time_revamped_days "$1" "$2" "$3"
  time_revamped_badge_zone="${TIME_REVAMPED_NUMBER}"
  time_revamped_days "$4" "$5" "$6"
  time_revamped_badge_delta=$((time_revamped_badge_zone - TIME_REVAMPED_NUMBER))
  if [ "${time_revamped_badge_delta}" -gt 0 ]; then
    TIME_REVAMPED_OUT="+${time_revamped_badge_delta}d"
  elif [ "${time_revamped_badge_delta}" -lt 0 ]; then
    TIME_REVAMPED_OUT="${time_revamped_badge_delta}d"
  fi
}

time_revamped_working() {
  time_revamped_number "${TIME_REVAMPED_S_work_start}" "${TIME_REVAMPED_DEFAULT_START}"
  time_revamped_working_start="${TIME_REVAMPED_NUMBER}"
  time_revamped_number "${TIME_REVAMPED_S_work_end}" "${TIME_REVAMPED_DEFAULT_END}"
  [ "$1" -ge "${time_revamped_working_start}" ] && [ "$1" -lt "${TIME_REVAMPED_NUMBER}" ]
}

time_revamped_compact() {
  time_revamped_compact_city="${1##*/}"
  case "${time_revamped_compact_city}" in
  *_*)
    TIME_REVAMPED_OUT=""
    time_revamped_compact_rest="${time_revamped_compact_city}"
    while [ -n "${time_revamped_compact_rest}" ]; do
      time_revamped_compact_part="${time_revamped_compact_rest%%_*}"
      TIME_REVAMPED_OUT="${TIME_REVAMPED_OUT}${time_revamped_compact_part%"${time_revamped_compact_part#?}"}"
      case "${time_revamped_compact_rest}" in
      *_*) time_revamped_compact_rest="${time_revamped_compact_rest#*_}" ;;
      *) time_revamped_compact_rest="" ;;
      esac
    done
    ;;
  *) TIME_REVAMPED_OUT="${time_revamped_compact_city%"${time_revamped_compact_city#???}"}" ;;
  esac
}

time_revamped_label_at() {
  TIME_REVAMPED_OUT=""
  time_revamped_label_at_rest="$2"
  time_revamped_label_at_count=0
  while [ "${time_revamped_label_at_count}" -lt "$1" ]; do
    case "${time_revamped_label_at_rest}" in
    *,*) time_revamped_label_at_rest="${time_revamped_label_at_rest#*,}" ;;
    *) return 0 ;;
    esac
    time_revamped_label_at_count=$((time_revamped_label_at_count + 1))
  done
  time_revamped_label_at_item="${time_revamped_label_at_rest%%,*}"
  time_revamped_label_at_item="${time_revamped_label_at_item#"${time_revamped_label_at_item%%[![:space:]]*}"}"
  TIME_REVAMPED_OUT="${time_revamped_label_at_item%"${time_revamped_label_at_item##*[![:space:]]}"}"
}

time_revamped_zone_name() {
  if [ -n "${TZ:-}" ]; then
    TIME_REVAMPED_OUT="${TZ}"
    return 0
  fi
  time_revamped_zone_name_link=$(readlink /etc/localtime 2>/dev/null) || time_revamped_zone_name_link=""
  case "${time_revamped_zone_name_link}" in
  *zoneinfo/*) TIME_REVAMPED_OUT="${time_revamped_zone_name_link#*zoneinfo/}" ;;
  *) TIME_REVAMPED_OUT="" ;;
  esac
}

time_revamped_city() {
  time_revamped_zone_name
  [ -n "${TIME_REVAMPED_OUT}" ] || return 0
  TIME_REVAMPED_OUT=$(printf '%s' "${TIME_REVAMPED_OUT##*/}" | tr '_' ' ')
}

time_revamped_geoip_chars_safe() {
  time_revamped_geoip_chars_rest=$(printf '%s' "$1" | LC_ALL=C tr -d "A-Za-z0-9 .,'\200-\377-")
  [ -z "${time_revamped_geoip_chars_rest}" ]
}

time_revamped_geoip_city() {
  TIME_REVAMPED_OUT=""
  case "$1" in
  *'"city"'*) time_revamped_geoip_city_name=$(printf '%s' "$1" | sed -n 's/.*"city"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p') ;;
  *) time_revamped_geoip_city_name=$(printf '%s\n' "$1" | sed -n 1p | tr -d '\r') ;;
  esac
  [ -n "${time_revamped_geoip_city_name}" ] || return 0
  revamped_publish_count "${time_revamped_geoip_city_name}"
  [ "${revamped_publish_count_out}" -le "${TIME_REVAMPED_GEOIP_MAX_CITY}" ] || return 0
  time_revamped_geoip_chars_safe "${time_revamped_geoip_city_name}" || return 0
  time_revamped_doubled "${time_revamped_geoip_city_name}"
  TIME_REVAMPED_OUT="${TIME_REVAMPED_DOUBLED}"
}

time_revamped_geoip_refresh() {
  time_revamped_geoip_body=$(curl -fsS --max-time "${TIME_REVAMPED_GEOIP_TIMEOUT}" "${TIME_REVAMPED_S_geoip_endpoint}" 2>/dev/null) || time_revamped_geoip_body=""
  time_revamped_geoip_city "${time_revamped_geoip_body}"
  [ -z "${TIME_REVAMPED_OUT}" ] || TIME_REVAMPED_S_geoip_city="${TIME_REVAMPED_OUT}"
  revamped_cache_set geoip_city "${TIME_REVAMPED_S_geoip_city}"
}

time_revamped_geoip_limit() {
  time_revamped_number "${TIME_REVAMPED_S_geoip_interval}" "${TIME_REVAMPED_DEFAULT_GEOIP}"
  TIME_REVAMPED_NUMBER=$((TIME_REVAMPED_NUMBER * 60))
}

time_revamped_geoip_due() {
  time_revamped_now
  time_revamped_geoip_limit
  time_revamped_geoip_due_limit="${TIME_REVAMPED_NUMBER}"
  if revamped_cache_is_number "${TIME_REVAMPED_S_geoip_city_ts}" && [ "$((TIME_REVAMPED_NOW - TIME_REVAMPED_S_geoip_city_ts))" -le "${time_revamped_geoip_due_limit}" ]; then
    return 1
  fi
  [ "${TIME_REVAMPED_S_geoip_city_lock}" = 1 ] || return 0
  revamped_cache_is_number "${TIME_REVAMPED_S_geoip_city_lock_ts}" || return 0
  [ "$((TIME_REVAMPED_NOW - TIME_REVAMPED_S_geoip_city_lock_ts))" -ge "${REVAMPED_CACHE_MAX_RUN_DEFAULT}" ]
}

time_revamped_geoip_poll() {
  time_revamped_geoip_due || return 0
  if [ "${TIME_REVAMPED_INTICK}" = 1 ]; then
    time_revamped_geoip_refresh
    return 0
  fi
  time_revamped_geoip_limit
  revamped_cache_refresh_if_stale geoip_city "${TIME_REVAMPED_NUMBER}" time_revamped_geoip_refresh
}

time_revamped_label_auto() {
  TIME_REVAMPED_OUT=""
  if [ "${TIME_REVAMPED_S_local_source}" = geoip ] && revamped_has_command curl; then
    time_revamped_geoip_poll
    TIME_REVAMPED_OUT="${TIME_REVAMPED_S_geoip_city}"
    [ -z "${TIME_REVAMPED_OUT}" ] || return 0
  fi
  time_revamped_city
}

time_revamped_weekend() {
  TIME_REVAMPED_OUT=0
  [ "${TIME_REVAMPED_S_weekend_override}" = 1 ] || return 0
  case "$1" in
  6 | 7) TIME_REVAMPED_OUT=1 ;;
  *) ;;
  esac
}

time_revamped_value_local() {
  time_revamped_pattern_time
  time_revamped_value_local_pattern="${TIME_REVAMPED_PATTERN:-%H:%M}"
  time_revamped_stamp "%H|${time_revamped_value_local_pattern}|%u"
  IFS='|' read -r time_revamped_value_local_hour time_revamped_value_local_time time_revamped_value_local_day <<EOF
${TIME_REVAMPED_OUT}
EOF
  TIME_REVAMPED_OUT=""
  [ -n "${time_revamped_value_local_time}" ] || return 0
  time_revamped_int "${time_revamped_value_local_hour}" || :
  time_revamped_value_local_hour="${TIME_REVAMPED_NUMBER}"
  time_revamped_weekend "${time_revamped_value_local_day}"
  time_revamped_value_local_weekend="${TIME_REVAMPED_OUT}"
  TIME_REVAMPED_OUT="${TIME_REVAMPED_S_local_label}"
  [ -n "${TIME_REVAMPED_OUT}" ] || time_revamped_label_auto
  time_revamped_entry "${TIME_REVAMPED_OUT}" "${time_revamped_value_local_time}" "${time_revamped_value_local_hour}" "${time_revamped_value_local_weekend}"
}

time_revamped_zone() {
  time_revamped_stamp_zone "%H|$1|%Z|%u|%Y|%m|%d" "$3"
  IFS='|' read -r time_revamped_zone_hour time_revamped_zone_time time_revamped_zone_abbr time_revamped_zone_day time_revamped_zone_y time_revamped_zone_m time_revamped_zone_d <<EOF
${TIME_REVAMPED_OUT}
EOF
  TIME_REVAMPED_OUT=""
  [ -n "${time_revamped_zone_time}" ] || return 0
  time_revamped_int "${time_revamped_zone_hour}" || :
  time_revamped_zone_hour="${TIME_REVAMPED_NUMBER}"
  time_revamped_weekend "${time_revamped_zone_day}"
  time_revamped_zone_weekend="${TIME_REVAMPED_OUT}"
  time_revamped_label_at "$2" "${TIME_REVAMPED_S_zone_labels}"
  time_revamped_zone_label="${TIME_REVAMPED_OUT}"
  if [ "${TIME_REVAMPED_S_compact}" = 1 ]; then
    [ -n "${time_revamped_zone_label}" ] || time_revamped_compact "$3"
    time_revamped_zone_label="${time_revamped_zone_label:-${TIME_REVAMPED_OUT}}"
  else
    time_revamped_zone_label="${time_revamped_zone_label:-${time_revamped_zone_abbr}}"
  fi
  time_revamped_entry "${time_revamped_zone_label}" "${time_revamped_zone_time}" "${time_revamped_zone_hour}" "${time_revamped_zone_weekend}"
  time_revamped_zone_entry="${TIME_REVAMPED_OUT}"
  time_revamped_zone_badge=""
  if [ "${TIME_REVAMPED_S_relative_day}" = 1 ]; then
    time_revamped_badge "${time_revamped_zone_y}" "${time_revamped_zone_m}" "${time_revamped_zone_d}" "$4" "$5" "$6"
    time_revamped_zone_badge="${TIME_REVAMPED_OUT}"
  fi
  time_revamped_zone_working=1
  if [ "${TIME_REVAMPED_S_work_hours}" = 1 ]; then
    time_revamped_working "${time_revamped_zone_hour}" || time_revamped_zone_working=0
  fi
  time_revamped_zone_primary=0
  [ "${TIME_REVAMPED_S_primary}" != "$2" ] || time_revamped_zone_primary=1
  time_revamped_decorate "${time_revamped_zone_entry}" "${time_revamped_zone_badge}" "${time_revamped_zone_primary}" "${time_revamped_zone_working}"
}

time_revamped_value_zones() {
  TIME_REVAMPED_OUT=""
  [ -n "${TIME_REVAMPED_S_timezones}" ] || return 0
  time_revamped_pattern_time
  time_revamped_value_zones_pattern="${TIME_REVAMPED_PATTERN:-%H:%M}"
  time_revamped_stamp '%Y|%m|%d'
  IFS='|' read -r time_revamped_value_zones_y time_revamped_value_zones_m time_revamped_value_zones_d <<EOF
${TIME_REVAMPED_OUT}
EOF
  time_revamped_value_zones_list=$(time_revamped_words "${TIME_REVAMPED_S_timezones}")
  time_revamped_value_zones_text=""
  time_revamped_value_zones_index=0
  while IFS= read -r time_revamped_value_zones_zone; do
    [ -n "${time_revamped_value_zones_zone}" ] || continue
    time_revamped_zone "${time_revamped_value_zones_pattern}" "${time_revamped_value_zones_index}" "${time_revamped_value_zones_zone}" "${time_revamped_value_zones_y}" "${time_revamped_value_zones_m}" "${time_revamped_value_zones_d}"
    time_revamped_value_zones_index=$((time_revamped_value_zones_index + 1))
    [ -n "${TIME_REVAMPED_OUT}" ] || continue
    time_revamped_value_zones_text="${time_revamped_value_zones_text:+${time_revamped_value_zones_text}${TIME_REVAMPED_S_zone_separator}}${TIME_REVAMPED_OUT}"
  done <<EOF
${time_revamped_value_zones_list}
EOF
  TIME_REVAMPED_OUT="${time_revamped_value_zones_text}"
}

time_revamped_value() {
  case "$1" in
  datetime) time_revamped_value_datetime ;;
  date) time_revamped_value_date ;;
  clock) time_revamped_value_clock ;;
  zones) time_revamped_value_zones ;;
  local) time_revamped_value_local ;;
  until) time_revamped_value_until ;;
  elapsed) time_revamped_value_elapsed ;;
  epoch) time_revamped_value_epoch ;;
  iso) time_revamped_value_iso ;;
  offset) time_revamped_value_offset ;;
  week) time_revamped_value_count %V ;;
  doy) time_revamped_value_count %j ;;
  dst) time_revamped_value_dst ;;
  *) time_revamped_value_overlap ;;
  esac
}

time_revamped_show() {
  time_revamped_value "$1"
  [ -z "${TIME_REVAMPED_OUT}" ] || printf '%s\n' "${TIME_REVAMPED_OUT}"
}

time_revamped_status() {
  time_revamped_load
  time_revamped_show "$1"
}

time_revamped_publish() {
  time_revamped_publish_rest="${TIME_REVAMPED_S_published}"
  while [ -n "${time_revamped_publish_rest}" ]; do
    time_revamped_publish_metric="${time_revamped_publish_rest%% *}"
    time_revamped_publish_rest="${time_revamped_publish_rest#"${time_revamped_publish_metric}"}"
    time_revamped_publish_rest="${time_revamped_publish_rest# }"
    [ -n "${time_revamped_publish_metric}" ] || continue
    time_revamped_value "${time_revamped_publish_metric}"
    revamped_publish_add "@time_revamped_out_${time_revamped_publish_metric}" "${TIME_REVAMPED_OUT}"
  done
  revamped_publish_commit || :
}

time_revamped_tick() {
  time_revamped_load
  TIME_REVAMPED_INTICK=1
  time_revamped_publish
}

time_revamped_daemon() {
  revamped_ticker_run time_revamped time_revamped_tick "$$" "${TIME_REVAMPED_DEFAULT_INTERVAL}"
}

time_revamped_say() {
  time_revamped_doubled "$1"
  tmux display-message "time-revamped: ${TIME_REVAMPED_DOUBLED}" 2>/dev/null || :
}

time_revamped_mark() {
  time_revamped_now
  tmux set-option -gq @time_revamped_mark_epoch "${TIME_REVAMPED_NOW}" 2>/dev/null || :
  time_revamped_say "mark set"
}

time_revamped_clipboard() {
  if revamped_has_command pbcopy; then
    printf '%s' "$1" | pbcopy
  elif revamped_has_command wl-copy; then
    printf '%s' "$1" | wl-copy
  elif revamped_has_command xclip; then
    printf '%s' "$1" | xclip -selection clipboard
  fi
}

time_revamped_copy() {
  case "$1" in
  epoch) time_revamped_value epoch ;;
  *) time_revamped_value iso ;;
  esac
  time_revamped_copy_value="${TIME_REVAMPED_OUT}"
  tmux set-buffer -- "${time_revamped_copy_value}" 2>/dev/null || :
  time_revamped_clipboard "${time_revamped_copy_value}" || :
  time_revamped_say "copied ${time_revamped_copy_value}"
}

time_revamped_toggle() {
  time_revamped_load
  if [ "${TIME_REVAMPED_S_time_format}" = 12H ]; then
    tmux set-option -gq @time_revamped_time_format 24H 2>/dev/null || :
  else
    tmux set-option -gq @time_revamped_time_format 12H 2>/dev/null || :
  fi
}

time_revamped_popup_check() {
  TIME_REVAMPED_POPUP_OK=0
  ! time_revamped_version_ge "${TIME_REVAMPED_TMUX}" "${TIME_REVAMPED_POPUP_SINCE}" || TIME_REVAMPED_POPUP_OK=1
}

time_revamped_calendar() {
  time_revamped_version
  time_revamped_popup_check
  if [ "${TIME_REVAMPED_POPUP_OK}" != 1 ]; then
    time_revamped_say "tmux ${TIME_REVAMPED_POPUP_SINCE}+ is required for the calendar popup"
    return 0
  fi
  tmux display-popup -E "${TIME_REVAMPED_CALENDAR}" 2>/dev/null || :
}

time_revamped_menu_rows() {
  time_revamped_menu_rows_tool=$(time_revamped_tmux_string "${TIME_REVAMPED_TOOL}")
  printf 'Toggle 12/24h\th\trun-shell "%s toggle-format"\n' "${time_revamped_menu_rows_tool}"
  printf 'Calendar\tc\trun-shell "%s calendar"\n' "${time_revamped_menu_rows_tool}"
  printf 'Copy ISO\ti\trun-shell "%s copy iso"\n' "${time_revamped_menu_rows_tool}"
  printf 'Copy epoch\te\trun-shell "%s copy epoch"\n' "${time_revamped_menu_rows_tool}"
  printf 'Set mark\tm\trun-shell "%s mark"\n' "${time_revamped_menu_rows_tool}"
  printf 'Doctor\td\trun-shell "%s doctor"\n' "${time_revamped_menu_rows_tool}"
}

time_revamped_menu() {
  time_revamped_tools
  time_revamped_menu_list=$(time_revamped_menu_rows)
  set -- display-menu -T "${TIME_REVAMPED_TITLE}"
  while IFS="${TIME_REVAMPED_TAB}" read -r time_revamped_menu_label time_revamped_menu_key time_revamped_menu_command; do
    set -- "$@" "${time_revamped_menu_label}" "${time_revamped_menu_key}" "${time_revamped_menu_command}"
  done <<EOF
${time_revamped_menu_list}
EOF
  tmux "$@" 2>/dev/null || :
}

time_revamped_plan_menu() {
  time_revamped_plan_menu_list=$(time_revamped_menu_rows)
  set -- display-menu -T "${TIME_REVAMPED_TITLE}"
  while IFS="${TIME_REVAMPED_TAB}" read -r time_revamped_plan_menu_label time_revamped_plan_menu_key time_revamped_plan_menu_command; do
    set -- "$@" "${time_revamped_plan_menu_label}" "${time_revamped_plan_menu_key}" "${time_revamped_plan_menu_command}"
  done <<EOF
${time_revamped_plan_menu_list}
EOF
  time_revamped_bind "${TIME_REVAMPED_S_menu_key}" "World clock menu" "$@"
}

time_revamped_plan_keys() {
  case "${TIME_REVAMPED_S_menu_key}: ${TIME_REVAMPED_KEYS} " in
  "${TIME_REVAMPED_DEFAULT_MENU_KEY}:"*" ${TIME_REVAMPED_DEFAULT_MENU_KEY} "*) TIME_REVAMPED_SKIPPED="${TIME_REVAMPED_SKIPPED}${TIME_REVAMPED_SKIPPED:+ }${TIME_REVAMPED_DEFAULT_MENU_KEY}" ;;
  *) time_revamped_plan_menu ;;
  esac
  time_revamped_bind "${TIME_REVAMPED_S_calendar_key}" "Calendar" run-shell "${TIME_REVAMPED_TOOL} calendar"
  time_revamped_bind "${TIME_REVAMPED_S_copy_key}" "Copy the ISO time" run-shell "${TIME_REVAMPED_TOOL} copy iso"
  time_revamped_bind "${TIME_REVAMPED_S_mark_key}" "Set the stopwatch mark" run-shell "${TIME_REVAMPED_TOOL} mark"
}

time_revamped_replaced() {
  printf '%s\n' "$1" | TIME_REVAMPED_PUT="${TIME_REVAMPED_JOB}" awk -v mode="${TIME_REVAMPED_S_render}" -v kinds="${TIME_REVAMPED_METRICS}" '
    BEGIN {
      command = ENVIRON["TIME_REVAMPED_PUT"]
      count = split(kinds, kind, " ")
    }
    {
      line = $0
      for (i = 1; i <= count; i++) {
        holder = (kind[i] == "datetime") ? "#{time}" : "#{time_" kind[i] "}"
        target = (mode == "options") ? "#{E:@time_revamped_out_" kind[i] "}" : "#(" command " status " kind[i] ")"
        done = ""
        while ((at = index(line, holder)) > 0) {
          done = done substr(line, 1, at - 1) target
          line = substr(line, at + length(holder))
        }
        line = done line
      }
      print line
    }
  '
}

time_revamped_used() {
  printf '%s\n' "$1" | awk -v kinds="${TIME_REVAMPED_METRICS}" '
    BEGIN { count = split(kinds, kind, " ") }
    { text = text $0 " " }
    END {
      out = ""
      for (i = 1; i <= count; i++) {
        holder = (kind[i] == "datetime") ? "#{time}" : "#{time_" kind[i] "}"
        if (index(text, holder) > 0 || index(text, "@time_revamped_out_" kind[i] "}") > 0 || index(text, " status " kind[i] ")") > 0) { out = out (out == "" ? "" : " ") kind[i] }
      }
      print out
    }
  '
}

time_revamped_plan_status() {
  time_revamped_plan_status_all=""
  for time_revamped_plan_status_option in status-left status-right; do
    time_revamped_plan_status_now=$(tmux show-option -gqv "${time_revamped_plan_status_option}" 2>/dev/null) || time_revamped_plan_status_now=""
    time_revamped_plan_status_all="${time_revamped_plan_status_all} ${time_revamped_plan_status_now}"
    case "${time_revamped_plan_status_now}" in
    *"#{time"*"}"*) time_revamped_plan_status_new=$(time_revamped_replaced "${time_revamped_plan_status_now}") ;;
    *) continue ;;
    esac
    [ "${time_revamped_plan_status_new}" != "${time_revamped_plan_status_now}" ] || continue
    time_revamped_emit set-option -gq "${time_revamped_plan_status_option}" "${time_revamped_plan_status_new}"
  done
  time_revamped_plan_status_used=$(time_revamped_used "${time_revamped_plan_status_all}")
  [ "${time_revamped_plan_status_used}" = "${TIME_REVAMPED_S_published}" ] || time_revamped_emit set-option -gq @time_revamped_published "${time_revamped_plan_status_used}"
  TIME_REVAMPED_S_published="${time_revamped_plan_status_used}"
}

time_revamped_plan() {
  time_revamped_load
  time_revamped_version
  TIME_REVAMPED_NOTES=0
  ! time_revamped_version_ge "${TIME_REVAMPED_TMUX}" "${TIME_REVAMPED_NOTES_SINCE}" || TIME_REVAMPED_NOTES=1
  time_revamped_tools
  TIME_REVAMPED_KEYS=$(time_revamped_held)
  TIME_REVAMPED_PLAN="" TIME_REVAMPED_SKIPPED=""
  time_revamped_plan_keys
  time_revamped_plan_status
}

time_revamped_apply() {
  time_revamped_plan
  time_revamped_apply_status=0
  time_revamped_deliver || time_revamped_apply_status=1
  if [ "${TIME_REVAMPED_S_render}" = options ]; then
    revamped_ticker_start "${REVAMPED_LIB%/lib}/bin/time-revamped"
  else
    tmux set-option -gqu @time_revamped_ticker_pid 2>/dev/null || :
  fi
  return "${time_revamped_apply_status}"
}

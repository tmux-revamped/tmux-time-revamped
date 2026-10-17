#!/usr/bin/env bash

[[ -n "${_TIME_REVAMPED_DATEMATH_LOADED:-}" ]] && return 0
_TIME_REVAMPED_DATEMATH_LOADED=1

_now_epoch() { date +%s 2>/dev/null || echo 0; }

days_from_civil() {
  local y="${1:-1970}" m="${2:-1}" d="${3:-1}"
  y=$(( 10#${y} )); m=$(( 10#${m} )); d=$(( 10#${d} ))
  (( m <= 2 )) && y=$(( y - 1 ))
  local era yoe doy doe mp
  if (( y >= 0 )); then era=$(( y / 400 )); else era=$(( (y - 399) / 400 )); fi
  yoe=$(( y - era * 400 ))
  if (( m > 2 )); then mp=$(( m - 3 )); else mp=$(( m + 9 )); fi
  doy=$(( (153 * mp + 2) / 5 + d - 1 ))
  doe=$(( yoe * 365 + yoe / 4 - yoe / 100 + doy ))
  echo $(( era * 146097 + doe - 719468 ))
}

parse_to_epoch() {
  local s="${1:-}" Y M D H Mi S days
  if [[ "${s}" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})([T\ ]([0-9]{2}):([0-9]{2})(:([0-9]{2}))?)?$ ]]; then
    Y="${BASH_REMATCH[1]}"; M="${BASH_REMATCH[2]}"; D="${BASH_REMATCH[3]}"
    H="${BASH_REMATCH[5]:-0}"; Mi="${BASH_REMATCH[6]:-0}"; S="${BASH_REMATCH[8]:-0}"
  else
    return 0
  fi
  days=$(days_from_civil "${Y}" "${M}" "${D}")
  echo $(( days * 86400 + 10#${H} * 3600 + 10#${Mi} * 60 + 10#${S} ))
}

fmt_duration() {
  local secs="${1:-0}"
  [[ "${secs}" =~ ^-?[0-9]+$ ]] || secs=0
  (( secs < 0 )) && secs=0
  local d h m
  d=$(( secs / 86400 ))
  h=$(( (secs % 86400) / 3600 ))
  m=$(( (secs % 3600) / 60 ))
  if (( d > 0 )); then
    printf '%dd %dh\n' "${d}" "${h}"
  elif (( h > 0 )); then
    printf '%dh %dm\n' "${h}" "${m}"
  elif (( m > 0 )); then
    printf '%dm\n' "${m}"
  else
    printf '<1m\n'
  fi
}

offset_minutes() {
  local z="${1:-}" val
  if [[ "${z}" =~ ^([+-])([0-9]{2})([0-9]{2})$ ]]; then
    val=$(( 10#${BASH_REMATCH[2]} * 60 + 10#${BASH_REMATCH[3]} ))
    [[ "${BASH_REMATCH[1]}" == "-" ]] && val=$(( -val ))
    echo "${val}"
    return 0
  fi
  echo 0
  return 1
}

export -f _now_epoch
export -f days_from_civil
export -f parse_to_epoch
export -f fmt_duration
export -f offset_minutes

#!/usr/bin/env bash

[[ -n "${_TIME_REVAMPED_GEOIP_LOADED:-}" ]] && return 0
_TIME_REVAMPED_GEOIP_LOADED=1

GEOIP_TIMEOUT="${GEOIP_TIMEOUT:-3}"

GEOIP_MAX_CITY_LEN=64

_read_geoip() {
  curl -fsS --max-time "${GEOIP_TIMEOUT}" "${1}" 2>/dev/null
}

geoip_city_chars_safe() {
  [[ -z "$(printf '%s' "${1}" | LC_ALL=C tr -d "A-Za-z0-9 .,'\200-\377-")" ]]
}

geoip_parse_city() {
  local body="${1}" city
  case "${body}" in
    *'"city"'*)
      city=$(printf '%s' "${body}" | sed -n 's/.*"city"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
      ;;
    *)
      city=$(printf '%s' "${body}" | head -n1 | tr -d '\r')
      ;;
  esac
  if [[ -z "${city}" || "${#city}" -gt "${GEOIP_MAX_CITY_LEN}" ]] || ! geoip_city_chars_safe "${city}"; then
    echo ""
    return 0
  fi
  printf '%s' "${city}"
}

export -f _read_geoip
export -f geoip_city_chars_safe
export -f geoip_parse_city

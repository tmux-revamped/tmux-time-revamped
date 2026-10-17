#!/usr/bin/env bash

[[ -n "${_TIME_REVAMPED_TMUX_CMD_LOADED:-}" ]] && return 0
_TIME_REVAMPED_TMUX_CMD_LOADED=1

_TIME_TMUX_CMD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_TIME_TMUX_CMD_DIR}/tmux-ops.sh"
# shellcheck source=/dev/null
source "${_TIME_TMUX_CMD_DIR}/../utils/has-command.sh"
# shellcheck source=/dev/null
source "${_TIME_TMUX_CMD_DIR}/../time/extras.sh"

_tmux() { tmux "$@"; }

_clipboard_copy() {
  if has_command pbcopy; then
    printf '%s' "${1}" | pbcopy
  elif has_command wl-copy; then
    printf '%s' "${1}" | wl-copy
  elif has_command xclip; then
    printf '%s' "${1}" | xclip -selection clipboard
  fi
}

time_set_mark() {
  local ep
  ep=$(_now_epoch)
  set_tmux_option "@time_revamped_mark_epoch" "${ep}"
  _tmux display-message "time-revamped: mark set"
}

time_copy_timestamp() {
  local fmt="${1:-iso}" value
  case "${fmt}" in
    epoch) value=$(read_epoch) ;;
    *)     value=$(read_iso) ;;
  esac
  _tmux set-buffer "${value}"
  _clipboard_copy "${value}"
  _tmux display-message "time-revamped: copied ${value}"
}

time_toggle_format() {
  local cur
  cur=$(get_tmux_option "@time_revamped_time_format" "24H")
  if [[ "${cur}" == "12H" ]]; then
    set_tmux_option "@time_revamped_time_format" "24H"
  else
    set_tmux_option "@time_revamped_time_format" "12H"
  fi
}

time_calendar_popup() {
  local script="cal; echo; read -rsn1 -p 'press any key to close'" quoted
  printf -v quoted '%q' "${script}"
  _tmux display-popup -E "bash -c ${quoted}"
}

_time_menu_cmd() {
  local cmd hash="#" bs='\' dq='"' dl='$' ebs='\\' edq='\"' edl='\$'
  cmd="$(printf '%q %s' "${TIME_DISPATCH:-}" "${1}")"
  cmd="${cmd//"${hash}"/${hash}${hash}}"
  cmd="${cmd//"${bs}"/${ebs}}"
  cmd="${cmd//"${dq}"/${edq}}"
  printf '%s' "${cmd//"${dl}"/${edl}}"
}

time_menu() {
  _tmux display-menu -T "time-revamped" \
    "Toggle 12/24h" h "run-shell \"$(_time_menu_cmd toggle-format)\"" \
    "Calendar"      c "run-shell \"$(_time_menu_cmd calendar)\"" \
    "Copy ISO"      i "run-shell \"$(_time_menu_cmd 'copy iso')\"" \
    "Copy epoch"    e "run-shell \"$(_time_menu_cmd 'copy epoch')\"" \
    "Set mark"      m "run-shell \"$(_time_menu_cmd mark)\"" \
    "Doctor"        d "run-shell \"$(_time_menu_cmd doctor)\""
}

export -f _tmux
export -f _clipboard_copy
export -f time_set_mark
export -f time_copy_timestamp
export -f time_toggle_format
export -f time_calendar_popup
export -f _time_menu_cmd
export -f time_menu

#!/usr/bin/env bash
#
# time-revamped.tmux: TPM entry point.
#
# Replaces the #{time_*} placeholders in status-left and status-right with calls
# to the dispatcher, which computes the clock live and never blocks the render.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIME_CMD="${PLUGIN_DIR}/src/time.sh"
HASH="#"
TIME_CMD_QUOTED="$(printf '%q' "${TIME_CMD}")"
TIME_CMD_QUOTED="${TIME_CMD_QUOTED//"${HASH}"/${HASH}${HASH}}"

placeholders=(
  "\#{time}"
  "\#{time_date}"
  "\#{time_clock}"
  "\#{time_zones}"
  "\#{time_local}"
  "\#{time_until}"
  "\#{time_elapsed}"
  "\#{time_epoch}"
  "\#{time_iso}"
  "\#{time_offset}"
  "\#{time_week}"
  "\#{time_doy}"
  "\#{time_dst}"
  "\#{time_overlap}"
)

commands=(
  "#(${TIME_CMD_QUOTED} datetime)"
  "#(${TIME_CMD_QUOTED} date)"
  "#(${TIME_CMD_QUOTED} clock)"
  "#(${TIME_CMD_QUOTED} zones)"
  "#(${TIME_CMD_QUOTED} local)"
  "#(${TIME_CMD_QUOTED} until)"
  "#(${TIME_CMD_QUOTED} elapsed)"
  "#(${TIME_CMD_QUOTED} epoch)"
  "#(${TIME_CMD_QUOTED} iso)"
  "#(${TIME_CMD_QUOTED} offset)"
  "#(${TIME_CMD_QUOTED} week)"
  "#(${TIME_CMD_QUOTED} doy)"
  "#(${TIME_CMD_QUOTED} dst)"
  "#(${TIME_CMD_QUOTED} overlap)"
)

render_mode="$(tmux show-option -gqv "@time_revamped_render")"

target_for() {
  local command="${1}" metric
  metric="${command##* }"
  metric="${metric%)}"
  if [[ "${render_mode}" == "options" ]]; then
    printf '#{E:@time_revamped_out_%s}' "${metric}"
  else
    printf '%s' "${command}"
  fi
}

interpolate() {
  local value="${1}" i placeholder replacement out rest
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    placeholder="${placeholders[i]#\\}"
    replacement="$(target_for "${commands[i]}")"
    out=""
    rest="${value}"
    while [[ "${rest}" == *"${placeholder}"* ]]; do
      out="${out}${rest%%"${placeholder}"*}${replacement}"
      rest="${rest#*"${placeholder}"}"
    done
    value="${out}${rest}"
  done
  echo "${value}"
}

used_metrics() {
  local text="${1}" used="" i metric
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    metric="${commands[i]##* }"
    metric="${metric%)}"
    if [[ "${text}" == *${placeholders[i]}* || "${text}" == *"@time_revamped_out_${metric}}"* ]]; then
      used="${used:+${used} }${metric}"
    fi
  done
  echo "${used}"
}

update_option() {
  local option="${1}"
  local current
  current=$(tmux show-option -gqv "${option}")
  tmux set-option -gq "${option}" "$(interpolate "${current}")"
}

# bind_key OPTION DEFAULT SUBCOMMAND: bind a key to a dispatcher action. The key
# comes from OPTION, falling back to DEFAULT; the literal value "off" skips it.
bind_key() {
  local opt="${1}" default="${2}" subcmd="${3}" key
  key=$(tmux show-option -gqv "${opt}")
  [[ -z "${key}" ]] && key="${default}"
  [[ "${key}" == "off" ]] && return 0
  tmux bind-key "${key}" run-shell "${TIME_CMD_QUOTED} ${subcmd}"
}

chmod +x "${TIME_CMD}" 2>/dev/null || true

status_text="$(tmux show-option -gqv status-left) $(tmux show-option -gqv status-right)"
tmux set-option -gq "@time_revamped_published" "$(used_metrics "${status_text}")"

update_option "status-left"
update_option "status-right"

if [[ "${render_mode}" == "options" ]]; then
  "${TIME_CMD}" start 2>/dev/null || true
fi

# The prefix menu is bound by default; the standalone actions are opt-in so they
# never clobber a user's keys. The menu already exposes calendar, copy, and mark.
bind_key "@time_revamped_menu_key" "M-t" "menu"
bind_key "@time_revamped_calendar_key" "off" "calendar"
bind_key "@time_revamped_copy_key" "off" "copy iso"
bind_key "@time_revamped_mark_key" "off" "mark"

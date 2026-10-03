#!/usr/bin/env bash
#
# time-revamped.tmux: TPM entry point.
#
# Replaces the #{time_*} placeholders in status-left and status-right with calls
# to the dispatcher, which computes the clock live and never blocks the render.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIME_CMD="${PLUGIN_DIR}/src/time.sh"

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
  "#(${TIME_CMD} datetime)"
  "#(${TIME_CMD} date)"
  "#(${TIME_CMD} clock)"
  "#(${TIME_CMD} zones)"
  "#(${TIME_CMD} local)"
  "#(${TIME_CMD} until)"
  "#(${TIME_CMD} elapsed)"
  "#(${TIME_CMD} epoch)"
  "#(${TIME_CMD} iso)"
  "#(${TIME_CMD} offset)"
  "#(${TIME_CMD} week)"
  "#(${TIME_CMD} doy)"
  "#(${TIME_CMD} dst)"
  "#(${TIME_CMD} overlap)"
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
  local value="${1}"
  local i
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    value="${value//${placeholders[i]}/$(target_for "${commands[i]}")}"
  done
  echo "${value}"
}

used_metrics() {
  local text="${1}" used="" i metric
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    if [[ "${text}" == *${placeholders[i]}* ]]; then
      metric="${commands[i]##* }"
      used="${used:+${used} }${metric%)}"
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
  tmux bind-key "${key}" run-shell "${TIME_CMD} ${subcmd}"
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
bind_key "@time_revamped_menu_key" "T" "menu"
bind_key "@time_revamped_calendar_key" "off" "calendar"
bind_key "@time_revamped_copy_key" "off" "copy iso"
bind_key "@time_revamped_mark_key" "off" "mark"

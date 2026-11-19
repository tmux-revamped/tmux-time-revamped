# shellcheck shell=bash
# shellcheck disable=SC2207

_time_revamped() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"

  case "${prev}" in
  --theme)
    COMPREPLY=($(compgen -W "kodougu catppuccin-mocha catppuccin-latte dracula nord gruvbox tokyo-night mono" -- "${cur}"))
    return
    ;;
  status)
    COMPREPLY=($(compgen -W "datetime date clock zones local until elapsed epoch iso offset week doy dst overlap" -- "${cur}"))
    return
    ;;
  copy)
    COMPREPLY=($(compgen -W "iso epoch" -- "${cur}"))
    return
    ;;
  --date-format)
    COMPREPLY=($(compgen -W "YMD MD DM MDY DMY hide" -- "${cur}"))
    return
    ;;
  --time-format)
    COMPREPLY=($(compgen -W "24H 12H hide" -- "${cur}"))
    return
    ;;
  --compact)
    COMPREPLY=($(compgen -W "0 1" -- "${cur}"))
    return
    ;;
  --weekend-override)
    COMPREPLY=($(compgen -W "0 1" -- "${cur}"))
    return
    ;;
  --local-source)
    COMPREPLY=($(compgen -W "timezone geoip" -- "${cur}"))
    return
    ;;
  --icon-position)
    COMPREPLY=($(compgen -W "middle before" -- "${cur}"))
    return
    ;;
  --relative-day)
    COMPREPLY=($(compgen -W "0 1" -- "${cur}"))
    return
    ;;
  --work-hours)
    COMPREPLY=($(compgen -W "0 1" -- "${cur}"))
    return
    ;;
  --render)
    COMPREPLY=($(compgen -W "jobs options" -- "${cur}"))
    return
    ;;
  --menu-key | --calendar-key | --copy-key | --mark-key | --timezones | --zone-labels | --zone-separator | --local-label | --geoip-endpoint | --geoip-interval | --morning-color | --day-color | --afternoon-color | --evening-color | --night-color | --weekend-color | --sunrise-icon | --morning-icon | --day-icon | --afternoon-icon | --sunset-icon | --evening-icon | --night-icon | --weekend-icon | --reset | --work-start | --work-end | --dim-style | --primary | --primary-style | --countdown-target | --countdown-label | --countdown-done | --dst-zone | --dst-horizon | --dst-label | --overlap-label | --overlap-none | --interval)
    return
    ;;
  *) ;;
  esac

  COMPREPLY=($(compgen -W "apply list status card menu calendar copy mark toggle-format daemon doctor version help --json --theme --menu-key --calendar-key --copy-key --mark-key --date-format --time-format --timezones --compact --zone-labels --zone-separator --weekend-override --local-label --local-source --geoip-endpoint --geoip-interval --morning-color --day-color --afternoon-color --evening-color --night-color --weekend-color --sunrise-icon --morning-icon --day-icon --afternoon-icon --sunset-icon --evening-icon --night-icon --weekend-icon --icon-position --reset --relative-day --work-hours --work-start --work-end --dim-style --primary --primary-style --countdown-target --countdown-label --countdown-done --dst-zone --dst-horizon --dst-label --overlap-label --overlap-none --render --interval" -- "${cur}"))
}

complete -F _time_revamped time-revamped

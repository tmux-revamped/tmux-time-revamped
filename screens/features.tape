Source common.tape
Output scratch.gif
Hide
Type "tmux -L revamped-screens attach -t demo"
Enter
Sleep 1.5s
Show
Sleep 1.5s
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_date_format DMY"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_time_format 12H"
Enter
Show
Sleep 2s
Screenshot formats.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_date_format"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_time_format"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_date_format hide"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_time_format hide"
Enter
Show
Sleep 2s
Screenshot hide.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_date_format"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_time_format"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_compact 1"
Enter
Show
Sleep 2s
Screenshot compact.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_compact"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_zone_labels 'LDN, TYO, SYD'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_zone_separator ' | '"
Enter
Show
Sleep 2s
Screenshot labels.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_zone_labels"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_zone_separator"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_timezones 'Pacific/Honolulu, America/New_York, Atlantic/Cape_Verde, Europe/Berlin, Asia/Dubai'"
Enter
Show
Sleep 2s
Screenshot periods.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_timezones 'Europe/London, Asia/Tokyo, Australia/Sydney'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_timezones 'Pacific/Honolulu, America/New_York, Atlantic/Cape_Verde, Europe/Berlin, Asia/Dubai'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell 'printf 1792247400 >/Users/Shared/demo/now'"
Enter
Show
Sleep 2s
Screenshot weekend.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_weekend_override 0"
Enter
Show
Sleep 2s
Screenshot weekend-override.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_weekend_override"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell 'printf 1792161000 >/Users/Shared/demo/now'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_timezones 'Europe/London, Asia/Tokyo, Australia/Sydney'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_timezones 'Pacific/Honolulu, America/New_York, Atlantic/Cape_Verde, Europe/Berlin, Asia/Dubai'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_morning_color '#[fg=#ff8700]'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_day_color '#[fg=#5fd700]'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_afternoon_color '#[fg=#00afff]'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_evening_color '#[fg=#ff5f87]'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_night_color '#[fg=#8787ff]'"
Enter
Show
Sleep 2s
Screenshot colors.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_morning_color"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_day_color"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_afternoon_color"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_evening_color"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_night_color"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_night_icon 'N'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_morning_icon 'M'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_day_icon 'D'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_afternoon_icon 'A'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_evening_icon 'E'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_sunrise_icon 'R'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_sunset_icon 'S'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_weekend_icon 'W'"
Enter
Show
Sleep 2s
Screenshot icons.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_icon_position before"
Enter
Show
Sleep 2s
Screenshot icon-position.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_icon_position"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_night_icon"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_morning_icon"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_day_icon"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_afternoon_icon"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_evening_icon"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_sunrise_icon"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_sunset_icon"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_weekend_icon"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_timezones 'Pacific/Auckland, America/Los_Angeles, Europe/London'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_relative_day 1"
Enter
Show
Sleep 2s
Screenshot relative-day.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell 'printf 1792126800 >/Users/Shared/demo/now'"
Enter
Show
Sleep 2s
Screenshot relative-day-back.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell 'printf 1792161000 >/Users/Shared/demo/now'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell 'printf 1792161000 >/Users/Shared/demo/now'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_timezones 'America/New_York, Europe/London, Asia/Tokyo, Australia/Sydney'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_relative_day"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_work_hours 1"
Enter
Show
Sleep 2s
Screenshot work-hours.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_dim_style '#[dim,italics]'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_work_start 8"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_work_end 12"
Enter
Show
Sleep 2s
Screenshot dim-style.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_dim_style"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_work_start"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_work_end"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_work_hours"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_primary 1"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_primary_style '#[fg=#f9e2af,bold]'"
Enter
Show
Sleep 2s
Screenshot primary.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_primary"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_primary_style"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_reset '#[fg=#6c7086]'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_zones} | #{time_clock}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Sleep 2s
Screenshot reset.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_reset"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_timezones 'Europe/London, Asia/Tokyo, Australia/Sydney'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_local} #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Sleep 2s
Screenshot local.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_local_label Home"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_local} #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Sleep 2s
Screenshot local-label.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_local_label"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_local_source geoip"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_local} #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Sleep 4s
Screenshot geoip.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_local_source"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_geoip_city"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_geoip_city_ts"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_geoip_city_lock"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_geoip_city_lock_ts"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_countdown_target '2026-10-20 18:00'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_countdown_label Launch"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_clock} #{time_until}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Sleep 2s
Screenshot countdown.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_countdown_target '2026-10-15 09:00'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_countdown_done Launched"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_clock} #{time_until}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Sleep 2s
Screenshot countdown-done.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_countdown_target"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_countdown_label"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_countdown_done"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_epoch} #{time_iso} #{time_offset} W#{time_week} D#{time_doy}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Sleep 2s
Screenshot epoch.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_timezones 'America/New_York, Europe/London'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_dst_zone America/New_York"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_dst_label Clocks"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_clock} #{time_dst}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell 'printf 1793361600 >/Users/Shared/demo/now'"
Enter
Show
Sleep 2s
Screenshot dst.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell 'printf 1792161000 >/Users/Shared/demo/now'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell 'printf 1792161000 >/Users/Shared/demo/now'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_clock} #{time_overlap}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Sleep 2s
Screenshot overlap.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_timezones 'America/New_York, Asia/Tokyo'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_overlap_label Meet"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_overlap_none never"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_clock} #{time_overlap}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Sleep 2s
Screenshot overlap-none.png
Sleep 500ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_overlap_label"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -gu @time_revamped_overlap_none"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g @time_revamped_timezones 'Europe/London, Asia/Tokyo, Australia/Sydney'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Sleep 500ms

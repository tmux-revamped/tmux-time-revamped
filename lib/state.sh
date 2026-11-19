#!/bin/sh
# shellcheck disable=SC2034

[ -n "${TIME_REVAMPED_STATE_LOADED:-}" ] && return 0
TIME_REVAMPED_STATE_LOADED=1

TIME_REVAMPED_SETTINGS='menu_key	M-t
calendar_key	off
copy_key	off
mark_key	off
date_format	YMD
time_format	24H
timezones
compact	0
zone_labels
zone_separator	 
weekend_override	1
local_label
local_source	timezone
geoip_endpoint	https://ipinfo.io/city
geoip_interval	30
morning_color	#[fg=yellow]
day_color	#[fg=green]
afternoon_color	#[fg=cyan]
evening_color	#[fg=magenta]
night_color	#[fg=blue]
weekend_color	#[fg=brightblack]
sunrise_icon
morning_icon
day_icon
afternoon_icon
sunset_icon
evening_icon
night_icon
weekend_icon
icon_position	middle
reset	#[default]
relative_day	0
work_hours	0
work_start	9
work_end	17
dim_style	#[dim]
primary
primary_style	#[bold]
countdown_target
countdown_label
countdown_done	now
dst_zone
dst_horizon	14
dst_label	DST
overlap_label	overlap
overlap_none	no overlap
render	jobs
interval	minute'
TIME_REVAMPED_NAMES='menu_key calendar_key copy_key mark_key date_format time_format timezones compact zone_labels zone_separator weekend_override local_label local_source geoip_endpoint geoip_interval morning_color day_color afternoon_color evening_color night_color weekend_color sunrise_icon morning_icon day_icon afternoon_icon sunset_icon evening_icon night_icon weekend_icon icon_position reset relative_day work_hours work_start work_end dim_style primary primary_style countdown_target countdown_label countdown_done dst_zone dst_horizon dst_label overlap_label overlap_none render interval'
TIME_REVAMPED_CARRIED='date_format time_format timezones compact zone_labels zone_separator weekend_override local_label local_source geoip_endpoint geoip_interval morning_color day_color afternoon_color evening_color night_color weekend_color sunrise_icon morning_icon day_icon afternoon_icon sunset_icon evening_icon night_icon weekend_icon icon_position reset relative_day work_hours work_start work_end dim_style primary primary_style countdown_target countdown_label countdown_done dst_zone dst_horizon dst_label overlap_label overlap_none'
TIME_REVAMPED_LIVE='mark_epoch geoip_city geoip_city_ts geoip_city_lock geoip_city_lock_ts published'
TIME_REVAMPED_S_menu_key='M-t'
TIME_REVAMPED_S_calendar_key='off'
TIME_REVAMPED_S_copy_key='off'
TIME_REVAMPED_S_mark_key='off'
TIME_REVAMPED_S_date_format='YMD'
TIME_REVAMPED_S_time_format='24H'
TIME_REVAMPED_S_timezones=''
TIME_REVAMPED_S_compact='0'
TIME_REVAMPED_S_zone_labels=''
TIME_REVAMPED_S_zone_separator=' '
TIME_REVAMPED_S_weekend_override='1'
TIME_REVAMPED_S_local_label=''
TIME_REVAMPED_S_local_source='timezone'
TIME_REVAMPED_S_geoip_endpoint='https://ipinfo.io/city'
TIME_REVAMPED_S_geoip_interval='30'
TIME_REVAMPED_S_morning_color='#[fg=yellow]'
TIME_REVAMPED_S_day_color='#[fg=green]'
TIME_REVAMPED_S_afternoon_color='#[fg=cyan]'
TIME_REVAMPED_S_evening_color='#[fg=magenta]'
TIME_REVAMPED_S_night_color='#[fg=blue]'
TIME_REVAMPED_S_weekend_color='#[fg=brightblack]'
TIME_REVAMPED_S_sunrise_icon=''
TIME_REVAMPED_S_morning_icon=''
TIME_REVAMPED_S_day_icon=''
TIME_REVAMPED_S_afternoon_icon=''
TIME_REVAMPED_S_sunset_icon=''
TIME_REVAMPED_S_evening_icon=''
TIME_REVAMPED_S_night_icon=''
TIME_REVAMPED_S_weekend_icon=''
TIME_REVAMPED_S_icon_position='middle'
TIME_REVAMPED_S_reset='#[default]'
TIME_REVAMPED_S_relative_day='0'
TIME_REVAMPED_S_work_hours='0'
TIME_REVAMPED_S_work_start='9'
TIME_REVAMPED_S_work_end='17'
TIME_REVAMPED_S_dim_style='#[dim]'
TIME_REVAMPED_S_primary=''
TIME_REVAMPED_S_primary_style='#[bold]'
TIME_REVAMPED_S_countdown_target=''
TIME_REVAMPED_S_countdown_label=''
TIME_REVAMPED_S_countdown_done='now'
TIME_REVAMPED_S_dst_zone=''
TIME_REVAMPED_S_dst_horizon='14'
TIME_REVAMPED_S_dst_label='DST'
TIME_REVAMPED_S_overlap_label='overlap'
TIME_REVAMPED_S_overlap_none='no overlap'
TIME_REVAMPED_S_render='jobs'
TIME_REVAMPED_S_interval='minute'
TIME_REVAMPED_S_mark_epoch=''
TIME_REVAMPED_S_geoip_city=''
TIME_REVAMPED_S_geoip_city_ts=''
TIME_REVAMPED_S_geoip_city_lock=''
TIME_REVAMPED_S_geoip_city_lock_ts=''
TIME_REVAMPED_S_published=''
TIME_REVAMPED_METRICS='datetime date clock zones local until elapsed epoch iso offset week doy dst overlap'
TIME_REVAMPED_DEFAULT_MENU_KEY='M-t'
TIME_REVAMPED_DEFAULT_INTERVAL=minute
TIME_REVAMPED_DEFAULT_GEOIP=30
TIME_REVAMPED_DEFAULT_HORIZON=14
TIME_REVAMPED_DEFAULT_START=9
TIME_REVAMPED_DEFAULT_END=17
TIME_REVAMPED_GEOIP_TIMEOUT=3
TIME_REVAMPED_GEOIP_MAX_CITY=64
TIME_REVAMPED_POPUP_SINCE=3.2
TIME_REVAMPED_NOTES_SINCE=3.1
TIME_REVAMPED_ZONEINFO=${REVAMPED_TEST_ZONEINFO:-/usr/share/zoneinfo}
TIME_REVAMPED_TITLE='time-revamped'
TIME_REVAMPED_EMPTY='time-revamped-empty-argument'
TIME_REVAMPED_TAB='	'
# shellcheck disable=SC2016
TIME_REVAMPED_CALENDAR='cal; printf "\npress any key to close"; state=$(stty -g); stty -icanon -echo min 1 time 0; dd bs=1 count=1 >/dev/null 2>&1; stty "${state}"'
TIME_REVAMPED_TMUX=''
TIME_REVAMPED_NOTES=0
TIME_REVAMPED_TOOL=''
TIME_REVAMPED_JOB=''
TIME_REVAMPED_KEYS=''
TIME_REVAMPED_SKIPPED=''
TIME_REVAMPED_PLAN=''
TIME_REVAMPED_NOW=0
TIME_REVAMPED_NUMBER=0
TIME_REVAMPED_DOUBLED=''
TIME_REVAMPED_OUT=''
TIME_REVAMPED_PATTERN=''
TIME_REVAMPED_PERIOD=''
TIME_REVAMPED_EPOCH=''
TIME_REVAMPED_DATE_GNU=''
TIME_REVAMPED_INTICK=0
TIME_REVAMPED_POPUP_OK=0
TIME_REVAMPED_CARD=''
REVAMPED_CACHE_PREFIX=time_revamped
TIME_REVAMPED_KINDS='work_start	number
work_end	number
dst_horizon	number
geoip_interval	number
primary	number
compact	0 1
weekend_override	0 1
relative_day	0 1
work_hours	0 1
date_format	YMD MD DM MDY DMY hide
time_format	24H 12H hide
icon_position	middle before
local_source	timezone geoip
render	jobs options'

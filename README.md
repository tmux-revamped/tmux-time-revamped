<div align="center">

# tmux-time-revamped

<strong>Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning.</strong>

English &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-time-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-time-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-time-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-time-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-time-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-time-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-time-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#quick-start"><strong>Quick start</strong></a> &nbsp;|&nbsp;
  <a href="#usage">Usage</a> &nbsp;|&nbsp;
  <a href="#how-it-works">How it works</a> &nbsp;|&nbsp;
  <a href="#screens">Screens</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="time-revamped showing the date, the time and three world clocks coloured by the hour, opening the world clock menu, switching to 12 hour time, the calendar, the stopwatch and the options render mode" width="800">
</p>

```console
$ time-revamped --timezones "Europe/London, Asia/Tokyo" card
Time           2026-11-19 13:02
ISO            2026-11-19T13:02:54-05:00
Epoch          1795111374
Offset         UTC-05:00
Week           47
Day of year    323
Local          New York 13:02
Zones          GMT 18:02 JST 03:02
Countdown      -
Stopwatch      -
Clock change   -
Overlap        overlap no overlap
Read. It is 2026-11-19T13:02:54-05:00.
```

**14** placeholders, **2** render modes, macOS and Linux, tmux **3.2** or later.

---

## Quick start

### Prerequisites

| Tool | Version | Used for |
|:-----|:--------|:---------|
| tmux | 3.2 or later | the family floor, and the calendar popup |
| `date` and the timezone database | system | every clock, with GNU, uutils, BusyBox or BSD `date` |
| `cal` | system | the calendar popup |
| `curl` | optional | the geoip place label |
| `pbcopy`, `wl-copy` or `xclip` | optional | copying a timestamp to the system clipboard |
| gum | optional | the menu, tables and colours of `time-revamped`; without it every command prints plain text |

It runs on Linux and macOS with BSD, GNU, uutils or BusyBox tools. A missing optional tool leaves its feature quiet, and `time-revamped doctor` names it.

### Install

With [TPM](https://github.com/tmux-plugins/tpm), add the plugin to `~/.tmux.conf` and press `prefix + I`:

```tmux
set -g @plugin 'tmux-revamped/tmux-time-revamped'
set -g status-right '#{time} #{time_zones}'
```

To install by hand, clone the repository and run the entrypoint from `~/.tmux.conf`:

```bash
git clone https://github.com/tmux-revamped/tmux-time-revamped ~/.tmux/plugins/tmux-time-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-time-revamped/time-revamped.tmux
```

Set `status-left` or `status-right` before the plugin loads. The plugin replaces the placeholders it finds there once, at load time.

`make install` in the clone also puts `time-revamped` in `~/.local/bin`, with its man page and completions under `~/.local/share`.

### Verify

```bash
~/.tmux/plugins/tmux-time-revamped/bin/time-revamped doctor
```

## Usage

The plugin replaces placeholders in `status-left` and `status-right` with the local date and time, any number of world clocks, and a few developer and calendar fields. Each world clock is colored by the hour at that place, so you can see at a glance who is in their morning and who is asleep.

| Placeholder | Output |
|:------------|:-------|
| `#{time}` | local date and time, such as `2026-10-16 14:30` |
| `#{time_date}` | local date only |
| `#{time_clock}` | local time only |
| `#{time_zones}` | one entry per configured timezone, colored by time of day |
| `#{time_local}` | the local clock styled like a world clock, with a place label |
| `#{time_until}` | countdown to a target, such as `1d 4h` |
| `#{time_elapsed}` | time since the stopwatch mark, such as `12m` |
| `#{time_epoch}` | unix time in seconds |
| `#{time_iso}` | local time in ISO 8601, such as `2026-10-16T14:30:00-04:00` |
| `#{time_offset}` | local UTC offset, such as `UTC-04:00`, or `UTC` |
| `#{time_week}` | ISO 8601 week number |
| `#{time_doy}` | day of the year |
| `#{time_dst}` | `DST in 3d` when a clock change is within the horizon |
| `#{time_overlap}` | the working-hours window every configured zone shares, in local time |

```tmux
set -g @time_revamped_timezones 'America/New_York, Europe/London, Asia/Tokyo'
set -g status-right '#{time} #{time_zones}'
```

With the local clock in New York, the right side of the status bar reads:

```text
2026-10-16 14:30 EDT 14:30 BST 19:30 JST 03:30
```

Each world clock carries its own color: morning, day, afternoon, evening, night, or the weekend color on Saturday and Sunday.

### World clock decorations

| Setting | Effect |
|:--------|:-------|
| `@time_revamped_compact '1'` | short city labels instead of zone abbreviations: `NY` for `America/New_York`, `Tok` for `Asia/Tokyo` |
| `@time_revamped_zone_labels 'NYC, LDN, TYO'` | your own labels, matched to the zones by position |
| `@time_revamped_relative_day '1'` | a `+1d` or `-1d` badge on a zone that is on another calendar day |
| `@time_revamped_work_hours '1'` | dims a zone outside `@time_revamped_work_start` to `@time_revamped_work_end` |
| `@time_revamped_primary '0'` | shows the zone at that zero-based index in bold |

`#{time_overlap}` intersects the working hours of every configured zone and prints the longest shared window in local time, such as `overlap 13:00-17:00`. With no shared hour it prints the label followed by `@time_revamped_overlap_none`, which reads `overlap no overlap` by default.

### The local place label

`#{time_local}` needs a place name. By default it takes the city from `TZ` or from the `/etc/localtime` link, offline. With `@time_revamped_local_source 'geoip'` it asks `@time_revamped_geoip_endpoint` for the city of your public IP instead. That request runs in the background every `@time_revamped_geoip_interval` minutes, times out after 3 seconds, keeps the last city when it fails, and sends your IP to the endpoint, so turn it on only when that is acceptable. A city is accepted only when it holds letters, digits, spaces, UTF-8 characters and `. , ' -`, at most 64 characters.

### Countdown, stopwatch and DST

`#{time_until}` counts down to `@time_revamped_countdown_target`, written as `YYYY-MM-DD` or `YYYY-MM-DD HH:MM`. Once the target passes it shows `@time_revamped_countdown_done`. `#{time_elapsed}` counts from the mark that the mark action sets. `#{time_dst}` checks the UTC offset of `@time_revamped_dst_zone`, or the local zone, once per day ahead for `@time_revamped_dst_horizon` days and reports the first change.

### Render mode

By default each placeholder becomes a `#()` call, which tmux reruns on every status redraw. Set `@time_revamped_render` to `options` and each placeholder becomes an option read such as `#{E:@time_revamped_out_local}`. One background process per server then renders every clock the status line uses, by default once a minute, one second after the minute changes, and writes them in a single tmux call, so the clocks change together.

```tmux
set -g @time_revamped_render 'options'
```

| Command | What it does |
|:--------|:-------------|
| `time-revamped apply` | Binds the keys and fills the placeholders now; the entry point runs it when tmux loads the plugin |
| `time-revamped list` | Prints every command `apply` would send and changes nothing; `--json` prints one object |
| `time-revamped status NAME` | Prints one placeholder, such as `zones`, `iso` or `until`; the status line runs it |
| `time-revamped card` | Reads everything now and prints one row per figure |
| `time-revamped menu` | Opens the world clock menu on the current client |
| `time-revamped calendar` | Opens `cal` in a tmux popup that stays until a key is pressed |
| `time-revamped copy [KIND]` | Copies the time, as `iso` or `epoch`, to the tmux buffer and the system clipboard |
| `time-revamped mark` | Sets the stopwatch mark that `#{time_elapsed}` counts from |
| `time-revamped toggle-format` | Switches between 12 and 24 hour time |
| `time-revamped daemon` | Publishes the placeholders once a minute, for the `options` render mode; `apply` starts it |
| `time-revamped doctor` | One row per dependency, the configured zones, the settings and any key left alone |
| `time-revamped version` | The version, then the tmux version |
| `time-revamped help` | The help page; `man time-revamped` documents the same commands and settings |
| `time-revamped` | On a terminal, a menu |

## Configuration

Every option is also a command option with dashes, such as `--timezones 'Asia/Tokyo'`, and an environment variable, such as `TIME_REVAMPED_TIMEZONES`; the command line wins over the environment, and the environment over the tmux option. An empty tmux option means its default. `doctor` names any setting that holds a value the plugin does not know. One given to `apply` rides on every key and every status call.

| Option | Default | Meaning |
|:-------|:--------|:--------|
| `@time_revamped_date_format` | `YMD` | `YMD`, `MD`, `DM`, `MDY`, `DMY` or `hide` |
| `@time_revamped_time_format` | `24H` | `24H`, `12H` or `hide`, for the local clock and every world clock |
| `@time_revamped_timezones` | empty | timezone names separated by commas or spaces |
| `@time_revamped_compact` | `0` | `1` for short city labels |
| `@time_revamped_zone_labels` | empty | comma-separated labels matched to the zones by position |
| `@time_revamped_zone_separator` | a space | text between world-clock entries |
| `@time_revamped_weekend_override` | `1` | `0` keeps the time-of-day color and icon on weekends |
| `@time_revamped_local_label` | empty | fixed label for `#{time_local}` |
| `@time_revamped_local_source` | `timezone` | `timezone` or `geoip` |
| `@time_revamped_geoip_endpoint` | `https://ipinfo.io/city` | URL returning a plain-text city or JSON with a `city` field |
| `@time_revamped_geoip_interval` | `30` | minutes between geoip requests |
| `@time_revamped_morning_color` | `#[fg=yellow]` | hours 05 to 12 |
| `@time_revamped_day_color` | `#[fg=green]` | hours 12 to 14 |
| `@time_revamped_afternoon_color` | `#[fg=cyan]` | hours 14 to 18 |
| `@time_revamped_evening_color` | `#[fg=magenta]` | hours 18 to 22 |
| `@time_revamped_night_color` | `#[fg=blue]` | hours 22 to 05 |
| `@time_revamped_weekend_color` | `#[fg=brightblack]` | Saturday and Sunday |
| `@time_revamped_{sunrise,morning,day,afternoon,sunset,evening,night,weekend}_icon` | empty | glyph for that period. Sunrise covers 05 to 08 and sunset 18 to 20 |
| `@time_revamped_icon_position` | `middle` | `middle` gives `NYC <icon> 18:00`, `before` gives `<icon> NYC 18:00` |
| `@time_revamped_reset` | `#[default]` | style written after each entry. `#[fg=default]` keeps a theme background |
| `@time_revamped_relative_day` | `0` | `1` adds the `+1d` or `-1d` badge |
| `@time_revamped_work_hours` | `0` | `1` dims zones outside working hours |
| `@time_revamped_work_start` | `9` | first working hour, inclusive |
| `@time_revamped_work_end` | `17` | last working hour, exclusive |
| `@time_revamped_dim_style` | `#[dim]` | style for a zone outside working hours. `none` turns it off |
| `@time_revamped_primary` | empty | zero-based index of the zone to highlight |
| `@time_revamped_primary_style` | `#[bold]` | style for the primary zone. `none` turns it off |
| `@time_revamped_countdown_target` | empty | target for `#{time_until}` |
| `@time_revamped_countdown_label` | empty | text before the countdown |
| `@time_revamped_countdown_done` | `now` | text once the target has passed |
| `@time_revamped_dst_zone` | empty | zone watched by `#{time_dst}`. Empty means local |
| `@time_revamped_dst_horizon` | `14` | days ahead to look for a clock change |
| `@time_revamped_dst_label` | `DST` | text before the day count |
| `@time_revamped_overlap_label` | `overlap` | text before the overlap window |
| `@time_revamped_overlap_none` | `no overlap` | text when no hour is shared |
| `@time_revamped_render` | `jobs` | `options` turns on render mode; any other value means `jobs` |
| `@time_revamped_interval` | `minute` | render-mode cadence: `minute`, or a number of seconds. Anything else falls back to `status-interval`, then 5 seconds |
| `@time_revamped_menu_key` | `M-t` | prefix key for the actions menu. `off` binds nothing |
| `@time_revamped_calendar_key` | `off` | prefix key for the calendar popup |
| `@time_revamped_copy_key` | `off` | prefix key that copies the ISO timestamp |
| `@time_revamped_mark_key` | `off` | prefix key that sets the stopwatch mark |

The colors are the 16 ANSI names, so they follow your terminal theme. To pin exact shades, set the color options to hex values.

<details>
<summary><strong>Hex colors for six themes</strong></summary>

```tmux
# Catppuccin Mocha
set -g @time_revamped_morning_color '#[fg=#ff8700]'
set -g @time_revamped_day_color '#[fg=#5fd700]'
set -g @time_revamped_afternoon_color '#[fg=#00afff]'
set -g @time_revamped_evening_color '#[fg=#ff5f87]'
set -g @time_revamped_night_color '#[fg=#8787ff]'
set -g @time_revamped_weekend_color '#[fg=#a6adc8]'

# Dracula
set -g @time_revamped_morning_color '#[fg=#f1fa8c]'
set -g @time_revamped_day_color '#[fg=#50fa7b]'
set -g @time_revamped_afternoon_color '#[fg=#8be9fd]'
set -g @time_revamped_evening_color '#[fg=#ff79c6]'
set -g @time_revamped_night_color '#[fg=#bd93f9]'
set -g @time_revamped_weekend_color '#[fg=#6272a4]'

# Nord
set -g @time_revamped_morning_color '#[fg=#ebcb8b]'
set -g @time_revamped_day_color '#[fg=#a3be8c]'
set -g @time_revamped_afternoon_color '#[fg=#88c0d0]'
set -g @time_revamped_evening_color '#[fg=#b48ead]'
set -g @time_revamped_night_color '#[fg=#81a1c1]'
set -g @time_revamped_weekend_color '#[fg=#d8dee9]'

# Gruvbox Dark
set -g @time_revamped_morning_color '#[fg=#fabd2f]'
set -g @time_revamped_day_color '#[fg=#b8bb26]'
set -g @time_revamped_afternoon_color '#[fg=#8ec07c]'
set -g @time_revamped_evening_color '#[fg=#d3869b]'
set -g @time_revamped_night_color '#[fg=#83a598]'
set -g @time_revamped_weekend_color '#[fg=#a89984]'

# Tokyo Night
set -g @time_revamped_morning_color '#[fg=#e0af68]'
set -g @time_revamped_day_color '#[fg=#9ece6a]'
set -g @time_revamped_afternoon_color '#[fg=#7dcfff]'
set -g @time_revamped_evening_color '#[fg=#bb9af7]'
set -g @time_revamped_night_color '#[fg=#7aa2f7]'
set -g @time_revamped_weekend_color '#[fg=#565f89]'

# Solarized Dark
set -g @time_revamped_morning_color '#[fg=#b58900]'
set -g @time_revamped_day_color '#[fg=#859900]'
set -g @time_revamped_afternoon_color '#[fg=#2aa198]'
set -g @time_revamped_evening_color '#[fg=#d33682]'
set -g @time_revamped_night_color '#[fg=#268bd2]'
set -g @time_revamped_weekend_color '#[fg=#586e75]'
```

</details>

### Internal state

The plugin manages these options itself. Do not set them.

| Option | Holds |
|:-------|:------|
| `@time_revamped_mark_epoch` | unix time of the last stopwatch mark |
| `@time_revamped_published` | the placeholders the status line uses, recorded at load so render mode publishes only those |
| `@time_revamped_out_<name>` | each rendered value in render mode |
| `@time_revamped_ticker_pid` | the process that owns render mode. A reload hands ownership to a new process and the old one exits |
| `@time_revamped_geoip_city` | the last city from geoip, with `_ts` and `_lock` companions for its age and the running request |

## Key bindings

| Key | Option | Action |
|:----|:-------|:-------|
| `prefix + M-t` | `@time_revamped_menu_key` | opens the world clock menu |
| unbound | `@time_revamped_calendar_key` | the calendar popup |
| unbound | `@time_revamped_copy_key` | copies the ISO time |
| unbound | `@time_revamped_mark_key` | sets the stopwatch mark |

The menu has six entries: `h` toggles 12 and 24 hour time, `c` opens the calendar, `i` and `e` copy the time as ISO 8601 or unix seconds to the tmux buffer and the system clipboard, `m` sets the stopwatch mark, and `d` runs `time-revamped doctor`. The default key is left alone when something else already holds it, and `doctor` says so. A key set to `off` binds nothing.

## How it works

[`time-revamped.tmux`](time-revamped.tmux) runs once when tmux loads the plugin. It records which placeholders `status-left` and `status-right` use in `@time_revamped_published`, binds the keys, then replaces each placeholder with a call to [`bin/time-revamped`](bin/time-revamped) or, in `options` mode, with an option read, and starts the background process.

In the default mode each `#()` call reads the clock once and prints it. In `options` mode one background process per server, which claims `@time_revamped_ticker_pid`, renders every placeholder the status line uses, by default once a minute, one second after the minute changes, and writes them in one tmux call, so the clocks change together. It stops when another process claims the option or the server goes away.

Every `date` call runs under the C locale. The clock change and overlap checks run `date` with `-d` on GNU, uutils and BusyBox and with `-r` on BSD, detected once per process. Countdowns, the stopwatch and relative days are integer arithmetic in the shell. The readers, the figures and the binding live in [`lib/time.sh`](lib/time.sh), and the settings table in [`lib/state.sh`](lib/state.sh).

<a id="screens"></a>

## Screens

<details>
<summary>Every screen, recorded inside a real tmux with <code>make screens</code>, with each key on the status line</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="time-revamped: The date, the time and three world clocks, each coloured by the hour"><br><sub>The date, the time and three world clocks, each coloured by the hour, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="time-revamped: prefix M-t opens the world clock menu"><br><sub><code>prefix M-t</code> opens the world clock menu, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/twelve.png" alt="time-revamped: h in the menu switches to 12 hour time"><br><sub><code>h</code> in the menu switches to 12 hour time, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/calendar.png" alt="time-revamped: c in the menu opens the calendar"><br><sub><code>c</code> in the menu opens the calendar, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/copy.png" alt="time-revamped: i in the menu copies the ISO time"><br><sub><code>i</code> in the menu copies the ISO time, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/calendar-key.png" alt="time-revamped: @time_revamped_calendar_key gives the calendar a key of its own"><br><sub><code>@time_revamped_calendar_key</code> gives the calendar a key of its own, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/copy-key.png" alt="time-revamped: @time_revamped_copy_key gives the ISO copy a key of its own"><br><sub><code>@time_revamped_copy_key</code> gives the ISO copy a key of its own, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/mark-key.png" alt="time-revamped: @time_revamped_mark_key sets the stopwatch mark"><br><sub><code>@time_revamped_mark_key</code> sets the stopwatch mark, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/mark.png" alt="time-revamped: #{time_elapsed} counts from the mark"><br><sub><code>#{time_elapsed}</code> counts from the mark, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/options.png" alt="time-revamped: In the options render mode each placeholder reads a tmux option"><br><sub>In the <code>options</code> render mode each placeholder reads a tmux option, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/formats.png" alt="time-revamped: @time_revamped_date_format and @time_revamped_time_format shape the date and the time"><br><sub><code>@time_revamped_date_format</code> and <code>@time_revamped_time_format</code> shape the date and the time, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/hide.png" alt="time-revamped: hide removes the date and the time of #{time_date} and #{time_clock}"><br><sub><code>hide</code> removes the date and the time of <code>#{time_date}</code> and <code>#{time_clock}</code>, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/compact.png" alt="time-revamped: @time_revamped_compact prints short city labels"><br><sub><code>@time_revamped_compact</code> prints short city labels, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/labels.png" alt="time-revamped: @time_revamped_zone_labels and @time_revamped_zone_separator name and separate the clocks"><br><sub><code>@time_revamped_zone_labels</code> and <code>@time_revamped_zone_separator</code> name and separate the clocks, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/periods.png" alt="time-revamped: Night, morning, day, afternoon and evening each have a colour"><br><sub>Night, morning, day, afternoon and evening each have a colour, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/weekend.png" alt="time-revamped: Saturday and Sunday use the weekend colour"><br><sub>Saturday and Sunday use the weekend colour, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/weekend-override.png" alt="time-revamped: @time_revamped_weekend_override set to 0 keeps the time of day colours on the weekend"><br><sub><code>@time_revamped_weekend_override</code> set to <code>0</code> keeps the time of day colours on the weekend, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/colors.png" alt="time-revamped: The period colours take any style, here hex colours"><br><sub>The period colours take any style, here hex colours, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="time-revamped: Each period has an icon option, here one letter each"><br><sub>Each period has an icon option, here one letter each, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/icon-position.png" alt="time-revamped: @time_revamped_icon_position set to before puts the icon first"><br><sub><code>@time_revamped_icon_position</code> set to <code>before</code> puts the icon first, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/relative-day.png" alt="time-revamped: @time_revamped_relative_day adds a +1d badge to a zone on the next day"><br><sub><code>@time_revamped_relative_day</code> adds a <code>+1d</code> badge to a zone on the next day, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/relative-day-back.png" alt="time-revamped: The same badge reads -1d for a zone on the day before"><br><sub>The same badge reads <code>-1d</code> for a zone on the day before, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/work-hours.png" alt="time-revamped: @time_revamped_work_hours dims a zone outside working hours"><br><sub><code>@time_revamped_work_hours</code> dims a zone outside working hours, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/dim-style.png" alt="time-revamped: @time_revamped_work_start, @time_revamped_work_end and @time_revamped_dim_style move the window and change the dimming"><br><sub><code>@time_revamped_work_start</code>, <code>@time_revamped_work_end</code> and <code>@time_revamped_dim_style</code> move the window and change the dimming, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/primary.png" alt="time-revamped: @time_revamped_primary and @time_revamped_primary_style highlight one zone"><br><sub><code>@time_revamped_primary</code> and <code>@time_revamped_primary_style</code> highlight one zone, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/reset.png" alt="time-revamped: @time_revamped_reset is the style written after each entry"><br><sub><code>@time_revamped_reset</code> is the style written after each entry, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/local.png" alt="time-revamped: #{time_local} names the place from TZ"><br><sub><code>#{time_local}</code> names the place from <code>TZ</code>, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/local-label.png" alt="time-revamped: @time_revamped_local_label sets the label itself"><br><sub><code>@time_revamped_local_label</code> sets the label itself, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/geoip.png" alt="time-revamped: @time_revamped_local_source set to geoip asks for the city of your IP"><br><sub><code>@time_revamped_local_source</code> set to <code>geoip</code> asks for the city of your IP, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/countdown.png" alt="time-revamped: #{time_until} counts down to @time_revamped_countdown_target"><br><sub><code>#{time_until}</code> counts down to <code>@time_revamped_countdown_target</code>, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/countdown-done.png" alt="time-revamped: Once the target has passed it shows @time_revamped_countdown_done"><br><sub>Once the target has passed it shows <code>@time_revamped_countdown_done</code>, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/epoch.png" alt="time-revamped: The unix time, the ISO time, the offset, the week and the day of the year"><br><sub>The unix time, the ISO time, the offset, the week and the day of the year, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/dst.png" alt="time-revamped: #{time_dst} warns days before a clock change in @time_revamped_dst_zone"><br><sub><code>#{time_dst}</code> warns days before a clock change in <code>@time_revamped_dst_zone</code>, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/overlap.png" alt="time-revamped: #{time_overlap} prints the working hours every zone shares"><br><sub><code>#{time_overlap}</code> prints the working hours every zone shares, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/overlap-none.png" alt="time-revamped: @time_revamped_overlap_label and @time_revamped_overlap_none word the answer"><br><sub><code>@time_revamped_overlap_label</code> and <code>@time_revamped_overlap_none</code> word the answer, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="time-revamped: The version"><br><sub>The version, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="time-revamped: An unknown command"><br><sub>An unknown command, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="time-revamped: status zones and status iso print one placeholder each"><br><sub><code>status zones</code> and <code>status iso</code> print one placeholder each, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="time-revamped: list prints every binding"><br><sub><code>list</code> prints every binding, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="time-revamped: list --json prints the same plan as one object"><br><sub><code>list --json</code> prints the same plan as one object, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/card.png" alt="time-revamped: card prints every figure"><br><sub><code>card</code> prints every figure, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="time-revamped: doctor"><br><sub><code>doctor</code>, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/toggle-command.png" alt="time-revamped: toggle-format switches to 12 hour time"><br><sub><code>toggle-format</code> switches to 12 hour time, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/copy-command.png" alt="time-revamped: copy epoch copies the unix time"><br><sub><code>copy epoch</code> copies the unix time, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/mark-command.png" alt="time-revamped: mark sets the stopwatch mark"><br><sub><code>mark</code> sets the stopwatch mark, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/calendar-command.png" alt="time-revamped: calendar opens the calendar"><br><sub><code>calendar</code> opens the calendar, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-command.png" alt="time-revamped: menu opens the world clock menu"><br><sub><code>menu</code> opens the world clock menu, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/menu-gum.png" alt="time-revamped: The menu"><br><sub>The menu, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="time-revamped: The card from the menu"><br><sub>The card from the menu, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="time-revamped: An accent from TIME_REVAMPED_ACCENT"><br><sub>An accent from <code>TIME_REVAMPED_ACCENT</code>, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="time-revamped: The menu without gum"><br><sub>The menu without gum, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="time-revamped: doctor from the menu, without gum"><br><sub><code>doctor</code> from the menu, without gum, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="time-revamped: card without gum"><br><sub><code>card</code> without gum, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="time-revamped: The header in six themes"><br><sub>The header in six themes, from <code>themes.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="time-revamped: The help page"><br><sub>The help page, from <code>help.tape</code></sub></td>
<td width="50%"></td>
</tr>
</table>

The recordings run the real plugin and tmux. Small scripts stand in for `date`, `cal`, `curl` and `pbcopy`, so the clock is fixed at Friday 2026-10-16 14:30 UTC, shown in New York, and nothing touches the clipboard.

</details>

## Portability

The plugin is POSIX `sh`. CI runs every suite on each row below.

| Shell | Status |
|:------|:-------|
| `dash`, `/bin/sh` on macOS | Supported |
| `bash` 3.2 and 5.x, the system's `zsh` and Homebrew's | Supported |

| System | Status |
|:-------|:-------|
| macOS | Tahoe on Apple Silicon and Intel, with the tools it ships, Homebrew's GNU tools and Homebrew's uutils |
| Linux | Ubuntu 26.04 on x86_64 and arm64, with GNU coreutils, uutils and BusyBox |

## Development

| Command | What it runs |
|:--------|:-------------|
| `make fmt` | shfmt `-i 2` on every script |
| `make lint` | shfmt, ShellCheck, mandoc, yamllint and actionlint, at zero findings |
| `make test` | The bats suites under the system `sh` |
| `make test-all` | The suites under every installed shell, both builds of bash and zsh on macOS |
| `make test-linux` | The suites in an Ubuntu container |
| `make coverage` | bashcov on this Mac and in the Ubuntu container, merged and gated at 100 percent |
| `make screens` | The screens above, recorded from the real plugin inside tmux with VHS, on macOS |
| `make install` | The command, its man page and completions under `PREFIX` |

On macOS, `brew bundle` installs every tool these targets call, from the [`Brewfile`](Brewfile).

Commits follow the conventional commit format and go straight to `main`. After a green `ci` run on `main`, `release.yml` runs semantic-release: every `feat` or `fix` since the last tag publishes a release, stamps the version constant and adds the notes to [`CHANGELOG.md`](CHANGELOG.md).

## License

[MIT](LICENSE), copyright Gustavo Franco.

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the same contract in [`FAMILY.md`](FAMILY.md) and the same shared library, and they are built to be installed together: no member claims a key or a tmux option that another member claims.

A defect found in one member is hunted across all of them before the fix is called done.

| Member | What it does |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | Edit your tmux config, save, and watch it reload itself, no key, no command |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | Battery status for your tmux status bar, without ever blocking the status render |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | Every connected Bluetooth device and its battery in your tmux status bar, without blocking the render |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | Disk usage for your tmux status bar, without ever blocking the status render |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Pick a URL, path, hash or any other token off the screen with fzf and type it at the cursor, in pure shell |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Switch to, kill, rename or create tmux sessions, windows and panes from fzf pickers in a popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Show the active pane's git branch, changes and provider counts in the tmux status bar without blocking it |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, clock, power and memory in the tmux status bar, from NVIDIA, AMD, Intel and Apple GPUs |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in the tmux status bar, parsed from kubeconfig without kubectl |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Open any terminal app in a tmux popup, window or split from one menu, starting at the project root |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | The starting point for a tmux-revamped plugin: shared library, bats harness and CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab along the tmux status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | **this plugin**, Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits |

<!-- family:end -->

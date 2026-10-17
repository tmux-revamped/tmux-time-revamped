# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- The plugin path is quoted with `printf %q`, with every `#` doubled, in each
  `#()` status call and in the key binding's `run-shell` command, so a plugin
  directory whose path holds a space, a quote or a `#` no longer breaks every
  metric and the binding. Placeholders are spliced by prefix and suffix instead
  of a pattern substitution, which treats a backslash differently in bash 3.2
  and bash 5.
- The menu quotes the plugin path, so its actions run when the plugin is
  installed under a directory whose name contains a space or a single quote.

## [2.0.0] - 2026-10-17

### Added

- `@time_revamped_render 'options'` replaces the `#()` calls with tmux option
  reads, written by one background process per server once a minute, just after the minute changes. tmux reruns a `#()` call on every redraw, so a
  shared bar ran each clock about once a second and painted them one by one.
- `@time_revamped_icon_position`. Set to `before`, each clock leads with its
  time-of-day icon, then the place and the time.

### Changed

- **Breaking:** the actions menu moves from `prefix + T` to `prefix + M-t`, the
  key the family allocation gives this plugin, so `T` goes back to tmux's own
  binding. Set `@time_revamped_menu_key` to `T` to keep the old key. The
  calendar, copy and mark actions stay unbound by default.
- The options-mode background process reads every option it needs in one tmux
  call per tick, sends its cache writes and published values in a second, and
  keeps its functions out of the environment of the commands it runs. Options
  mode wakes once a minute, one second after the minute changes, instead of
  every few seconds.

### Fixed

- The DST warning ran `date --version` once for every day of its horizon on
  every render, fifteen extra processes with the default horizon. The date
  flavor is now detected once per process.
- The calendar popup ran its `read -rsn1 -p` under tmux's default shell, which
  zsh and dash reject, so with either as the default shell the popup closed at
  once or printed an error. The popup now runs its script with bash.
- With `@time_revamped_local_source 'geoip'`, the city from the network
  response reached the status line unfiltered except for `<`, `>` and `{`, so
  a response holding `#(...)` ran a command through tmux. A city is now
  accepted only when it holds letters, digits, spaces, UTF-8 characters and `.
  , ' -`, and any `#` is doubled before tmux sees it.
- In options mode, running the entry point a second time, as two overlapping
  config reloads do, found no placeholders left in the status line and
  published nothing, which froze every value. A metric whose option read is
  already on the status line now counts as used.

## [1.2.0] - 2026-06-30

### Added

- Developer time formats: `#{time_epoch}` (unix seconds), `#{time_iso}`
  (ISO 8601 with a colon in the offset), and `#{time_offset}` (the local UTC
  offset as `UTC+02:00`).
- Calendar fields: `#{time_week}` (ISO 8601 week number) and `#{time_doy}`
  (day of the year).
- `#{time_until}`: a countdown to `@time_revamped_countdown_target`, with an
  optional label and a "done" message once the target passes.
- `#{time_elapsed}`: a stopwatch since the mark stored by the mark action.
- `#{time_dst}`: a "DST in Nd" warning when a zone's UTC offset is about to
  change within `@time_revamped_dst_horizon` days.
- `#{time_overlap}`: the shared working-hours window across the configured
  zones, expressed in the local zone, or a "no overlap" message.
- World-clock decorations: a relative-day badge per zone
  (`@time_revamped_relative_day`), dimming a zone outside working hours
  (`@time_revamped_work_hours` with `@time_revamped_work_start` and
  `@time_revamped_work_end`), and a highlight on the primary zone
  (`@time_revamped_primary`).
- Interactive actions, bound through a mockable seam: a prefix menu
  (`prefix + T`), a calendar popup, copy the timestamp to the tmux buffer and
  the system clipboard, set a stopwatch mark, and a `doctor` report that
  validates the configured timezone names.

All date arithmetic is pure shell, identical on BSD and GNU `date`, and every
clock read sits behind a seam so the work stays non-blocking and the live model
is unchanged.

## [1.1.1] - 2026-06-23

### Changed

- Self-audit for the family hardening pass. Alongside the clock and date, the
  plugin renders additional time zones for distributed teams, and the colors are
  named colors safe under tmux 3.7 format expansion. No code change needed.

## [1.1.0] - 2026-06-20

### Added

- Separate `sunrise` and `sunset` period icons. World-clock icons now use seven
  hour buckets instead of five, so a dawn glyph (`@time_revamped_sunrise_icon`,
  hours 05 to 08) and a dusk glyph (`@time_revamped_sunset_icon`, hours 18 to 20)
  can be configured independently. Color buckets are unchanged, and every icon
  option still defaults to empty.

## [1.0.0] - 2026-06-20

### Added

- Local clock placeholders: `#{time}`, `#{time_date}`, `#{time_clock}`, with
  configurable date and time formats, including a `hide` option for each.
- World clocks via `#{time_zones}`: any number of timezones, each rendered with
  its abbreviation or a compact city label and the local time.
- Time-of-day coloring per timezone: morning, day, afternoon, evening, and night
  buckets, with a weekend override and an optional per-period icon.
- Non-blocking design: the clock is computed live from a single `date` call, with
  no temp files and all configuration in tmux server options.

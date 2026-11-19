# tmux-time-revamped

Guidance for anyone, human or agent, changing tmux-time-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-time-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`time-revamped.tmux`](time-revamped.tmux) | The entry point TPM runs: it runs `bin/time-revamped apply` |
| [`bin/time-revamped`](bin/time-revamped) | The command: `apply`, `list`, `status`, `card`, `menu`, `calendar`, `copy`, `mark`, `toggle-format`, `daemon`, `doctor`, `version`, `help` and the start menu. Every command a key or a status job runs works without loading the interface modules |
| [`lib/time.sh`](lib/time.sh) | Reading the settings, every clock and figure, the colours and icons, the geoip place label, the publisher's tick, the menu, the calendar popup and the binding |
| [`lib/state.sh`](lib/state.sh) | Every global, including `TIME_REVAMPED_SETTINGS`, the table of setting names and defaults, `TIME_REVAMPED_LIVE`, the names of the options that hold state, and `TIME_REVAMPED_KINDS` |
| [`lib/core.sh`](lib/core.sh) | The version |
| [`lib/`](lib) | Every other file is the shared library, identical in every member |
| [`test/values.bats`](test/values.bats), [`test/plan.bats`](test/plan.bats), [`test/commands.bats`](test/commands.bats) | Every figure with each of its options, the binding, both render modes, the daemon and every command, against a stand-in tmux and a stand-in `date` from [`test/time_helpers.bash`](test/time_helpers.bash). The stand-in `date` answers a fixed time through GNU's `-d` or BSD's `-r`, whichever the test asks for, and keeps the real zone database |
| [`test/entrypoint.bats`](test/entrypoint.bats), [`test/keys.bats`](test/keys.bats) | The plugin on a private tmux server, with the menu and every key pressed through a second tmux attached to it, in both render modes; both share [`test/server_helpers.bash`](test/server_helpers.bash), whose stand-in `date` is fixed at 2026-10-16 14:30 UTC |
| [`screens/`](screens) | The tapes and the recording's tmux config. `prepare.sh` copies the plugin to a neutral folder and writes stand-ins for `date`, `curl` and `cal` |

## Names

- Settings are the tmux options `@time_revamped_<setting>` listed in `TIME_REVAMPED_SETTINGS`, the long options with dashes, such as `--zone-labels`, and the environment variables `TIME_REVAMPED_<SETTING>`. `render` and `interval` are read by the daemon and by `apply` only.
- State is `@time_revamped_mark_epoch`, `@time_revamped_geoip_city` with `_ts`, `_lock` and `_lock_ts`, `@time_revamped_published`, `@time_revamped_out_<name>` and `@time_revamped_ticker_pid`. None of them is a setting.
- The placeholders are `#{time}`, `#{time_date}`, `#{time_clock}`, `#{time_zones}`, `#{time_local}`, `#{time_until}`, `#{time_elapsed}`, `#{time_epoch}`, `#{time_iso}`, `#{time_offset}`, `#{time_week}`, `#{time_doy}`, `#{time_dst}` and `#{time_overlap}`; `status` names each one without the `time_`, and `#{time}` is `datetime`.
- The version constant is `TIME_REVAMPED_VERSION`.
- The command's own functions and the library's never share a name, because the command is sourced after the library and would replace it.

## Behaviour

- `apply` reads every setting and the state options with one `tmux display-message` call and one `env` read, reads the prefix table once, and sends the binding and the replaced status strings in one tmux call. When that call fails, it sends each command alone and `apply` exits 1.
- In `jobs` mode each placeholder in `status-left` or `status-right` becomes `#(<tool> status <name>)`, with the tool's path and every carried value quoted for a shell and every `#` and `%` doubled, since tmux reads the status line as a format and as a time format. In `options` mode it becomes `#{E:@time_revamped_out_<name>}`, `apply` starts the daemon, and a status refresh starts no process. A render mode other than `options` means `jobs`. A string already rewritten is not written again, and the names it uses stay in `@time_revamped_published`, so loading twice changes nothing.
- `status` makes one tmux read and prints the value at once. A clock is one `date` call; `#{time_zones}` is one per zone.
- The daemon is the shared ticker: it claims `@time_revamped_ticker_pid`, renders every name in `@time_revamped_published` and publishes them in one tmux call per tick, sleeps until one second after the next minute, or for the seconds `@time_revamped_interval` names, and ends when another process holds the claim or the server is gone. At the ticker's tick cap it starts itself again.
- `M-t` opens the world clock menu: `h` toggles 12 and 24 hour time, `c` opens the calendar, `i` and `e` copy the ISO time or the unix time, `m` sets the stopwatch mark and `d` runs doctor. The calendar, copy and mark keys are bound only when their options name a key. A key set to `off` binds nothing. Only the default key is skipped when someone else holds it, and `doctor` names it; a key the person names is bound whoever holds it.
- A setting `apply` got from the command line or the environment rides, as an option, on every key command and every status call; `TIME_REVAMPED_CARRIED` lists the ones that ride. The daemon inherits the environment of the `apply` that started it.

## Domain rules

- Every `date` call runs under `LC_ALL=C`, so digits, `AM` and `PM` read the same in any locale. A zone is `TZ` for one `date` call.
- The clock change and overlap checks run `date` with `-d @EPOCH` on GNU, uutils and BusyBox and with `-r EPOCH` on BSD, picked once per process by asking `date -d @0 +%s`. The clock change check asks one day at a time up to `@time_revamped_dst_horizon` days and reports the first day whose UTC offset differs from today's. The overlap check makes one `awk` pass over the offsets of every zone.
- Countdowns, the stopwatch and relative days are integer arithmetic in the shell. The countdown target is read as `YYYY-MM-DD`, with `HH:MM` or `HH:MM:SS` after a space or a `T`, in the local zone.
- The period of an hour is night from 22 to 04, morning to 11, day to 13, afternoon to 17 and evening after that, and the weekend replaces it on Saturday and Sunday. The icon periods split morning at 08 and evening at 20 into sunrise, morning, sunset and evening.
- The overlap window is the longest run of UTC hours in which every zone is inside `@time_revamped_work_start` to `@time_revamped_work_end`, wrapping across midnight, printed in the local zone as `HH:00-HH:00`; all 24 hours shared print the same hour twice.
- The local place name is the label setting, else the geoip city when the source is `geoip`, `curl` exists and the city is known, else the city of `TZ` or of the `/etc/localtime` link. A request runs in the background in `jobs` mode and in the daemon's own shell in `options` mode, times out after 3 seconds and keeps the last city when it fails. A city is kept only when it holds at most 64 characters of letters, digits, spaces, UTF-8 characters and `. , ' -`.

## Release

- `TIME_REVAMPED_VERSION` in [`lib/core.sh`](lib/core.sh) holds the version. Nobody edits it by hand.
- After a green `ci` run on `main`, [`release.yml`](.github/workflows/release.yml) runs semantic-release: a `feat` or `fix` since the last tag publishes a release, [`set-version.sh`](.github/scripts/set-version.sh) stamps the constant, and the notes go into [`CHANGELOG.md`](CHANGELOG.md).

## Gaps against FAMILY.md

As of 2026-11-19:

- No `@time_revamped_notify` for the alarm or the next calendar event yet.
- `#{time_dst}` and `#{time_overlap}` ask `date` once per day or once per zone, because BSD `date` takes one epoch per call.

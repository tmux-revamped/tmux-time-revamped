<div align="center">

# tmux-time-revamped

<strong>在 tmux 状态栏显示本地时钟和世界时钟，按时间段着色，并带有倒计时和夏令时提醒。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; 简体中文 &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-time-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-time-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-time-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-time-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-time-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-time-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-time-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速开始"><strong>快速开始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#工作原理">工作原理</a> &nbsp;|&nbsp;
  <a href="#截图">截图</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="time-revamped 显示日期、时间和按小时着色的三个世界时钟，并演示世界时钟菜单、12 小时制、日历、秒表和 options 渲染模式" width="800">
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

**14** 个占位符，**2** 种渲染模式，支持 macOS 和 Linux，需要 tmux **3.2** 或更高版本。

---

## 快速开始

### 前提条件

| 工具 | 版本 | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 或更高 | 家族的最低版本，以及日历弹窗 |
| `date` 与时区数据库 | 系统自带 | 所有时钟，支持 GNU、uutils、BusyBox 和 BSD 的 `date` |
| `cal` | 系统自带 | 日历弹窗 |
| `curl` | 可选 | geoip 地点标签 |
| `pbcopy`、`wl-copy` 或 `xclip` | 可选 | 把时间戳复制到系统剪贴板 |
| gum | 可选 | `time-revamped` 的菜单、表格和颜色；没有它时所有命令输出纯文本 |

它在 Linux 和 macOS 上运行，可使用 BSD、GNU、uutils 或 BusyBox 工具。缺少可选工具时对应功能保持安静，`time-revamped doctor` 会指出它。

### 安装

使用 [TPM](https://github.com/tmux-plugins/tpm)，把插件加入 `~/.tmux.conf`，然后按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-time-revamped'
set -g status-right '#{time} #{time_zones}'
```

手动安装时，克隆仓库并在 `~/.tmux.conf` 中运行入口脚本：

```bash
git clone https://github.com/tmux-revamped/tmux-time-revamped ~/.tmux/plugins/tmux-time-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-time-revamped/time-revamped.tmux
```

请在插件加载之前设置 `status-left` 或 `status-right`。插件在加载时只替换一次它在那里找到的占位符。

在克隆目录中运行 `make install`，还会把 `time-revamped` 放入 `~/.local/bin`，把 man 手册和补全放入 `~/.local/share`。

### 验证

```bash
~/.tmux/plugins/tmux-time-revamped/bin/time-revamped doctor
```

## 用法

本插件把 `status-left` 和 `status-right` 中的占位符替换为本地日期和时间、任意数量的世界时钟，以及一些面向开发和日历的字段。每个世界时钟按当地的钟点着色，一眼就能看出谁在上午、谁在睡觉。

| 占位符 | 输出 |
|:------------|:-------|
| `#{time}` | 本地日期和时间，例如 `2026-10-16 14:30` |
| `#{time_date}` | 仅本地日期 |
| `#{time_clock}` | 仅本地时间 |
| `#{time_zones}` | 每个已配置时区一项，按时段着色 |
| `#{time_local}` | 与世界时钟样式一致的本地时钟，带地点标签 |
| `#{time_until}` | 到目标时间的倒计时，例如 `1d 4h` |
| `#{time_elapsed}` | 自秒表标记以来的时间，例如 `12m` |
| `#{time_epoch}` | Unix 时间，单位为秒 |
| `#{time_iso}` | ISO 8601 格式的本地时间，例如 `2026-10-16T14:30:00-04:00` |
| `#{time_offset}` | 本地 UTC 偏移，例如 `UTC-04:00`，或 `UTC` |
| `#{time_week}` | ISO 8601 周数 |
| `#{time_doy}` | 一年中的第几天 |
| `#{time_dst}` | 时钟调整在范围内时显示 `DST in 3d` |
| `#{time_overlap}` | 所有已配置时区共有的工作时段，以本地时间显示 |

```tmux
set -g @time_revamped_timezones 'America/New_York, Europe/London, Asia/Tokyo'
set -g status-right '#{time} #{time_zones}'
```

本地时钟在纽约时，状态栏右侧显示为：

```text
2026-10-16 14:30 EDT 14:30 BST 19:30 JST 03:30
```

每个世界时钟都有自己的颜色：上午、中午、下午、傍晚、夜间，或周六和周日的周末颜色。

### 世界时钟装饰

| 设置 | 效果 |
|:--------|:-------|
| `@time_revamped_compact '1'` | 用简短城市名代替时区缩写：`America/New_York` 为 `NY`，`Asia/Tokyo` 为 `Tok` |
| `@time_revamped_zone_labels 'NYC, LDN, TYO'` | 自定义标签，按顺序对应各时区 |
| `@time_revamped_relative_day '1'` | 在处于另一个日期的时区旁显示 `+1d` 或 `-1d` 标记 |
| `@time_revamped_work_hours '1'` | 淡化处于 `@time_revamped_work_start` 到 `@time_revamped_work_end` 之外的时区 |
| `@time_revamped_primary '0'` | 以粗体显示该从零开始编号的时区 |

`#{time_overlap}` 求出所有已配置时区工作时间的交集，并以本地时间显示最长的共同时段，例如 `overlap 13:00-17:00`。没有共同时段时，显示标签加上 `@time_revamped_overlap_none`，默认为 `overlap no overlap`。

### 本地地点标签

`#{time_local}` 需要一个地点名称。默认离线地从 `TZ` 或 `/etc/localtime` 链接中取城市名。设置 `@time_revamped_local_source 'geoip'` 后，会改为向 `@time_revamped_geoip_endpoint` 查询你的公网 IP 所在城市。该请求每隔 `@time_revamped_geoip_interval` 分钟在后台运行，3 秒超时，失败时保留上一个城市，并会把你的 IP 发给该端点，因此请仅在可以接受时开启。只接受由字母、数字、空格、UTF-8 字符和 `. , ' -` 组成且不超过 64 个字符的城市名。

### 倒计时、秒表与夏令时

`#{time_until}` 倒数到 `@time_revamped_countdown_target`，格式为 `YYYY-MM-DD` 或 `YYYY-MM-DD HH:MM`。目标过去后显示 `@time_revamped_countdown_done`。`#{time_elapsed}` 从标记操作设置的标记开始计时。`#{time_dst}` 逐日检查 `@time_revamped_dst_zone` 或本地时区在未来 `@time_revamped_dst_horizon` 天内的 UTC 偏移，并报告第一次变化。

### 渲染模式

默认情况下每个占位符都变成一个 `#()` 调用，tmux 每次重绘状态栏都会重新运行它。把 `@time_revamped_render` 设为 `options` 后，每个占位符变成对选项的读取，例如 `#{E:@time_revamped_out_local}`。每个服务器上的一个后台进程默认会在每分钟切换后一秒渲染状态栏用到的全部时钟，每分钟一次，并在一次 tmux 调用中写入，因此所有时钟同时变化。

```tmux
set -g @time_revamped_render 'options'
```

| 命令 | 作用 |
|:--------|:-------------|
| `time-revamped apply` | 立即绑定按键并替换占位符；入口脚本在 tmux 加载插件时运行它 |
| `time-revamped list` | 打印 `apply` 将发送的每条命令，不做任何更改；`--json` 输出一个对象 |
| `time-revamped status NAME` | 打印一个占位符，例如 `zones`、`iso` 或 `until`；状态栏运行它 |
| `time-revamped card` | 立即读取所有数值，每个数值输出一行 |
| `time-revamped menu` | 在当前客户端打开世界时钟菜单 |
| `time-revamped calendar` | 在 tmux 弹窗中打开 `cal`，直到按键才关闭 |
| `time-revamped copy [KIND]` | 把时间按 `iso` 或 `epoch` 复制到 tmux 缓冲区和系统剪贴板 |
| `time-revamped mark` | 设置 `#{time_elapsed}` 开始计时的秒表标记 |
| `time-revamped toggle-format` | 在 12 小时制和 24 小时制之间切换 |
| `time-revamped daemon` | 为 `options` 渲染模式每分钟发布一次占位符；`apply` 会启动它 |
| `time-revamped doctor` | 每个依赖一行，已配置的时区、设置，以及被让开的按键 |
| `time-revamped version` | 版本号，然后是 tmux 版本 |
| `time-revamped help` | 帮助页；`man time-revamped` 说明相同的命令和设置 |
| `time-revamped` | 在终端中是一个菜单 |

## 配置

每个选项也可以用带短横线的命令行选项指定，例如 `--timezones 'Asia/Tokyo'`，也可以用环境变量指定，例如 `TIME_REVAMPED_TIMEZONES`；命令行优先于环境变量，环境变量优先于 tmux 选项。空的 tmux 选项表示使用默认值。`doctor` 会指出持有插件不认识的值的设置。传给 `apply` 的设置会带到每个按键和每次状态调用上。

| 选项 | 默认值 | 含义 |
|:-------|:--------|:--------|
| `@time_revamped_date_format` | `YMD` | `YMD`、`MD`、`DM`、`MDY`、`DMY` 或 `hide` |
| `@time_revamped_time_format` | `24H` | `24H`、`12H` 或 `hide`，作用于本地时钟和所有世界时钟 |
| `@time_revamped_timezones` | 空 | 以逗号或空格分隔的时区名称 |
| `@time_revamped_compact` | `0` | 设为 `1` 使用简短城市名 |
| `@time_revamped_zone_labels` | 空 | 以逗号分隔、按顺序对应各时区的标签 |
| `@time_revamped_zone_separator` | 一个空格 | 世界时钟各项之间的文本 |
| `@time_revamped_weekend_override` | `1` | 设为 `0` 时周末也保留时段颜色和图标 |
| `@time_revamped_local_label` | 空 | `#{time_local}` 的固定标签 |
| `@time_revamped_local_source` | `timezone` | `timezone` 或 `geoip` |
| `@time_revamped_geoip_endpoint` | `https://ipinfo.io/city` | 返回纯文本城市名或带 `city` 字段的 JSON 的 URL |
| `@time_revamped_geoip_interval` | `30` | geoip 请求间隔，单位为分钟 |
| `@time_revamped_morning_color` | `#[fg=yellow]` | 05 点到 12 点 |
| `@time_revamped_day_color` | `#[fg=green]` | 12 点到 14 点 |
| `@time_revamped_afternoon_color` | `#[fg=cyan]` | 14 点到 18 点 |
| `@time_revamped_evening_color` | `#[fg=magenta]` | 18 点到 22 点 |
| `@time_revamped_night_color` | `#[fg=blue]` | 22 点到 05 点 |
| `@time_revamped_weekend_color` | `#[fg=brightblack]` | 周六和周日 |
| `@time_revamped_{sunrise,morning,day,afternoon,sunset,evening,night,weekend}_icon` | 空 | 该时段的图标。sunrise 为 05 点到 08 点，sunset 为 18 点到 20 点 |
| `@time_revamped_icon_position` | `middle` | `middle` 显示为 `NYC <icon> 18:00`，`before` 显示为 `<icon> NYC 18:00` |
| `@time_revamped_reset` | `#[default]` | 每项之后写入的样式。`#[fg=default]` 可保留主题背景 |
| `@time_revamped_relative_day` | `0` | 设为 `1` 时添加 `+1d` 或 `-1d` 标记 |
| `@time_revamped_work_hours` | `0` | 设为 `1` 时淡化工作时间之外的时区 |
| `@time_revamped_work_start` | `9` | 工作开始的钟点，包含在内 |
| `@time_revamped_work_end` | `17` | 工作结束的钟点，不包含在内 |
| `@time_revamped_dim_style` | `#[dim]` | 工作时间之外的时区样式。`none` 表示关闭 |
| `@time_revamped_primary` | 空 | 要突出显示的时区，从零开始编号 |
| `@time_revamped_primary_style` | `#[bold]` | 主时区的样式。`none` 表示关闭 |
| `@time_revamped_countdown_target` | 空 | `#{time_until}` 的目标时间 |
| `@time_revamped_countdown_label` | 空 | 倒计时前的文本 |
| `@time_revamped_countdown_done` | `now` | 目标过去后显示的文本 |
| `@time_revamped_dst_zone` | 空 | `#{time_dst}` 监视的时区。空表示本地时区 |
| `@time_revamped_dst_horizon` | `14` | 向前查找时钟调整的天数 |
| `@time_revamped_dst_label` | `DST` | 天数前的文本 |
| `@time_revamped_overlap_label` | `overlap` | 重叠时段前的文本 |
| `@time_revamped_overlap_none` | `no overlap` | 没有共同时段时的文本 |
| `@time_revamped_render` | `jobs` | `options` 开启渲染模式；其他任何值都表示 `jobs` |
| `@time_revamped_interval` | `minute` | 渲染模式的节奏：`minute` 或秒数。其他值依次回退到 `status-interval`，再到 5 秒 |
| `@time_revamped_menu_key` | `M-t` | 打开操作菜单的前缀键。`off` 表示不绑定 |
| `@time_revamped_calendar_key` | `off` | 日历弹出窗口的前缀键 |
| `@time_revamped_copy_key` | `off` | 复制 ISO 时间戳的前缀键 |
| `@time_revamped_mark_key` | `off` | 设置秒表标记的前缀键 |

颜色使用 16 种 ANSI 名称，因此会跟随终端主题。若要固定确切色调，把颜色选项设为十六进制值。

<details>
<summary><strong>六个主题的十六进制颜色</strong></summary>

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

### 内部状态

这些选项由插件自行管理，请勿设置。

| 选项 | 保存内容 |
|:-------|:------|
| `@time_revamped_mark_epoch` | 最后一次秒表标记的 Unix 时间 |
| `@time_revamped_published` | 状态栏用到的占位符，在加载时记录，使渲染模式只发布这些 |
| `@time_revamped_out_<name>` | 渲染模式下渲染出的每个值 |
| `@time_revamped_ticker_pid` | 负责渲染模式的进程。重新加载会把所有权交给新进程，旧进程随即退出 |
| `@time_revamped_geoip_city` | geoip 得到的最后一个城市，并带有表示其时效和进行中请求的 `_ts` 与 `_lock` |

## 快捷键

| 按键 | 选项 | 动作 |
|:----|:-------|:-------|
| `prefix + M-t` | `@time_revamped_menu_key` | 打开世界时钟菜单 |
| 未绑定 | `@time_revamped_calendar_key` | 日历弹窗 |
| 未绑定 | `@time_revamped_copy_key` | 复制 ISO 时间 |
| 未绑定 | `@time_revamped_mark_key` | 设置秒表标记 |

菜单有六项：`h` 切换 12 小时制和 24 小时制，`c` 打开日历，`i` 和 `e` 把时间按 ISO 8601 或 Unix 秒复制到 tmux 缓冲区和系统剪贴板，`m` 设置秒表标记，`d` 运行 `time-revamped doctor`。默认按键如果已被其他绑定占用就保持不动，`doctor` 会指出。设为 `off` 的按键不绑定任何东西。

## 工作原理

[`time-revamped.tmux`](time-revamped.tmux) 在 tmux 加载插件时运行一次。它把 `status-left` 和 `status-right` 使用的占位符记录到 `@time_revamped_published`，绑定按键，然后把每个占位符替换为对 [`bin/time-revamped`](bin/time-revamped) 的调用，在 `options` 模式下则替换为选项读取，并启动后台进程。

默认模式下，每次 `#()` 调用读取一次时钟并输出。`options` 模式下，每个服务器一个后台进程占用 `@time_revamped_ticker_pid`，默认每分钟、在分钟变化一秒之后渲染状态栏用到的全部占位符，并通过一次 tmux 调用写入，所以各时钟同时变化。当另一个进程占用该选项或服务器退出时，它停止。

每次 `date` 调用都在 C 区域设置下运行。夏令时和重叠检查在 GNU、uutils 和 BusyBox 上用 `-d` 运行 `date`，在 BSD 上用 `-r`，每个进程检测一次。倒计时、秒表和相对日期是 shell 中的整数运算。读取、数值和按键绑定在 [`lib/time.sh`](lib/time.sh) 中，设置表在 [`lib/state.sh`](lib/state.sh) 中。

<a id="截图"></a>

## 截图

<details>
<summary>全部截图，在真实的 tmux 中用 <code>make screens</code> 录制，每个按键都显示在状态栏上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="time-revamped: 日期、时间和三个世界时钟，按小时着色"><br><sub>日期、时间和三个世界时钟，按小时着色（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="time-revamped: prefix M-t 打开世界时钟菜单"><br><sub><code>prefix M-t</code> 打开世界时钟菜单（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/twelve.png" alt="time-revamped: 菜单中的 h 切换到 12 小时制"><br><sub>菜单中的 <code>h</code> 切换到 12 小时制（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/calendar.png" alt="time-revamped: 菜单中的 c 打开日历"><br><sub>菜单中的 <code>c</code> 打开日历（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/copy.png" alt="time-revamped: 菜单中的 i 复制 ISO 时间"><br><sub>菜单中的 <code>i</code> 复制 ISO 时间（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/calendar-key.png" alt="time-revamped: @time_revamped_calendar_key 为日历指定专用按键"><br><sub><code>@time_revamped_calendar_key</code> 为日历指定专用按键（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/copy-key.png" alt="time-revamped: @time_revamped_copy_key 为复制 ISO 时间指定专用按键"><br><sub><code>@time_revamped_copy_key</code> 为复制 ISO 时间指定专用按键（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/mark-key.png" alt="time-revamped: @time_revamped_mark_key 设置秒表标记"><br><sub><code>@time_revamped_mark_key</code> 设置秒表标记（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/mark.png" alt="time-revamped: #{time_elapsed} 从标记开始计时"><br><sub><code>#{time_elapsed}</code> 从标记开始计时（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/options.png" alt="time-revamped: 在 options 渲染模式下，每个占位符读取一个 tmux 选项"><br><sub>在 <code>options</code> 渲染模式下，每个占位符读取一个 tmux 选项（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/formats.png" alt="time-revamped: @time_revamped_date_format 和 @time_revamped_time_format 决定日期和时间的格式"><br><sub><code>@time_revamped_date_format</code> 和 <code>@time_revamped_time_format</code> 决定日期和时间的格式（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/hide.png" alt="time-revamped: hide 去掉 #{time_date} 和 #{time_clock} 的日期和时间"><br><sub><code>hide</code> 去掉 <code>#{time_date}</code> 和 <code>#{time_clock}</code> 的日期和时间（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/compact.png" alt="time-revamped: @time_revamped_compact 输出简短的城市标签"><br><sub><code>@time_revamped_compact</code> 输出简短的城市标签（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/labels.png" alt="time-revamped: @time_revamped_zone_labels 和 @time_revamped_zone_separator 为时钟命名并分隔"><br><sub><code>@time_revamped_zone_labels</code> 和 <code>@time_revamped_zone_separator</code> 为时钟命名并分隔（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/periods.png" alt="time-revamped: 夜晚、早晨、白天、下午和傍晚各有一种颜色"><br><sub>夜晚、早晨、白天、下午和傍晚各有一种颜色（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/weekend.png" alt="time-revamped: 星期六和星期日使用周末颜色"><br><sub>星期六和星期日使用周末颜色（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/weekend-override.png" alt="time-revamped: @time_revamped_weekend_override 设为 0 时，周末仍使用时间段颜色"><br><sub><code>@time_revamped_weekend_override</code> 设为 <code>0</code> 时，周末仍使用时间段颜色（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/colors.png" alt="time-revamped: 各时间段的颜色可使用任意样式，这里是十六进制颜色"><br><sub>各时间段的颜色可使用任意样式，这里是十六进制颜色（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="time-revamped: 每个时间段都有图标选项，这里各用一个字母"><br><sub>每个时间段都有图标选项，这里各用一个字母（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/icon-position.png" alt="time-revamped: @time_revamped_icon_position 设为 before 时，图标放在最前面"><br><sub><code>@time_revamped_icon_position</code> 设为 <code>before</code> 时，图标放在最前面（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/relative-day.png" alt="time-revamped: @time_revamped_relative_day 为处于次日的时区加上 +1d 标记"><br><sub><code>@time_revamped_relative_day</code> 为处于次日的时区加上 <code>+1d</code> 标记（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/relative-day-back.png" alt="time-revamped: 前一天的时区上，同一标记显示为 -1d"><br><sub>前一天的时区上，同一标记显示为 <code>-1d</code>（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/work-hours.png" alt="time-revamped: @time_revamped_work_hours 让工作时间之外的时区变暗"><br><sub><code>@time_revamped_work_hours</code> 让工作时间之外的时区变暗（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/dim-style.png" alt="time-revamped: @time_revamped_work_start、@time_revamped_work_end 和 @time_revamped_dim_style 调整时段和变暗样式"><br><sub><code>@time_revamped_work_start</code>、<code>@time_revamped_work_end</code> 和 <code>@time_revamped_dim_style</code> 调整时段和变暗样式（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/primary.png" alt="time-revamped: @time_revamped_primary 和 @time_revamped_primary_style 突出显示一个时区"><br><sub><code>@time_revamped_primary</code> 和 <code>@time_revamped_primary_style</code> 突出显示一个时区（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/reset.png" alt="time-revamped: @time_revamped_reset 是写在每一项之后的样式"><br><sub><code>@time_revamped_reset</code> 是写在每一项之后的样式（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/local.png" alt="time-revamped: #{time_local} 根据 TZ 命名地点"><br><sub><code>#{time_local}</code> 根据 <code>TZ</code> 命名地点（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/local-label.png" alt="time-revamped: @time_revamped_local_label 直接设定标签"><br><sub><code>@time_revamped_local_label</code> 直接设定标签（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/geoip.png" alt="time-revamped: @time_revamped_local_source 设为 geoip 时，查询你 IP 所在的城市"><br><sub><code>@time_revamped_local_source</code> 设为 <code>geoip</code> 时，查询你 IP 所在的城市（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/countdown.png" alt="time-revamped: #{time_until} 倒数到 @time_revamped_countdown_target"><br><sub><code>#{time_until}</code> 倒数到 <code>@time_revamped_countdown_target</code>（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/countdown-done.png" alt="time-revamped: 目标时间一过，就显示 @time_revamped_countdown_done"><br><sub>目标时间一过，就显示 <code>@time_revamped_countdown_done</code>（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/epoch.png" alt="time-revamped: Unix 时间、ISO 时间、偏移、周数和一年中的第几天"><br><sub>Unix 时间、ISO 时间、偏移、周数和一年中的第几天（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/dst.png" alt="time-revamped: #{time_dst} 在 @time_revamped_dst_zone 的时钟调整前几天发出提醒"><br><sub><code>#{time_dst}</code> 在 <code>@time_revamped_dst_zone</code> 的时钟调整前几天发出提醒（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/overlap.png" alt="time-revamped: #{time_overlap} 输出所有时区共有的工作时段"><br><sub><code>#{time_overlap}</code> 输出所有时区共有的工作时段（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/overlap-none.png" alt="time-revamped: @time_revamped_overlap_label 和 @time_revamped_overlap_none 决定显示的措辞"><br><sub><code>@time_revamped_overlap_label</code> 和 <code>@time_revamped_overlap_none</code> 决定显示的措辞（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="time-revamped: 版本号"><br><sub>版本号（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="time-revamped: 未知命令"><br><sub>未知命令（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="time-revamped: status zones 和 status iso 各输出一个占位符"><br><sub><code>status zones</code> 和 <code>status iso</code> 各输出一个占位符（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="time-revamped: list 打印所有绑定"><br><sub><code>list</code> 打印所有绑定（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="time-revamped: list --json 把同一份计划输出为一个对象"><br><sub><code>list --json</code> 把同一份计划输出为一个对象（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/card.png" alt="time-revamped: card 打印所有数值"><br><sub><code>card</code> 打印所有数值（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="time-revamped: doctor"><br><sub><code>doctor</code>（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/toggle-command.png" alt="time-revamped: toggle-format 切换到 12 小时制"><br><sub><code>toggle-format</code> 切换到 12 小时制（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/copy-command.png" alt="time-revamped: copy epoch 复制 Unix 时间"><br><sub><code>copy epoch</code> 复制 Unix 时间（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/mark-command.png" alt="time-revamped: mark 设置秒表标记"><br><sub><code>mark</code> 设置秒表标记（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/calendar-command.png" alt="time-revamped: calendar 打开日历"><br><sub><code>calendar</code> 打开日历（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-command.png" alt="time-revamped: menu 打开世界时钟菜单"><br><sub><code>menu</code> 打开世界时钟菜单（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/menu-gum.png" alt="time-revamped: 菜单"><br><sub>菜单（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="time-revamped: 从菜单打开的卡片"><br><sub>从菜单打开的卡片（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="time-revamped: 来自 TIME_REVAMPED_ACCENT 的强调色"><br><sub>来自 <code>TIME_REVAMPED_ACCENT</code> 的强调色（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="time-revamped: 没有 gum 的菜单"><br><sub>没有 gum 的菜单（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="time-revamped: 没有 gum 时，从菜单运行的 doctor"><br><sub>没有 gum 时，从菜单运行的 <code>doctor</code>（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="time-revamped: 没有 gum 的 card"><br><sub>没有 gum 的 <code>card</code>（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="time-revamped: 六个主题下的标题"><br><sub>六个主题下的标题（<code>themes.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="time-revamped: 帮助页"><br><sub>帮助页（<code>help.tape</code>）</sub></td>
<td width="50%"></td>
</tr>
</table>

录制运行真实的插件和 tmux。`date`、`cal`、`curl` 和 `pbcopy` 由小脚本代替，所以时钟固定在 2026-10-16 星期五 14:30 UTC，以纽约时间显示，并且不会碰剪贴板。

</details>

## 可移植性

本插件是 POSIX `sh`。CI 在下面每一行上运行全部测试套件。

| Shell | 状态 |
|:------|:-------|
| `dash`、macOS 上的 `/bin/sh` | 支持 |
| `bash` 3.2 和 5.x、系统自带的 `zsh` 和 Homebrew 的 `zsh` | 支持 |

| 系统 | 状态 |
|:-------|:-------|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用系统自带工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 开发

| 命令 | 运行内容 |
|:--------|:-------------|
| `make fmt` | 对每个脚本运行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零问题 |
| `make test` | 在系统 `sh` 下运行 bats 测试套件 |
| `make test-all` | 在每个已安装的 shell 下运行测试套件，macOS 上包括两种 bash 和 zsh |
| `make test-linux` | 在 Ubuntu 容器中运行测试套件 |
| `make coverage` | 在本机 Mac 和 Ubuntu 容器中运行 bashcov，合并后要求 100% |
| `make screens` | 上面的截图，在 macOS 上用 VHS 从真实插件在 tmux 内录制 |
| `make install` | 把命令、man 手册和补全安装到 `PREFIX` |

在 macOS 上，`brew bundle` 会按 [`Brewfile`](Brewfile) 安装这些目标用到的全部工具。

提交遵循 Conventional Commits 格式，直接推送到 `main`。`main` 上的 `ci` 通过后，`release.yml` 运行 semantic-release：自上一个标签以来的每个 `feat` 或 `fix` 都会发布一个版本、写入版本常量，并把说明加入 [`CHANGELOG.md`](CHANGELOG.md)。

## 许可证

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

这个插件是 tmux-revamped 插件家族的一员。每个成员都带有 [`FAMILY.md`](FAMILY.md) 中相同的约定和相同的共享库，并且设计为一起安装：没有成员占用另一个成员占用的按键或 tmux 选项。

在一个成员中发现的缺陷，要在全部成员中排查之后才算修复完成。

| 成员 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 编辑并保存 tmux 配置后，它会自动重新加载，无需按键，也无需命令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 状态栏显示电池状态，从不阻塞状态栏渲染 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 状态栏显示每个已连接的蓝牙设备及其电量，不阻塞渲染 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 状态栏显示 CPU 负载、温度和频率，从不阻塞渲染 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 状态栏显示磁盘用量，从不阻塞状态栏渲染 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 从屏幕上挑选 URL、路径、哈希或任意其他词元，并输入到光标处，全部用纯 shell 实现 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在弹出窗口中的 fzf 选择器里切换、关闭、重命名或创建 tmux 会话、窗口和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 状态栏中显示活动窗格的 git 分支、改动和托管平台计数，且不阻塞渲染 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 状态栏中显示 NVIDIA、AMD、Intel 和 Apple GPU 的负载、温度、频率、功耗和显存 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 状态栏中显示当前的 Kubernetes 上下文和命名空间，不依赖 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在弹出窗口或新窗口中启动任意 TUI 应用，从当前窗格的目录开始，每个应用可配置一个按键 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 将任意窗格保存到文件：实时日志、完整回滚缓冲区或一次性截图 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 状态栏显示正在播放的曲目，从不阻塞状态栏渲染 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 状态栏显示网络吞吐量，从不阻塞渲染 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和窗口管理按键，适配 tmux 版本，兼容 vim，每个 prefix 按键都可禁用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 保存 tmux 的所有会话、窗口和窗格，按定时器自动保存，并在重启后全部恢复 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起点：共享库、bats 测试框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用鼠标在 tmux 状态栏上拖动窗口标签来移动该窗口 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 将鼠标滚轮交给能自行滚动的应用，其他情况下进入 tmux 复制模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和终端区分的合理默认设置，不改动你自己设置的选项 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平铺窗口管理：八种布局，包括 BSP dwindle 和 spiral，并支持撤销布局 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | **本插件**，状态栏中的本地时钟和世界时钟，按一天中的时段着色，并提供倒计时和夏令时提醒 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在后台从 wttr.in 获取天气并显示在状态栏，状态栏无需等待 |

<!-- family:end -->

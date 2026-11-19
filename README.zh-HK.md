<div align="center">

# tmux-time-revamped

<strong>在 tmux 狀態列顯示本地時鐘和世界時鐘，按時段着色，並設有倒數和夏令時間提示。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; 繁體中文（香港）

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-time-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-time-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-time-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-time-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-time-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-time-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-time-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速開始"><strong>快速開始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#運作原理">運作原理</a> &nbsp;|&nbsp;
  <a href="#截圖">截圖</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="time-revamped 顯示日期、時間和按小時着色的三個世界時鐘，並示範世界時鐘選單、12 小時制、日曆、秒錶和 options 渲染模式" width="800">
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

**14** 個佔位符，**2** 種渲染模式，支援 macOS 和 Linux，需要 tmux **3.2** 或更高版本。

---

## 快速開始

### 前提條件

| 工具 | 版本 | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 或更高 | 家族的最低版本，以及日曆彈出視窗 |
| `date` 與時區資料庫 | 系統內置 | 所有時鐘，支援 GNU、uutils、BusyBox 和 BSD 的 `date` |
| `cal` | 系統內置 | 日曆彈出視窗 |
| `curl` | 選用 | geoip 地點標籤 |
| `pbcopy`、`wl-copy` 或 `xclip` | 選用 | 把時間戳複製到系統剪貼簿 |
| gum | 選用 | `time-revamped` 的選單、表格和顏色；沒有它時所有指令輸出純文字 |

它在 Linux 和 macOS 上運行，可使用 BSD、GNU、uutils 或 BusyBox 工具。缺少選用工具時，對應功能保持靜默，`time-revamped doctor` 會指出它。

### 安裝

使用 [TPM](https://github.com/tmux-plugins/tpm)，把插件加入 `~/.tmux.conf`，然後按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-time-revamped'
set -g status-right '#{time} #{time_zones}'
```

手動安裝時，複製儲存庫並在 `~/.tmux.conf` 中執行入口腳本：

```bash
git clone https://github.com/tmux-revamped/tmux-time-revamped ~/.tmux/plugins/tmux-time-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-time-revamped/time-revamped.tmux
```

請在插件載入之前設定 `status-left` 或 `status-right`。插件在載入時只取代一次它在那裏找到的佔位符。

在複製的目錄中執行 `make install`，還會把 `time-revamped` 放入 `~/.local/bin`，把 man 手冊和補全放入 `~/.local/share`。

### 驗證

```bash
~/.tmux/plugins/tmux-time-revamped/bin/time-revamped doctor
```

## 用法

本插件把 `status-left` 和 `status-right` 中的佔位符取代為本地日期和時間、任何數量的世界時鐘，以及一些開發和日曆用的欄位。每個世界時鐘按當地的鐘點著色，一眼便看出誰在早上、誰在睡覺。

| 佔位符 | 輸出 |
|:------------|:-------|
| `#{time}` | 本地日期和時間，例如 `2026-10-16 14:30` |
| `#{time_date}` | 只有本地日期 |
| `#{time_clock}` | 只有本地時間 |
| `#{time_zones}` | 每個已設定時區一項，按時段著色 |
| `#{time_local}` | 與世界時鐘樣式一致的本地時鐘，附地點標籤 |
| `#{time_until}` | 到目標時間的倒數，例如 `1d 4h` |
| `#{time_elapsed}` | 自秒錶標記以來的時間，例如 `12m` |
| `#{time_epoch}` | Unix 時間，以秒為單位 |
| `#{time_iso}` | ISO 8601 格式的本地時間，例如 `2026-10-16T14:30:00-04:00` |
| `#{time_offset}` | 本地 UTC 偏移，例如 `UTC-04:00`，或 `UTC` |
| `#{time_week}` | ISO 8601 週數 |
| `#{time_doy}` | 一年中的第幾天 |
| `#{time_dst}` | 時鐘調整在範圍內時顯示 `DST in 3d` |
| `#{time_overlap}` | 所有已設定時區共有的工作時段，以本地時間顯示 |

```tmux
set -g @time_revamped_timezones 'America/New_York, Europe/London, Asia/Tokyo'
set -g status-right '#{time} #{time_zones}'
```

本地時鐘在紐約時，狀態列右方顯示為：

```text
2026-10-16 14:30 EDT 14:30 BST 19:30 JST 03:30
```

每個世界時鐘都有自己的顏色：早上、中午、下午、傍晚、夜間，或星期六和星期日的週末顏色。

### 世界時鐘裝飾

| 設定 | 效果 |
|:--------|:-------|
| `@time_revamped_compact '1'` | 以簡短城市名代替時區縮寫：`America/New_York` 為 `NY`，`Asia/Tokyo` 為 `Tok` |
| `@time_revamped_zone_labels 'NYC, LDN, TYO'` | 自訂標籤，按次序對應各時區 |
| `@time_revamped_relative_day '1'` | 在處於另一個日期的時區旁顯示 `+1d` 或 `-1d` 標記 |
| `@time_revamped_work_hours '1'` | 淡化處於 `@time_revamped_work_start` 至 `@time_revamped_work_end` 以外的時區 |
| `@time_revamped_primary '0'` | 以粗體顯示該由零開始編號的時區 |

`#{time_overlap}` 求出所有已設定時區工作時間的交集，並以本地時間顯示最長的共同時段，例如 `overlap 13:00-17:00`。沒有共同時段時，顯示標籤加上 `@time_revamped_overlap_none`，預設為 `overlap no overlap`。

### 本地地點標籤

`#{time_local}` 需要一個地點名稱。預設以離線方式從 `TZ` 或 `/etc/localtime` 連結取得城市名。設定 `@time_revamped_local_source 'geoip'` 後，會改為向 `@time_revamped_geoip_endpoint` 查詢你的公共 IP 所在城市。該請求每隔 `@time_revamped_geoip_interval` 分鐘在背景執行，3 秒逾時，失敗時保留上一個城市，並會把你的 IP 傳送給該端點，所以請只在可以接受時開啟。只接受由字母、數字、空格、UTF-8 字符和 `. , ' -` 組成而不超過 64 個字符的城市名。

### 倒數、秒錶與夏令時間

`#{time_until}` 倒數至 `@time_revamped_countdown_target`，格式為 `YYYY-MM-DD` 或 `YYYY-MM-DD HH:MM`。目標過去後顯示 `@time_revamped_countdown_done`。`#{time_elapsed}` 由標記操作設定的標記開始計時。`#{time_dst}` 逐日檢查 `@time_revamped_dst_zone` 或本地時區在未來 `@time_revamped_dst_horizon` 天內的 UTC 偏移，並報告第一次變化。

### 渲染模式

預設情況下每個佔位符都變成一個 `#()` 呼叫，tmux 每次重繪狀態列都會重新執行它。把 `@time_revamped_render` 設為 `options` 後，每個佔位符變成對選項的讀取，例如 `#{E:@time_revamped_out_local}`。每部伺服器上的一個背景進程預設會在每分鐘轉換後一秒繪製狀態列用到的所有時鐘，每分鐘一次，並以一次 tmux 呼叫寫入，因此所有時鐘同時轉變。

```tmux
set -g @time_revamped_render 'options'
```

| 指令 | 作用 |
|:--------|:-------------|
| `time-revamped apply` | 立即綁定按鍵並取代佔位符；入口腳本在 tmux 載入插件時執行它 |
| `time-revamped list` | 列出 `apply` 會發送的每條指令，不作任何更改；`--json` 輸出一個物件 |
| `time-revamped status NAME` | 輸出一個佔位符，例如 `zones`、`iso` 或 `until`；狀態列執行它 |
| `time-revamped card` | 立即讀取所有數值，每個數值輸出一行 |
| `time-revamped menu` | 在目前的客戶端開啟世界時鐘選單 |
| `time-revamped calendar` | 在 tmux 彈出視窗中開啟 `cal`，直至按鍵才關閉 |
| `time-revamped copy [KIND]` | 把時間按 `iso` 或 `epoch` 複製到 tmux 緩衝區和系統剪貼簿 |
| `time-revamped mark` | 設定 `#{time_elapsed}` 開始計時的秒錶標記 |
| `time-revamped toggle-format` | 在 12 小時制和 24 小時制之間切換 |
| `time-revamped daemon` | 為 `options` 渲染模式每分鐘發佈一次佔位符；`apply` 會啟動它 |
| `time-revamped doctor` | 每個依賴一行，已設定的時區、設定，以及被讓開的按鍵 |
| `time-revamped version` | 版本號，然後是 tmux 版本 |
| `time-revamped help` | 說明頁；`man time-revamped` 說明相同的指令和設定 |
| `time-revamped` | 在終端機中是一個選單 |

## 設定

每個選項也可以用帶短橫線的指令選項指定，例如 `--timezones 'Asia/Tokyo'`，也可以用環境變數指定，例如 `TIME_REVAMPED_TIMEZONES`；指令列優先於環境變數，環境變數優先於 tmux 選項。空的 tmux 選項表示使用預設值。`doctor` 會指出持有插件不認識的值的設定。傳給 `apply` 的設定會帶到每個按鍵和每次狀態呼叫上。

| 選項 | 預設值 | 意思 |
|:-------|:--------|:--------|
| `@time_revamped_date_format` | `YMD` | `YMD`、`MD`、`DM`、`MDY`、`DMY` 或 `hide` |
| `@time_revamped_time_format` | `24H` | `24H`、`12H` 或 `hide`，適用於本地時鐘和所有世界時鐘 |
| `@time_revamped_timezones` | 空 | 以逗號或空格分隔的時區名稱 |
| `@time_revamped_compact` | `0` | 設為 `1` 使用簡短城市名 |
| `@time_revamped_zone_labels` | 空 | 以逗號分隔、按次序對應各時區的標籤 |
| `@time_revamped_zone_separator` | 一個空格 | 世界時鐘各項之間的文字 |
| `@time_revamped_weekend_override` | `1` | 設為 `0` 時週末也保留時段顏色和圖示 |
| `@time_revamped_local_label` | 空 | `#{time_local}` 的固定標籤 |
| `@time_revamped_local_source` | `timezone` | `timezone` 或 `geoip` |
| `@time_revamped_geoip_endpoint` | `https://ipinfo.io/city` | 傳回純文字城市名或附 `city` 欄位的 JSON 的 URL |
| `@time_revamped_geoip_interval` | `30` | geoip 請求的間隔，以分鐘計 |
| `@time_revamped_morning_color` | `#[fg=yellow]` | 05 時至 12 時 |
| `@time_revamped_day_color` | `#[fg=green]` | 12 時至 14 時 |
| `@time_revamped_afternoon_color` | `#[fg=cyan]` | 14 時至 18 時 |
| `@time_revamped_evening_color` | `#[fg=magenta]` | 18 時至 22 時 |
| `@time_revamped_night_color` | `#[fg=blue]` | 22 時至 05 時 |
| `@time_revamped_weekend_color` | `#[fg=brightblack]` | 星期六和星期日 |
| `@time_revamped_{sunrise,morning,day,afternoon,sunset,evening,night,weekend}_icon` | 空 | 該時段的圖示。sunrise 為 05 時至 08 時，sunset 為 18 時至 20 時 |
| `@time_revamped_icon_position` | `middle` | `middle` 顯示為 `NYC <icon> 18:00`，`before` 顯示為 `<icon> NYC 18:00` |
| `@time_revamped_reset` | `#[default]` | 每項之後寫入的樣式。`#[fg=default]` 可保留主題背景 |
| `@time_revamped_relative_day` | `0` | 設為 `1` 時加上 `+1d` 或 `-1d` 標記 |
| `@time_revamped_work_hours` | `0` | 設為 `1` 時淡化工作時間以外的時區 |
| `@time_revamped_work_start` | `9` | 工作開始的鐘點，包括在內 |
| `@time_revamped_work_end` | `17` | 工作結束的鐘點，不包括在內 |
| `@time_revamped_dim_style` | `#[dim]` | 工作時間以外的時區樣式。`none` 表示關閉 |
| `@time_revamped_primary` | 空 | 要突顯的時區，由零開始編號 |
| `@time_revamped_primary_style` | `#[bold]` | 主時區的樣式。`none` 表示關閉 |
| `@time_revamped_countdown_target` | 空 | `#{time_until}` 的目標時間 |
| `@time_revamped_countdown_label` | 空 | 倒數前的文字 |
| `@time_revamped_countdown_done` | `now` | 目標過去後顯示的文字 |
| `@time_revamped_dst_zone` | 空 | `#{time_dst}` 監察的時區。空表示本地時區 |
| `@time_revamped_dst_horizon` | `14` | 向前尋找時鐘調整的天數 |
| `@time_revamped_dst_label` | `DST` | 天數前的文字 |
| `@time_revamped_overlap_label` | `overlap` | 重疊時段前的文字 |
| `@time_revamped_overlap_none` | `no overlap` | 沒有共同時段時的文字 |
| `@time_revamped_render` | `jobs` | `options` 開啟渲染模式；其他任何值都表示 `jobs` |
| `@time_revamped_interval` | `minute` | 渲染模式的節奏：`minute` 或秒數。其他值依次退回 `status-interval`，再退回 5 秒 |
| `@time_revamped_menu_key` | `M-t` | 開啟操作選單的前綴鍵。`off` 表示不綁定 |
| `@time_revamped_calendar_key` | `off` | 日曆彈出視窗的前綴鍵 |
| `@time_revamped_copy_key` | `off` | 複製 ISO 時間戳記的前綴鍵 |
| `@time_revamped_mark_key` | `off` | 設定秒錶標記的前綴鍵 |

顏色使用 16 種 ANSI 名稱，因此會跟隨終端機主題。如要固定確切色調，把顏色選項設為十六進制值。

<details>
<summary><strong>六個主題的十六進制顏色</strong></summary>

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

### 內部狀態

這些選項由插件自行管理，請勿設定。

| 選項 | 保存內容 |
|:-------|:------|
| `@time_revamped_mark_epoch` | 最後一次秒錶標記的 Unix 時間 |
| `@time_revamped_published` | 狀態列用到的佔位符，在載入時記錄，令渲染模式只發佈這些 |
| `@time_revamped_out_<name>` | 渲染模式下繪製出的每個值 |
| `@time_revamped_ticker_pid` | 負責渲染模式的進程。重新載入會把擁有權交給新進程，舊進程隨即結束 |
| `@time_revamped_geoip_city` | geoip 取得的最後一個城市，並附有表示其時效和進行中請求的 `_ts` 與 `_lock` |

## 快捷鍵

| 按鍵 | 選項 | 動作 |
|:----|:-------|:-------|
| `prefix + M-t` | `@time_revamped_menu_key` | 開啟世界時鐘選單 |
| 未綁定 | `@time_revamped_calendar_key` | 日曆彈出視窗 |
| 未綁定 | `@time_revamped_copy_key` | 複製 ISO 時間 |
| 未綁定 | `@time_revamped_mark_key` | 設定秒錶標記 |

選單有六項：`h` 切換 12 小時制和 24 小時制，`c` 開啟日曆，`i` 和 `e` 把時間按 ISO 8601 或 Unix 秒複製到 tmux 緩衝區和系統剪貼簿，`m` 設定秒錶標記，`d` 執行 `time-revamped doctor`。預設按鍵如果已被其他綁定佔用就保持不動，`doctor` 會指出。設為 `off` 的按鍵不綁定任何東西。

## 運作原理

[`time-revamped.tmux`](time-revamped.tmux) 在 tmux 載入插件時執行一次。它把 `status-left` 和 `status-right` 使用的佔位符記錄到 `@time_revamped_published`，綁定按鍵，然後把每個佔位符取代為對 [`bin/time-revamped`](bin/time-revamped) 的呼叫，在 `options` 模式下則取代為選項讀取，並啟動背景程序。

預設模式下，每次 `#()` 呼叫讀取一次時鐘並輸出。`options` 模式下，每個伺服器一個背景程序佔用 `@time_revamped_ticker_pid`，預設每分鐘、在分鐘變化一秒之後渲染狀態列用到的全部佔位符，並透過一次 tmux 呼叫寫入，所以各時鐘同時變化。當另一個程序佔用該選項或伺服器結束時，它停止。

每次 `date` 呼叫都在 C 區域設定下執行。夏令時間和重疊檢查在 GNU、uutils 和 BusyBox 上用 `-d` 執行 `date`，在 BSD 上用 `-r`，每個程序偵測一次。倒數、秒錶和相對日期是 shell 中的整數運算。讀取、數值和按鍵綁定在 [`lib/time.sh`](lib/time.sh) 中，設定表在 [`lib/state.sh`](lib/state.sh) 中。

<a id="截圖"></a>

## 截圖

<details>
<summary>全部截圖，在真實的 tmux 中用 <code>make screens</code> 錄製，每個按鍵都顯示在狀態列上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="time-revamped: 日期、時間和三個世界時鐘，按小時着色"><br><sub>日期、時間和三個世界時鐘，按小時着色（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="time-revamped: prefix M-t 開啟世界時鐘選單"><br><sub><code>prefix M-t</code> 開啟世界時鐘選單（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/twelve.png" alt="time-revamped: 選單中的 h 切換至 12 小時制"><br><sub>選單中的 <code>h</code> 切換至 12 小時制（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/calendar.png" alt="time-revamped: 選單中的 c 開啟日曆"><br><sub>選單中的 <code>c</code> 開啟日曆（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/copy.png" alt="time-revamped: 選單中的 i 複製 ISO 時間"><br><sub>選單中的 <code>i</code> 複製 ISO 時間（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/calendar-key.png" alt="time-revamped: @time_revamped_calendar_key 為日曆指定專用按鍵"><br><sub><code>@time_revamped_calendar_key</code> 為日曆指定專用按鍵（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/copy-key.png" alt="time-revamped: @time_revamped_copy_key 為複製 ISO 時間指定專用按鍵"><br><sub><code>@time_revamped_copy_key</code> 為複製 ISO 時間指定專用按鍵（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/mark-key.png" alt="time-revamped: @time_revamped_mark_key 設定秒錶標記"><br><sub><code>@time_revamped_mark_key</code> 設定秒錶標記（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/mark.png" alt="time-revamped: #{time_elapsed} 從標記開始計時"><br><sub><code>#{time_elapsed}</code> 從標記開始計時（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/options.png" alt="time-revamped: 在 options 渲染模式下，每個佔位符讀取一個 tmux 選項"><br><sub>在 <code>options</code> 渲染模式下，每個佔位符讀取一個 tmux 選項（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/formats.png" alt="time-revamped: @time_revamped_date_format 和 @time_revamped_time_format 決定日期和時間的格式"><br><sub><code>@time_revamped_date_format</code> 和 <code>@time_revamped_time_format</code> 決定日期和時間的格式（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/hide.png" alt="time-revamped: hide 去掉 #{time_date} 和 #{time_clock} 的日期和時間"><br><sub><code>hide</code> 去掉 <code>#{time_date}</code> 和 <code>#{time_clock}</code> 的日期和時間（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/compact.png" alt="time-revamped: @time_revamped_compact 輸出簡短的城市標籤"><br><sub><code>@time_revamped_compact</code> 輸出簡短的城市標籤（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/labels.png" alt="time-revamped: @time_revamped_zone_labels 和 @time_revamped_zone_separator 為時鐘命名並分隔"><br><sub><code>@time_revamped_zone_labels</code> 和 <code>@time_revamped_zone_separator</code> 為時鐘命名並分隔（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/periods.png" alt="time-revamped: 夜晚、早晨、白天、下午和傍晚各有一種顏色"><br><sub>夜晚、早晨、白天、下午和傍晚各有一種顏色（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/weekend.png" alt="time-revamped: 星期六和星期日使用週末顏色"><br><sub>星期六和星期日使用週末顏色（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/weekend-override.png" alt="time-revamped: @time_revamped_weekend_override 設為 0 時，週末仍使用時段顏色"><br><sub><code>@time_revamped_weekend_override</code> 設為 <code>0</code> 時，週末仍使用時段顏色（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/colors.png" alt="time-revamped: 各時段的顏色可使用任意樣式，這裏是十六進制顏色"><br><sub>各時段的顏色可使用任意樣式，這裏是十六進制顏色（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="time-revamped: 每個時段都有圖示選項，這裏各用一個字母"><br><sub>每個時段都有圖示選項，這裏各用一個字母（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/icon-position.png" alt="time-revamped: @time_revamped_icon_position 設為 before 時，圖示放在最前面"><br><sub><code>@time_revamped_icon_position</code> 設為 <code>before</code> 時，圖示放在最前面（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/relative-day.png" alt="time-revamped: @time_revamped_relative_day 為處於翌日的時區加上 +1d 標記"><br><sub><code>@time_revamped_relative_day</code> 為處於翌日的時區加上 <code>+1d</code> 標記（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/relative-day-back.png" alt="time-revamped: 前一天的時區上，同一標記顯示為 -1d"><br><sub>前一天的時區上，同一標記顯示為 <code>-1d</code>（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/work-hours.png" alt="time-revamped: @time_revamped_work_hours 讓工作時間之外的時區變暗"><br><sub><code>@time_revamped_work_hours</code> 讓工作時間之外的時區變暗（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/dim-style.png" alt="time-revamped: @time_revamped_work_start、@time_revamped_work_end 和 @time_revamped_dim_style 調整時段和變暗樣式"><br><sub><code>@time_revamped_work_start</code>、<code>@time_revamped_work_end</code> 和 <code>@time_revamped_dim_style</code> 調整時段和變暗樣式（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/primary.png" alt="time-revamped: @time_revamped_primary 和 @time_revamped_primary_style 突出顯示一個時區"><br><sub><code>@time_revamped_primary</code> 和 <code>@time_revamped_primary_style</code> 突出顯示一個時區（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/reset.png" alt="time-revamped: @time_revamped_reset 是寫在每一項之後的樣式"><br><sub><code>@time_revamped_reset</code> 是寫在每一項之後的樣式（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/local.png" alt="time-revamped: #{time_local} 根據 TZ 命名地點"><br><sub><code>#{time_local}</code> 根據 <code>TZ</code> 命名地點（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/local-label.png" alt="time-revamped: @time_revamped_local_label 直接設定標籤"><br><sub><code>@time_revamped_local_label</code> 直接設定標籤（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/geoip.png" alt="time-revamped: @time_revamped_local_source 設為 geoip 時，查詢你 IP 所在的城市"><br><sub><code>@time_revamped_local_source</code> 設為 <code>geoip</code> 時，查詢你 IP 所在的城市（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/countdown.png" alt="time-revamped: #{time_until} 倒數到 @time_revamped_countdown_target"><br><sub><code>#{time_until}</code> 倒數到 <code>@time_revamped_countdown_target</code>（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/countdown-done.png" alt="time-revamped: 目標時間一過，就顯示 @time_revamped_countdown_done"><br><sub>目標時間一過，就顯示 <code>@time_revamped_countdown_done</code>（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/epoch.png" alt="time-revamped: Unix 時間、ISO 時間、偏移、週數和一年中的第幾天"><br><sub>Unix 時間、ISO 時間、偏移、週數和一年中的第幾天（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/dst.png" alt="time-revamped: #{time_dst} 在 @time_revamped_dst_zone 的時鐘調整前幾天發出提示"><br><sub><code>#{time_dst}</code> 在 <code>@time_revamped_dst_zone</code> 的時鐘調整前幾天發出提示（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/overlap.png" alt="time-revamped: #{time_overlap} 輸出所有時區共有的工作時段"><br><sub><code>#{time_overlap}</code> 輸出所有時區共有的工作時段（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/overlap-none.png" alt="time-revamped: @time_revamped_overlap_label 和 @time_revamped_overlap_none 決定顯示的措辭"><br><sub><code>@time_revamped_overlap_label</code> 和 <code>@time_revamped_overlap_none</code> 決定顯示的措辭（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="time-revamped: 版本號"><br><sub>版本號（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="time-revamped: 未知指令"><br><sub>未知指令（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="time-revamped: status zones 和 status iso 各輸出一個佔位符"><br><sub><code>status zones</code> 和 <code>status iso</code> 各輸出一個佔位符（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="time-revamped: list 列出所有綁定"><br><sub><code>list</code> 列出所有綁定（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="time-revamped: list --json 把同一份計劃輸出為一個物件"><br><sub><code>list --json</code> 把同一份計劃輸出為一個物件（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/card.png" alt="time-revamped: card 輸出所有數值"><br><sub><code>card</code> 輸出所有數值（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="time-revamped: doctor"><br><sub><code>doctor</code>（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/toggle-command.png" alt="time-revamped: toggle-format 切換至 12 小時制"><br><sub><code>toggle-format</code> 切換至 12 小時制（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/copy-command.png" alt="time-revamped: copy epoch 複製 Unix 時間"><br><sub><code>copy epoch</code> 複製 Unix 時間（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/mark-command.png" alt="time-revamped: mark 設定秒錶標記"><br><sub><code>mark</code> 設定秒錶標記（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/calendar-command.png" alt="time-revamped: calendar 開啟日曆"><br><sub><code>calendar</code> 開啟日曆（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-command.png" alt="time-revamped: menu 開啟世界時鐘選單"><br><sub><code>menu</code> 開啟世界時鐘選單（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/menu-gum.png" alt="time-revamped: 選單"><br><sub>選單（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="time-revamped: 從選單開啟的卡片"><br><sub>從選單開啟的卡片（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="time-revamped: 來自 TIME_REVAMPED_ACCENT 的強調色"><br><sub>來自 <code>TIME_REVAMPED_ACCENT</code> 的強調色（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="time-revamped: 沒有 gum 的選單"><br><sub>沒有 gum 的選單（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="time-revamped: 沒有 gum 時，從選單執行的 doctor"><br><sub>沒有 gum 時，從選單執行的 <code>doctor</code>（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="time-revamped: 沒有 gum 的 card"><br><sub>沒有 gum 的 <code>card</code>（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="time-revamped: 六個主題下的標題"><br><sub>六個主題下的標題（<code>themes.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="time-revamped: 說明頁"><br><sub>說明頁（<code>help.tape</code>）</sub></td>
<td width="50%"></td>
</tr>
</table>

錄製運行真實的插件和 tmux。`date`、`cal`、`curl` 和 `pbcopy` 由小腳本代替，所以時鐘固定在 2026-10-16 星期五 14:30 UTC，以紐約時間顯示，並且不會碰剪貼簿。

</details>

## 可移植性

本插件是 POSIX `sh`。CI 在下面每一行上執行全部測試套件。

| Shell | 狀態 |
|:------|:-------|
| `dash`、macOS 上的 `/bin/sh` | 支援 |
| `bash` 3.2 和 5.x、系統內置的 `zsh` 和 Homebrew 的 `zsh` | 支援 |

| 系統 | 狀態 |
|:-------|:-------|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用系統內置工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 開發

| 指令 | 執行內容 |
|:--------|:-------------|
| `make fmt` | 對每個腳本執行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零問題 |
| `make test` | 在系統 `sh` 下執行 bats 測試套件 |
| `make test-all` | 在每個已安裝的 shell 下執行測試套件，macOS 上包括兩種 bash 和 zsh |
| `make test-linux` | 在 Ubuntu 容器中執行測試套件 |
| `make coverage` | 在本機 Mac 和 Ubuntu 容器中執行 bashcov，合併後要求 100% |
| `make screens` | 上面的截圖，在 macOS 上用 VHS 從真實插件在 tmux 內錄製 |
| `make install` | 把指令、man 手冊和補全安裝到 `PREFIX` |

在 macOS 上，`brew bundle` 會按 [`Brewfile`](Brewfile) 安裝這些目標用到的全部工具。

提交遵循 Conventional Commits 格式，直接推送到 `main`。`main` 上的 `ci` 通過後，`release.yml` 執行 semantic-release：自上一個標籤以來的每個 `feat` 或 `fix` 都會發佈一個版本、寫入版本常數，並把說明加入 [`CHANGELOG.md`](CHANGELOG.md)。

## 授權

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

這個插件是 tmux-revamped 插件家族的一員。每個成員都帶有 [`FAMILY.md`](FAMILY.md) 中相同的約定和相同的共用程式庫，並且設計為一起安裝：沒有成員佔用另一個成員佔用的按鍵或 tmux 選項。

在一個成員中發現的缺陷，要在全部成員中排查後才算修正完成。

| 成員 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 編輯並儲存 tmux 設定後，它會自動重新載入，毋須按鍵，也毋須指令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 狀態列顯示電池狀態，從不阻塞狀態列繪製 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 狀態列顯示每部已連接的藍牙裝置及其電量，不阻塞繪製 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 狀態列顯示 CPU 負載、溫度及頻率，從不阻塞繪製 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 狀態列顯示磁碟用量，從不阻塞狀態列繪製 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 從畫面上揀選 URL、路徑、雜湊值或任何其他字詞，並輸入到游標位置，全部以純 shell 實現 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在彈出視窗的 fzf 選擇器中切換、關閉、重新命名或建立 tmux 工作階段、視窗和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 狀態列顯示當前窗格的 git 分支、改動和託管平台數目，而不會阻塞顯示 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 狀態列顯示 NVIDIA、AMD、Intel 及 Apple GPU 的負載、溫度、時脈、功耗及記憶體 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 狀態列顯示目前的 Kubernetes 上下文及命名空間，毋須 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在彈出視窗或新視窗中啟動任何 TUI 應用程式，從目前窗格的目錄開始，每個應用程式可設定一個按鍵 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 將任何窗格儲存到檔案：即時記錄、完整捲動緩衝區或一次性截圖 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 狀態列顯示正在播放的歌曲，從不阻塞狀態列的繪製 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 狀態列顯示網絡傳輸量，從不阻塞繪製 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和視窗管理按鍵，配合 tmux 版本，與 vim 相容，每個 prefix 按鍵都可停用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 儲存 tmux 的所有工作階段、視窗及窗格，按計時器自動儲存，並在重新開機後全部還原 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起點：共用程式庫、bats 測試框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 狀態列中的番茄鐘計時器，所有狀態都儲存在 tmux 選項中，不使用暫存檔 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用滑鼠在 tmux 狀態列上拖動視窗標籤來移動該視窗 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 將滑鼠滾輪交給能自行捲動的應用程式，其他情況下進入 tmux 複製模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和終端機區分的合理預設設定，不會改動你自己設定的選項 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平鋪視窗管理：八種版面，包括 BSP dwindle 和 spiral，並支援復原版面 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | **本插件**，狀態列中的本地時鐘和世界時鐘，按一天中的時段著色，並提供倒數和夏令時間提示 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在背景從 wttr.in 取得天氣並顯示在狀態列，狀態列毋須等待 |

<!-- family:end -->

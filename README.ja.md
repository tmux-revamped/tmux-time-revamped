<div align="center">

# tmux-time-revamped

<strong>tmux のステータスバーにローカル時計と世界時計を表示します。時間帯で色分けし、カウントダウンと夏時間の警告も出せます。</strong>

[English](README.md) &nbsp;|&nbsp; 日本語 &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-time-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-time-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-time-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-time-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-time-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-time-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-time-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#クイックスタート"><strong>クイックスタート</strong></a> &nbsp;|&nbsp;
  <a href="#使い方">使い方</a> &nbsp;|&nbsp;
  <a href="#仕組み">仕組み</a> &nbsp;|&nbsp;
  <a href="#画面">画面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="日付、時刻、時間帯で色分けした 3 つの世界時計を表示し、世界時計メニュー、12 時間表示、カレンダー、ストップウォッチ、options 描画モードを操作する time-revamped" width="800">
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

プレースホルダー **14** 個、描画モード **2** つ、macOS と Linux、tmux **3.2** 以降。

---

## クイックスタート

### 前提条件

| ツール | バージョン | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 以降 | ファミリーの下限、およびカレンダーのポップアップ |
| `date` とタイムゾーンデータベース | システム | すべての時計。GNU、uutils、BusyBox、BSD の `date` に対応 |
| `cal` | システム | カレンダーのポップアップ |
| `curl` | 任意 | geoip の現在地ラベル |
| `pbcopy`、`wl-copy`、`xclip` | 任意 | タイムスタンプをシステムのクリップボードへコピー |
| gum | 任意 | `time-revamped` のメニュー、表、色。ない場合はすべてのコマンドがプレーンテキストを出力します |

Linux と macOS で、BSD、GNU、uutils、BusyBox のツールとともに動作します。任意のツールがなければその機能は黙って無効になり、`time-revamped doctor` が名前を示します。

### インストール

[TPM](https://github.com/tmux-plugins/tpm) を使う場合は、プラグインを `~/.tmux.conf` に追加して `prefix + I` を押します。

```tmux
set -g @plugin 'tmux-revamped/tmux-time-revamped'
set -g status-right '#{time} #{time_zones}'
```

手動でインストールする場合は、リポジトリをクローンして `~/.tmux.conf` からエントリーポイントを実行します。

```bash
git clone https://github.com/tmux-revamped/tmux-time-revamped ~/.tmux/plugins/tmux-time-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-time-revamped/time-revamped.tmux
```

プラグインを読み込む前に `status-left` か `status-right` を設定してください。プラグインは読み込み時に、そこにあるプレースホルダーを一度だけ置き換えます。

クローンで `make install` を実行すると、`time-revamped` が `~/.local/bin` に、man ページと補完が `~/.local/share` に入ります。

### 確認

```bash
~/.tmux/plugins/tmux-time-revamped/bin/time-revamped doctor
```

## 使い方

このプラグインは、`status-left`と`status-right`のプレースホルダーを、ローカルの日付と時刻、任意の数の世界時計、開発やカレンダー向けのいくつかの項目に置き換えます。世界時計はそれぞれ現地の時刻に応じて色が付くので、誰が朝で誰が寝ている時間かが一目で分かります。

| プレースホルダー | 出力 |
|:------------|:-------|
| `#{time}` | ローカルの日付と時刻。例: `2026-10-16 14:30` |
| `#{time_date}` | ローカルの日付のみ |
| `#{time_clock}` | ローカルの時刻のみ |
| `#{time_zones}` | 設定したタイムゾーンごとに1項目、時間帯ごとの色付き |
| `#{time_local}` | 世界時計と同じ見た目のローカル時計。場所のラベル付き |
| `#{time_until}` | 目標日時までのカウントダウン。例: `1d 4h` |
| `#{time_elapsed}` | ストップウォッチのマークからの経過時間。例: `12m` |
| `#{time_epoch}` | UNIX時間の秒数 |
| `#{time_iso}` | ISO 8601形式のローカル時刻。例: `2026-10-16T14:30:00-04:00` |
| `#{time_offset}` | ローカルのUTCオフセット。例: `UTC-04:00`、または`UTC` |
| `#{time_week}` | ISO 8601の週番号 |
| `#{time_doy}` | 年初からの通算日 |
| `#{time_dst}` | 時刻の切り替えが期間内にあれば`DST in 3d` |
| `#{time_overlap}` | 設定した全ゾーンに共通する勤務時間帯をローカル時刻で表示 |

```tmux
set -g @time_revamped_timezones 'America/New_York, Europe/London, Asia/Tokyo'
set -g status-right '#{time} #{time_zones}'
```

ローカルの時計がニューヨークの場合、ステータスバーの右側は次のようになります。

```text
2026-10-16 14:30 EDT 14:30 BST 19:30 JST 03:30
```

世界時計にはそれぞれ色が付きます。朝、昼、午後、夕方、夜の色か、土曜と日曜は週末の色です。

### 世界時計の装飾

| 設定 | 効果 |
|:--------|:-------|
| `@time_revamped_compact '1'` | ゾーンの略称の代わりに短い都市名。`America/New_York`は`NY`、`Asia/Tokyo`は`Tok` |
| `@time_revamped_zone_labels 'NYC, LDN, TYO'` | 自分で付けたラベル。順番でゾーンに対応します |
| `@time_revamped_relative_day '1'` | 日付が異なるゾーンに`+1d`か`-1d`のバッジ |
| `@time_revamped_work_hours '1'` | `@time_revamped_work_start`から`@time_revamped_work_end`の外にあるゾーンを薄く表示 |
| `@time_revamped_primary '0'` | 0から数えたその番号のゾーンを太字で表示 |

`#{time_overlap}`は設定した全ゾーンの勤務時間の重なりを求め、最も長い共通の時間帯をローカル時刻で表示します。例: `overlap 13:00-17:00`。共通の時間がなければ、ラベルに続けて`@time_revamped_overlap_none`を表示し、既定では`overlap no overlap`となります。

### 現在地のラベル

`#{time_local}`には場所の名前が必要です。既定では`TZ`か`/etc/localtime`のリンクから都市名をオフラインで取ります。`@time_revamped_local_source 'geoip'`にすると、代わりに`@time_revamped_geoip_endpoint`にグローバルIPの都市を問い合わせます。この要求は`@time_revamped_geoip_interval`分ごとにバックグラウンドで実行され、3秒でタイムアウトし、失敗すれば最後の都市を使い続けます。IPアドレスがエンドポイントに送られるので、それを許容できる場合にのみ有効にしてください。都市名は、英字、数字、空白、UTF-8の文字、`. , ' -`だけからなる64文字以下のものだけを受け付けます。

### カウントダウン、ストップウォッチ、夏時間

`#{time_until}`は、`YYYY-MM-DD`か`YYYY-MM-DD HH:MM`の形式で書いた`@time_revamped_countdown_target`までを数えます。目標を過ぎると`@time_revamped_countdown_done`を表示します。`#{time_elapsed}`は、マーク操作で設定したマークからの時間を数えます。`#{time_dst}`は、`@time_revamped_dst_zone`かローカルゾーンのUTCオフセットを`@time_revamped_dst_horizon`日先まで1日ずつ調べ、最初の変化を報告します。

### レンダーモード

既定では各プレースホルダーは`#()`呼び出しになり、tmuxはステータスを再描画するたびにそれを実行し直します。`@time_revamped_render`を`options`にすると、各プレースホルダーは`#{E:@time_revamped_out_local}`のようなオプションの読み取りになります。そしてサーバーごとに1つのバックグラウンドプロセスが、ステータスラインで使う時計をすべて、既定では分が変わった1秒後に1分に1回描画し、1回のtmux呼び出しで書き込むので、時計がそろって変わります。

```tmux
set -g @time_revamped_render 'options'
```

| コマンド | 内容 |
|:--------|:-------------|
| `time-revamped apply` | キーを割り当て、プレースホルダーを今すぐ置き換えます。エントリーポイントが tmux の読み込み時に実行します |
| `time-revamped list` | `apply` が送るコマンドをすべて表示し、何も変更しません。`--json` で 1 つのオブジェクトを出力します |
| `time-revamped status NAME` | `zones`、`iso`、`until` などプレースホルダーを 1 つ出力します。ステータスラインが実行します |
| `time-revamped card` | 今すぐすべてを読み取り、数値ごとに 1 行を出力します |
| `time-revamped menu` | 現在のクライアントに世界時計メニューを開きます |
| `time-revamped calendar` | `cal` を tmux のポップアップで開き、キーが押されるまで表示します |
| `time-revamped copy [KIND]` | 時刻を `iso` か `epoch` の形式で tmux のバッファーとシステムのクリップボードにコピーします |
| `time-revamped mark` | `#{time_elapsed}` が数え始めるストップウォッチのマークを設定します |
| `time-revamped toggle-format` | 12 時間表示と 24 時間表示を切り替えます |
| `time-revamped daemon` | `options` 描画モード用に、プレースホルダーを 1 分に 1 回公開します。`apply` が起動します |
| `time-revamped doctor` | 依存ごとに 1 行、設定したゾーン、設定、割り当てを見送ったキー |
| `time-revamped version` | バージョン、続いて tmux のバージョン |
| `time-revamped help` | ヘルプページ。`man time-revamped` が同じコマンドと設定を説明します |
| `time-revamped` | ターミナルではメニュー |

## 設定

すべてのオプションは、ダッシュ付きのコマンドオプション（例: `--timezones 'Asia/Tokyo'`）と、環境変数（例: `TIME_REVAMPED_TIMEZONES`）でも指定できます。優先順位はコマンドライン、環境変数、tmux オプションの順です。空の tmux オプションは既定値を意味します。`doctor` は、プラグインが知らない値を持つ設定を示します。`apply` に渡した設定は、すべてのキーとステータス呼び出しに引き継がれます。

| オプション | 既定値 | 意味 |
|:-------|:--------|:--------|
| `@time_revamped_date_format` | `YMD` | `YMD`、`MD`、`DM`、`MDY`、`DMY`、`hide` |
| `@time_revamped_time_format` | `24H` | `24H`、`12H`、`hide`。ローカル時計とすべての世界時計に適用 |
| `@time_revamped_timezones` | 空 | カンマか空白で区切ったタイムゾーン名 |
| `@time_revamped_compact` | `0` | `1`で短い都市名 |
| `@time_revamped_zone_labels` | 空 | 順番でゾーンに対応する、カンマ区切りのラベル |
| `@time_revamped_zone_separator` | 空白1つ | 世界時計の項目の間に入れる文字列 |
| `@time_revamped_weekend_override` | `1` | `0`で週末も時間帯の色とアイコンを使用 |
| `@time_revamped_local_label` | 空 | `#{time_local}`の固定ラベル |
| `@time_revamped_local_source` | `timezone` | `timezone`か`geoip` |
| `@time_revamped_geoip_endpoint` | `https://ipinfo.io/city` | 都市名のテキストか、`city`フィールドを持つJSONを返すURL |
| `@time_revamped_geoip_interval` | `30` | geoip要求の間隔、分単位 |
| `@time_revamped_morning_color` | `#[fg=yellow]` | 05時から12時 |
| `@time_revamped_day_color` | `#[fg=green]` | 12時から14時 |
| `@time_revamped_afternoon_color` | `#[fg=cyan]` | 14時から18時 |
| `@time_revamped_evening_color` | `#[fg=magenta]` | 18時から22時 |
| `@time_revamped_night_color` | `#[fg=blue]` | 22時から05時 |
| `@time_revamped_weekend_color` | `#[fg=brightblack]` | 土曜と日曜 |
| `@time_revamped_{sunrise,morning,day,afternoon,sunset,evening,night,weekend}_icon` | 空 | その時間帯のグリフ。sunriseは05時から08時、sunsetは18時から20時 |
| `@time_revamped_icon_position` | `middle` | `middle`は`NYC <icon> 18:00`、`before`は`<icon> NYC 18:00` |
| `@time_revamped_reset` | `#[default]` | 各項目の後に書くスタイル。`#[fg=default]`でテーマの背景を保持 |
| `@time_revamped_relative_day` | `0` | `1`で`+1d`か`-1d`のバッジを追加 |
| `@time_revamped_work_hours` | `0` | `1`で勤務時間外のゾーンを薄く表示 |
| `@time_revamped_work_start` | `9` | 勤務開始の時、この時を含む |
| `@time_revamped_work_end` | `17` | 勤務終了の時、この時を含まない |
| `@time_revamped_dim_style` | `#[dim]` | 勤務時間外のゾーンのスタイル。`none`で無効 |
| `@time_revamped_primary` | 空 | 強調するゾーンの、0から数えた番号 |
| `@time_revamped_primary_style` | `#[bold]` | 強調するゾーンのスタイル。`none`で無効 |
| `@time_revamped_countdown_target` | 空 | `#{time_until}`の目標日時 |
| `@time_revamped_countdown_label` | 空 | カウントダウンの前に付ける文字列 |
| `@time_revamped_countdown_done` | `now` | 目標を過ぎた後の文字列 |
| `@time_revamped_dst_zone` | 空 | `#{time_dst}`が監視するゾーン。空ならローカル |
| `@time_revamped_dst_horizon` | `14` | 時刻の切り替えを探す日数 |
| `@time_revamped_dst_label` | `DST` | 日数の前に付ける文字列 |
| `@time_revamped_overlap_label` | `overlap` | 重なりの時間帯の前に付ける文字列 |
| `@time_revamped_overlap_none` | `no overlap` | 共通の時間がないときの文字列 |
| `@time_revamped_render` | `jobs` | `options`でレンダーモードを有効にします。それ以外の値は`jobs`として扱います |
| `@time_revamped_interval` | `minute` | レンダーモードの間隔。`minute`か秒数。それ以外は`status-interval`、さらに5秒の順で代わりに使います |
| `@time_revamped_menu_key` | `M-t` | 操作メニューを開くプレフィックスキー。`off`で割り当てなし |
| `@time_revamped_calendar_key` | `off` | カレンダーのポップアップのプレフィックスキー |
| `@time_revamped_copy_key` | `off` | ISOタイムスタンプをコピーするプレフィックスキー |
| `@time_revamped_mark_key` | `off` | ストップウォッチのマークを設定するプレフィックスキー |

色は16色のANSIの名前なので、端末のテーマに従います。正確な色にしたい場合は、色のオプションに16進数の値を設定します。

<details>
<summary><strong>6つのテーマの16進数カラー</strong></summary>

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

### 内部状態

これらのオプションはプラグインが管理します。設定しないでください。

| オプション | 保持する内容 |
|:-------|:------|
| `@time_revamped_mark_epoch` | 最後のストップウォッチのマークのUNIX時間 |
| `@time_revamped_published` | ステータスラインで使うプレースホルダー。レンダーモードがそれだけを公開するよう、読み込み時に記録します |
| `@time_revamped_out_<name>` | レンダーモードで描画した各値 |
| `@time_revamped_ticker_pid` | レンダーモードを担当するプロセス。再読み込みで新しいプロセスに引き継がれ、古いプロセスは終了します |
| `@time_revamped_geoip_city` | geoipで得た最後の都市名。経過時間と実行中の要求を表す`_ts`と`_lock`が付随します |

## キーバインド

| キー | オプション | 動作 |
|:----|:-------|:-------|
| `prefix + M-t` | `@time_revamped_menu_key` | 世界時計メニューを開く |
| 割り当てなし | `@time_revamped_calendar_key` | カレンダーのポップアップ |
| 割り当てなし | `@time_revamped_copy_key` | ISO 形式の時刻をコピー |
| 割り当てなし | `@time_revamped_mark_key` | ストップウォッチのマークを設定 |

メニューには 6 つの項目があります。`h` は 12 時間表示と 24 時間表示を切り替え、`c` はカレンダーを開き、`i` と `e` は時刻を ISO 8601 か UNIX 秒で tmux のバッファーとシステムのクリップボードにコピーし、`m` はストップウォッチのマークを設定し、`d` は `time-revamped doctor` を実行します。既定のキーは、ほかの割り当てがすでにある場合は触れず、`doctor` がそれを示します。`off` にしたキーは何も割り当てません。

## 仕組み

[`time-revamped.tmux`](time-revamped.tmux) は tmux がプラグインを読み込むときに一度実行されます。`status-left` と `status-right` が使うプレースホルダーを `@time_revamped_published` に記録し、キーを割り当て、各プレースホルダーを [`bin/time-revamped`](bin/time-revamped) の呼び出しに、`options` モードではオプションの読み取りに置き換えて、バックグラウンドプロセスを起動します。

既定のモードでは、各 `#()` 呼び出しが時計を 1 回読んで出力します。`options` モードでは、サーバーごとに 1 つのバックグラウンドプロセスが `@time_revamped_ticker_pid` を取得し、ステータスラインが使うプレースホルダーをすべて、既定では分が変わった 1 秒後に 1 分に 1 回描画して 1 回の tmux 呼び出しで書き込むので、時計がそろって変わります。別のプロセスがこのオプションを取得するかサーバーがなくなると終了します。

`date` の呼び出しはすべて C ロケールで実行します。夏時間と重なりの判定では、GNU、uutils、BusyBox では `-d`、BSD では `-r` を付けて `date` を実行し、その判別はプロセスごとに 1 回だけ行います。カウントダウン、ストップウォッチ、日付の差はシェルの整数演算です。読み取り、数値、キーの割り当ては [`lib/time.sh`](lib/time.sh) に、設定の表は [`lib/state.sh`](lib/state.sh) にあります。

<a id="画面"></a>

## 画面

<details>
<summary>すべての画面。実際の tmux の中で <code>make screens</code> で録画し、押したキーをステータスラインに表示しています</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="time-revamped: 日付、時刻、3 つの世界時計。時間帯ごとに色が変わります"><br><sub>日付、時刻、3 つの世界時計。時間帯ごとに色が変わります（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="time-revamped: prefix M-t で世界時計メニューを開きます"><br><sub><code>prefix M-t</code> で世界時計メニューを開きます（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/twelve.png" alt="time-revamped: メニューの h で 12 時間表示に切り替えます"><br><sub>メニューの <code>h</code> で 12 時間表示に切り替えます（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/calendar.png" alt="time-revamped: メニューの c でカレンダーを開きます"><br><sub>メニューの <code>c</code> でカレンダーを開きます（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/copy.png" alt="time-revamped: メニューの i で ISO 形式の時刻をコピーします"><br><sub>メニューの <code>i</code> で ISO 形式の時刻をコピーします（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/calendar-key.png" alt="time-revamped: @time_revamped_calendar_key でカレンダー専用のキーを割り当てます"><br><sub><code>@time_revamped_calendar_key</code> でカレンダー専用のキーを割り当てます（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/copy-key.png" alt="time-revamped: @time_revamped_copy_key で ISO コピー専用のキーを割り当てます"><br><sub><code>@time_revamped_copy_key</code> で ISO コピー専用のキーを割り当てます（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/mark-key.png" alt="time-revamped: @time_revamped_mark_key でストップウォッチのマークを設定します"><br><sub><code>@time_revamped_mark_key</code> でストップウォッチのマークを設定します（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/mark.png" alt="time-revamped: #{time_elapsed} はマークから数えます"><br><sub><code>#{time_elapsed}</code> はマークから数えます（<code>hero.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/options.png" alt="time-revamped: options 描画モードでは、各プレースホルダーが tmux オプションを読みます"><br><sub><code>options</code> 描画モードでは、各プレースホルダーが tmux オプションを読みます（<code>hero.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/formats.png" alt="time-revamped: @time_revamped_date_format と @time_revamped_time_format で日付と時刻の書式を変えます"><br><sub><code>@time_revamped_date_format</code> と <code>@time_revamped_time_format</code> で日付と時刻の書式を変えます（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/hide.png" alt="time-revamped: hide で #{time_date} と #{time_clock} の日付と時刻を消します"><br><sub><code>hide</code> で <code>#{time_date}</code> と <code>#{time_clock}</code> の日付と時刻を消します（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/compact.png" alt="time-revamped: @time_revamped_compact で短い都市名にします"><br><sub><code>@time_revamped_compact</code> で短い都市名にします（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/labels.png" alt="time-revamped: @time_revamped_zone_labels と @time_revamped_zone_separator で時計の名前と区切りを決めます"><br><sub><code>@time_revamped_zone_labels</code> と <code>@time_revamped_zone_separator</code> で時計の名前と区切りを決めます（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/periods.png" alt="time-revamped: 夜、朝、昼、午後、夕方にそれぞれ色があります"><br><sub>夜、朝、昼、午後、夕方にそれぞれ色があります（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/weekend.png" alt="time-revamped: 土曜と日曜は週末の色になります"><br><sub>土曜と日曜は週末の色になります（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/weekend-override.png" alt="time-revamped: @time_revamped_weekend_override を 0 にすると、週末も時間帯の色のままです"><br><sub><code>@time_revamped_weekend_override</code> を <code>0</code> にすると、週末も時間帯の色のままです（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/colors.png" alt="time-revamped: 時間帯の色には任意のスタイルを使えます。ここでは 16 進カラーです"><br><sub>時間帯の色には任意のスタイルを使えます。ここでは 16 進カラーです（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="time-revamped: 各時間帯にはアイコンのオプションがあります。ここでは 1 文字ずつです"><br><sub>各時間帯にはアイコンのオプションがあります。ここでは 1 文字ずつです（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/icon-position.png" alt="time-revamped: @time_revamped_icon_position を before にすると、アイコンが先頭に来ます"><br><sub><code>@time_revamped_icon_position</code> を <code>before</code> にすると、アイコンが先頭に来ます（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/relative-day.png" alt="time-revamped: @time_revamped_relative_day で、翌日のゾーンに +1d のバッジが付きます"><br><sub><code>@time_revamped_relative_day</code> で、翌日のゾーンに <code>+1d</code> のバッジが付きます（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/relative-day-back.png" alt="time-revamped: 前日のゾーンには同じバッジが -1d と表示されます"><br><sub>前日のゾーンには同じバッジが <code>-1d</code> と表示されます（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/work-hours.png" alt="time-revamped: @time_revamped_work_hours で、勤務時間外のゾーンが薄く表示されます"><br><sub><code>@time_revamped_work_hours</code> で、勤務時間外のゾーンが薄く表示されます（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/dim-style.png" alt="time-revamped: @time_revamped_work_start、@time_revamped_work_end、@time_revamped_dim_style で時間帯と薄く表示するスタイルを変えます"><br><sub><code>@time_revamped_work_start</code>、<code>@time_revamped_work_end</code>、<code>@time_revamped_dim_style</code> で時間帯と薄く表示するスタイルを変えます（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/primary.png" alt="time-revamped: @time_revamped_primary と @time_revamped_primary_style で 1 つのゾーンを強調します"><br><sub><code>@time_revamped_primary</code> と <code>@time_revamped_primary_style</code> で 1 つのゾーンを強調します（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/reset.png" alt="time-revamped: @time_revamped_reset は各項目の後ろに書くスタイルです"><br><sub><code>@time_revamped_reset</code> は各項目の後ろに書くスタイルです（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/local.png" alt="time-revamped: #{time_local} は TZ から場所の名前を付けます"><br><sub><code>#{time_local}</code> は <code>TZ</code> から場所の名前を付けます（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/local-label.png" alt="time-revamped: @time_revamped_local_label でラベルそのものを決めます"><br><sub><code>@time_revamped_local_label</code> でラベルそのものを決めます（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/geoip.png" alt="time-revamped: @time_revamped_local_source を geoip にすると、IP の都市を問い合わせます"><br><sub><code>@time_revamped_local_source</code> を <code>geoip</code> にすると、IP の都市を問い合わせます（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/countdown.png" alt="time-revamped: #{time_until} は @time_revamped_countdown_target までを数えます"><br><sub><code>#{time_until}</code> は <code>@time_revamped_countdown_target</code> までを数えます（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/countdown-done.png" alt="time-revamped: 目標を過ぎると @time_revamped_countdown_done を表示します"><br><sub>目標を過ぎると <code>@time_revamped_countdown_done</code> を表示します（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/epoch.png" alt="time-revamped: UNIX 時間、ISO 形式の時刻、オフセット、週番号、年内の通算日"><br><sub>UNIX 時間、ISO 形式の時刻、オフセット、週番号、年内の通算日（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/dst.png" alt="time-revamped: #{time_dst} は @time_revamped_dst_zone の時刻切り替えの数日前に警告します"><br><sub><code>#{time_dst}</code> は <code>@time_revamped_dst_zone</code> の時刻切り替えの数日前に警告します（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/overlap.png" alt="time-revamped: #{time_overlap} はすべてのゾーンが共有する勤務時間を表示します"><br><sub><code>#{time_overlap}</code> はすべてのゾーンが共有する勤務時間を表示します（<code>features.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/overlap-none.png" alt="time-revamped: @time_revamped_overlap_label と @time_revamped_overlap_none で表示の文言を決めます"><br><sub><code>@time_revamped_overlap_label</code> と <code>@time_revamped_overlap_none</code> で表示の文言を決めます（<code>features.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="time-revamped: バージョン"><br><sub>バージョン（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="time-revamped: 未知のコマンド"><br><sub>未知のコマンド（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="time-revamped: status zones と status iso はそれぞれプレースホルダーを 1 つ出力します"><br><sub><code>status zones</code> と <code>status iso</code> はそれぞれプレースホルダーを 1 つ出力します（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="time-revamped: list はすべての割り当てを出力します"><br><sub><code>list</code> はすべての割り当てを出力します（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="time-revamped: list --json は同じ計画を 1 つのオブジェクトで出力します"><br><sub><code>list --json</code> は同じ計画を 1 つのオブジェクトで出力します（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/card.png" alt="time-revamped: card はすべての数値を出力します"><br><sub><code>card</code> はすべての数値を出力します（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="time-revamped: doctor"><br><sub><code>doctor</code>（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/toggle-command.png" alt="time-revamped: toggle-format は 12 時間表示に切り替えます"><br><sub><code>toggle-format</code> は 12 時間表示に切り替えます（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/copy-command.png" alt="time-revamped: copy epoch は UNIX 時間をコピーします"><br><sub><code>copy epoch</code> は UNIX 時間をコピーします（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/mark-command.png" alt="time-revamped: mark はストップウォッチのマークを設定します"><br><sub><code>mark</code> はストップウォッチのマークを設定します（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/calendar-command.png" alt="time-revamped: calendar はカレンダーを開きます"><br><sub><code>calendar</code> はカレンダーを開きます（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-command.png" alt="time-revamped: menu は世界時計メニューを開きます"><br><sub><code>menu</code> は世界時計メニューを開きます（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/menu-gum.png" alt="time-revamped: メニュー"><br><sub>メニュー（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="time-revamped: メニューから開いたカード"><br><sub>メニューから開いたカード（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="time-revamped: TIME_REVAMPED_ACCENT のアクセント色"><br><sub><code>TIME_REVAMPED_ACCENT</code> のアクセント色（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="time-revamped: gum なしのメニュー"><br><sub>gum なしのメニュー（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="time-revamped: gum なしで、メニューから開いた doctor"><br><sub>gum なしで、メニューから開いた <code>doctor</code>（<code>stills.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="time-revamped: gum なしの card"><br><sub>gum なしの <code>card</code>（<code>stills.tape</code>）</sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="time-revamped: 6 つのテーマのヘッダー"><br><sub>6 つのテーマのヘッダー（<code>themes.tape</code>）</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="time-revamped: ヘルプページ"><br><sub>ヘルプページ（<code>help.tape</code>）</sub></td>
<td width="50%"></td>
</tr>
</table>

録画では実際のプラグインと tmux を動かしています。`date`、`cal`、`curl`、`pbcopy` は小さなスクリプトで置き換えているため、時計は 2026-10-16 金曜 14:30 UTC に固定され、ニューヨークの時刻で表示され、クリップボードには触れません。

</details>

## 移植性

このプラグインは POSIX `sh` です。CI は下の各行ですべてのスイートを実行します。

| シェル | 状態 |
|:------|:-------|
| `dash`、macOS の `/bin/sh` | 対応 |
| `bash` 3.2 と 5.x、システムの `zsh` と Homebrew の `zsh` | 対応 |

| システム | 状態 |
|:-------|:-------|
| macOS | Apple Silicon と Intel の Tahoe。標準のツール、Homebrew の GNU ツール、Homebrew の uutils |
| Linux | x86_64 と arm64 の Ubuntu 26.04。GNU coreutils、uutils、BusyBox |

## 開発

| コマンド | 実行するもの |
|:--------|:-------------|
| `make fmt` | すべてのスクリプトに shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint、actionlint。指摘は 0 件 |
| `make test` | システムの `sh` での bats スイート |
| `make test-all` | インストール済みのすべてのシェルでのスイート。macOS では bash と zsh の両方のビルド |
| `make test-linux` | Ubuntu コンテナでのスイート |
| `make coverage` | この Mac と Ubuntu コンテナでの bashcov。統合して 100 パーセントを要求 |
| `make screens` | 上の画面。実際のプラグインを tmux の中で VHS で録画（macOS） |
| `make install` | コマンド、man ページ、補完を `PREFIX` の下にインストール |

macOS では、`brew bundle` を実行すると、これらのターゲットが使うツールがすべて [`Brewfile`](Brewfile) からインストールされます。

コミットは Conventional Commits の形式で、`main` に直接プッシュします。`main` で `ci` が成功すると、`release.yml` が semantic-release を実行します。前回のタグ以降の `feat` か `fix` ごとにリリースを公開し、バージョン定数を書き換え、ノートを [`CHANGELOG.md`](CHANGELOG.md) に追加します。

## ライセンス

[MIT](LICENSE)、copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped ファミリー

このプラグインは tmux-revamped ファミリーの一員です。すべてのメンバーが [`FAMILY.md`](FAMILY.md) の同じ規約と同じ共有ライブラリを持ちます。メンバーは一緒にインストールする前提で作られており、ほかのメンバーが使うキーや tmux オプションを使うメンバーはありません。

あるメンバーで見つかった不具合は、修正完了とする前に全メンバーで同じ不具合を探します。

| メンバー | 機能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | tmuxの設定を編集して保存するだけで、キーもコマンドも使わずに自動で再読み込みされます |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | tmuxのステータスバーに電池の状態を表示し、ステータスの描画を一切止めません |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 接続中のすべてのBluetooth機器とその電池残量をtmuxのステータスバーに表示し、描画を止めません |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPUの負荷、温度、周波数をtmuxのステータスバーに表示し、描画を一切止めません |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | tmuxのステータスバーにディスク使用量を表示し、ステータスの描画を一切止めません |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 画面上の URL、パス、ハッシュなどのトークンを fzf で選び、カーソル位置に入力します。純粋なシェルだけで動きます |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | ポップアップ内の fzf ピッカーから、tmux のセッション、ウィンドウ、ペインの切り替え、終了、名前変更、作成を行います |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | アクティブなペインのgitブランチ、変更、プロバイダーの件数を、描画を止めずにtmuxのステータスバーに表示します |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | NVIDIA、AMD、Intel、Apple の GPU の負荷、温度、クロック、電力、メモリを tmux のステータスバーに表示します |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 現在の Kubernetes コンテキストと名前空間を、kubectl を使わずに kubeconfig から解析して tmux のステータスバーに表示します |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 任意の TUI アプリを、現在のペインのディレクトリでポップアップまたはウィンドウとして起動します。アプリごとにキーを設定できます |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 任意のペインをファイルに保存します。ライブのログ記録、スクロールバック全体、1 回限りのスクリーンショットに対応します |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 再生中の曲をステータスバーに表示し、ステータスの描画を止めません |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | ネットワークのスループットをステータスバーに表示し、描画を止めません |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux のペインとウィンドウの操作キー。tmux のバージョンに対応し、vim と共存でき、どの prefix キーも無効にできます |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | tmuxのすべてのセッション、ウィンドウ、ペインを保存し、タイマーで自動保存して、再起動後にすべて復元します |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revampedプラグインの出発点です。共有ライブラリ、batsハーネス、CIを含みます |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | tmuxのステータスバー上でウィンドウのタブをマウスでドラッグして、そのウィンドウを移動します |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 自分でスクロールできるアプリにはマウスホイールを渡し、それ以外ではtmuxのコピーモードに入ります |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | tmuxのバージョンと端末に合わせて適用され、ユーザーが設定したオプションには触れない、妥当な初期設定です |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmuxのタイル型ウィンドウ管理です。BSPのdwindleとspiralを含む8つのレイアウトと、レイアウトの取り消しがあります |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | **このプラグイン**、ステータスバーにローカル時計と世界時計を時間帯ごとの色で表示し、カウントダウンと夏時間の警告も出します |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | wttr.inの天気をバックグラウンドで取得し、ステータスバーを待たせずに表示します |

<!-- family:end -->

# Console Animation GIF Generator

お気に入り動画を開発コンソールの隅っこで楽しめる ASCII 風 GIF アニメーションに変換するスクリプトです。

## Overview

処理の流れ

```txt
動画 URL リスト
  ↓ download.sh
ダウンロードして軽量化とファイル分割
  ↓ mp4cast.sh
コンソールで再生しながら録画
  ↓ cast2gif.sh
GIF に変換
```

## Files

```txt
urls.txt       # 収集する動画URL一覧
download.sh    # ダウンロード、軽量化、分割
mp4cast.sh     # 動画 を ASCII 表示して asciinema cast 録画
cast2gif.sh    # cast を GIF に変換
```

## Requirements

以下のコマンドを使用します。

```bash
brew install coreutils
brew install yt-dlp ffmpeg asciinema agg gifsicle
```

また、[ascii-term](https://github.com/itsakeyfut/ascii-term) が必要です。

`mp4cast.sh` は標準では iTerm2 のウィンドウサイズを AppleScript で調整します。
iTerm2 以外の実行環境でこの処理が不要な場合は、`./mp4cast.sh --no-iterm2-resize` を使用してください。

各ツールは利用するサービス・素材の規約や権利関係を確認したうえで、個人利用の範囲で使用してください。

## Directory Structure

実行時に以下のディレクトリを使用します。

```txt
originals/  # ダウンロードした動画
work/       # 軽量化した中間 MP4
src/        # 分割済み MP4
rec/        # asciinema cast
gif/        # 変換直後の GIF
out/        # 最終出力 GIF
```

## Usage

### 1. URLリストを用意

`urls.txt` に1行ずつ動画URLを書きます。

```txt
https://example.com/watch?v=xxxxxxxxxxx
https://example.com/watch?v=yyyyyyyyyyy
```

空行と `#` 始まりの行は無視されます。

### 2. 動画をダウンロードして軽量化と分割

```bash
./download.sh
```

主な処理内容:

- URL リストから動画をダウンロード
- 音声を削除
- 低 FPS で低解像度な軽量の動画に変換
- 30秒前後になるように均等分割

出力先:

```txt
src/
```

### 3. MP4 ファイルを asciinema cast に変換

```bash
./mp4cast.sh
```

iTerm2 のリサイズ処理を無効化する場合:

```bash
./mp4cast.sh --no-iterm2-resize
```

主な処理内容:

- `src/` 以下の `.mp4` を走査
- `ascii-term` で ASCII表示
- `asciinema` で録画

出力先:

```txt
rec/
```

### 4. cast ファイルを GIF アニメに変換

```bash
./cast2gif.sh
```

主な処理内容:

- `rec/` 以下の `.cast` を GIF に変換
- `gifsicle` で最適化
- 冒頭フレームを削除

最終出力:

```txt
out/
```

## Recommended Workflow

```bash
./download.sh
./mp4cast.sh
./cast2gif.sh
```

完成したGIFは `out/` に出力されます。

この `out/` を良い感じに開発コンソールとかの隅っこで再生していると心が豊かになる。

## Tuning

### download.sh

動画の軽量化設定を調整します。

```bash
FPS=8
SCALE=320:-1
RATE_F=32
```

目安:

| 設定 | 意味 |
|---|---|
| `FPS` | 動画のフレームレート。小さいほど軽量 |
| `SCALE` | 動画サイズ。`320:-1` は横幅320pxで縦は自動 |
| `RATE_F` | libx264の品質。大きいほど低画質・軽量 |

### mp4cast.sh

ASCII表示の見た目を調整します。

```bash
FPS=8
CHAR=6
```

`CHAR` は [ascii-term](https://github.com/itsakeyfut/ascii-term#character-maps) の文字マップです。

```txt
0 Basic
3 Blocks
4 Braille
6 Gradient
9 Emoji
```

### cast2gif.sh

GIFレンダリングを調整します。

```bash
agg --font-size 15
gifsicle --optimize=3 --colors 256
```

`asciinema` の `.cast` は「文字とタイミング」の記録なので、GIF化時の見た目は `agg` のフォント・サイズ・テーマ設定に依存します。

## Notes

- `.cast` は動画そのものではなく、端末出力の記録です。
- GIF の品質（表示）は `agg` のレンダリング設定に左右されます。
- `ascii-term` の見た目は、ターミナルサイズやフォントに影響されます。
- 長い動画は扱いやすいように30秒前後へ分割します。
- 生成物は個人利用・ローカル利用を前提としています。

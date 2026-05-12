#!/bin/bash

set -euo pipefail

FPS="8"

# 0 Basic       .:-=+*#%@
# 1 Extended    67-char set
# 2 Full        92-char set
# 3 Blocks      ░▒▓█
# 4 Braille     ⠁⠃⠇⠏⠟⠿⣿
# 5 Dots        dot-based
# 6 Gradient    ▁▂▃▄▅▆▇█
# 7	Binary      black/white
# 8	BinDots     binary dots
# 9	Emoji       emoji-style
CHAR="6"

RESIZE_ITERM2="1"

for arg in "$@"; do
    case "$arg" in
    --no-iterm2-resize)
        RESIZE_ITERM2="0"
        ;;
    *)
        echo "Usage: $0 [--no-iterm2-resize]" >&2
        exit 1
        ;;
    esac
done

mkdir -p src rec

resize_iterm2_1280x720() {
    osascript <<'APPLESCRIPT'
tell application "iTerm2"
  tell current window
    set bounds to {100, 100, 1380, 820}
  end tell
end tell
APPLESCRIPT
}

if [[ "$RESIZE_ITERM2" == "1" ]]; then
    resize_iterm2_1280x720
fi

printf '\e[8;45;160t'

clear

find src -type f -iname "*.mp4" | sort | while IFS= read -r file; do
    clear

    echo "Playing ${file} in ascii-term and recording ..."

    base="$(basename "$file")"
    id="${base%.*}"

    duration="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file")"
    sec="$(awk "BEGIN { print int($duration) }")"

    asciinema rec --overwrite --headless --idle-time-limit "$sec" --window-size 160x45 \
        --command "gtimeout ${sec}s ascii-term --no-audio --fps $FPS --char-map $CHAR $file" \
        "rec/${id}.cast"
done

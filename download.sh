#!/bin/bash

set -euo pipefail

FPS="8"
SCALE="320:-1"
RATE_F="32"

mkdir -p originals work src

while IFS= read -r url; do
    [[ -z "$url" || "$url" =~ ^# ]] && continue

    echo "Downloading ${url} ..."

    id="$(yt-dlp --get-id "$url")"

    yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --merge-output-format mp4 -o "originals/${id}.%(ext)s" "$url"

    input="originals/${id}.mp4"
    normalized="work/${id}.mp4"

    ffmpeg -nostdin -y -i "$input" -vf "fps=$FPS,scale=$SCALE" -an -c:v libx264 -preset veryfast -crf "$RATE_F" "$normalized"

    duration="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$normalized")"
    parts="$(awk "BEGIN { print int(($duration + 29.999) / 30) }")"

    if [[ "$parts" -gt 1 ]]; then
        segment_time="$(awk "BEGIN { print $duration / $parts }")"
        ffmpeg -nostdin -y -i "$normalized" -c copy -map 0 -f segment -segment_time "$segment_time" -reset_timestamps 1 "src/${id}_%03d.mp4"
    else
        cp "$normalized" "src/${id}.mp4"
    fi
done <urls.txt

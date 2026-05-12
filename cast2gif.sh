#!/bin/bash

set -euo pipefail

mkdir -p rec gif out

find rec -type f -iname "*.cast" | sort | while IFS= read -r file; do
    echo "Converting ${file} to GIF ..."

    base="$(basename "$file")"
    id="${base%.*}"

    [[ -z "$id" ]] && continue

    agg --theme asciinema --text-font-family "Hack Nerd Font Mono" --font-size 15 --no-loop --speed 1 "rec/${id}.cast" "gif/${id}.gif"
    gifsicle --batch --verbose --optimize=3 --colors 256 "gif/${id}.gif" '#2-' --out "out/${id}.gif"
done

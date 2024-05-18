#!/bin/bash

EPOCH=$(date +%s)

TMP="$OUTPUT_PATH/tmp-$EPOCH"
mkdir -p "$TMP"
mkdir -p "$TMP/audio"

files=()
count=0
while IFS='' read -r file; do
    if [[ -z "$file" ]]; then
        break
    fi

    cp "$file" "$TMP/audio/$count.mp3"
    files+=("$TMP/audio/$count.mp3")
    count=$(( count + 1 ))
done <<< "$(find "$AUDIOS_PATH" -name '*.mp3' ! -name 'audio.mp3')"

echo sox $(printf "%q " "${files[@]}") "$TMP/audio.mp3" || exit 1
sox $(printf "%q " "${files[@]}") "$TMP/audio.mp3" || exit 1

# parse merged duration
DURATION=$(sox "$TMP/audio.mp3" -n stat 2>&1 | sed -nE 's,Length \(seconds\): +([0-9.]+),\1,p')

ffmpeg \
    -loop 1 \
    -i "$BG_FILE" \
    -c:v libx264 \
    -t "$DURATION" \
    -pix_fmt yuv420p \
    -vf scale=1960:800 \
    -filter:v fps=30 \
    "$TMP/video.mp4" \
    || rm -rf "$TMP" \
    || exit 1

ffmpeg \
    -i "$TMP/video.mp4" -i "$TMP/audio.mp3" \
    -c:v copy \
    -map 0:v -map 1:a \
    -y "$OUTPUT_PATH/lofi.mp4" \
    || rm -rf "$TMP"  \
    || exit 1

rm -rf "$TMP"

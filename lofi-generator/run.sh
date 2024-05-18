#!/bin/bash

EPOCH=$(date +%s)

TMP="$OUTPUT_PATH/tmp-$EPOCH"
mkdir -p "$TMP"

OUTPUT_PATH="$TMP" python main.py \
    || rm -rf "$TMP" \
    || exit 1

DURATION=$(cat "$TMP/duration.txt")

ffmpeg \
    -loop 1 \
    -i "$BG_FILE" \
    -c:v libx264 \
    -t "$DURATION" \
    -pix_fmt yuv420p \
    -vf scale=1960:800 \
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

#!/bin/bash

EPOCH=$(date +%s)

TMP="$OUTPUT_PATH/tmp-$EPOCH"
mkdir -p "$TMP"

OUTPUT_PATH="$TMP" python main.py || exit 1

ffmpeg \
    -i "$TMP/video.mp4" -i "$TMP/audio.mp3" \
    -c:v copy \
    -map 0:v -map 1:a \
    -y "$OUTPUT_PATH/lofi.mp4"

rm -rf "$TMP"

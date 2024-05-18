#!/bin/bash

python main.py || exit 1

ffmpeg \
    -i "$OUTPUT_PATH/lofi.mp4" -i "$OUTPUT_PATH/lofi.mp3" \
    -c:v copy \
    -map 0:v -map 1:a \
    -y "$OUTPUT_PATH/lofi-final.mp4"

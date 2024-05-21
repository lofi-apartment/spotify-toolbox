#!/bin/bash

if [[ -z "$YOUTUBE_STREAM_KEY" ]]; then
    echo "Missing YOUTUBE_STREAM_KEY"
    exit 1
fi

if [[ -z "$FILE" ]]; then
    echo "Missing FILE"
    exit 1
fi

run_stream () {
    ffmpeg \
        -hide_banner \
        -re \
        -i "$FILE" \
        -pix_fmt yuvj420p \
        -x264-params keyint=48:min-keyint=48:scenecut=-1 \
        -b:v 4500k \
        -b:a 128k \
        -ar 44100 \
        -acodec aac \
        -vcodec libx264 \
        -preset ultrafast \
        -crf 28 \
        -threads 4 \
        -f flv \
        "rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_KEY"
}

while run_stream; do :; done

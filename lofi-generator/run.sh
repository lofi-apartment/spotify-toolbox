#!/bin/bash

EPOCH=$(date +%s)

TMP="$OUTPUT_PATH/tmp-$EPOCH"
mkdir -p "$TMP"
mkdir -p "$TMP/audio"

CWD=$(pwd)

if [[ -n "$PLAYLIST_URL" ]]; then
    cd "$AUDIOS_PATH"
    spotdl --output "{list-position}.{output-ext}"  --threads 4 --format wav "$PLAYLIST_URL" || exit 1
    cd "$CWD"
fi

files=()
count=0
while IFS='' read -r file; do
    if [[ -z "$file" ]]; then
        break
    fi

    files+=("$file")
done <<< "$(find "$AUDIOS_PATH" -name '*.wav' ! -name 'audio.wav')"

echo "Combining audio files"
sox $(printf "%q " "${files[@]}") "$TMP/audio.wav" || exit 1

# parse merged duration
DURATION=$(sox "$TMP/audio.wav" -n stat 2>&1 | sed -nE 's,Length \(seconds\): +([0-9.]+),\1,p')

echo "Generating background"
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

echo "Adding audio to video"
ffmpeg \
    -i "$TMP/video.mp4" -i "$TMP/audio.wav" \
    -c:v copy \
    -map 0:v -map 1:a \
    -y "$OUTPUT_PATH/lofi.mp4" \
    || rm -rf "$TMP"  \
    || exit 1

rm -rf "$TMP"

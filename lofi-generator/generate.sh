#!/bin/bash

FFMPEG='ffmpeg -hide_banner -loglevel warning'

EPOCH=$(date +%s)

TMP="$OUTPUT_PATH/tmp-$EPOCH"
mkdir -p "$TMP"
mkdir -p "$TMP/audio"

cleanuptmp () {
    echo "Command failed. Cleaning up"
    find $OUTPUT_PATH -path ./tmp-* -delete
    exit 1
}

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

echo "Combining ${#files[@]} audio files"
SECONDS=0
sox $(printf "%q " "${files[@]}") "$TMP/audio.wav" \
    || cleanuptmp \
    || exit 1

# parse merged duration
DURATION=$(sox "$TMP/audio.wav" -n stat 2>&1 \
    | sed -nE 's,Length \(seconds\): +([0-9.]+),\1,p')\
    || cleanuptmp \
    || exit 1

DURATION_ROUNDED_UP=$(printf '%.0f' "$DURATION")
DURATION_ROUNDED_UP=$((DURATION_ROUNDED_UP+1))

MINS=$((DURATION_ROUNDED_UP/60))
MINS=$(printf '%.0f' "$MINS")
HOURS=$(( MINS / 60 ))
HOURS=$(printf '%.1f' "$HOURS")
echo "Combining took ${SECONDS} seconds"
echo "Final : ${HOURS}h"

echo "Generating background"
SECONDS=0
$FFMPEG \
    -loop 1 \
    -i "$BG_FILE" \
    -c:v libx264 \
    -pix_fmt yuv420p \
    -t 1 \
    -vf 'scale=1920:1080,fps=30' \
    "$TMP/pre-video.mp4" \
    || cleanuptmp \
    || exit 1

$FFMPEG \
    -stream_loop "${DURATION_ROUNDED_UP}" \
    -i "$TMP/pre-video.mp4" \
    -c copy \
    -y "$TMP/video.mp4" \
    || cleanuptmp \
    || exit 1

echo "Generating background took ${SECONDS} seconds"

echo "Adding audio to video"
SECONDS=0
$FFMPEG \
    -i "$TMP/video.mp4" -i "$TMP/audio.wav" \
    -c:v copy \
    -map 0:v -map 1:a \
    -y "$OUTPUT_PATH/lofi.mp4" \
    || cleanuptmp \
    || exit 1

MINS=$(( SECONDS / 60 ))
MINS=$(printf '%.1f' "$MINS")
echo "Adding audio took ${MINS}m"

rm -rf "$TMP"

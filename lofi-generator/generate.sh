#!/bin/bash

if [[ -z "$AUDIOS_PATH" ]]; then
    echo "Command failed: AUDIOS_PATH unset"
    exit 1
elif [[ -z "$BG_FILE" ]]; then
    echo "Command failed: BG_FILE unset"
    exit 1
elif [[ -z "$OUTPUT_PATH" ]]; then
    echo "Command failed: BG_FILE unset"
    exit 1
elif [[ -z "$REGULAR_FONT" ]]; then
    echo "Command failed: REGULAR_FONT unset"
    exit 1
elif [[ -z "$BOLD_FONT" ]]; then
    echo "Command failed: BOLD_FONT unset"
    exit 1
fi

FFMPEG='ffmpeg -hide_banner -loglevel warning'

EPOCH=$(date +%s)

TMP="$OUTPUT_PATH/tmp-$EPOCH"
mkdir -p "$TMP"
mkdir -p "$TMP/audio"

cleanuptmp () {
    echo "Command failed. Cleaning up"
    find $OUTPUT_PATH -path '*/tmp-*' -delete
    exit 1
}

CWD=$(pwd)

if [[ -n "$PLAYLIST_URL" ]]; then
    cd "$AUDIOS_PATH"
    spotdl --output "{list-position}.{output-ext}"  --threads 4 --format wav "$PLAYLIST_URL" || exit 1
    cd "$CWD"
fi

# add files to array
files=()
while IFS='' read -r file || [[ -n "$file" ]]; do
    files+=("$file")
done <<< "$(find "$AUDIOS_PATH" -name '*.wav' ! -name 'audio.wav')"

echo "Combining ${#files[@]} audio files"
SECONDS=0
sox $(printf "%q " "${files[@]}") "$TMP/audio.wav" \
    || cleanuptmp \
    || exit 1

# parse track metadata and durations
parse_songs () {
    json_details='[]'
    order=0
    start_ms=0
    for file in "${files[@]}"; do
        file_details=$(ffprobe -i "$file" 2>&1)
        title=$(printf '%s' "$file_details" | sed -nE 's/ +title +: +(.+)/\1/p' | head -1)
        artist=$(printf '%s' "$file_details" | sed -nE 's/ +artist +: +(.+)/\1/p' | head -1)
        duration_string=$(printf '%s' "$file_details" | sed -nE 's/ +Duration: ([:.0-9]+),.+/\1/p' | head -1)

        duration_h=$(printf '%s' "$duration_string" | sed -nE 's/0?([0-9]+):0?([0-9]+):0?([0-9]+)\.0?([0-9]+)/\1/p')
        duration_m=$(printf '%s' "$duration_string" | sed -nE 's/0?([0-9]+):0?([0-9]+):0?([0-9]+)\.0?([0-9]+)/\2/p')
        duration_s=$(printf '%s' "$duration_string" | sed -nE 's/0?([0-9]+):0?([0-9]+):0?([0-9]+)\.0?([0-9]+)/\3/p')
        # fractional second uses centiseconds
        duration_cs=$(printf '%s' "$duration_string" | sed -nE 's/0?([0-9]+):0?([0-9]+):0?([0-9]+)\.0?([0-9]+)/\4/p')

        cs_ms=10
        s_ms=1000
        m_ms=$(( 60 * s_ms ))
        h_ms=$(( 60 * m_ms ))

        duration_ms=$(( (duration_h * h_ms) + (duration_m * m_ms) + (duration_s * s_ms) + (duration_cs * cs_ms) ))

        file_details=$(jq -rc --null-input \
            --argjson order "$order" \
            --arg title "$title" \
            --arg artist "$artist" \
            --argjson start_ms "$start_ms" \
            --argjson duration_ms "$duration_ms" \
            '{
                order: $order,
                title: $title,
                artist: $artist,
                start_ms: $start_ms,
                duration_ms: $duration_ms
            }')

        json_details=$(jq -rc --null-input \
            --argjson all "$json_details" \
            --argjson next "$file_details" \
            '$all | . += [$next]')

        order=$(( order + 1 ))
        start_ms=$(( start_ms + duration_ms ))
    done

    printf '%s\n' "$json_details" > "$TMP/track-details.json"
}

parse_songs || exit 1

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

generate-background () {
    echo "Generating background"

    SECONDS=0
    mkdir "$TMP/tracks"

    # initial image, 1s long
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

    # generate track videos, each with text added
    for encodedRow in $(cat "$TMP/track-details.json" | jq -r '.[] | @base64'); do
        track=$(printf '%s\n' "$encodedRow" | base64 --decode)
        title=$(printf '%s\n' "$track" | jq -rc '.title')
        artist=$(printf '%s\n' "$track" | jq -rc '.artist')
        order=$(printf '%s\n' "$track" | jq -rc '.order')
        order=$(printf '%05d' "$order")

        duration_s=$(printf '%s\n' "$track" | jq -rc '.duration_ms')
        duration_s=$(( duration_s / 1000 ))

        drawtext="drawtext=text='$title'"
        drawtext="${drawtext}:fontcolor='white'"
        drawtext="${drawtext}:fontfile='$BOLD_FONT'"
        drawtext="${drawtext}:fontsize=32"
        drawtext="${drawtext}:x=20"
        drawtext="${drawtext}:y=20"
        drawtext="${drawtext},drawtext=text='by $artist'"
        drawtext="${drawtext}:fontcolor='white'"
        drawtext="${drawtext}:fontfile='$REGULAR_FONT'"
        drawtext="${drawtext}:fontsize=24"
        drawtext="${drawtext}:x=20"
        drawtext="${drawtext}:y=20+40"

        $FFMPEG -re \
            -i "$TMP/pre-video.mp4" \
            -c:v libx264 \
            -c:a copy \
            -pix_fmt yuv420p \
            -vf "${drawtext}" \
            -y "$TMP/tracks/pre-$order.mp4" \
            || cleanuptmp \
            || exit 1

        $FFMPEG \
            -stream_loop "${duration_s}" \
            -i "$TMP/tracks/pre-$order.mp4" \
            -c copy \
            -y "$TMP/tracks/$order.mp4" \
            || cleanuptmp \
            || exit 1

        echo "file '$TMP/tracks/$order.mp4'" >> "$TMP/track-files.txt"
    done

    # combine tracks into a single video
    $FFMPEG \
        -safe 0 \
        -f concat \
        -i "$TMP/track-files.txt" \
        -c copy \
        -y "$TMP/video.mp4" \
        || cleanuptmp \
        || exit 1

    rm -rf "$TMP/tracks"

    echo "Generating background took ${SECONDS} seconds"
}

generate-background

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

find $OUTPUT_PATH -path '*/tmp-*' -delete

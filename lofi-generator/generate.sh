#!/bin/bash

set -e

CWD=$(pwd)
cachedir=".lofigenerator"
FFMPEG='ffmpeg -hide_banner -loglevel warning'

source "$(dirname "${BASH_SOURCE[0]}")/helper.sh"

validate-inputs

trap cleanuptmp EXIT

setuptmp

download-playlist-if-needed

echo "Checking for changes..."
setup-audiocache

echo "Generating audio..."
list-audiofiles
combine-audiofiles

echo "Parsing track data..."
parse-track-details

echo "Generating background..."
generate-background

echo "Adding audio to video..."
add-audio

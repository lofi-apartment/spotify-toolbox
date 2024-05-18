#!/bin/bash

IMAGE_NAME=downloader

docker build . -t "${IMAGE_NAME}" || exit 1
docker run \
    -v $(pwd):/root \
    "${IMAGE_NAME}" \
    spotdl --ffmpeg /root/.spotdl/ffmpeg $@

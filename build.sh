#!/usr/bin/env bash

set -xeo pipefail

cd "$(dirname "$0")"

DOCKERFILE=${1:?usage: $0 <dockerfile>}
DOWNLOADS=downloads.${DOCKERFILE#Dockerfile.}

docker buildx inspect ffbuilder &>/dev/null || docker buildx create \
    --bootstrap \
    --name ffbuilder \
    --buildkitd-flags "--oci-max-parallelism=4" \
    --driver-opt network=host \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1

if grep -q '^FROM .* AS downloader$' "$DOCKERFILE"; then
    if [[ ! -d downloads ]]; then
        bash download.sh Dockerfile.0.clean downloads
    fi
    cp -lrP downloads/. "$DOWNLOADS"
    bash download.sh "$DOCKERFILE" "$DOWNLOADS"
fi

docker buildx build \
    --builder ffbuilder \
    --load \
    --build-arg ENABLE_FDKAAC=1 \
    -t static-ffmpeg-fdk \
    --build-arg DOCKERFILE="$DOCKERFILE" \
    --build-arg DOWNLOADS="$DOWNLOADS" \
    -f "$DOCKERFILE" .

rm -rf "$DOWNLOADS"

docker buildx build \
    --build-arg CACHE_BUST="$(date +%s)" \
    --target export \
    --output type=local,dest=. \
    -f export .

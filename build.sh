#!/usr/bin/env bash

set -xeo pipefail

cd "$(dirname "$0")"

DOCKERFILE=${1:?usage: $0 <dockerfile>}

docker buildx inspect ffbuilder &>/dev/null || docker buildx create \
    --bootstrap \
    --name ffbuilder \
    --buildkitd-flags "--oci-max-parallelism=4" \
    --driver-opt network=host \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1

CACHE=
if [[ -d downloads ]] && grep -q '^FROM .* AS downloader$' "$DOCKERFILE"; then
    CACHE=downloads
fi

docker buildx build \
    --builder ffbuilder \
    --load \
    --build-arg ENABLE_FDKAAC=1 \
    ${HTTP_PROXY:+--build-arg http_proxy="$HTTP_PROXY"} \
    -t static-ffmpeg-fdk \
    --build-arg DOCKERFILE="$DOCKERFILE" \
    ${CACHE:+--build-context downloads="$CACHE"} \
    -f "$DOCKERFILE" .

docker buildx build \
    --build-arg CACHE_BUST="$(date +%s)" \
    --target export \
    --output type=local,dest=. \
    -f export .

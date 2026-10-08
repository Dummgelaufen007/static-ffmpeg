#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

DOCKERFILES=("${@:?usage: $0 <dockerfile>...}")
LOGDIR="buildtime-$(date +%y%m%d_%H%M%S)"
BUILDER=buildtime
PARALLELISM=3

fmt() {
    printf '%02d:%02d:%02d' $(($1 / 3600)) $((($1 % 3600) / 60)) $(($1 % 60))
}

mkdir -p "$LOGDIR"

docker buildx inspect "$BUILDER" &>/dev/null || docker buildx create \
    --bootstrap \
    --name "$BUILDER" \
    --buildkitd-flags "--oci-max-parallelism=$PARALLELISM" \
    --driver-opt network=host \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1

secs=()
rcs=()
tags=()

for df in "${DOCKERFILES[@]}"; do
    tag="buildtime-${df,,}"
    tags+=("$tag")
    log="$LOGDIR/$df.log"

    echo "=== $df -> $tag (Log: $log)"
    cache=
    if [[ -d downloads ]] && grep -q '^FROM .* AS downloader$' "$df"; then
        cache=downloads
    fi
    start=$(date +%s)
    rc=0
    docker buildx build \
        --builder "$BUILDER" \
        --load \
        --no-cache \
        --progress=rawjson \
        --build-arg ENABLE_FDKAAC=1 \
        ${HTTP_PROXY:+--build-arg http_proxy="$HTTP_PROXY"} \
        --build-arg DOCKERFILE="$df" \
        ${cache:+--build-context downloads="$cache"} \
        -t "$tag" \
        -f "$df" . 2>&1 | tee "$log" 2>&1 || rc=$?
    elapsed=$(($(date +%s) - start))

    secs+=("$elapsed")
    rcs+=("$rc")

    if [[ $rc -eq 0 ]]; then
        echo "    ok   $(fmt "$elapsed")"
    else
        echo "    FEHLGESCHLAGEN (rc=$rc) nach $(fmt "$elapsed"), letzte Zeilen:"
        tail -n 20 "$log" | sed 's/^/    | /'
    fi
done

echo
echo "=== Ergebnis"
width=0
for df in "${DOCKERFILES[@]}"; do
    label="Differenz $df"
    if [[ ${#label} -gt $width ]]; then
        width=${#label}
    fi
done

for i in "${!DOCKERFILES[@]}"; do
    if [[ ${rcs[$i]} -eq 0 ]]; then
        printf '%-*s  %s  (%d s)\n' \
            "$width" "${DOCKERFILES[$i]}" "$(fmt "${secs[$i]}")" "${secs[$i]}"
    else
        printf '%-*s  %s  FEHLGESCHLAGEN (rc=%d)\n' \
            "$width" "${DOCKERFILES[$i]}" "$(fmt "${secs[$i]}")" "${rcs[$i]}"
    fi
done

for i in "${!DOCKERFILES[@]}"; do
    if [[ $i -gt 0 && ${rcs[0]} -eq 0 && ${rcs[$i]} -eq 0 ]]; then
        delta=$((secs[$i] - secs[0]))
        if [[ $delta -lt 0 ]]; then
            sign=-
            abs=$((-delta))
        else
            sign=+
            abs=$delta
        fi
        printf '%-*s %s%s  (%s%d s, %s%s %%)\n' \
            "$width" "Differenz ${DOCKERFILES[$i]}" \
            "$sign" "$(fmt "$abs")" \
            "$sign" "$abs" \
            "$sign" "$(awk -v a="$abs" -v b="${secs[0]}" 'BEGIN { printf "%.1f", a * 100 / b }')"
    fi
done

echo
echo "=== Aufräumen"
docker image rm -f "${tags[@]}" >/dev/null 2>&1 || true
docker buildx rm -f "$BUILDER"

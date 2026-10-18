#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

find buildtime* -name "*.log" -exec xz -9 -v -T0 {} \;
rsync -aPh --rsync-path='/opt/bin/rsync' ./buildtime* nasa:/share/Media/Projekte/docker/wader/static-ffmpeg/buildlogs/${HOSTNAME,,}/
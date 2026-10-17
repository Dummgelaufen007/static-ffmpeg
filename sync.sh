#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

rsync -aPh --delete --exclude="/.*" nasa:/share/Media/Projekte/docker/wader/static-ffmpeg/ .
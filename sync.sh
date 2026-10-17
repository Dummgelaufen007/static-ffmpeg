#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

rsync -aPh --rsync-path='/opt/bin/rsync' --exclude={'/.*','/buildlogs'} --delete-delay --delete-excluded nasa:/share/Media/Projekte/docker/wader/static-ffmpeg/ .
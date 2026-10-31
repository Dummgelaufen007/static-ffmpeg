# Fetch ffmpeg as .tar.xz

With this PR ffmpeg is fetched as .tar.xz instead of .tar.bz2 ([releases](https://ffmpeg.org/releases/)): the same release, 17 % smaller to download (14.46 MB → 12.04 MB). The unpacked top directory stays the same.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `ffmpeg` URL, sha256 and archive name changed to the .tar.xz |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

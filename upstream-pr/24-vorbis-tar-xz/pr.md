# Fetch vorbis as .tar.xz

With this PR vorbis is fetched as .tar.xz instead of .tar.gz ([releases](https://downloads.xiph.org/releases/vorbis/)): the same release, 27 % smaller to download (1.66 MB → 1.20 MB). The unpacked top directory stays the same.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `vorbis` URL, sha256 and archive name changed to the .tar.xz |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

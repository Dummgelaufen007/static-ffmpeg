# Fetch ogg as .tar.xz

With this PR ogg is fetched as .tar.xz instead of .tar.gz ([releases](https://downloads.xiph.org/releases/ogg/)): the same release, 27 % smaller to download (0.60 MB → 0.44 MB). The unpacked top directory stays the same.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `ogg` URL, sha256 and archive name changed to the .tar.xz |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

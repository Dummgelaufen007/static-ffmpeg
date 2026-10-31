# Fetch xvid as .tar.bz2

With this PR xvid is fetched as .tar.bz2 instead of .tar.gz ([releases](https://downloads.xvid.com/downloads/)): the same release, 15 % smaller to download (0.82 MB → 0.70 MB). The unpacked top directory stays the same.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `xvid` URL, sha256 and archive name changed to the .tar.bz2 |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

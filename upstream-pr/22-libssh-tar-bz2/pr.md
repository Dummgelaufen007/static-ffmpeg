# Fetch libssh as .tar.bz2

With this PR libssh is fetched as .tar.bz2 instead of .tar.gz ([releases](https://gitlab.com/libssh/libssh-mirror/-/tags)): the same release, 23 % smaller to download (1.12 MB → 0.86 MB). The unpacked top directory stays the same.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `libssh` URL, sha256 and archive name changed to the .tar.bz2 |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

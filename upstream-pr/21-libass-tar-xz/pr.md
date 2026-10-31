# Fetch libass as .tar.xz

With this PR libass is fetched as .tar.xz instead of .tar.gz ([releases](https://github.com/libass/libass/releases)): the same release, 29 % smaller to download (0.65 MB → 0.46 MB). The unpacked top directory stays the same.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `libass` URL, sha256 and archive name changed to the .tar.xz |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

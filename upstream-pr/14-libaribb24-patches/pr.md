# Apply the decoder fixes of libaribb24's open pull requests

With this PR libaribb24 builds with the decoder fixes of three pull requests that are still open upstream: [12](https://github.com/nkoriyama/aribb24/pull/12), [13](https://github.com/nkoriyama/aribb24/pull/13) and [17](https://github.com/nkoriyama/aribb24/pull/17).

The commits are fetched as patches with a checksum and applied before the build. They are identical to BtbN's [patches](https://github.com/BtbN/FFmpeg-Builds/tree/6c9aec5fc9a72ec3abedd1fa84db141fa18cf52b/patches/aribb24).

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `ARG` with URL and sha256 for each of the three patches |
| `Dockerfile` | the libaribb24 recipe downloads, checks and applies them |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

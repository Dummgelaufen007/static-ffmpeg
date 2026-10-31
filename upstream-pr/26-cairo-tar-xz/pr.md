# Fetch cairo as release tarball from cairographics.org

With this PR cairo is fetched as the `.tar.xz` release tarball from [cairographics.org](https://cairographics.org/releases/) instead of the generated `.tar.gz` archive on gitlab.freedesktop.org: the same release, 32 % smaller to download (47.84 MB → 32.73 MB).

This goes back to the host that #837 moved away from, because it was failing at the TLS handshake then.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `cairo` URL, sha256 and archive name changed to the `.tar.xz` |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

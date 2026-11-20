# Add libcurl

ffmpeg 9.1 has a new `libcurl` protocol, an alternative to the native `http`/`https`. It runs all connections of one input, such as the segments of an HLS stream, on a shared libcurl event loop, so they reuse connections and can multiplex over HTTP/2 and HTTP/3. The native protocol stays the default. libcurl is used with a `libcurl:` URL prefix or with `-prefer_libcurl 1` ([protocols.texi#L1115-L1126](https://github.com/FFmpeg/FFmpeg/blob/n9.1/doc/protocols.texi#L1115-L1126)).

## Why curl is built instead of taken from apk

Alpine's `curl-static` links statically, but it is built without HTTP/3. curl's HTTP/3 with OpenSSL goes through ngtcp2's OpenSSL backend, which needs OpenSSL 3.5 or newer ([HTTP3.md#L52](https://github.com/curl/curl/blob/curl-8_23_0/docs/HTTP3.md#L52)). Alpine's `ngtcp2-static` only ships the gnutls backend ([package contents](https://pkgs.alpinelinux.org/contents?name=ngtcp2-static&branch=v3.24&arch=aarch64)), so ngtcp2 is built against Alpine's OpenSSL 3.5. ffmpeg only uses curl for `http` and `https`, so curl is built without its other protocols.

libcurl is autodetected ([configure#L7241](https://github.com/FFmpeg/FFmpeg/blob/n9.1/configure#L7241)), so without `--enable-libcurl` a missing dependency drops the protocol without an error.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | apk packages for curl; ngtcp2 and libcurl recipes; `--enable-libcurl`; `libcurl`, `ngtcp2`, `nghttp2`, `nghttp3` in `versions.json` |
| `README.md` | libcurl in the list of libraries |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

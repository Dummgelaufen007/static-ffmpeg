# Add libcurl

ffmpeg 9.1 has a new `libcurl` protocol next to the native `http`/`https`. The native protocol stays the default; libcurl is used with a `libcurl:` URL prefix or with `-prefer_libcurl 1` ([protocols.texi#L1115-L1126](https://github.com/FFmpeg/FFmpeg/blob/n9.1/doc/protocols.texi#L1115-L1126)).

## What it adds

Compared with the native protocol, which uses HTTP/1.1, requests no compression and takes only `http://` proxies:

- HTTP/2 over HTTPS by default, HTTP/3 with `-http_version 3` ([libcurl.c#L1819-L1827](https://github.com/FFmpeg/FFmpeg/blob/n9.1/libavformat/libcurl.c#L1819-L1827))
- shared connections and multiplexing for all requests of one input, such as HLS segments
- gzip, brotli and zstd compression
- HSTS and HTTPS proxies

## Build

curl is built with ngtcp2 and nghttp3 for HTTP/3, and only with `http` and `https`, which is all ffmpeg uses. libcurl is autodetected ([configure#L7241](https://github.com/FFmpeg/FFmpeg/blob/n9.1/configure#L7241)), so without `--enable-libcurl` a missing dependency drops the protocol without an error.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | apk packages for curl; ngtcp2 and libcurl recipes; `--enable-libcurl`; `libcurl`, `ngtcp2`, `nghttp2`, `nghttp3` in `versions.json` |
| `README.md` | libcurl in the list of libraries |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

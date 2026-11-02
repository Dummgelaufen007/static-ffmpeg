# Download sources with curl

As asked in #861: all downloads now use curl instead of wget. wget gives up on a failed TLS handshake despite `--tries`, curl with `--retry-all-errors` tries again. That is how #861 failed twice, on ffmpeg.org and downloads.xiph.org.

`CURL_OPTS` replaces `WGET_OPTS` with the same retries and timeout, and `curl` takes the place of `wget` in `apk add`.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

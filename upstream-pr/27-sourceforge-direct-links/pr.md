# Fetch the sourceforge sources by their direct links

With this PR libmodplug, mp3lame and opencore-amr are fetched from `downloads.sourceforge.net/project/...`, sourceforge's direct link to the file. It redirects once to a mirror (302 → 200). Archives and checksums stay the same.

Measured with `curl -sIL <url>` for the redirects and an `ADD --checksum` of each URL for the download page, which fails with a digest mismatch; this is what it replaces:

| Library | Effect |
|---|---|
| libmodplug | `wget` gets the archive, `ADD` gets sourceforge's HTML download page |
| mp3lame | one redirect less (302 → 302 → 200 before) |
| opencore-amr | three redirects less (301 → 301 → 302 → 302 → 200 before); `wget` gets the archive, `ADD` gets the HTML download page |

So this also clears the way for #841.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `LIBMODPLUG_URL`, `MP3LAME_URL` and `OPENCOREAMR_URL` changed to the direct links |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

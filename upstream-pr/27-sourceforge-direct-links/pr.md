# Fetch the sourceforge sources by their direct links

With this PR libmodplug, mp3lame and opencore-amr are fetched from `downloads.sourceforge.net/project/...`, sourceforge's direct link to the file, so all three use the same URL scheme. It redirects once to a mirror (302 → 200). Archives and checksums stay the same.

Measured with `curl -sIL <url>`; this is what it replaces:

| Library | Effect |
|---|---|
| libmodplug | one redirect less (301 → 302 → 200 before) |
| mp3lame | one redirect less (302 → 302 → 200 before) |
| opencore-amr | three redirects less (301 → 301 → 302 → 302 → 200 before) |

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `LIBMODPLUG_URL`, `MP3LAME_URL` and `OPENCOREAMR_URL` changed to the direct links |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

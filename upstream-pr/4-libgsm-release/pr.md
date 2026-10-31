# Release archive instead of a 2018 mirror commit for libgsm

With this PR libgsm builds from the release archive 1.0.24 on the project's home page with a sha256, and bump reports libgsm releases.

libgsm has no git repository; its author publishes releases as archives on [quut.com/gsm](https://www.quut.com/gsm/). The GitHub mirror stopped at "Import of 1.0.17" in 2018, so bump never saw the releases 1.0.18 to 1.0.24.

## Changes

| Library | Change |
|---|---|
| libgsm | archive 1.0.24 from quut.com with sha256; bump on the home page |
| `versions.json` | `libgsm` as version |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

# Add libunibreak for wrap_unicode in the subtitles filter

With this PR `wrap_unicode=1` of the `subtitles` filter works: libass is built with libunibreak, in a new recipe before it, as Alpine has no static archive of it.

ffmpeg passes the option to libass and otherwise warns "libass wasn't built with ASS_FEATURE_WRAP_UNICODE support" ([vf_subtitles.c#L484-L492](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/libavfilter/vf_subtitles.c#L484-L492)). libass enables the feature only when it finds libunibreak ([configure.ac#L124-L128](https://github.com/libass/libass/blob/0.17.5/configure.ac#L124-L128), [ass.c#L1817](https://github.com/libass/libass/blob/0.17.5/libass/ass.c#L1817)).

## Changes

| File | Change |
|---|---|
| `Dockerfile` | libunibreak 8.0 recipe before libass, with bump lines |
| `Dockerfile` | `--enable-libunibreak` for libass |
| `Dockerfile` | `libunibreak` in `versions.json` |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

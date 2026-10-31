# Encode alpha with x265

With this PR `yuva420p` works with libx265.

ffmpeg offers that pixel format for every x265 of this version ([libx265.c#L984-L987](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/libavcodec/libx265.c#L984-L987)), but x265 builds alpha encoding only with `-DENABLE_ALPHA=ON` ([CMakeLists.txt#L905](https://github.com/Multicorewareinc/x265/blob/4.3/source/CMakeLists.txt#L905)).

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `-DENABLE_ALPHA=ON` in the `CMAKEFLAGS` of x265 |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

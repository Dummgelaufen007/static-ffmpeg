# Decode 10 bit streams with uavs3d

With this PR uavs3d decodes 10 bit streams: `-DCOMPILE_10BIT=1` ([CMakeLists.txt#L93-L98](https://github.com/uavs3/uavs3d/blob/1.2/source/CMakeLists.txt#L93-L98)) sets `BIT_DEPTH` to 10 ([com_def.h#L44-L49](https://github.com/uavs3/uavs3d/blob/1.2/source/decore/com_def.h#L44-L49)). An 8 bit build rejects such streams with `ERR_BAD_BITDEPTH` ([parser.c#L97-L101](https://github.com/uavs3/uavs3d/blob/1.2/source/decoder/parser.c#L97-L101)).

`-DCOMPILE_10BIT=1` is uavs3d's own option, and its arm64 sources handle it ([arm64.c#L100](https://github.com/uavs3/uavs3d/blob/1.2/source/decore/arm64/arm64.c#L100), [pixel_arm64.S#L37](https://github.com/uavs3/uavs3d/blob/1.2/source/decore/arm64/pixel_arm64.S#L37)). An arm64 build has not been run yet.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `-DCOMPILE_10BIT=1` for uavs3d |
| `Dockerfile` | the comment on `BIT_DEPTH` replaced |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

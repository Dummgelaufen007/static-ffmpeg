# Enable assembler in davs2 and xavs2 on x86_64

This PR turns on the assembler of davs2 and xavs2 on x86_64. Both build on musl and link as static-pie without text relocations; the commit that added the TODO comment on musl gives no reason ([230fc97](https://github.com/wader/static-ffmpeg/commit/230fc9727d77a6a8118eba58c165d2be19fcd5ab)).

xavs2 encodes 3.5x, davs2 decodes 1.5x as fast (library CLIs, 640x352).

## Why x86_64 only

Both projects have assembler for x86 only ([davs2](https://github.com/pkuvcl/davs2/tree/1.7/source/common), [xavs2](https://github.com/pkuvcl/xavs2/tree/1.4/source/common)). On aarch64 `configure` still turns it on and the build fails on missing files ([davs2#28](https://github.com/pkuvcl/davs2/issues/28), [xavs2#28](https://github.com/pkuvcl/xavs2/issues/28)), so `--disable-asm` stays on every other architecture.

## CPU requirements

All sources get SIMD flags, so decoding needs AVX ([Makefile#L88](https://github.com/pkuvcl/davs2/blob/1.7/build/linux/Makefile#L88)) and encoding SSE4.1 ([Makefile#L126](https://github.com/pkuvcl/xavs2/blob/1.4/build/linux/Makefile#L126)); 0.78 and 0.08 % of x86 systems lack them ([Steam survey](https://store.steampowered.com/hwsurvey/), 2026-09).

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `--disable-asm` only off x86_64, in the davs2 and xavs2 recipes |
| `Dockerfile` | the two TODO comments on asm with musl removed |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

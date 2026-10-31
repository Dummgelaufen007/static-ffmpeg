# Enable assembler in davs2 and xavs2 on x86_64

With this PR davs2 and xavs2 use their assembler on x86_64. `--disable-asm` stays on every other architecture, as the source has assembler for x86 only ([davs2](https://github.com/pkuvcl/davs2/tree/1.7/source/common), [xavs2](https://github.com/pkuvcl/xavs2/tree/1.4/source/common)). With the assembler on, both link as static-pie.

xavs2 encodes 3.5x, davs2 decodes 1.5x as fast (library CLIs, 640x352).

## CPU requirements

All sources get SIMD flags, so decoding needs AVX ([Makefile#L88](https://github.com/pkuvcl/davs2/blob/1.7/build/linux/Makefile#L88)) and encoding SSE4.1 ([Makefile#L126](https://github.com/pkuvcl/xavs2/blob/1.4/build/linux/Makefile#L126)); 0.78 and 0.08 % of x86 systems lack them ([Steam survey](https://store.steampowered.com/hwsurvey/), 2026-09).

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `--disable-asm` only off x86_64, in the davs2 and xavs2 recipes |
| `Dockerfile` | the two TODO comments on asm with musl removed |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

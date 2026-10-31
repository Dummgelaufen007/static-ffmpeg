# Add libopenmpt

ffmpeg gains the `libopenmpt` demuxer for tracker music (MOD, XM, IT, S3M and many more) ([configure#L7413](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/configure#L7413)).

## How it is built

libopenmpt is built from its makefile release, which needs no autotools or cmake. Its switches ([Makefile#L202-L217](https://github.com/OpenMPT/openmpt/blob/libopenmpt-0.8.9/Makefile#L202-L217)) leave out everything but the static library: no shared library, no examples, no `openmpt123` player, no tests.

`NO_MPG123=1` selects the minimp3 copy libopenmpt bundles for MP3 samples inside modules ([Makefile#L1578-L1583](https://github.com/OpenMPT/openmpt/blob/libopenmpt-0.8.9/Makefile#L1578-L1583)), because Alpine has no static libmpg123. Ogg and Vorbis come from their own recipes, so this one sits after vorbis.

`CXXSTDLIB_PCLIBSPRIVATE=-lstdc++` puts the C++ runtime into the `Libs.private` of `libopenmpt.pc` ([Makefile#L811](https://github.com/OpenMPT/openmpt/blob/libopenmpt-0.8.9/Makefile#L811)), which the static link of ffmpeg needs.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | libopenmpt recipe with bump lines |
| `Dockerfile` | `--enable-libopenmpt` for ffmpeg |
| `Dockerfile` | `libopenmpt` in `versions.json` |
| `README.md` | libopenmpt in the list of libraries |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

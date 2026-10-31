# Add libdvdread and libdvdnav, with optional libdvdcss

ffmpeg gains the `dvdvideo` demuxer, which reads DVD-Video structures (titles, chapters, menus) from an image or directory. It needs libdvdread and libdvdnav ([configure#L7338-L7339](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/configure#L7338-L7339)).

## libdvdcss is opt-in

`ENABLE_LIBDVDCSS` builds libdvdcss and links it into libdvdread; without it ffmpeg reads unencrypted DVDs only. It has to be linked in at build time: when libdvdread is built without libdvdcss, it tries to load libdvdcss with `dlopen()` at runtime ([dvd_input.c#L77](https://code.videolan.org/videolan/libdvdread/-/blob/7.1.1/src/dvd_input.c#L77)), which a static binary cannot do. It is opt-in because it raises the same kind of legal question as fdk-aac.

## A define for musl

The recipe adds `-D_LARGEFILE64_SOURCE` to the `Cflags` of `dvdread.pc`, so every user of the library gets it. `dvd_reader.h` defines it itself so that `off64_t` exists in its public headers ([dvd_reader.h#L26-L28](https://code.videolan.org/videolan/libdvdread/-/blob/7.1.1/src/dvdread/dvd_reader.h#L26-L28)), but musl provides `off64_t` only when it is defined before the first `sys/types.h` ([sys/types.h#L74-L79](https://git.musl-libc.org/cgit/musl/tree/include/sys/types.h?h=v1.2.6#n74)), and in ffmpeg's sources other headers come first.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | libdvdcss, libdvdread and libdvdnav recipes, with bump lines; libdvdcss only with `ENABLE_LIBDVDCSS` |
| `Dockerfile` | `-D_LARGEFILE64_SOURCE` added to the `Cflags` of `dvdread.pc` |
| `Dockerfile` | `--enable-libdvdnav --enable-libdvdread` for ffmpeg |
| `Dockerfile` | `libdvdcss`, `libdvdnav`, `libdvdread` in `versions.json`; `libdvdcss` removed when `ENABLE_LIBDVDCSS` is empty |
| `README.md` | libdvdnav and libdvdread in the list of libraries |

## Build args

| Arg | Default | Meaning |
|---|---|---|
| `ENABLE_LIBDVDCSS` | empty | set to build libdvdcss and link it into libdvdread, for CSS-encrypted DVDs |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

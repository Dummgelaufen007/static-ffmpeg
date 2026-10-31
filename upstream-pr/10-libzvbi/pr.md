# Add libzvbi

ffmpeg gains the `libzvbi_teletext` decoder, which turns DVB teletext pages and subtitles into text or bitmap subtitles ([configure#L7510](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/configure#L7510)).

## Why zvbi gets a stage of its own

This PR adds a small `zvbi` stage before the builder. It installs the autotools and `gettext-dev`, fetches the source and runs only `autoreconf`. The builder copies the prepared tree and runs `configure` and `make` there, with `--disable-nls`, so nothing of gettext reaches the binary.

The stage keeps `gettext-dev` out of the builder. zvbi releases carry only a signature ([v0.2.45](https://github.com/zapping-vbi/zvbi/releases/tag/v0.2.45)), so the source is the archive of the git tag and needs `autoreconf`, which finds the gettext macros of zvbi's `configure.ac` ([#L505-L507](https://github.com/zapping-vbi/zvbi/blob/v0.2.45/configure.ac#L505-L507)) only with `gettext-dev` installed. But musl has gettext in its libc, while the `libintl.h` of GNU gettext redirects `gettext` and the rest to `libintl_`-prefixed symbols ([libgnuintl.in.h#L63](https://github.com/autotools-mirror/gettext/blob/master/gettext-runtime/intl/libgnuintl.in.h#L63)). Every later recipe, glib and ffmpeg included, would then need GNU libintl. `gettext-dev` also ships `/usr/include/libintl.h`, the one file of `musl-libintl`, so the two packages cannot be installed together.

## What is left out

ffmpeg only decodes with zvbi. The capture interfaces (V4L, DVB, proxy) are disabled, and PNG page export is switched off by presetting the libpng check to `no` ([configure.ac#L315-L322](https://github.com/zapping-vbi/zvbi/blob/v0.2.45/configure.ac#L315-L322)). Only the library in `src` and the `.pc` file are built and installed.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `zvbi` stage before `builder`: autotools and `gettext-dev`, download, `autoreconf` |
| `Dockerfile` | zvbi recipe in the builder: copies the tree from the `zvbi` stage, `configure`, `make` |
| `Dockerfile` | `--enable-libzvbi` for ffmpeg |
| `Dockerfile` | `libzvbi` in `versions.json`, read with `pkg-config` |
| `README.md` | libzvbi in the list of libraries |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

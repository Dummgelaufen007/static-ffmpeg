# Add libzvbi

Adds the `libzvbi_teletext` decoder: DVB teletext pages and subtitles to text or bitmap subtitles ([configure#L7510](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/configure#L7510)).

## Why zvbi gets a stage of its own

The `zvbi` stage only generates `configure`, because that needs `gettext-dev`; running `configure --disable-nls` and `make` stays in the builder.

zvbi releases carry only a signature ([v0.2.45](https://github.com/zapping-vbi/zvbi/releases/tag/v0.2.45)), so the source is the archive of the git tag, and `autoreconf` has to generate `configure`. It finds the gettext macros of zvbi's `configure.ac` ([#L505-L507](https://github.com/zapping-vbi/zvbi/blob/v0.2.45/configure.ac#L505-L507)) only with `gettext-dev` installed.

`gettext-dev` has to stay out of the builder. musl has gettext in its libc, while the `libintl.h` of GNU gettext redirects `gettext` and the rest to `libintl_`-prefixed symbols ([libgnuintl.in.h#L63](https://github.com/autotools-mirror/gettext/blob/master/gettext-runtime/intl/libgnuintl.in.h#L63)). Every later recipe, glib and ffmpeg included, would then need GNU libintl. `musl-libintl` consists only of `/usr/include/libintl.h`, which `gettext-dev` ships too, so the two packages cannot be installed together.

## What is left out

ffmpeg only decodes with zvbi. The capture interfaces (V4L, DVB, proxy) are disabled, and PNG page export is switched off by presetting the libpng check to `no` ([configure.ac#L315-L322](https://github.com/zapping-vbi/zvbi/blob/v0.2.45/configure.ac#L315-L322)). Only the library in `src` and the `.pc` file are built and installed.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `zvbi` stage and builder recipe; `--enable-libzvbi`; `libzvbi` in `versions.json` via `pkg-config` |
| `README.md` | libzvbi in the list of libraries |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

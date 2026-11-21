# Add libzvbi

Adds the `libzvbi_teletextdec` decoder (DVB teletext to text or bitmap subtitles).

zvbi has no release tarballs since moving to GitHub, the [releases](https://github.com/zapping-vbi/zvbi/releases) only have a `.asc`. So it builds from the tag archive and needs `autoreconf`, which needs `gettext-dev` for zvbi's gettext macros. `gettext-dev` conflicts with `musl-libintl`, and its `libintl.h` would make glib and ffmpeg link GNU libintl, so `autoreconf` runs in a separate stage and the builder only gets the generated source.

Only the decoding library is built: no V4L/DVB/proxy capture, no PNG export, no NLS.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

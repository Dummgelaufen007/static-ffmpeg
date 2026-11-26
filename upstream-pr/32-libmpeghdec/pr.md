# Add libmpeghdec

- libmpeghdec: https://github.com/Fraunhofer-IIS/mpeghdec

## Assessment

- FFmpeg 9.1: decoder `libmpeghdec` for MPEG-H 3D Audio, decoding only; FFmpeg has no native MPEG-H decoder. `configure` requires `mpeghdec >= 3.0.0` via pkg-config; output defaults to 48 kHz.
- Licence: listed in `EXTERNAL_LIBRARY_NONFREE_LIST`, so it needs `--enable-nonfree` and belongs behind a switch like `ENABLE_FDKAAC`.
- Use: object-based immersive audio in ATSC 3.0, Brazil's TV 3.0, a DVB option and 360 Reality Audio (not checked against a source). Without it, the audio of such broadcast recordings cannot be decoded.
- Container relevance: high wherever broadcast recordings are processed.
- Future: growing.
- Open: static musl build not checked.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

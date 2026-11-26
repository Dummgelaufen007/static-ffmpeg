# Add liblc3

- liblc3: https://github.com/google/liblc3

## Assessment

- FFmpeg 9.1: encoder and decoder `liblc3`; no native LC3 codec. The `lc3` muxer and demuxer are already built in. `configure` requires `lc3 >= 1.1.0` and checks `lc3_hr_setup_encoder` (high-resolution mode, guess).
- Use: mandatory codec of Bluetooth LE Audio and Auracast; liblc3 is Google's implementation from Android (not checked against a source).
- Container relevance: low; LC3 mostly lives on the radio link and rarely shows up as a file. Small and cheap to build.
- Future: growing, but rarely in files.
- Open: static musl build not checked.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

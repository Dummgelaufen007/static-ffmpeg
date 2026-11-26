# Add liblcevc_dec

- liblcevc_dec: https://github.com/v-novaltd/LCEVCdec

## Assessment

- FFmpeg 9.1: filter `lcevc` (`lcevc_filter_deps="liblcevc_dec"`), decodes the LCEVC enhancement layer on top of the base codec.
- Use: LCEVC (MPEG-5 Part 2) enhances existing codecs instead of replacing them; adopted in DVB and, as a guess, in Brazil's TV 3.0 (not checked against a source).
- Container relevance: medium; decodes LCEVC streams at full quality.
- Future: growing.
- Open: static musl build not checked.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

# Add libopencolorio

- libopencolorio: https://github.com/AcademySoftwareFoundation/OpenColorIO

## Assessment

- FFmpeg 9.1: filter `ocio` (`ocio_filter_deps="libopencolorio"`); `configure` checks the C++ header `OpenColorIO/OpenColorIO.h` via pkg-config.
- Use: colour management in VFX pipelines, standard there together with ACES (not checked against a source).
- Build: needs yaml-cpp, Imath, pystring and minizip-ng (not checked against a source).
- Runtime data: OCIO configurations, passed in from outside (volume in a container).
- Container relevance: medium.
- Future: stable.
- Open: static musl build not checked.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

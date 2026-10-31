# Tag archive instead of a master commit for uavs3d

With this PR uavs3d builds from the tag archive 1.2 with a sha256, and bump reports uavs3d tags instead of every commit on master. Tag 1.2 points to the same commit, so the code stays the same.

The one visible difference: `uavs3d.pc` reports 1.2.0 instead of 1.2.89. The build number is counted from the git history ([version.sh#L19](https://github.com/uavs3/uavs3d/blob/0e20d2c291853f196c68922a264bcd8471d75b68/version.sh#L19)) and written into `uavs3d.pc` by CMake ([source/CMakeLists.txt#L103-L137](https://github.com/uavs3/uavs3d/blob/0e20d2c291853f196c68922a264bcd8471d75b68/source/CMakeLists.txt#L103-L137)), and an archive has no history. ffmpeg requires `uavs3d >= 1.1.41` ([configure#L7371](https://github.com/FFmpeg/FFmpeg/blob/master/configure#L7371)) and does not read the version elsewhere.

## Changes

| Library | Change |
|---|---|
| uavs3d | tag archive 1.2 with sha256; bump on tags |
| `versions.json` | `libuavs3d` as version |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

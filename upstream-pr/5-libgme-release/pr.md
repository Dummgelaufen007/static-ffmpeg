# Release archive instead of a master commit for libgme

With this PR libgme builds from the release archive 0.6.5 with a sha256 ([release](https://github.com/libgme/game-music-emu/releases/tag/0.6.5)), and bump reports libgme releases instead of every commit on master.

This moves libgme 5 commits back: master already carries the version 0.6.6 for further development ([gme.h#L11](https://github.com/libgme/game-music-emu/blob/f68963b1de0633149b05732113d3c3113c6f63a1/gme/gme.h#L11)), which is not released yet. Among the 5 commits are "Ay_Emu.cpp: Don't read farther than buffer allows" and the zip and rar changes of the player ([compare](https://github.com/libgme/game-music-emu/compare/0.6.5...f68963b1de0633149b05732113d3c3113c6f63a1)). They come back with the next libgme release; merged once 0.6.6 is out, the PR changes no code.

## Changes

| Library | Change |
|---|---|
| libgme | release archive 0.6.5 with sha256; bump on tags |
| `versions.json` | `libgme` as version |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

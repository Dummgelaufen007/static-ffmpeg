# Enable HDR10+ in the 10 and 12 bit builds of x265

With this PR `dhdr10-info` works with libx265: a `sed` in `multilib.sh` adds `-DENABLE_HDR10_PLUS=ON` ([CMakeLists.txt#L280](https://github.com/Multicorewareinc/x265/blob/4.3/source/CMakeLists.txt#L280)) next to `-DHIGH_BIT_DEPTH=ON`, so it reaches the 10 and 12 bit builds only.

The flag also compiles `json11.cpp` ([dynamicHDR10/CMakeLists.txt#L2-L6](https://github.com/Multicorewareinc/x265/blob/4.3/source/dynamicHDR10/CMakeLists.txt#L2-L6)), which uses `uint8_t` without including `<cstdint>` ([json11.cpp#L22-L27](https://github.com/Multicorewareinc/x265/blob/4.3/source/dynamicHDR10/json11/json11.cpp#L22-L27)); g++ 15.2 needs the include.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `sed` in `multilib.sh` for `-DENABLE_HDR10_PLUS=ON` |
| `Dockerfile` | `sed` that adds `#include <cstdint>` to `json11.cpp` |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

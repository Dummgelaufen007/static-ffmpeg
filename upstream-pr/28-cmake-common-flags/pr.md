# Bundle the common CMake options in one ARG

With this PR the four options every CMake recipe needs come from one `ARG CMAKE_COMMON_FLAGS`, like `CFLAGS`, `CXXFLAGS` and `LDFLAGS`: one place to set them, and every recipe gets the same ones.

```
-DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_LIBDIR=lib
```

## Changes

| File | Change |
|---|---|
| `Dockerfile` | new `ARG CMAKE_COMMON_FLAGS`, used by every CMake recipe; `-G"Unix Makefiles"` removed, it is CMake's default on Linux |
| `Dockerfile` | x265: the `multilib.sh` sed appends only `${CMAKEFLAGS}`, without `-G "Unix Makefiles"` |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

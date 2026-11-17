# Build libgsm with its own Makefile

libgsm's Makefile has a target for the library alone, `lib/libgsm.a`, which builds only the 18 sources of the codec and leaves out the toast tools. Called with `CCFLAGS` on the command line, it compiles with our `CFLAGS` and in parallel, so the hand-written `gcc`/`ar`/`ranlib` steps are no longer needed ([Dockerfile#L479-L488](https://github.com/wader/static-ffmpeg/blob/23ead1fbde5f5e54277fc5df34d7d4ec6ff485af/Dockerfile#L479-L488)).

The Makefile of gsm 1.0.24 sets its compile flags itself: `CC = gcc -ansi -pedantic` (line 46), `CCFLAGS = -c -O2 -DNeedFunctionPrototypes=1 -Wall -Wno-comment` (line 47), and `CFLAGS = $(CCFLAGS) $(SASR) … $(WAV49) … -I$(INC)` (line 132) with `-DSASR` and `-DWAV49` (lines 7, 25). A `CFLAGS` from the environment is therefore ignored, which is why the recipe bypassed the Makefile. Overriding `CCFLAGS` instead keeps everything the Makefile adds and replaces only `-O2` with our flags; `-DNDEBUG` stays as before. The resulting compile line:

```
gcc -ansi -pedantic -c -O3 -static-libgcc -fno-strict-overflow -fstack-protector-all -fPIC -DNeedFunctionPrototypes=1 -Wall -Wno-comment -DNDEBUG -DSASR -DWAV49 -I./inc src/add.c
```

The install targets are still not used: `gsminstall` puts `gsm.h` flat into `$(INSTALL_ROOT)/inc` (line 83), while ffmpeg includes `gsm/gsm.h`. So the header is copied by hand as before, now only `gsm.h`, the one header ffmpeg includes, instead of all of `inc/*.h`. The `-s` of the old line is dropped; it is a linker option and has no effect with `-c`.

## Check

Built both recipes from the same `gsm-1.0.24.tar.gz` in `alpine:3.24.4` with the `CFLAGS` of the Dockerfile (x86_64):

- `ar t`: the same 18 objects
- `nm -g --defined-only`: the same 42 symbols
- `size`: text 52481, data 160 for both
- a test program with `#include <gsm/gsm.h>` links with `-static-pie` against `-lgsm` and runs

## Changes

| Library | Change |
|---|---|
| libgsm | `make -j$(nproc) lib/libgsm.a` with `CCFLAGS` instead of a single `gcc` call; install only `gsm.h` |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

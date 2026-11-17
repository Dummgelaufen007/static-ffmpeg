# Build libgsm with its own Makefile

This builds libgsm with the Makefile target `lib/libgsm.a`, which compiles only the library. Our flags are passed as `CCFLAGS` on the command line, since the Makefile sets `CFLAGS` itself and ignores it from the environment.

The recipe gets shorter and compiles in parallel. The flags the Makefile sets (`-ansi -pedantic -DSASR -DWAV49`) are no longer repeated by hand. Besides our `CFLAGS`, only `-DNDEBUG` is passed.

The install target puts `gsm.h` flat into `inc/`, while ffmpeg includes `gsm/gsm.h`. So the header is still copied by hand, now only `gsm.h` instead of all of `inc/*.h`.

I built the old and the new recipe from `gsm-1.0.24.tar.gz` in `alpine:3.24.4`. Both `libgsm.a` have the same objects, symbols and sizes. The objects are byte-identical to a build that keeps the Makefile's other default flags. A test program including `gsm/gsm.h` links against the library with `-static-pie` and runs.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

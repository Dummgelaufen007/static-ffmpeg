# Build libgsm with its own Makefile

This builds libgsm with the Makefile target `lib/libgsm.a`, which compiles only the library. Our flags are passed as `CCFLAGS` on the command line, since the Makefile sets `CFLAGS` itself and ignores it from the environment.

The recipe gets shorter and compiles in parallel. The flags the Makefile sets (`-ansi -pedantic -DSASR -DWAV49`) are no longer repeated by hand. Only `-O2` is replaced by our `CFLAGS`, and `-DNDEBUG` stays.

The header is still copied by hand, since the install target puts `gsm.h` flat into `inc/` while ffmpeg includes `gsm/gsm.h`; now only `gsm.h` instead of all of `inc/*.h`.

Built both ways from `gsm-1.0.24.tar.gz` in `alpine:3.24.4`, both `libgsm.a` have the same objects, symbols and sizes, and a test program including `gsm/gsm.h` links against it with `-static-pie` and runs.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

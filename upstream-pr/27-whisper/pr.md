# Add whisper

Adds the `whisper` audio filter, speech-to-text with [whisper.cpp](https://github.com/ggml-org/whisper.cpp), as asked in #713. It builds on the `whisper` branch; the linking issue there comes from `whisper.pc`.

## Why whisper.pc is rewritten

whisper.cpp installs `Libs: -L${libdir} -lggml  -lggml-base -lwhisper` ([whisper.pc.in#L9](https://github.com/ggml-org/whisper.cpp/blob/v1.9.5/cmake/whisper.pc.in#L9)). That is fine for shared libraries, but in a static link the linker resolves left to right, so `-lwhisper` has to come before the ggml archives, and the CPU backend `libggml-cpu.a` is not listed at all. ffmpeg's configure check then fails with `undefined reference to 'ggml_backend_free'`. The sed sets the order and adds `-lggml-cpu`, `-lstdc++`, `-lm` and `-fopenmp`; ggml's CPU backend uses OpenMP by default, which ffmpeg already links.

## Why the backend loader is stubbed

`af_whisper` calls `ggml_backend_load_all()` once ([af_whisper.c#L96](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/libavfilter/af_whisper.c#L96)), which searches for backend plugins with `dlopen`. In a static build the CPU backend is compiled in (`GGML_BACKEND_DL` requires shared libs), and musl's static `dlopen` always fails, so the search can never succeed. The sed on `ggml-backend-dl.cpp`/`.h` replaces `dlopen`, `dlsym`, `dlerror` and `dlclose` there, so ggml no longer pulls them into the binary.

## Build options

`GGML_NATIVE=OFF` avoids `-march=native` of the build host. ggml then still enables AVX2, FMA, F16C and BMI2 for its CPU backend, so on amd64 the filter needs an AVX2 CPU; the rest of ffmpeg is unaffected. Examples, tests and server are not built.

## Changes

| File | Change |
|---|---|
| `Dockerfile` | whisper.cpp recipe; `--enable-whisper`; `whisper` in `versions.json`; `-h filter=whisper` test |
| `README.md` | whisper in the list of libraries |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

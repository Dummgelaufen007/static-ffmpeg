# whisper: findings

Issue: https://github.com/wader/static-ffmpeg/issues/713. wader's WIP branch
`upstream/whisper` (31abc79) used whisper.cpp 1.8.3; the slice uses 1.9.5.

## Link failure in the WIP branch

- `cmake/whisper.pc.in` (1.8.3 and 1.9.5 identical in this line):
  `Libs: -L${libdir} -lggml  -lggml-base -lwhisper`. Static link needs
  `-lwhisper` first and `-lggml-cpu`, which the line omits.
- kadaver, alpine 3.24.4, ffmpeg 9.0.2 configure with the WIP recipe:
  `whisper.cpp: undefined reference to 'ggml_backend_free'`. With
  `-lwhisper -lggml -lggml-cpu -lggml-base -lstdc++ -lm -fopenmp`:
  `CONFIG_WHISPER=yes`.

## Static link of all symbols af_whisper.c uses

- ffmpeg 9.0.2 `libavfilter/af_whisper.c` calls 21 `whisper_*` functions;
  none changed declaration between 1.8.3 and 1.9.5, nor the three params
  structs.
- 1.9.5, patched, OpenMP on: test program referencing all 21 links with
  `-static-pie`, runs, 0 `NEEDED`. 1.8.3 linked the same with OpenMP on and
  off.

## dlopen

- `af_whisper.c:96`: `ff_thread_once(&init_static_once, ggml_backend_load_all)`.
  ggml reaches `dlopen` through `dl_load_library`, in 1.9.5 in
  `ggml/src/ggml-backend-dl.cpp` (`dlclose` in `ggml-backend-dl.h`), in 1.8.3
  in `ggml-backend-reg.cpp`.
- `GGML_BACKEND_DL` with `BUILD_SHARED_LIBS=OFF` is a `FATAL_ERROR`, so the CPU
  backend is compiled in; musl's static `dlopen` is a weak stub that always
  fails.
- After the sed on `ggml-backend-dl.*`: no archive of whisper.cpp references
  `dlopen`/`dlsym`/`dlclose`. The binary still has them, from
  `libgomp.a(oacc-profiling.o)` and `libgomp.a(allocator.o)`.
- Published `mwader/static-ffmpeg:latest` `/ffmpeg` already contains libgomp
  (`GOMP_` 12, `ACC_PROFLIB` 2) and the musl stub string
  `Dynamic loading not supported`: OpenMP adds no new dlopen.
- `src/aneforge/whisper-aneforge.cpp` (new in 1.9.x) calls dlopen only under
  `__APPLE__ && __aarch64__`; a stub elsewhere.

## CPU features

- `ggml/CMakeLists.txt`: with `GGML_NATIVE=OFF` and a native default,
  `INS_ENB` is ON, so `GGML_SSE42`, `GGML_AVX`, `GGML_AVX2`, `GGML_BMI2`,
  `GGML_FMA`, `GGML_F16C` default ON. Without `GGML_CPU_ALL_VARIANTS` (needs
  `GGML_BACKEND_DL`) there is no runtime dispatch: the whisper filter needs an
  AVX2 CPU on amd64. Not measured on a CPU without AVX2.

## 1.8.3 → 1.9.5, relevant for the build

- New: `ggml-backend-dl.{cpp,h}`, `libparakeet` (installed, not linked by
  libwhisper), `aneforge/`, `vitisai/` (only with `WHISPER_VITISAI`, OFF).
- `whisper.pc.in`: `libdir` from `CMAKE_INSTALL_FULL_LIBDIR`; with
  `-DCMAKE_INSTALL_LIBDIR=lib` still `/usr/local/lib`.

## Not checked

- Full image build of the slice; `RUN ["/ffmpeg", "-h", "filter=whisper"]`.
- arm64.
- Transcription with a model.

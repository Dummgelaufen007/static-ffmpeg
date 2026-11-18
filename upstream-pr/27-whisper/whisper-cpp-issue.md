# whisper.pc does not work for static linking

With `BUILD_SHARED_LIBS=OFF`, `pkg-config --static --libs whisper` gives a link line that fails. For example, FFmpeg 9.0.2 configure with `--enable-whisper` fails with whisper.cpp v1.9.5 on Alpine 3.24 (musl, gcc 15.2):

```
whisper.cpp:(.text.unlikely+0x99): undefined reference to `ggml_backend_free'
```

`cmake/whisper.pc.in` is a fixed line, filled in only with paths:

```
Libs: -L${libdir} -lggml  -lggml-base -lwhisper
```

For a static build this has `-lwhisper` after the ggml archives and lists none of the backend archives (`libggml-cpu.a`, `libggml-blas.a`, …) or what they need (`-lstdc++`, `-lm`, threads, OpenMP, BLAS, Vulkan, …). `cmake/parakeet.pc.in` has the same problem.

For a CPU-only build with OpenMP, this works:

```
Libs: -L${libdir} -lwhisper -lggml -lggml-cpu -lggml-base -lstdc++ -lm -fopenmp
```

`ggml-config.cmake` sets the interface link libraries per backend for static builds, and `whisper-config.cmake` uses it. Only pkg-config users are affected.

A fix can generate `Libs.private` from the backends and dependencies CMake configured, or install `ggml.pc` and have `whisper.pc` require it. The second needs more than `Requires.private: ggml`, since `ggml.pc` is generated only with `GGML_STANDALONE` and `ggml/ggml.pc.in` is not in the whisper.cpp tree.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

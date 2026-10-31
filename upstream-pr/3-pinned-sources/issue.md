**Describe the bug**

libjxl decides which Highway targets it compiles through a fixed list,
`JPEGXL_HWY_TARGETS`. Every target in that list gets a
`JPEGXL_ENABLE_HWY_<target>` option, and the ones switched off are passed to
the compiler as `HWY_DISABLED_TARGETS`
([CMakeLists.txt#L128-L131](https://github.com/libjxl/libjxl/blob/v0.12.0/CMakeLists.txt#L128-L131),
[#L194-L201](https://github.com/libjxl/libjxl/blob/v0.12.0/CMakeLists.txt#L194-L201),
[#L222-L238](https://github.com/libjxl/libjxl/blob/v0.12.0/CMakeLists.txt#L222-L238)).
A target that is not in the list can therefore not be switched off; whether it
is compiled is left entirely to Highway.

Highway 1.3.0 added new targets, among them AVX10_2 and, on LoongArch, LSX and
LASX. None of them is in `JPEGXL_HWY_TARGETS`, on `main` either. Highway 1.4.0
compiles AVX10_2 by default on x86
([detect_targets.h#L909-L916](https://github.com/google/highway/blob/1.4.0/hwy/detect_targets.h#L909-L916))
and blocks it only for gcc < 15.2 and clang < 23
([#L198-L207](https://github.com/google/highway/blob/1.4.0/hwy/detect_targets.h#L198-L207)).

So when libjxl is built against a system Highway >= 1.3.0
(`JPEGXL_FORCE_SYSTEM_HWY=ON`, which
[third_party/CMakeLists.txt#L34](https://github.com/libjxl/libjxl/blob/v0.12.0/third_party/CMakeLists.txt#L34)
accepts from 1.0.7 on) with gcc 15.2 or newer, every `foreach_target` source is
additionally compiled for AVX10_2. That code path is neither tested by libjxl
(`deps.sh` still pins Highway 1.2.0, which has no AVX10_2) nor reachable through
the `JPEGXL_ENABLE_HWY_*` options. The bundled Highway is not affected.

Defining `HWY_DISABLED_TARGETS` from outside does not help either: libjxl then
warns "HWY_DISABLED_TARGETS is overridden; JPEGXL_ENABLE_hwy_target will be
ignored" and drops its own target selection
([#L222-L223](https://github.com/libjxl/libjxl/blob/v0.12.0/CMakeLists.txt#L222-L223)).

**To Reproduce**

Alpine 3.24.2 (gcc 15.2.0), x86_64:

1. Build and install Highway 1.4.0 as a static library (`BUILD_SHARED_LIBS=OFF`).
2. Build libjxl 0.12.0 with `-DJPEGXL_FORCE_SYSTEM_HWY=ON -DBUILD_SHARED_LIBS=OFF`
   and otherwise default target options.
3. Count the functions per target namespace in the result:

   ```sh
   for target in AVX10_2 AVX3_DL AVX2 SSE4 SSE2; do
     echo "$target: $(nm -C /usr/local/lib/libjxl.a | grep -c "N_${target}::")"
   done
   ```

Result:

```
AVX10_2: 794
AVX3_DL: 794
AVX2: 750
SSE4: 746
SSE2: 703
```

The targets libjxl switches off by default (AVX3, AVX3_SPR, AVX3_ZEN4) are at 0,
AVX10_2 is not.

Adding `#define HWY_BROKEN_AVX10_2 HWY_AVX10_2` to the installed
`hwy/detect_targets.h` brings AVX10_2 to 0 while libjxl's own target selection
stays in effect. The define has to come before Highway's own default for it,
which it then skips; after installing Highway and before configuring libjxl:

```sh
sed -i 's|^#ifndef HWY_BROKEN_AVX10_2  // allow override|#define HWY_BROKEN_AVX10_2 HWY_AVX10_2\n&|' /usr/local/include/hwy/detect_targets.h
```

Passing the same define through the `Cflags` of `libhwy.pc`
does not work: `jxl_dec-obj` and `jxl_enc-obj` take only Highway's include
directories
([lib/jxl.cmake#L119-L138](https://github.com/libjxl/libjxl/blob/v0.12.0/lib/jxl.cmake#L119-L138)),
not its interface compile options, so the define reaches only the targets that
link `hwy` directly.

**Expected behavior**

Every target Highway may compile is controllable through `JPEGXL_ENABLE_HWY_*`.
A suggestion: add AVX10_2, LSX and LASX to `JPEGXL_HWY_TARGETS`, with AVX10_2
in `JPEGXL_HWY_TARGETS_OFF_BY_DEFAULT` like AVX3_SPR and AVX3_ZEN4 until it is
covered by the tests.

**Environment**
 - OS: Alpine Linux 3.24.2 (static build)
 - Compiler version: gcc 15.2.0
 - CPU type: x86_64
 - cjxl/djxl version string: not built; libjxl 0.12.0, Highway 1.4.0

**Additional context**

Related: #4398 and #2269 (continuous testing with newer Highway and with
Highway master; their target matrix covers only targets in
`JPEGXL_HWY_TARGETS`, so AVX10_2 is not exercised), #4907 (build failure in
the SVE2_128 target with gcc 16.1 and Highway 1.4), #3887 (binary size: every
additional target adds a full copy of the SIMD code; AVX10_2 adds as many
functions as AVX3_DL, 794 in the reproduction above).

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

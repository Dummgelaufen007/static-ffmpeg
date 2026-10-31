# Satisfy lib requirements by apk: cairo

The cairo step downloads more than its own source: pixman is not installed, so meson fetches it during that step ([master build](https://github.com/wader/static-ffmpeg/actions/runs/41099660522/job/124214372586)).

| Lib | Needs | Hidden download from | Alpine packages | Package version |
|---|---|---|---|---|
| cairo | pixman 0.44.2 | `www.cairographics.org` | `pixman-dev pixman-static` | 0.46.4-r0 |

During the cairographics.org outage behind #837 this download failed as well: meson got past it, and the build stayed green with nothing but a warning in its log ([build of #837](https://github.com/wader/static-ffmpeg/actions/runs/38788273369/job/116605838413#step:5:6070)):

```
Downloading pixman source from https://www.cairographics.org/releases/pixman-0.44.2.tar.gz
<urlopen error _ssl.c:1064: The handshake operation timed out>
WARNING: failed to download with error: could not get https://www.cairographics.org/releases/pixman-0.44.2.tar.gz; is the internet available?. Trying after a delay...
```

With this PR meson does not download pixman. It comes from an Alpine package named in `apk add`, so a problem with it shows up in the first step of the build, under the package's own name.

## Alpine packages

Alpine ships pixman with a static archive. With the packages from the table installed, meson finds it and the build log has no "Downloading" line left ([build](https://github.com/wader/static-ffmpeg/actions/runs/41101956127/job/124220543899)).

Complete meson output of the step, master build against this PR: `-` appears only on master, `+` only with this PR.

<details><summary>cairo step</summary>

```diff
 The Meson build system
 Version: 1.11.1
 Source dir: /cairo-1.18.6
 Build dir: /cairo-1.18.6/build
 Build type: native build
 Program version.py found: YES (/cairo-1.18.6/version.py)
 Project name: cairo
 Project version: 1.18.6
 C compiler for the host machine: cc (gcc 15.2.0 "cc (Alpine 15.2.0) 15.2.0")
 C linker for the host machine: cc ld.bfd 2.45.1
 Host machine cpu family: x86_64
 Host machine cpu: x86_64
 Compiler for C supports arguments -Wmissing-declarations: YES 
 Compiler for C supports arguments -Werror-implicit-function-declaration: YES 
 Compiler for C supports arguments -Wpointer-arith: YES 
 Compiler for C supports arguments -Wwrite-strings: YES 
 Compiler for C supports arguments -Wsign-compare: YES 
 Compiler for C supports arguments -Wpacked: YES 
 Compiler for C supports arguments -Wswitch-enum: YES 
 Compiler for C supports arguments -Wmissing-format-attribute: YES 
 Compiler for C supports arguments -Wvolatile-register-var: YES 
 Compiler for C supports arguments -Wstrict-aliasing=2: YES 
 Compiler for C supports arguments -Winit-self: YES 
 Compiler for C supports arguments -Wunsafe-loop-optimizations: YES 
 Compiler for C supports arguments -Wno-missing-field-initializers: YES 
 Compiler for C supports arguments -Wno-unused-parameter: YES 
 Compiler for C supports arguments -Wno-attributes: YES 
 Compiler for C supports arguments -Wno-long-long: YES 
 Compiler for C supports arguments -Winline: YES 
 Compiler for C supports arguments -Wno-unused-but-set-variable: YES 
 Compiler for C supports arguments -Wno-enum-conversion: YES 
 Compiler for C supports arguments -fno-strict-aliasing: YES 
 Compiler for C supports arguments -fno-common: YES 
 Compiler for C supports arguments -Wp,-D_FORTIFY_SOURCE=2: YES 
 Program python3 found: YES (/usr/bin/python3)
 Library m found: YES
 Dependency gtk+-2.0 for host machine skipped: feature gtk2-utils disabled
 Compiler for C supports link arguments -Wl,-Bsymbolic-functions: YES 
 Fetching value of define "__FLOAT_WORD_ORDER__" : 1234 
 Fetching value of define "__ORDER_BIG_ENDIAN__" : 4321 
 Found pkg-config: YES (/usr/bin/pkg-config) 2.5.1
 Found CMake: /usr/bin/cmake (4.2.3)
 Run-time dependency lzo2 found: NO  (tried pkg-config and cmake)
 Library dl found: YES
 Checking for function "dlsym" with dependency -ldl: YES 
 Run-time dependency zlib found: YES 1.3.2
 Run-time dependency libpng found: YES 1.6.59
 Run-time dependency fontconfig found: YES 2.17.1
 Program ttx found: NO
 Run-time dependency freetype2 found: YES 26.6.20
 Checking for type "FT_SVG_Document" with dependency freetype2: YES 
 Checking if define "FT_LOAD_NO_SVG" with dependency freetype2 exists: YES 
 Checking for function "FT_Get_Color_Glyph_Paint" with dependency freetype2: YES 
 Dependency x11 for host machine skipped: feature xlib disabled
 Dependency xext for host machine skipped: feature xlib disabled
 Dependency xcb for host machine skipped: feature xcb disabled
 Dependency xcb-render for host machine skipped: feature xcb disabled
 Run-time dependency gobject-2.0 found: YES 2.90.1
 Run-time dependency glib-2.0 found: YES 2.90.1
 Has header "bfd.h" : NO 
 Program gs skipped: feature tests disabled
 Run-time dependency libspectre found: NO  (tried pkg-config and cmake)
 Dependency poppler-glib for host machine skipped: feature tests disabled
 Dependency librsvg-2.0 for host machine skipped: feature tests disabled
-Run-time dependency pixman-1 found: NO  (tried pkg-config and cmake)
-Looking for a fallback subproject for the dependency pixman-1
-Downloading pixman source from https://www.cairographics.org/releases/pixman-0.44.2.tar.gz
-
-Executing subproject pixman 
-
-pixman| Project name: pixman
-pixman| Project version: 0.44.2
-pixman| C compiler for the host machine: cc (gcc 15.2.0 "cc (Alpine 15.2.0) 15.2.0")
-pixman| C linker for the host machine: cc ld.bfd 2.45.1
-pixman| Compiler for C supports arguments -Wdeclaration-after-statement: YES
-pixman| Compiler for C supports arguments -fno-strict-aliasing: YES (cached)
-pixman| Compiler for C supports arguments -fvisibility=hidden: YES
-pixman| Compiler for C supports arguments -Wundef: YES
-pixman| Compiler for C supports arguments -ftrapping-math: YES
-pixman| Compiler for C supports arguments -Wunused-local-typedefs: YES
-pixman| Checking if "SSSE3 Intrinsic Support" compiles: YES
-pixman| Checking if "test for ASM .func directive" compiles: YES
-pixman| Checking if "test for ASM .syntax unified directive" compiles: NO
-pixman| Checking if "test for ASM leading underscore" links: NO
-pixman| Checking if "GNU Inline ASM support." compiles: YES
-pixman| Run-time dependency OpenMP found: YES 4.5
-pixman| Run-time dependency gtk+-3.0 found: NO  (tried pkg-config and cmake)
-pixman| Dependency glib-2.0 for host machine found: YES 2.90.1 (cached)
-pixman| Dependency libpng for host machine found: YES 1.6.59 (cached)
-pixman| Library m found: YES
-pixman| Run-time dependency threads found: YES
-pixman| Has header "pthread.h" : YES
-pixman| Checking for function "sigaction" : YES
-pixman| Checking for function "alarm" : YES
-pixman| Checking for function "mprotect" : YES
-pixman| Checking for function "getpagesize" : YES
-pixman| Checking for function "mmap" : YES
-pixman| Checking for function "getisax" : NO
-pixman| Checking for function "gettimeofday" : YES
-pixman| Checking for function "posix_memalign" : YES
-pixman| Checking for function "feenableexcept" with dependency -lm: NO
-pixman| Header "fenv.h" has symbol "FE_DIVBYZERO" : YES
-pixman| Check usable header "sys/mman.h" : YES
-pixman| Check usable header "fenv.h" : YES
-pixman| Check usable header "unistd.h" : YES
-pixman| Checking if "TLS via __thread" compiles: YES
-pixman| Checking if "__attribute__((constructor))" links: YES
-pixman| Checking if "__attribute__((destructor))" links: YES
-pixman| Checking if "Has float128 support" links: YES
-pixman| Checking for function "clz" : YES
-pixman| Checking if "Support for GCC vector extensions" links: YES
-pixman| Checking for size of "long" : 8
-pixman| Configuring pixman-config.h using configuration
-pixman| Configuring pixman-version.h using configuration
-pixman| Found pkg-config: YES (/usr/bin/pkg-config) 2.5.1
-pixman| Build targets in project: 43
-pixman| Subproject pixman finished.
-
-Dependency pixman-1 for host machine found: YES 0.44.2 (overridden)
+Run-time dependency pixman-1 found: YES 0.46.4
 Checking for size of "void *" : 8 
 Checking for size of "int" : 4 
 Checking for size of "long" : 8 
 Checking for size of "long long" : 8 
 Checking for size of "size_t" : 8 
 Has header "stdint.h" : YES 
 Has header "inttypes.h" : YES 
 Has header "sys/int_types.h" : NO 
 Has header "fcntl.h" : YES 
 Has header "unistd.h" : YES 
 Has header "signal.h" : YES 
 Has header "sys/stat.h" : YES 
 Has header "sys/socket.h" : YES 
 Has header "poll.h" : YES 
 Has header "sys/poll.h" : YES 
 Has header "sys/un.h" : YES 
 Has header "sched.h" : YES 
 Has header "sys/mman.h" : YES 
 Has header "time.h" : YES 
 Has header "libgen.h" : YES 
 Has header "byteswap.h" : YES 
 Has header "signal.h" : YES (cached)
 Has header "setjmp.h" : YES 
 Has header "fenv.h" : YES 
 Has header "sys/wait.h" : YES 
 Has header "sys/stat.h" : YES (cached)
 Has header "io.h" : NO 
 Has header "fenv.h" : YES (cached)
 Has header "xlocale.h" : NO 
 Has header "sys/ioctl.h" : YES 
 Has header "intsafe.h" : NO 
 Has header "alloca.h" : YES 
 Has header "termios.h" : YES 
 Checking for type "uint64_t" : YES 
 Checking for type "uint128_t" : NO 
 Checking for type "__uint128_t" : YES 
-Checking for function "alarm" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "ctime_r" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "localtime_r" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "gmtime_r" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "drand48" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "flockfile" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "funlockfile" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "getline" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "link" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "fork" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "waitpid" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "raise" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "newlocale" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "strtod_l" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "FcInit" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "FcFini" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "sched_getaffinity" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "mmap" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "clock_gettime" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
-Checking for function "feenableexcept" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: NO 
-Checking for function "fedisableexcept" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: NO 
-Checking for function "feclearexcept" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2: YES 
+Checking for function "alarm" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "ctime_r" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "localtime_r" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "gmtime_r" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "drand48" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "flockfile" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "funlockfile" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "getline" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "link" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "fork" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "waitpid" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "raise" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "newlocale" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "strtod_l" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "FcInit" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "FcFini" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "sched_getaffinity" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "mmap" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "clock_gettime" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
+Checking for function "feenableexcept" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: NO 
+Checking for function "fedisableexcept" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: NO 
+Checking for function "feclearexcept" with dependencies -lm, -ldl, zlib, libpng, fontconfig, freetype2, pixman-1: YES 
 Checking for function "strndup" : YES 
 Checking if "pthreads" links: YES 
 Checking if "Atomic ops: c11" links: YES 
 Library rt found: YES
 Checking for function "shm_open" with dependency -lrt: YES 
 Compiler for C supports arguments -Wno-attributes: YES (cached)
 Compiler for C supports arguments -Wno-unused-but-set-variable: YES (cached)
 Compiler for C supports arguments -Wno-missing-field-initializers: YES (cached)
 Compiler for C supports arguments -Wno-unused-parameter: YES (cached)
 Compiler for C supports arguments -Wno-long-long: YES (cached)
 Configuring cairo-features.h using configuration
+Found pkg-config: YES (/usr/bin/pkg-config) 2.5.1
 Program sh found: YES (/bin/sh)
 Configuring cairo-trace using configuration
 Configuring config.h using configuration
-Build targets in project: 53
+Build targets in project: 10
 
 cairo 1.18.6
 
   Surface Backends
     Image                   : YES
     Recording               : YES
     Observer                : YES
     Mime                    : YES
     Tee                     : NO
     Xlib                    : NO
     Xlib Xrender            : NO
     Quartz                  : NO
     Quartz-image            : NO
     XCB                     : NO
     Win32                   : NO
     CairoScript             : YES
     PostScript              : YES
     PDF                     : YES
     SVG                     : YES
 
   Font Backends
     User                    : YES
     FreeType                : YES
     Fontconfig              : YES
     Win32                   : NO
     Win32 DWrite            : NO
     Quartz                  : NO
 
   Functions
     PNG functions           : YES
     X11-xcb                 : NO
     XCB-shm                 : NO
 
   Features and Utilities
     cairo-trace:            : YES
     cairo-script-interpreter: YES
     API reference           : NO
 
-  Subprojects
-    pixman                  : YES
-
   User defined options
     buildtype               : release
     default_library         : static
     quartz                  : disabled
     tee                     : disabled
     tests                   : disabled
     xcb                     : disabled
     xlib                    : disabled
     xlib-xcb                : disabled
 
 Found ninja-1.9 at /usr/bin/ninja
```

</details>

`versions.json` lists pixman.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

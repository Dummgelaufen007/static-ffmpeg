# Flag changes in Dockerfile.opt and their sources

Every flag that `Dockerfile.opt` adds or changes compared to `Dockerfile`, with the upstream default and the web source that defines it at the pinned version.

| Library | Dockerfile | Dockerfile.opt | Upstream default | Web source (pinned version) |
|---|---|---|---|---|
| vmaf | – | `-Denable_tools=false` | `true` "Build libvmaf tools" | [vmaf v3.2.1 libvmaf/meson_options.txt#L11](https://github.com/Netflix/vmaf/blob/v3.2.1/libvmaf/meson_options.txt#L11) |
| glib | – | `-Dtests=false` | `true` "build tests" | [glib 2.84.1 meson.options#L95](https://github.com/GNOME/glib/blob/2.84.1/meson.options#L95) (GitHub mirror) |
| | – | `-Dsysprof=disabled` | `auto` "include tracing support for sysprof"; not found falls back to the `sysprof` wrap (git clone) | [meson.options#L69-L72](https://github.com/GNOME/glib/blob/2.84.1/meson.options#L69-L72), [glib/meson.build#L34-L45](https://github.com/GNOME/glib/blob/2.84.1/glib/meson.build#L34-L45) |
| | – | `sed` drops `-Wl,--export-dynamic` from `gmodule-2.0.pc` and `gmodule-export-2.0.pc` | set on every host except windows, darwin, ios and sunos, and written into both `.pc` files | [meson.build#L2543-L2556](https://github.com/GNOME/glib/blob/2.84.1/meson.build#L2543-L2556), [gmodule/meson.build#L117-L135](https://github.com/GNOME/glib/blob/2.84.1/gmodule/meson.build#L117-L135) |
| harfbuzz | – | `-Dtests=disabled` | `enabled` | [harfbuzz 14.4.0 meson_options.txt#L48](https://github.com/harfbuzz/harfbuzz/blob/14.4.0/meson_options.txt#L48) |
| | – | `-Dutilities=disabled` | `enabled` "Build harfbuzz utils" | [#L56](https://github.com/harfbuzz/harfbuzz/blob/14.4.0/meson_options.txt#L56) |
| | – | `-Dsubset=disabled` | `enabled` (subsetting library) | [#L44](https://github.com/harfbuzz/harfbuzz/blob/14.4.0/meson_options.txt#L44) |
| | – | `-Draster=disabled` | `enabled` (rasterization library) | [#L36](https://github.com/harfbuzz/harfbuzz/blob/14.4.0/meson_options.txt#L36) |
| | – | `-Dvector=disabled` | `enabled` (vector drawing library) | [#L38](https://github.com/harfbuzz/harfbuzz/blob/14.4.0/meson_options.txt#L38) |
| | – | `-Dgpu=disabled` | `enabled` (GPU rasterization library) | [#L40](https://github.com/harfbuzz/harfbuzz/blob/14.4.0/meson_options.txt#L40) |
| pango | `-Ddefault_library=both` | `-Ddefault_library=static` | meson built-in option; `both` was only "currently to not fail building tests" | [wader/static-ffmpeg dfa84ce Dockerfile#L156-L157](https://github.com/wader/static-ffmpeg/blob/dfa84ce4b2c705c104d87927fc1f74c822725c9d/Dockerfile#L156-L157) |
| | – | `-Dbuild-testsuite=false` | `true` | [pango 1.56.4 meson.options#L23](https://github.com/GNOME/pango/blob/1.56.4/meson.options#L23) (GitHub mirror); [NEWS#L66](https://github.com/GNOME/pango/blob/1.56.4/NEWS#L66) calls it `build-tests` |
| | – | `-Dbuild-examples=false` | `true` | [meson.options#L28](https://github.com/GNOME/pango/blob/1.56.4/meson.options#L28) |
| aom | – | `-DENABLE_APPS=NO` | `ON` "aomenc/aomdec" | [aom de4c1d1 cmake/aom_config_defaults.cmake#199](https://aomedia.googlesource.com/aom/+/de4c1d1edc49723a78954d30a83690aa1937422f/cmake/aom_config_defaults.cmake#199); [CHANGELOG v3.15.0](https://aomedia.googlesource.com/aom/+/de4c1d1edc49723a78954d30a83690aa1937422f/CHANGELOG) "ENABLE_APPS was added to build aomdec and aomenc" |
| | – | `-DCONFIG_LIBYUV=0` | `1` "Enables libyuv scaling/conversion support."; the `yuv` object library (19 sources) is compiled whenever it is set, and linked only into the app targets, or into libaom with `CONFIG_TUNE_BUTTERAUGLI` | [aom 44d0a57 cmake/aom_config_defaults.cmake#91](https://aomedia.googlesource.com/aom/+/44d0a57786f432d933ff64b653347c66f4d0fa1d/cmake/aom_config_defaults.cmake#91); [CMakeLists.txt#116](https://aomedia.googlesource.com/aom/+/44d0a57786f432d933ff64b653347c66f4d0fa1d/CMakeLists.txt#116), [#528](https://aomedia.googlesource.com/aom/+/44d0a57786f432d933ff64b653347c66f4d0fa1d/CMakeLists.txt#528), [#616](https://aomedia.googlesource.com/aom/+/44d0a57786f432d933ff64b653347c66f4d0fa1d/CMakeLists.txt#616), [#828](https://aomedia.googlesource.com/aom/+/44d0a57786f432d933ff64b653347c66f4d0fa1d/CMakeLists.txt#828) |
| libbluray | – | `-Denable_tools=false` | `true` "Build libbluray cli tools" | [libbluray 1.5.0 meson_options.txt#L11](https://code.videolan.org/videolan/libbluray/-/blob/1.5.0/meson_options.txt#L11) |
| dav1d | – | `-Denable_tools=false` | `true` | [dav1d 1.5.4 meson_options.txt#L13](https://github.com/videolan/dav1d/blob/1.5.4/meson_options.txt#L13) (GitHub mirror) |
| | – | `-Denable_tests=false` | `true` | [#L23](https://github.com/videolan/dav1d/blob/1.5.4/meson_options.txt#L23) |
| mp3lame | – | `--disable-decoder` | `yes` "Exclude mpg123 decoder" | [lame RELEASE__3_100 configure.in, line 536](https://svn.code.sf.net/p/lame/svn/tags/RELEASE__3_100/lame/configure.in) |
| lcms2 | – | `--without-jpeg` | `with_jpeg=yes`, gates `jpgicc` via `HasJPEG` | [lcms2.19.1 configure.ac#L101](https://github.com/mm2/Little-CMS/blob/lcms2.19.1/configure.ac#L101), [utils/jpgicc/Makefile.am#L11](https://github.com/mm2/Little-CMS/blob/lcms2.19.1/utils/jpgicc/Makefile.am#L11) |
| | – | `--without-tiff` | `with_tiff=yes`, gates `tificc` via `HasTIFF` | [configure.ac#L119](https://github.com/mm2/Little-CMS/blob/lcms2.19.1/configure.ac#L119), [utils/tificc/Makefile.am#L13](https://github.com/mm2/Little-CMS/blob/lcms2.19.1/utils/tificc/Makefile.am#L13) |
| librabbitmq | – | `-DBUILD_TESTING=OFF` | `ON` "toggles building test code. ON by default." | [rabbitmq-c v0.18.0 README.md#L81](https://github.com/alanxz/rabbitmq-c/blob/v0.18.0/README.md#L81), [CMakeLists.txt#L140](https://github.com/alanxz/rabbitmq-c/blob/v0.18.0/CMakeLists.txt#L140) |
| rav1e | – | `--library-type staticlib` | cargo-c builds only `staticlib` on musl targets anyway (`("none", _) \| (_, "musl")`); on Alpine the option makes the default explicit | [cargo-c v0.9.32 src/build.rs#L1056-L1059](https://github.com/lu-zero/cargo-c/blob/v0.9.32/src/build.rs#L1056-L1059) (Alpine 3.20 ships cargo-c 0.9.32) |
| | – | `--no-default-features` | `default = ["binaries", "asm", "threading", "signal_support", "git_version"]`; `binaries` only feeds the `rav1e` CLI (`required-features`), `signal-hook` is only used in `src/bin` | [rav1e v0.7.1 Cargo.toml#L30-L45](https://github.com/xiph/rav1e/blob/v0.7.1/Cargo.toml#L30-L45), [#L159-L161](https://github.com/xiph/rav1e/blob/v0.7.1/Cargo.toml#L159-L161), [src/bin/rav1e.rs#L126](https://github.com/xiph/rav1e/blob/v0.7.1/src/bin/rav1e.rs#L126) |
| | – | `--features asm,threading,git_version,capi` | re-enables the remaining defaults; cargo-c adds `capi` by itself | [Cargo.toml#L41-L51](https://github.com/xiph/rav1e/blob/v0.7.1/Cargo.toml#L41-L51), [cargo-c v0.9.32 src/build.rs#L816-L818](https://github.com/lu-zero/cargo-c/blob/v0.9.32/src/build.rs#L816-L818) |
| | – | `CARGO_PROFILE_RELEASE_DEBUG=false` | `[profile.release] debug = true`; "Specifying a profile in a config file or environment variable will override the settings from Cargo.toml" | [rav1e v0.7.1 Cargo.toml#L181-L182](https://github.com/xiph/rav1e/blob/v0.7.1/Cargo.toml#L181-L182), [Cargo 1.78 profiles](https://doc.rust-lang.org/1.78.0/cargo/reference/profiles.html), [environment variables](https://doc.rust-lang.org/1.78.0/cargo/reference/environment-variables.html) |
| librtmp | `make …` | `make -C librtmp …` | `install: $(PROGS)` builds and copies `PROGS=rtmpdump rtmpgw rtmpsrv rtmpsuck`, then `@cd librtmp; $(MAKE) install` | [rtmpdump 138fdb2 Makefile, lines 55-67](https://git.ffmpeg.org/gitweb/rtmpdump.git/blob/138fdb258d9fc26f1843fd1b891180416c9dc575:/Makefile) |
| libssh | `-DWITH_PCAP=ON` | `-DWITH_PCAP=OFF` | `ON` "Compile with Pcap generation support" | [libssh 0.12.1 DefineOptions.cmake#L11](https://gitlab.com/libssh/libssh-mirror/-/blob/libssh-0.12.1/DefineOptions.cmake#L11) |
| svtav1 | – | `-DBUILD_APPS=OFF` | `ON` "Build Enc Apps" | [SVT-AV1 v4.2.0 CMakeLists.txt#L268](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/v4.2.0/CMakeLists.txt#L268) |
| | – | `-DSVT_AV1_LTO=OFF` | `ON` with gcc 9 or later, "Attempt to enable Link Time Optimization if available"; sets `CMAKE_INTERPROCEDURAL_OPTIMIZATION`, so the archive holds intermediate code that is compiled when ffmpeg and ffprobe are linked ("requires the complete toolchain to be aware of LTO"). The only recipe that compiles with `-flto` | [CMakeLists.txt#L409-L421](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/v4.2.0/CMakeLists.txt#L409-L421), [GCC 13.2 Optimize Options, `-ffat-lto-objects`](https://gcc.gnu.org/onlinedocs/gcc-13.2.0/gcc/Optimize-Options.html) |
| libvpx | – | `--disable-tools` | every target of `libs examples tools docs` is on if its `.mk` exists ([tools.mk](https://github.com/webmproject/libvpx/blob/v1.17.0/tools.mk) does) | [libvpx v1.17.0 configure#L191-L196](https://github.com/webmproject/libvpx/blob/v1.17.0/configure#L191-L196) |
| x265 | – | `-DENABLE_CLI=OFF` (in `CMAKEFLAGS`) | `ON` "Build standalone CLI application" | [x265 4.2 source/CMakeLists.txt#1145](https://bitbucket.org/multicoreware/x265_git/src/4.2/source/CMakeLists.txt#lines-1145); [x265 API docs](https://x265.readthedocs.io/en/master/api.html) (unversioned) "recommended to also set ENABLE_SHARED and ENABLE_CLI to OFF" |
| libjxl | – | `-DJPEGXL_ENABLE_TOOLS=OFF` | `true` "Build JPEGXL user tools: cjxl and djxl." | [libjxl v0.12.0 CMakeLists.txt#L142](https://github.com/libjxl/libjxl/blob/v0.12.0/CMakeLists.txt#L142) |
| libzmq | – | `--disable-perf` | `yes` "don't build performance measurement tools" | [libzmq v4.3.5 configure.ac#L490](https://github.com/zeromq/libzmq/blob/v4.3.5/configure.ac#L490) |
| vvenc | – | `-DVVENC_LIBRARY_ONLY=ON` | `OFF` "build strictly only libvvenc" | [vvenc wiki: Build](https://github.com/fraunhoferhhi/vvenc/wiki/Build) (unversioned), [v1.14.0 CMakeLists.txt#L185](https://github.com/fraunhoferhhi/vvenc/blob/v1.14.0/CMakeLists.txt#L185) |
| ffmpeg | `make -j$(nproc) install` | `set -o pipefail && make -j$(nproc) install LDXX='$(CXX) -Wl,-t' \| tee ld-trace.log` | `LDXX := $(CXX)` only while `LD` equals `CC`, and link lines with `-lstdc++` go through `$(LDXX)`, so `LDXX` (not `LD`) keeps the `g++` link; `-t` only prints "the names of the input files as ld processes them"; `pipefail` keeps make's exit status behind `tee` | [FFmpeg n9.0.2 ffbuild/common.mak#L7-L13](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/ffbuild/common.mak#L7-L13), [Makefile#L149-L150](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/Makefile#L149-L150), [GNU ld 2.42 Options](https://sourceware.org/binutils/docs-2.42/ld/Options.html) (Alpine 3.20 ships binutils 2.42) |
| checkdupsym | `checkdupsym` | `checkdupsym.opt` | upstream deletes `ffmpeg*` and relinks with `make V=1 LD="gcc -Wl,-t"` only to get the archive list; `.opt` reads `ld-trace.log` instead and keeps only bare path lines (`^[^[:space:]]+\.a$`), because the build output also carries `AR`/`INSTALL` lines for libswscale and libswresample | [wader/static-ffmpeg dfa84ce checkdupsym#L17-L22](https://github.com/wader/static-ffmpeg/blob/dfa84ce4b2c705c104d87927fc1f74c822725c9d/checkdupsym#L17-L22) |
| 18 autotools libraries¹ | – | `--disable-dependency-tracking` | on; automake standard option, "Speed up one-time builds" | [Automake manual](https://www.gnu.org/software/automake/manual/automake.html) |

¹ libaribb24, libass, fdk-aac, kvazaar, libmodplug, mp3lame, lcms2, opencoreamr, opus, libshine, speex, ogg, theora, twolame, vorbis, libwebp, zimg, libzmq

rabbitmq-c renamed `-DBUILD_TESTS` to `-DBUILD_TESTING` in v0.12.0 ([ChangeLog.md#L97](https://github.com/alanxz/rabbitmq-c/blob/v0.18.0/ChangeLog.md#L97)), so the original `-DBUILD_TESTS=OFF` is a no-op.

## Code removed from linked libraries

Two flags drop code from a library ffmpeg links, not a separate target. In both cases the dropped code runs only through API calls or setters that ffmpeg n9.0.2 never makes, and no ffmpeg option leads there.

### mp3lame `--disable-decoder`

Removes `HAVE_MPGLIB` and `DECODE_ON_THE_FLY` ([lame 3.100 configure.in, lines 536-546](https://svn.code.sf.net/p/lame/svn/tags/RELEASE__3_100/lame/configure.in)).

| Side | Reference | Finding |
|---|---|---|
| ffmpeg | [configure#L7398](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/configure#L7398) | `require "libmp3lame >= 3.98.3" lame/lame.h lame_set_VBR_quality`: checks an encoder function only |
| ffmpeg | [configure#L3848](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/configure#L3848) | used only by `libmp3lame_encoder` |
| ffmpeg | [libavcodec/libmp3lame.c#L91-L235](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/libavcodec/libmp3lame.c#L91-L235) | calls `lame_close`, `lame_init`, `lame_set_*`, `lame_init_params`, `lame_get_encoder_delay/framesize`, `lame_encode_buffer*`, `lame_encode_flush`; no `hip_*`, `lame_decode*`, `lame_set_decode_on_the_fly`, `lame_set_findReplayGain` |
| ffmpeg | [libmp3lame.c#L315-L319](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/libavcodec/libmp3lame.c#L315-L319) | options `reservoir`, `joint_stereo`, `abr`, `copyright`, `original` |
| lame | [libmp3lame/lame.c, line 2444](https://svn.code.sf.net/p/lame/svn/tags/RELEASE__3_100/lame/libmp3lame/lame.c) | `lame_init` sets `gfp->decode_on_the_fly = 0` |
| lame | [libmp3lame/bitstream.c, lines 993-994](https://svn.code.sf.net/p/lame/svn/tags/RELEASE__3_100/lame/libmp3lame/bitstream.c); lame.c, lines 1300-1301 | code under `DECODE_ON_THE_FLY` runs only `if (cfg->decode_on_the_fly …)`; the cleanup in util.c, lines 156-161, only frees `gfc->hip`, which is set only in the lame.c block |
| lame | [libmp3lame/set_get.c, lines 534-537](https://svn.code.sf.net/p/lame/svn/tags/RELEASE__3_100/lame/libmp3lame/set_get.c) | only `lame_set_decode_on_the_fly` turns it on |

### libssh `WITH_PCAP=OFF`

| Side | Reference | Finding |
|---|---|---|
| ffmpeg | [configure#L7440](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/configure#L7440) | `require_pkg_config libssh "libssh >= 0.6.0" libssh/sftp.h sftp_init` |
| ffmpeg | [configure#L4137](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/configure#L4137) | used only by `libssh_protocol` (SFTP) |
| ffmpeg | [libavformat/libssh.c#L49-L461](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/libavformat/libssh.c#L49-L461) | calls `ssh_new`, `ssh_options_set`, `ssh_options_parse_config`, `ssh_connect`, `ssh_userauth_*`, `ssh_pki_import_privkey_file`, `ssh_disconnect`, `ssh_free`, `ssh_get_error`, `sftp_*`; no `ssh_set_pcap_file`, `ssh_pcap_*` |
| ffmpeg | [libssh.c#L477-L479](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/libavformat/libssh.c#L477-L479) | options `timeout`, `truncate`, `private_key` |
| libssh | [src/pcap.c#L530-L541](https://gitlab.com/libssh/libssh-mirror/-/blob/libssh-0.12.1/src/pcap.c#L530-L541) | `session->pcap_ctx` is set only in `ssh_set_pcap_file` |
| libssh | [src/packet.c#L1482](https://gitlab.com/libssh/libssh-mirror/-/blob/libssh-0.12.1/src/packet.c#L1482), [#L1953](https://gitlab.com/libssh/libssh-mirror/-/blob/libssh-0.12.1/src/packet.c#L1953), [src/client.c#L123](https://gitlab.com/libssh/libssh-mirror/-/blob/libssh-0.12.1/src/client.c#L123), [#L235](https://gitlab.com/libssh/libssh-mirror/-/blob/libssh-0.12.1/src/client.c#L235), [src/server.c#L552](https://gitlab.com/libssh/libssh-mirror/-/blob/libssh-0.12.1/src/server.c#L552), [src/session.c#L276](https://gitlab.com/libssh/libssh-mirror/-/blob/libssh-0.12.1/src/session.c#L276) | every `WITH_PCAP` block in the packet path also checks `session->pcap_ctx` at runtime |
| libssh | [src/pcap.c#L24-L546](https://gitlab.com/libssh/libssh-mirror/-/blob/libssh-0.12.1/src/pcap.c#L24-L546) | the pcap implementation itself; reached only through its own API (`ssh_pcap_file_*`, `ssh_set_pcap_file`) |
| libssh | `src/options.c`, `src/config.c` | no pcap reference, so an ssh config file cannot enable it via `ssh_options_parse_config` |

## Symbols removed from the binary

### glib `-Wl,--export-dynamic`

The flag is no build parameter of glib; it travels through pkg-config onto the ffmpeg link line. Nothing can use what it exports from a static binary, and it keeps thread-local accesses from being resolved at link time.

| Side | Reference | Finding |
|---|---|---|
| glib | [meson.build#L2555](https://github.com/GNOME/glib/blob/2.84.1/meson.build#L2555) | `export_dynamic_ldflags = ['-Wl,--export-dynamic']` on Linux |
| glib | [gmodule/meson.build#L106-L135](https://github.com/GNOME/glib/blob/2.84.1/gmodule/meson.build#L106-L135) | `gmodule-export-2.0` and `gmodule-2.0` carry it in `libraries`; `gmodule-no-export-2.0` does not |
| librsvg | [librsvg 2.60.0 meson.build#L120-L121](https://github.com/GNOME/librsvg/blob/2.60.0/meson.build#L120-L121) | depends on `gmodule-2.0`, so `pkg-config --static` hands the flag to ffmpeg |
| ld | [GNU ld 2.42 Options](https://sourceware.org/binutils/docs-2.42/ld/Options.html) | `--export-dynamic` "causes the linker to add all symbols to the dynamic symbol table"; meant for a `dlopen`ed object "which needs to refer back to the symbols defined by the program" |
| ld | [binutils 2.42 bfd/elfxx-x86.h, lines 288-293](https://sourceware.org/git/?p=binutils-gdb.git;a=blob;f=bfd/elfxx-x86.h;hb=refs/tags/binutils-2_42#l288), [bfd/elf64-x86-64.c, line 1434](https://sourceware.org/git/?p=binutils-gdb.git;a=blob;f=bfd/elf64-x86-64.c;hb=refs/tags/binutils-2_42#l1434) | a TLS access becomes local-exec only while the symbol has no dynamic index (`(H)->dynindx == -1`); an exported one keeps its GOT entry and an `R_X86_64_TPOFF64` relocation |
| musl | [musl 1.2.5 crt/rcrt1.c](https://git.musl-libc.org/cgit/musl/tree/crt/rcrt1.c?h=v1.2.5), [ldso/dlstart.c, lines 129-139](https://git.musl-libc.org/cgit/musl/tree/ldso/dlstart.c?h=v1.2.5#n129) | the static pie start code applies relative relocations only (`if (!IS_RELATIVE(rel[1], 0)) continue;`), so that GOT entry stays 0 |
| musl | [src/ldso/dlopen.c, lines 4-10](https://git.musl-libc.org/cgit/musl/tree/src/ldso/dlopen.c?h=v1.2.5#n4) | in a static link `dlopen` is a stub ("Dynamic loading not supported"); nothing can look the exported symbols up |
| measured | Alpine 3.21.8, glib to librsvg plus an ffmpeg with only the librsvg decoder | with the flag 22570 dynamic symbols and 9 `R_X86_64_TPOFF64`, `ffprobe` on an SVG ends with signal 11 in `rsvg::document::Document::load_from_stream`; without it 4 and 0, the SVG is probed, the binary stays `static-pie linked` |
| measured | Alpine 3.20.3 binary | 11 `R_X86_64_TPOFF64`, their GOT entries 0 at run time; the SVG test passes there with rust 1.78 |

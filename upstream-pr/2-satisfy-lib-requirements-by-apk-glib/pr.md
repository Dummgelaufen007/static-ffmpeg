# Satisfy lib requirements by apk: glib

The glib step downloads more than its own source: when glib needs a library that is not installed, meson fetches it during that step ([master build](https://github.com/wader/static-ffmpeg/actions/runs/41099660522/job/124214372586)).

| Lib | Needs | Hidden download from | Alpine packages | Package version |
|---|---|---|---|---|
| glib | pcre2 10.46 | `github.com/PCRE2Project/pcre2`, patch from `wrapdb.mesonbuild.com` | `pcre2-dev pcre2-static` | 10.49-r0 |
| glib | libffi 3.5.2 | `github.com/libffi/libffi`, patch from `wrapdb.mesonbuild.com` | `libffi-dev` | 3.5.2-r1 |
| glib | libintl (proxy-libintl 0.5) | `github.com/frida/proxy-libintl` | `musl-libintl` | 1.2.6-r3 |

When the build breaks in the glib step, you cannot see that it broke on one of these hidden downloads.

With this PR meson downloads none of them. They come from Alpine packages named in `apk add`, so a problem with them shows up in the first step of the build, under the package's own name.

## Alpine packages

Alpine ships pcre2 and libffi with static archives. gettext is part of musl's libc, so `musl-libintl` only adds `libintl.h`. With the packages from the table installed, meson finds all three and the build log has no "Downloading" line left ([build](https://github.com/wader/static-ffmpeg/actions/runs/41101956127/job/124220543899)).

Complete meson output of the step, master build against this PR: `-` appears only on master, `+` only with this PR.

<details><summary>glib step</summary>

```diff
 The Meson build system
 Version: 1.11.1
 Source dir: /glib-2.90.1
 Build dir: /glib-2.90.1/build
 Build type: native build
 Project name: glib
 Project version: 2.90.1
 C compiler for the host machine: cc (gcc 15.2.0 "cc (Alpine 15.2.0) 15.2.0")
 C linker for the host machine: cc ld.bfd 2.45.1
 Host machine cpu family: x86_64
 Host machine cpu: x86_64
 Compiler for C supports arguments -std=c89: YES 
 Compiler for C supports arguments -std=c99: YES 
 Compiler for C supports arguments -std=c11: YES 
 Compiler for C supports arguments -std=c17: YES 
 Compiler for C supports arguments -std=c23: YES 
 C++ compiler for the host machine: c++ (gcc 15.2.0 "c++ (Alpine 15.2.0) 15.2.0")
 C++ linker for the host machine: c++ ld.bfd 2.45.1
 Compiler for C++ supports arguments -std=c++98: YES 
 Compiler for C++ supports arguments -std=c++03: YES 
 Compiler for C++ supports arguments -std=c++11: YES 
 Compiler for C++ supports arguments -std=c++14: YES 
 Compiler for C++ supports arguments -std=c++17: YES 
 Compiler for C++ supports arguments -std=c++20: YES 
 Compiler for C++ supports arguments -std=c++23: YES 
 Compiler for C++ supports arguments -std=c++2c: YES 
 Compiler for C++ supports arguments -std=c++latest: NO 
 Checking if "building for musl libc" compiles: YES 
 Program ./.gitlab-ci/thorough-test-wrapper.sh found: YES (/bin/bash /glib-2.90.1/./.gitlab-ci/thorough-test-wrapper.sh)
 Program valgrind found: NO
 Compiler for C supports arguments -fno-strict-aliasing: YES 
 Message: Disabling cast checks
 Has header "alloca.h" : YES 
 Has header "afunix.h" : NO 
 Has header "crt_externs.h" : NO 
 Has header "dirent.h" : YES 
 Has header "float.h" : YES 
 Has header "fstab.h" : NO 
 Has header "ftw.h" : YES 
 Has header "grp.h" : YES 
 Has header "intsafe.h" : NO 
 Has header "inttypes.h" : YES 
 Has header "libproc.h" : NO 
 Has header "limits.h" : YES 
 Has header "linux/netlink.h" : YES 
 Has header "locale.h" : YES 
 Has header "mach/mach_time.h" : NO 
 Has header "memory.h" : YES 
 Has header "mntent.h" : YES 
 Has header "netlink/netlink.h" : NO 
 Has header "netlink/netlink_route.h" : NO 
 Has header "poll.h" : YES 
 Has header "pwd.h" : YES 
 Has header "sched.h" : YES 
 Has header "spawn.h" : YES 
 Has header "stdatomic.h" : YES 
 Has header "stdckdint.h" : YES 
 Has header "stdint.h" : YES 
 Has header "stdlib.h" : YES 
 Has header "string.h" : YES 
 Has header "strings.h" : YES 
 Has header "sys/auxv.h" : YES 
 Has header "sys/event.h" : NO 
 Has header "sys/uio.h" : YES 
 Has header "sys/filio.h" : NO 
 Has header "sys/inotify.h" : YES 
 Has header "sys/mkdev.h" : NO 
 Has header "sys/mntctl.h" : NO 
 Has header "sys/mnttab.h" : NO 
 Has header "sys/mount.h" : YES 
 Has header "sys/param.h" : YES 
 Has header "sys/prctl.h" : YES 
 Has header "sys/resource.h" : YES 
 Has header "sys/select.h" : YES 
 Has header "sys/statfs.h" : YES 
 Has header "sys/stat.h" : YES 
 Has header "sys/statvfs.h" : YES 
 Has header "sys/sysctl.h" : NO 
 Has header "sys/time.h" : YES 
 Has header "sys/times.h" : YES 
 Has header "sys/types.h" : YES 
 Has header "sys/ucred.h" : NO 
 Has header "sys/uio.h" : YES (cached)
 Has header "sys/vfs.h" : YES 
 Has header "sys/vfstab.h" : NO 
 Has header "sys/vmount.h" : NO 
 Has header "sys/wait.h" : YES 
 Has header "syslog.h" : YES 
 Has header "termios.h" : YES 
 Has header "unistd.h" : YES 
 Has header "values.h" : YES 
 Has header "vcruntime.h" : NO 
 Has header "wchar.h" : YES 
 Has header "xlocale.h" : NO 
 Check usable header "malloc.h" : YES 
 Checking if "statx() test" compiles: YES 
 Header "locale.h" has symbol "LC_MESSAGES" : YES 
 Checking if "type "struct stat" has member "st_mtimensec"" compiles: NO 
 Checking if "type "struct stat" has member "st_mtim.tv_nsec"" compiles: YES 
 Checking if "type "struct stat" has member "st_atimensec"" compiles: NO 
 Checking if "type "struct stat" has member "st_atim.tv_nsec"" compiles: YES 
 Checking if "type "struct stat" has member "st_ctimensec"" compiles: NO 
 Checking if "type "struct stat" has member "st_ctim.tv_nsec"" compiles: YES 
 Checking if "type "struct stat" has member "st_birthtime"" compiles: NO 
 Checking if "type "struct stat" has member "st_birthtimensec"" compiles: NO 
 Checking if "type "struct stat" has member "st_birthtim"" compiles: NO 
 Checking if "type "struct stat" has member "st_birthtim.tv_nsec"" compiles: NO 
 Checking if "type "struct stat" has member "st_blksize"" compiles: YES 
 Checking if "type "struct stat" has member "st_blocks"" compiles: YES 
 Checking if "type "struct statfs" has member "f_fstypename"" compiles: NO 
 Checking if "type "struct statfs" has member "f_bavail"" compiles: YES 
 Checking if "type "struct dirent" has member "d_type"" compiles: YES 
 Checking if "type "struct statvfs" has member "f_basetype"" compiles: NO 
 Checking if "type "struct statvfs" has member "f_fstypename"" compiles: NO 
 Checking if "type "struct statvfs" has member "f_type"" compiles: YES 
 Checking if "type "struct tm" has member "tm_gmtoff"" compiles: YES 
 Checking if "type "struct tm" has member "__tm_gmtoff"" compiles: YES 
 Compiler for C supports arguments -Wduplicated-branches: YES 
 Compiler for C supports arguments -Wfloat-conversion: YES 
 Compiler for C supports arguments -Wimplicit-fallthrough: YES 
 Compiler for C supports arguments -Wmisleading-indentation: YES 
 Compiler for C supports arguments -Wmissing-field-initializers: YES 
 Compiler for C supports arguments -Wnonnull: YES 
 Compiler for C supports arguments -Wnull-dereference: YES 
 Compiler for C supports arguments -Wunused: YES 
 Compiler for C supports arguments -Wno-unused-parameter: YES 
 Compiler for C supports arguments -Wno-cast-function-type: YES 
 Compiler for C supports arguments -Wno-pedantic: YES 
 Compiler for C supports arguments -Wno-format-zero-length: YES 
 Compiler for C supports arguments -Wno-variadic-macros: YES 
 Compiler for C supports arguments -Werror=format=2: YES 
 Compiler for C supports arguments -Werror=init-self: YES 
 Compiler for C supports arguments -Werror=missing-include-dirs: YES 
 Compiler for C supports arguments -Werror=pointer-arith: YES 
 Compiler for C supports arguments -Werror=unused-result: YES 
 Compiler for C supports arguments -Wstrict-prototypes: YES 
 Compiler for C supports arguments -Wno-bad-function-cast: YES 
 Compiler for C supports arguments -Werror=implicit-function-declaration: YES 
 Compiler for C supports arguments -Werror=missing-prototypes: YES 
 Compiler for C supports arguments -Werror=pointer-sign: YES 
 Compiler for C supports arguments -Werror=typedef-redefinition: NO 
 Compiler for C supports arguments -Wno-string-plus-int: NO 
 Compiler for C++ supports arguments -Wduplicated-branches: YES 
 Compiler for C++ supports arguments -Wfloat-conversion: YES 
 Compiler for C++ supports arguments -Wimplicit-fallthrough: YES 
 Compiler for C++ supports arguments -Wmisleading-indentation: YES 
 Compiler for C++ supports arguments -Wmissing-field-initializers: YES 
 Compiler for C++ supports arguments -Wnonnull: YES 
 Compiler for C++ supports arguments -Wnull-dereference: YES 
 Compiler for C++ supports arguments -Wunused: YES 
 Compiler for C++ supports arguments -Wno-unused-parameter: YES 
 Compiler for C++ supports arguments -Wno-cast-function-type: YES 
 Compiler for C++ supports arguments -Wno-pedantic: YES 
 Compiler for C++ supports arguments -Wno-format-zero-length: YES 
 Compiler for C++ supports arguments -Wno-variadic-macros: YES 
 Compiler for C++ supports arguments -Werror=format=2: YES 
 Compiler for C++ supports arguments -Werror=init-self: YES 
 Compiler for C++ supports arguments -Werror=missing-include-dirs: YES 
 Compiler for C++ supports arguments -Werror=pointer-arith: YES 
 Compiler for C++ supports arguments -Werror=unused-result: YES 
 Compiler for C supports arguments -Wsign-conversion: YES 
 Compiler for C supports arguments -Wshorten-64-to-32: NO 
 Compiler for C supports link arguments -Wl,-z,nodelete: YES 
 Compiler for C supports link arguments -Wl,-Bsymbolic-functions: YES 
 Checking for function "accept4" : YES 
 Checking for function "close_range" : NO 
 Checking for function "copy_file_range" : YES 
 Checking for function "endmntent" : YES 
 Checking for function "endservent" : YES 
 Checking for function "epoll_create1" : YES 
 Checking for function "faccessat" : YES 
 Checking for function "fallocate" : YES 
 Checking for function "fchmod" : YES 
 Checking for function "fchown" : YES 
 Checking for function "fdwalk" : NO 
 Checking for function "free_aligned_sized" : NO 
 Checking for function "free_sized" : NO 
 Checking for function "fsync" : YES 
 Checking for function "ftruncate64" : NO 
 Checking for function "getauxval" : YES 
 Checking for function "getc_unlocked" : YES 
 Checking for function "getfsent" : NO 
 Checking for function "getfsstat" : NO 
 Checking for function "getgrgid_r" : YES 
 Checking for function "getifaddrs" : YES 
 Checking for function "getmntent_r" : YES 
 Checking for function "getpwnam_r" : YES 
 Checking for function "getpwuid_r" : YES 
 Checking for function "getresuid" : YES 
 Checking for function "getvfsstat" : NO 
 Checking for function "gmtime_r" : YES 
 Checking for function "hasmntopt" : YES 
 Checking for function "inotify_init1" : YES 
 Checking for function "issetugid" : YES 
 Checking for function "kevent" : NO 
 Checking for function "kqueue" : NO 
 Checking for function "lchmod" : YES 
 Checking for function "lchown" : YES 
 Checking for function "link" : YES 
 Checking for function "localtime_r" : YES 
 Checking for function "lstat" : YES 
 Checking for function "mbrtowc" : YES 
 Checking for function "memalign" : YES 
 Checking for function "memmem" : YES 
 Checking for function "mmap" : YES 
 Checking for function "newlocale" : YES 
 Checking for function "pipe2" : YES 
 Checking for function "poll" : YES 
 Checking for function "prlimit" : YES 
 Checking for function "readlink" : YES 
 Checking for function "recvmmsg" : YES 
 Checking for function "sendmmsg" : YES 
 Checking for function "setenv" : YES 
 Checking for function "setmntent" : YES 
 Checking for function "strerror_r" : YES 
 Checking for function "strnlen" : YES 
 Checking for function "strsignal" : YES 
 Checking for function "strtod_l" : YES 
 Checking for function "strtoll_l" : NO 
 Checking for function "strtoull_l" : NO 
 Checking for function "symlink" : YES 
 Checking for function "timegm" : YES 
 Checking for function "unsetenv" : YES 
 Checking for function "uselocale" : YES 
 Checking for function "utimes" : YES 
 Checking for function "utimensat" : YES 
 Checking for function "valloc" : YES 
 Checking for function "vasprintf" : YES 
 Checking for function "vsnprintf" : YES 
 Checking for function "wcrtomb" : YES 
 Checking for function "wcslen" : YES 
 Checking for function "wcsnlen" : YES 
 Checking for function "sysctlbyname" : NO 
 Checking for function "statvfs" : YES 
 Checking for function "statfs" : YES 
 Checking for function "prctl" : YES 
 Checking for function "if_indextoname" : YES 
 Checking for function "if_nametoindex" : YES 
 Checking for function "splice" : YES 
 Checking for function "sysinfo" : YES 
 Checking for function "stpcpy" : YES 
 Checking for function "memalign" : YES 
 Checking if "getservbyname_r()" compiles: YES 
 Checking for function "_aligned_malloc" : NO 
 Checking for function "aligned_alloc" : YES 
 Checking for function "posix_memalign" : YES 
 Checking for function "posix_spawn" : YES 
 Checking if "strerror_r() returns char *" compiles: NO 
 Checking for function "snprintf" : YES 
 Checking for function "strcasecmp" : YES 
 Checking for function "strncasecmp" : YES 
 Header "sys/sysmacros.h" has symbol "major" : YES 
 Header "dlfcn.h" has symbol "RTLD_LAZY" : YES 
 Header "dlfcn.h" has symbol "RTLD_NOW" : YES 
 Header "dlfcn.h" has symbol "RTLD_GLOBAL" : YES 
 Header "dlfcn.h" has symbol "RTLD_NEXT" : YES 
 Checking for type "loff_t" : NO 
 Checking for function "unshare" : YES 
 Message: Checking whether to use statfs or statvfs .. statfs
 Checking for function "mkostemp" : YES 
 Checking if "futex(2) system call" compiles: YES 
 Checking if "futex_time64(2) system call" compiles: NO 
 Checking if "eventfd(2) system call" links: YES 
 Checking if "ppoll(2) system call" links: YES 
 Checking if "pidfd_open(2) system call" links: YES 
 Checking if "__uint128_t available" compiles: YES 
 Checking if "clock_gettime" links: YES 
 Checking for function "clock_nanosleep" : YES 
 Checking if "dlopen() and dlsym() in system libraries" links: YES 
 Checking if "number of arguments to statfs() (n=2)" compiles: YES 
 Checking if "open() option O_DIRECTORY" compiles: YES 
 Checking if "fcntl() option F_FULLFSYNC" compiles: NO 
 Checking if "C99 vsnprintf" runs: YES
 Checking if "C99 snprintf" runs: YES
 Checking if "Unix98 printf positional parameters" runs: YES
 Checking if "nl_langinfo and CODESET" links: YES 
 Checking if "nl_langinfo (PM_STR)" links: YES 
 Checking if "nl_langinfo (ERA)" links: NO 
 Checking if "nl_langinfo (_NL_CTYPE_OUTDIGITn_MB)" links: NO 
 Checking if "nl_langinfo (ALTMON_n)" links: NO 
 Checking if "nl_langinfo (_NL_ABALTMON_n)" links: NO 
 Checking if "nl_langinfo and _NL_TIME_CODESET" links: NO 
 Checking if "signed" compiles: YES 
 Header "stddef.h" has symbol "ptrdiff_t" : YES 
 Checking if "sig_atomic_t" links: YES 
 Checking if "long long" compiles: YES 
 Checking if "long double" compiles: YES 
 Header "stddef.h" has symbol "wchar_t" : YES 
 Header "wchar.h" has symbol "wint_t" : YES 
 Checking if "uintmax_t in inttypes.h" compiles: YES 
 Checking if "uintmax_t in stdint.h" compiles: YES 
 Checking for size of "char" : 1 
 Checking for size of "short" : 2 
 Checking for size of "int" : 4 
 Checking for size of "void*" : 8 
 Checking for size of "long" : 8 
 Checking for size of "long long" : 8 
 Checking for size of "size_t" : 8 
 Checking for size of "ssize_t" : 8 
 Checking if "int64_t is long" compiles: YES 
 Checking for alignment of "char" : 1 
 Checking for alignment of "short" : 2 
 Checking for alignment of "int" : 4 
 Checking for alignment of "void*" : 8 
 Checking for alignment of "long" : 8 
 Checking for alignment of "long long" : 8 
 Checking for alignment of "size_t" : 8 
 Checking for size of "wchar_t" : 4 
 Checking if "GCC size_t typedef is long" compiles: YES 
 Checking if "GCC size_t typedef is long long" compiles: NO 
 Checking if "va_lists can be copied as values" runs: DID NOT COMPILE
 Checking if "ISO C99 varargs macros in C" compiles: YES 
 Checking if "ISO C99 varargs macros in C++" compiles: YES 
 Checking if "GNUC varargs macros" compiles: YES 
 Has header "alloca.h" : YES (cached)
 Has header "sys/poll.h" : YES 
 Has header "sys/types.h" : YES (cached)
 Has header "winsock2.h" : NO 
 Computing int of "POLLIN" : 1
 Computing int of "POLLOUT" : 4
 Computing int of "POLLPRI" : 2
 Computing int of "POLLERR" : 8
 Computing int of "POLLHUP" : 16
 Computing int of "POLLNVAL" : 32
 Computing int of "AF_UNIX" : 1
 Computing int of "AF_INET" : 2
 Computing int of "AF_INET6" : 10
 Computing int of "MSG_OOB" : 1
 Computing int of "MSG_PEEK" : 2
 Computing int of "MSG_DONTROUTE" : 4
 Checking for type "struct in6_addr" : YES 
 Checking if "atomic ops" links: YES 
 Checking if "atomic ops define" compiles: YES 
 Checking if "sync swap" links: NO 
 Run-time dependency threads found: YES
 Header "pthread.h" has symbol "pthread_attr_setstacksize" : YES 
 Header "pthread.h" has symbol "pthread_attr_setinheritsched" : YES 
 Header "pthread.h" has symbol "pthread_condattr_setclock" : YES 
 Header "pthread.h" has symbol "pthread_cond_timedwait_relative_np" : NO 
 Header "pthread.h" has symbol "pthread_getname_np" : YES 
 Header "pthread.h" has symbol "pthread_getaffinity_np" : YES 
 Checking if "pthread_setname_np(const char*)" with dependency threads links: NO 
 Checking if "pthread_setname_np(pthread_t, const char*)" with dependency threads links: YES 
 Checking if "stack grows check" runs: NO (1)
 Run-time dependency iconv found: YES
 Found pkg-config: YES (/usr/bin/pkg-config) 2.5.1
-Found CMake: /usr/bin/cmake (4.2.3)
-Run-time dependency libpcre2-8 found: NO  (tried pkg-config and cmake)
-Run-time dependency libpcre2-8 found: NO  (tried pkg-config and cmake)
-Looking for a fallback subproject for the dependency libpcre2-8
-Downloading pcre2 source from https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.46/pcre2-10.46.tar.bz2
-Downloading pcre2 patch from https://wrapdb.mesonbuild.com/v2/pcre2_10.46-1/get_patch
-Applying diff file "pcre2/fix-build-on-apple-platforms.patch"
-
-Executing subproject pcre2 
-
-pcre2| Project name: pcre2
-pcre2| Project version: 10.46
-pcre2| C compiler for the host machine: cc (gcc 15.2.0 "cc (Alpine 15.2.0) 15.2.0")
-pcre2| C linker for the host machine: cc ld.bfd 2.45.1
-pcre2| Compiler for C supports function attribute visibility:default: YES
-pcre2| Dependency threads for host machine found: YES unknown (cached)
-pcre2| Has header "sys/stat.h" : YES (cached)
-pcre2| Has header "sys/types.h" : YES (cached)
-pcre2| Has header "assert.h" : YES
-pcre2| Has header "dirent.h" : YES (cached)
-pcre2| Has header "windows.h" : NO
-pcre2| Has header "unistd.h" : YES (cached)
-pcre2| Checking for function "bcopy" : YES
-pcre2| Checking for function "memmove" : YES
-pcre2| Checking for function "realpath" : YES
-pcre2| Checking for function "strerror" : YES
-pcre2| Checking if "__builtin_unreachable" links: YES
-pcre2| Checking if "__builtin_mul_overflow" links: YES
-pcre2| Checking if "__assume" links: NO
-pcre2| Checking if "__attribute__((uninitialized))" compiles: YES
-pcre2| Configuring pcre2.h using configuration
-pcre2| Configuring config.h using configuration
-pcre2| Found pkg-config: YES (/usr/bin/pkg-config) 2.5.1
-pcre2| Build targets in project: 5
-pcre2| Subproject pcre2 finished.
+Run-time dependency libpcre2-8 found: YES 10.49
 
-Dependency libpcre2-8 for host machine from subproject subprojects/pcre2-10.46 found: YES 10.46
-
 Executing subproject gvdb 
 
 gvdb| Project name: gvdb
 gvdb| Project version: 0.0
 gvdb| C compiler for the host machine: cc (gcc 15.2.0 "cc (Alpine 15.2.0) 15.2.0")
 gvdb| C linker for the host machine: cc ld.bfd 2.45.1
-gvdb| Build targets in project: 5
+gvdb| Build targets in project: 0
 gvdb| Subproject gvdb finished.
 
 Dependency gvdb for host machine found: YES 0.0 (overridden)
 Library m found: YES
-Run-time dependency libffi found: NO  (tried pkg-config and cmake)
-Looking for a fallback subproject for the dependency libffi
-Downloading libffi source from https://github.com/libffi/libffi/releases/download/v3.5.2/libffi-3.5.2.tar.gz
-Downloading libffi patch from https://wrapdb.mesonbuild.com/v2/libffi_3.5.2-1/get_patch
-
-Executing subproject libffi 
-
-libffi| Project name: libffi
-libffi| Project version: 3.5.2
-libffi| C compiler for the host machine: cc (gcc 15.2.0 "cc (Alpine 15.2.0) 15.2.0")
-libffi| C linker for the host machine: cc ld.bfd 2.45.1
-libffi| Checking for size of "size_t" : 8 (cached)
-libffi| Has header "stdlib.h" : YES (cached)
-libffi| Has header "string.h" : YES (cached)
-libffi| Has header "sys/memfd.h" : NO
-libffi| Has header "alloca.h" : YES (cached)
-libffi| Has header "inttypes.h" : YES (cached)
-libffi| Has header "stdint.h" : YES (cached)
-libffi| Has header "stdio.h" : YES
-libffi| Has header "stdlib.h" : YES (cached)
-libffi| Has header "strings.h" : YES (cached)
-libffi| Has header "string.h" : YES (cached)
-libffi| Has header "sys/stat.h" : YES (cached)
-libffi| Has header "sys/types.h" : YES (cached)
-libffi| Has header "unistd.h" : YES (cached)
-libffi| Has header "dlfcn.h" : YES
-libffi| Checking for function "memfd_create" : YES
-libffi| Checking for function "memcpy" : YES
-libffi| Checking for size of "long double" : 16
-libffi| Checking for size of "double" : 8
-libffi| Checking if "ASM .cfi" compiles: YES
-libffi| Checking if "ASM x86 PCREL" compiles: YES
-libffi| Compiler for C supports arguments -fno-lto: YES
-libffi| Compiler for C supports function attribute visibility: YES
-libffi| Message: .hidden pseudo-op is available
-libffi| Configuring fficonfig.h using configuration
-libffi| Configuring ffi.h using configuration
-libffi| Compiler for C supports link arguments -shared -Wl,--version-script=/glib-2.90.1/subprojects/libffi-3.5.2/libffi.map.in: YES
-libffi| Build targets in project: 7
-libffi| Subproject libffi finished.
-
-Dependency libffi for host machine found: YES 3.5.2 (overridden)
+Run-time dependency libffi found: YES 3.5.2
 Run-time dependency zlib found: YES 1.3.2
 Checking if "check for -latomic" links: YES 
 Library atomic found: YES
-Run-time dependency intl found: NO  (tried builtin and system)
-Run-time dependency intl found: NO  (tried builtin and system)
-Looking for a fallback subproject for the dependency intl
-Downloading proxy-libintl source from https://github.com/frida/proxy-libintl/archive/refs/tags/0.5.tar.gz
-
-Executing subproject proxy-libintl 
-
-proxy-libintl| Project name: proxy-libintl
-proxy-libintl| Project version: 1
-proxy-libintl| C compiler for the host machine: cc (gcc 15.2.0 "cc (Alpine 15.2.0) 15.2.0")
-proxy-libintl| C linker for the host machine: cc ld.bfd 2.45.1
-proxy-libintl| Build targets in project: 8
-proxy-libintl| Subproject proxy-libintl finished.
-
-Dependency intl for host machine from subproject subprojects/proxy-libintl-0.5 found: YES 1
+Run-time dependency intl found: YES
+Checking for function "ngettext" with dependency intl: YES 
+Checking for function "bind_textdomain_codeset" with dependency intl: YES 
 Dependency mount for host machine skipped: feature libmount disabled
+Found CMake: /usr/bin/cmake (4.2.3)
 Run-time dependency libselinux found: NO  (tried pkg-config and cmake)
 Checking for function "getxattr" : YES 
 Has header "sys/xattr.h" : YES 
 Checking if "XATTR_NOFOLLOW" compiles: NO 
 Checking for function "strlcpy" : YES 
 Checking if "OpenBSD strlcpy/strlcat" runs: YES
 Checking if "/proc/self/cmdline" runs: YES
 Program python3 found: YES (/usr/bin/python3)
 Program bash found: YES (/bin/bash)
 Run-time dependency bash-completion found: NO  (tried pkg-config and cmake)
 Program sh found: YES (/bin/sh)
 Program pkg-config found: YES (/usr/bin/pkg-config)
 Program env found: YES (/usr/bin/env)
 Program dtrace found: NO
 Header "sys/ptrace.h" has symbol "PTRACE_O_EXITKILL" : YES 
 Program g-ir-scanner found: NO
 Run-time dependency gobject-introspection-1.0 found: NO  (tried pkg-config and cmake)
 Configuring glib-gettextize using configuration
 Program gen-visibility-macros.py found: YES (/glib-2.90.1/tools/gen-visibility-macros.py)
 Configuring glibconfig.h using configuration
 Compiler for C supports arguments -Wno-sign-conversion: YES 
 Dependency sysprof-capture-4 for host machine skipped: feature sysprof disabled
+Found pkg-config: YES (/usr/bin/pkg-config) 2.5.1
 Configuring gtester-report using configuration
 Configuring libglib-2.0.so.0.9000.1-gdb.py using configuration
 Configuring glib-genmarshal using configuration
 Configuring glib-mkenums using configuration
 Configuring libgobject-2.0.so.0.9000.1-gdb.py using configuration
 Checking if "dlsym() preceding underscores" runs: YES
 Checking for function "dlerror" : YES 
 Configuring gmoduleconf.h using configuration
 Checking if "C_IN in public headers (no arpa/nameser_compat.h needed)" compiles: YES 
 Checking if "res_query()" links: YES 
 Checking if "socket()" links: YES 
 Checking if "dn_comp()" links: YES 
 Checking if "res_nclose()" links: NO 
 Checking if "res_ndestroy()" links: NO 
 Checking if "res_ninit()" links: NO 
 Checking if "res_nquery()" links: NO 
 Checking for type "struct ip_mreqn" : YES 
 Checking if "ioctl with request SIOCGIFADDR" compiles: YES 
 Configuring gnetworking.h using configuration
 Configuring gdbus-codegen using configuration
 Configuring config.py using configuration
 Compiler for C supports arguments -Wno-sign-conversion: YES (cached)
 Run-time dependency libinotify found: NO  (tried pkg-config and cmake)
 Message: Found bash-completion but the .pc file did not set 'completionsdir', fallback to a predefined path
 Run-time dependency libelf found: NO  (tried pkg-config and cmake)
 Library elf found: NO
 Compiler for C supports arguments -Wno-implicit-fallthrough: YES 
 Compiler for C supports arguments -Wno-old-style-definition: YES 
 Compiler for C supports arguments -Wno-suggest-attribute=noreturn: YES 
 Compiler for C supports arguments -Wno-type-limits: YES 
 Compiler for C supports arguments -Wno-undef: YES 
 Compiler for C supports arguments -Wno-unused-parameter: YES (cached)
 Compiler for C supports arguments -Wno-cast-align: YES 
 Compiler for C supports arguments -Wno-unused-function: YES 
 Compiler for C supports arguments -Wno-return-type: YES 
 Compiler for C supports arguments -Wno-sometimes-uninitialized: NO 
 Compiler for C supports arguments -Wno-old-style-definition: YES (cached)
 Compiler for C supports arguments -Wno-type-limits: YES (cached)
 Compiler for C supports arguments -Wno-old-style-definition: YES (cached)
 Compiler for C supports arguments -Wno-cast-align: YES (cached)
 Compiler for C supports arguments -Wno-unused-parameter: YES (cached)
 Compiler for C supports arguments -Wno-duplicated-branches: YES 
 Compiler for C supports arguments -Wno-cast-align: YES (cached)
 Compiler for C supports arguments -Wno-unused-parameter: YES (cached)
 Compiler for C supports arguments -Wno-duplicated-branches: YES (cached)
 Compiler for C supports arguments -Wno-type-limits: YES (cached)
 Compiler for C supports arguments -Wno-cast-align: YES (cached)
 Compiler for C supports arguments -Wno-missing-field-initializers: YES 
 Compiler for C supports arguments -Wno-old-style-definition: YES (cached)
 Compiler for C supports arguments -Wno-cast-align: YES (cached)
 Compiler for C supports arguments -Wno-unused-parameter: YES (cached)
 Compiler for C supports arguments -Wno-duplicated-branches: YES (cached)
 Compiler for C supports arguments -Wno-old-style-definition: YES (cached)
 Compiler for C supports arguments -Wno-cast-align: YES (cached)
 Compiler for C supports arguments -Wno-unused-parameter: YES (cached)
 Compiler for C supports arguments -Wno-duplicated-branches: YES (cached)
 Compiler for C supports arguments -Wno-old-style-definition: YES (cached)
 Compiler for C supports arguments -Wno-cast-align: YES (cached)
 Compiler for C supports arguments -Wno-unused-parameter: YES (cached)
 Compiler for C supports arguments -Wno-duplicated-branches: YES (cached)
 Compiler for C supports arguments -Werror=unused-function: YES 
 Library FuzzingEngine skipped: feature oss_fuzz disabled
 Program xgettext found: NO
 Configuring config.h using configuration
 Program rst2man rst2man.py found: NO
 Program rst2html5 rst2html5.py found: NO
-Build targets in project: 57
+Build targets in project: 49
 
-libffi 3.5.2
-
-    Host CPU       : x86_64
-    Host CPU family: x86_64
-    Host system    : linux
-    Target         : X86_64
-    ASM sources    : unix64.S
-                     win64.S
-    C sources      : ffi64.c
-                     ffiw64.c
-
 glib 2.90.1
 
   Build environment
     host cpu            : x86_64
     host endian         : little
     host system         : linux
     C Compiler          : gcc
     C++ Compiler        : gcc
     shared build        : false
     static build        : true
     linux_libc          : musl
 
   Directories
     prefix              : /usr/local
     bindir              : /usr/local/bin
     libexecdir          : /usr/local/libexec
     pkgdatadir          : /usr/local/share/glib-2.0
     datadir             : /usr/local/share
     localedir           : /usr/local/share/locale
     includedir          : /usr/local/include/glib-2.0
     giomodulesdir       : /usr/local/lib/gio/modules
     localstatedir       : /var/local
     runstatedir         : /run
 
   Options
     selinux             : false
     libmount            : false
     xattr               : false
     man-pages           : auto
     dtrace              : false
     systemtap           : false
     sysprof             : false
     documentation       : false
     bsymbolic_functions : true
     force_posix_threads : false
     tests               : false
     installed_tests     : false
     nls                 : auto
     oss_fuzz            : disabled
     glib_debug          : disabled
     glib_assert         : true
     glib_checks         : true
     libelf              : auto
     multiarch           : false
     introspection       : false
     file_monitor_backend: auto
 
   Subprojects
     gvdb                : YES
-    libffi              : YES
-    pcre2               : YES
-    proxy-libintl       : YES
 
   User defined options
     buildtype           : release
     default_library     : static
     glib_debug          : disabled
     libmount            : disabled
     sysprof             : disabled
     tests               : false
 
 Found ninja-1.9 at /usr/bin/ninja
```

</details>

From now on these versions follow `ALPINE_VERSION`. `versions.json` lists pcre2 and libffi. The comments of the `apk add` now sit inline above their packages, as suggested in #849.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

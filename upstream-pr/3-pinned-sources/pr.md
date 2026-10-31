# No hidden downloads in the libjxl, glib and cairo steps

Two kinds of downloads bypass the Dockerfile today: libjxl's `deps.sh` fetches nine archives without a checksum, and meson downloads subprojects for glib and cairo when a dependency is not installed. Neither shows in the Dockerfile, and both fail only when the build reaches them.

With this PR these steps download nothing the Dockerfile does not list. highway gets its own recipe with a checksum, and the dependencies meson used to fetch come from Alpine packages pinned by `ALPINE_VERSION`.

## libjxl without deps.sh

`deps.sh` fetches nine GitHub tarballs by commit hash, without a checksum: testdata, brotli, googletest, highway, sjpeg, skcms, zlib, libpng and libjpeg-turbo ([deps.sh#L50](https://github.com/libjxl/libjxl/blob/v0.12.0/deps.sh#L50), [#L78-L86](https://github.com/libjxl/libjxl/blob/v0.12.0/deps.sh#L78-L86)). Of these the recipe needs only highway; brotli is installed already and the rest are not built.

highway is now built before libjxl as a static library, without tests, examples and contrib ([CMakeLists.txt#L85-L88](https://github.com/google/highway/blob/1.2.0/CMakeLists.txt#L85-L88)), switched off as libjxl does for its bundled copy ([third_party/CMakeLists.txt#L22-L24](https://github.com/libjxl/libjxl/blob/v0.12.0/third_party/CMakeLists.txt#L22-L24)); libjxl picks it up with `-DJPEGXL_FORCE_SYSTEM_HWY=ON` ([third_party/CMakeLists.txt#L28-L34](https://github.com/libjxl/libjxl/blob/v0.12.0/third_party/CMakeLists.txt#L28-L34)). Without `deps.sh` nothing uses `curl` any more, so the package is dropped.

highway stays at the version libjxl pins in `deps.sh`, 1.2.0 for libjxl 0.12.0 ([deps.sh#L20](https://github.com/libjxl/libjxl/blob/v0.12.0/deps.sh#L20)). That is the version libjxl builds and tests with; newer releases bring targets libjxl cannot switch off ([libjxl#5047](https://github.com/libjxl/libjxl/issues/5047)). So highway has no bump rule of its own: the libjxl bump reads the pin from the new `deps.sh` and sets highway's version and checksum to match. highway moves only when libjxl moves it.

## Alpine packages instead of meson subprojects

glib looks for pcre2, libffi and libintl and downloads each missing one as a wrap subproject ([meson.build#L2259-L2276](https://github.com/GNOME/glib/blob/2.90.1/meson.build#L2259-L2276), [#L2302](https://github.com/GNOME/glib/blob/2.90.1/meson.build#L2302), [#L2315-L2353](https://github.com/GNOME/glib/blob/2.90.1/meson.build#L2315-L2353)); cairo does the same for pixman ([meson.build#L677-L679](https://gitlab.freedesktop.org/cairo/cairo/-/blob/1.18.6/meson.build#L677-679)). The build log of the current Dockerfile shows "Run-time dependency libpcre2-8 found: NO", likewise for `libffi`, `intl` and `pixman-1`, followed by the downloads of pcre2 10.46, libffi 3.5.2, proxy-libintl 0.5 and pixman 0.44.2.

Alpine ships pcre2, libffi and pixman with static archives. gettext is part of musl's libc, so `musl-libintl` only adds `libintl.h`. With `pcre2-dev pcre2-static libffi-dev musl-libintl pixman-dev pixman-static` installed, meson finds all four ("libpcre2-8 found: YES 10.49", "libffi found: YES 3.5.2", "intl found: YES", "pixman-1 found: YES 0.46.4") and downloads nothing. `versions.json` lists the three new packages.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

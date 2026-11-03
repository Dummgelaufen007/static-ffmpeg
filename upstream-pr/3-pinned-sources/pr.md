# No hidden downloads in the libjxl step

libjxl's `deps.sh` bypasses the Dockerfile today: it fetches nine archives without a checksum. That does not show in the Dockerfile and fails only when the build reaches it.

With this PR the libjxl step downloads nothing the Dockerfile does not list: highway gets its own recipe with a checksum.

## libjxl without deps.sh

`deps.sh` fetches nine GitHub tarballs by commit hash, without a checksum: testdata, brotli, googletest, highway, sjpeg, skcms, zlib, libpng and libjpeg-turbo ([deps.sh#L50](https://github.com/libjxl/libjxl/blob/v0.12.0/deps.sh#L50), [#L78-L86](https://github.com/libjxl/libjxl/blob/v0.12.0/deps.sh#L78-L86)). Of these the recipe needs only highway; brotli is installed already and the rest are not built.

highway is now built before libjxl as a static library, without tests, examples and contrib ([CMakeLists.txt#L85-L88](https://github.com/google/highway/blob/1.2.0/CMakeLists.txt#L85-L88)), switched off as libjxl does for its bundled copy ([third_party/CMakeLists.txt#L22-L24](https://github.com/libjxl/libjxl/blob/v0.12.0/third_party/CMakeLists.txt#L22-L24)); libjxl picks it up with `-DJPEGXL_FORCE_SYSTEM_HWY=ON` ([third_party/CMakeLists.txt#L28-L34](https://github.com/libjxl/libjxl/blob/v0.12.0/third_party/CMakeLists.txt#L28-L34)).

highway stays at the version libjxl pins in `deps.sh`, 1.2.0 for libjxl 0.12.0 ([deps.sh#L20](https://github.com/libjxl/libjxl/blob/v0.12.0/deps.sh#L20)). That is the version libjxl builds and tests with; newer releases bring targets libjxl cannot switch off ([libjxl#5047](https://github.com/libjxl/libjxl/issues/5047)). So highway has no bump rule of its own: the libjxl bump reads the pin from the new `deps.sh` and sets highway's version and checksum to match. highway moves only when libjxl moves it.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

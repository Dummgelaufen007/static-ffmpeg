# Build the libraries in parallel stages

Almost none of the libraries needs another self-built library, yet each one waits for all the ones before it. The goal of this PR is a shorter build: libraries that do not depend on each other are built at the same time, so the runner's cores do work while one library is in a phase that uses only one of them.

Only where a library uses another self-built one, its stage builds on the stage of that library:

```
glib ──┬─► harfbuzz ──┬─► libass
       │              ▼
       └─► cairo ───► pango ───┐
                      dav1d ───┼─► librsvg
                      rust ──┬─┘
                             └─► rav1e
vmaf ──► aom
libudfread ──► libbluray
[libdvdcss] ──► libdvdread ──► libdvdnav
ogg ──┬─► theora
      └─► vorbis
highway ──┬─► libjxl
lcms2 ────┘
```

- aom needs vmaf for `-DCONFIG_TUNE_VMAF=1`, librsvg needs dav1d for avif, libdvdread links libdvdcss when it is enabled.
- cairo needs glib: librsvg requires `cairo-gobject` ([meson.build#L71](https://gitlab.gnome.org/GNOME/librsvg/-/blob/2.63.4/meson.build#L71)), which cairo builds only when it finds glib ([meson.build#L587-L598](https://gitlab.freedesktop.org/cairo/cairo/-/blob/1.18.6/meson.build#L587-L598)). Today the order of the recipes meets this without saying so.

harfbuzz also stays on glib, which it uses when it finds it ([meson_options.txt#L2](https://github.com/harfbuzz/harfbuzz/blob/15.1.0/meson_options.txt#L2)), so it is built as today.

rust, cargo and cargo-c move from the package list of `base` into their own `rust` stage. Every chain starts at `base`, and only librsvg and rav1e need rust, so the others no longer wait for its install.

## versions.json

The library versions are `ARG`s of their own stages now, so `builder` no longer sees them as `env.X_VERSION`. Instead each library that has a key in `versions.json` ends its `RUN` with one line that writes its version to a file named after that key, e.g.

```dockerfile
echo "$VMAF_VERSION" > /usr/local/share/versions/libvmaf
```

The `COPY --from` lines bring these files into `builder` with the rest of `/usr/local`. The `versions.json` step keeps reading the apk packages and ffmpeg as before and adds one entry per file, with the file name as key:

```dockerfile
jq -S -Rn '{ ... } + reduce inputs as $v ({}; . + {(input_filename | split("/")[-1]): $v})' /usr/local/share/versions/* > /versions.json
```

libfdk-aac and libdvdcss write their file only when `ENABLE_FDKAAC` or `ENABLE_LIBDVDCSS` is set, which replaces the two `del()`. The keys are the same as today; `-S` sorts them.

ffmpeg itself stays the same: the same libraries, built with the same recipes.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

# Runbook: Parallelizing the static-ffmpeg Dockerfile

## Scope

Restructure wader/static-ffmpeg's `Dockerfile` so BuildKit builds the libraries in parallel stages instead of one serial `builder` stage, without changing what `ffmpeg`/`ffprobe` link against.

This describes the method, not a fixed result. Re-derive every concrete detail (library list, chains, stage count) from the current upstream file on each run.

- Source: `https://raw.githubusercontent.com/wader/static-ffmpeg/refs/heads/master/Dockerfile`. Fetch it fresh and read the whole file.
- Keep unchanged: the Alpine version, every library version, and every build command/flag. Only the stage structure changes.
- Put `# syntax=docker/dockerfile:1` as line 1.

## Step 1: dependency graph

Only a few libraries depend on other self-built libraries; everything else depends only on apk packages and builds in parallel.

Method: list every library RUN block; for each, find what its steps read that an earlier `RUN` wrote — libraries its configure/meson/cmake step picks up from `/usr/local` as well as anything else (read the build scripts, not just the flags); classify each edge as hard (build fails without it) or optional (feature detected if present). Keep optional edges in their original order so the output stays identical.

Chains found in the last run (re-verify each time):

| Chain | Reason |
| --- | --- |
| vmaf → aom | `-DCONFIG_TUNE_VMAF=1`, plus the `sed` on `libvmaf.pc` |
| glib → harfbuzz → cairo → pango → librsvg | pango needs glib, harfbuzz, cairo; librsvg needs all four. glib→harfbuzz and glib→cairo are optional, harfbuzz→cairo does not exist; kept for identical output |
| harfbuzz → libass | harfbuzz is not an apk package |
| ogg → theora, ogg → vorbis |  |
| lcms2 → libjxl | with `JPEGXL_ENABLE_SKCMS=OFF` libjxl needs an installed lcms2; `deps.sh` does not fetch lcms |
| libva → libvpl | original order; kept |
| x265-base → {x265-12bit, x265-10bit} → x265 | introduced by the x265 split in Step 3 |
| all leaf build stages → builder (ffmpeg) |  |

Not a build dependency: symbol collisions handled at link time (e.g. libzmq/libssh `sha1_init`).

## Step 2: one stage per library

1. **Global ARG block.** Move every `ARG` the library stages and the `versions.json` block use, together with their `# bump:` comments, before the first `FROM`, and re-declare it in each stage that uses it. Also global: `ALPINE_VERSION`, `APK_OPTS`, `CFLAGS`, `CXXFLAGS`, `LDFLAGS`, `WGET_OPTS`, `TAR_OPTS`, `ENABLE_FDKAAC`.
2. **base stage.** `FROM $ALPINE_VERSION AS base`, the unchanged `apk add` list, then import the flags and download settings and set them as `ENV`.
3. **One stage per library.** `FROM base AS <lib>` (or `FROM <parent>` for chains), containing the library's original download and build commands unchanged. Import the ARGs the stage uses. Stage names: lowercase, `[a-z0-9-_.]`. Builds that fetch during compile (cargo in rav1e and librsvg) keep a `RUN --mount=type=cache,target=/root/.cargo/registry --mount=type=cache,target=/root/.cargo/git` on the build RUN so crates are not re-downloaded — a flag only, no extra stage.
4. **Every stage passes on what later stages read.** Libraries install into `/usr/local` so `.pc` prefixes stay valid after the merge; check non-standard installs (cargo cinstall, manual `cp`, symlinks).
5. **`builder` stage.** `FROM base AS builder`, then one `COPY --link --from=<leaf>` per leaf build stage for what the `builder` reads, then download and build ffmpeg as in the original; chain members arrive through the last stage of their chain. The COPYs must precede the ffmpeg build so `./configure` finds the libraries. `--link` is safe here because the merges are additive and duplicate files from chains are identical.
6. **versions.json.** Re-declare every version ARG the `jq` block reads via `env.*`; missing ones silently become `null`.
7. **Keep unchanged:** `checkelf`, `checkdupsym`, the font `apk add`, the final stages, and the stage name `builder`.
8. **Comment the non-obvious:** which chain links are hard and which are kept only for identical output, and why each stage has its parent.

## Step 3: x265 — parallel bit depths instead of multilib.sh

`build/linux/multilib.sh` builds 12-bit, 10-bit and 8-bit serially. Replace it with stages that rebuild exactly what the script does:

- `x265-src` (`FROM base`): download and verify, extract into a fixed dir (`-C x265 --strip-components=1`), then `grep -qxF` guards on the unmodified cmake lines of `multilib.sh`.
- `x265-base` (`FROM base`): `COPY --from=x265-src`, then an `ENV` holding the common cmake flags the original passed via `CMAKEFLAGS`.
- `x265-12bit` and `x265-10bit` (`FROM x265-base`): the script's 12-bit and 10-bit cmake calls plus the common flags, then `make`.
- `x265` (`FROM x265-base`): copy both `libx265.a` into `8bit/` under the names the script links (`libx265_main12.a`, `libx265_main10.a`), run the script's 8-bit cmake call, `make`, rename to `libx265_main.a`, merge the three with `ar -M` exactly as the script does, `make install`.

The guards make the build fail loudly when upstream changes `multilib.sh`; then re-derive the stages from the new script. Keep the stage name `x265` so the builder COPY stays valid. Do not patch `multilib.sh` with `sed`.

## Step 4: verification without Docker

Static checks catch structure errors; only a real build proves the dependency graph, so say so explicitly.

- Every `COPY --from` / `FROM` references an existing stage.
- Every leaf build stage is copied into `builder`.
- Optional: **hadolint** (run on the upstream file first as baseline; only new rule types or count jumps need a look) and **dockerfile-parse** to count stages/RUNs and assert no RUN starts or ends with `&&`.

Report what could not be verified (the real build) in one line.

## Pitfalls

- **Hidden hard dependencies.** Check every "independent" assumption against the build scripts, not the flag names (e.g. libjxl's `deps.sh` does not vendor lcms; the build fails with `Could NOT find LCMS2`).
- **Only what is copied crosses stages.** Anything in `builder` that reads a source dir (e.g. `checkdupsym /ffmpeg-*`) works only because `builder` builds ffmpeg there.
- **Glob collisions.** Patterns like `cd ffmpeg*` or `cd libssh*` match both the tarball and the directory. This works in the upstream file; do not change these patterns.
- **Oversubscription.** N parallel stages × `-j$(nproc)` each; cap it with BuildKit's max-parallelism if needed. Do not change `-j` values.
- **Cheap syntax tests mislead.** Compiling configure-based C projects without their generated headers produces fatal errors that hide real ones. Only claim results for files that actually compiled.

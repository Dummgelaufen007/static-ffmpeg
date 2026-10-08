# Runbook: Download cache for the static-ffmpeg Dockerfile

## Scope

Every source the Dockerfile fetches itself is kept in a local cache directory and reused by the build. Nothing is compiled differently: the cache variant builds the same `ffmpeg` as the file it is derived from.

- Input: a Dockerfile whose downloads have been cleaned (`runbook-for-cleaning.md`).
- Output: a cache variant next to it; the `diff -u` against the input is the review artifact.
- Out of scope: downloads a recipe triggers by itself during the build (meson wraps, cargo crates, helper scripts); see "Downloads" in `runbook-for-optimizing.md`.

This describes the method, not a fixed result. File names, stage names and code below illustrate the implementation at the time of writing.

## Prerequisite

The cache matches files by name, so what the cleaning runbook establishes is what the cache relies on:

- Every downloaded file has a name that is unique and carries its version, so a cached file can never stand in for another version.
- Every download has an integrity check in its recipe.
- Every git source takes its URL from a variable and is pinned to a commit.

A Dockerfile that misses one of these is cleaned first.

## Step 1: fill the cache

The tool that fills the cache has to:

- Derive what to fetch from the Dockerfile itself, resolving its variables the way the build does — never from a second list that can drift.
- Keep an existing file only when it passes the checksum the Dockerfile declares for it, and never leave a partial download under its final name.
- Fetch git sources only in their pinned state and make them available under the name the recipe expects. Today: a directory named after the commit plus a relative symlink with the clone's name. An existing directory is accepted by that name; it only comes into being by a clone into a temporary directory that is renamed when complete.
- Remove what the Dockerfile no longer references. Today every directory without a pointing symlink is deleted — including anything placed there by hand.
- Fail loudly on missing input: errors inside command or process substitution do not stop a shell script on their own.

## Step 2: bring the cache into the build

- The fill tool runs inside the build, in its own stage ahead of the compile stages. It delivers every source fetched and verified, so the fetching runs alongside the builder's package installation, and a source that cannot be fetched or verified stops the build before anything is compiled.
- The cache is an addition, not a requirement: without one the tool fetches everything, with one only what is missing, and the build never changes it. Today: the stage copies its starting content from a stage that is empty by default and that the caller replaces by a directory.
- That tool reads the Dockerfile actually being built, not a fixed name. Today: a build argument names it, with the standard file name as default; a variant under another name has to pass its own, and a wrong name goes unnoticed, the tool then works off another file's sources. The `ARG`s that give a source its URL, file name, checksum or commit stay in the Dockerfile: the tool derives its work from them.
- Whatever the tool calls is available to it in that stage. Today: its helper script is mounted next to it.
- The cache reaches each recipe where and under the name the recipe already uses, so the recipe's extraction stays untouched.
- With that a recipe carries no fetch, checksum or git step of its own. It starts with the extraction; for a git source, with the change into its directory.

Illustration, as implemented today:

```dockerfile
FROM scratch AS downloads

FROM <base> AS downloader
ARG APK_OPTS=""
RUN apk add --no-cache $APK_OPTS bash wget git
COPY --from=downloads / /downloads/
ARG DOCKERFILE=Dockerfile
RUN --mount=src=<fill tool>,dst=/download.sh \
    --mount=src=<git helper>,dst=/git-mini-clone \
    --mount=src=$DOCKERFILE,dst=/Dockerfile \
  bash /download.sh /Dockerfile /downloads

FROM <base> AS builder
…
COPY --from=downloader /downloads/ /
…
RUN \
  tar $TAR_OPTS $VMAF_FILE && cd vmaf-*/libvmaf && \
```

```sh
docker buildx build --build-context downloads=<cache directory> --build-arg DOCKERFILE=<Dockerfile being built> …
```

GNU `wget` is installed there because busybox `wget` is assumed not to support the options in `WGET_OPTS` (untested).

## Step 3: the build script

- Hand the cache directory to the build when there is one.
- Pass the name of the Dockerfile being built.
- All variants share one directory and need no copy of it, because a build cannot alter it.
- Filling the cache is no part of a build. What a build fetches is gone with its layers, so new sources reach the directory in a step of their own, run when sources have changed. Today: the fill tool on the host, once per Dockerfile on a hard-linked copy of the directory; the copy's symlinks are dropped, what is new is moved into the directory and the copy removed. A second pass that fetches nothing confirms the result. The copy is needed because the tool removes what its Dockerfile does not reference.
- That step needs the tools the fill script uses on the host; which ones and where they come from differs per host (e.g. `sha256sum` is not part of stock macOS).

## Step 4: verification without a build

- A dry run of the fill tool with its fetch functions stubbed: it finds as many downloads as the Dockerfile has, every name is fully resolved, and every name exists in the cache.
- Below the builder stage no recipe fetches, checks or clones any more.
- The download stage built without a cache directory fetches every source; built with a complete one it fetches none.
- A real run after deleting or corrupting one small file fetches only that file again.
- A fill run with an unreachable URL, a wrong checksum, a missing checksum or a git version that is no commit ends with an error and leaves nothing under a final name.

## Cache behaviour

- A download stage that mounts the Dockerfile depends on its whole content and reruns after any change; with a filled cache that costs one pass of integrity checks.
- `COPY --from` of the download stage is expected to be keyed by content, so the builder would stay cached when the downloads are unchanged; untested, including whether changed file timestamps alone invalidate it.
- Anything new in the cache directory invalidates what copies it; keep stray files out. Symlinks there are meaningless: the fill tool removes them all before it sets its own.

## Pitfalls

- **Nothing is written back to the host from inside a build.** A bind mount is read-only; with `rw` its writes are discarded after the `RUN`. Results leave a build only through `--output`, and one call exports one target.
- **A directory handed over as a named context must exist.** A missing one stops the build before its first step, whether or not a stage refers to it.
- **Mount single files or the needed directory, never the whole context.** A mount's content is part of the cache key; mounting `.` invalidates the layer with every log or script that changes.
- **Symlinks survive `COPY` and `COPY --from`** as symlinks, so a relative link resolves in the builder.

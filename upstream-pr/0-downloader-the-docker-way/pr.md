# Let BuildKit fetch the sources with ADD (The Docker Way)

This is an alternative to #840: it reaches the same early failure without a download stage.

Today every recipe fetches its own source when the build reaches it, so a failed download stops the build in the middle, after everything before it has been compiled.

With this PR each recipe names its source in one `ADD` line above its `RUN`, next to its `ARG`s and bump lines. Docker fetches and checks all sources at the start of the build, so a broken source stops the build in its first seconds, at the line of that source.

## How BuildKit fetches a source

This PR adds `# syntax=docker/dockerfile:1` as first line, so BuildKit fetches the current Dockerfile frontend instead of using the one built into the local Docker; `ADD --unpack` below needs syntax 1.17 ([ADD](https://docs.docker.com/reference/dockerfile/#add)).

`ADD --checksum=<hash> <url> <dest>` downloads a file and checks it; `--unpack=true` extracts it. A git URL (`git://` or ending in `.git`) with `#<commit>` is fetched as a checkout of that single commit and checked against it. No `ADD` source depends on an earlier step, so BuildKit fetches them all at once when the build starts.

## What changes in the Dockerfile

**Archives.** `wget`, `sha256sum` and `tar` become one line; libaribb24 now enters `aribb24-*`, the directory inside its archive.

```dockerfile
ADD --checksum=sha256:$VMAF_SHA256 --unpack=true $VMAF_URL /
RUN \
  cd vmaf-*/libvmaf && \
```

**Git sources.** `git clone` and `git checkout` become an `ADD` into the directory the recipe already enters.

```dockerfile
ADD --checksum=$LIBGME_COMMIT $LIBGME_URL#$LIBGME_COMMIT /game-music-emu
```

**x264 and uavs3d** count their git history for their version string ([x264](https://code.videolan.org/videolan/x264/-/blob/b35605ace3ddf7c1a5d67a2eb553f034aef41d55/version.sh#L10-12), [uavs3d](https://github.com/uavs3/uavs3d/blob/0e20d2c291853f196c68922a264bcd8471d75b68/version.sh#L19)), so they keep `.git` and fetch the history before building; the version string stays the same.

```dockerfile
ADD --keep-git-dir=true --checksum=$X264_VERSION $X264_URL#$X264_VERSION /x264
RUN \
  cd x264 && \
  git fetch --unshallow --filter=tree:0 origin +refs/heads/master:refs/remotes/origin/master && \
```

**libmodplug and opencore-amr** now use the same sourceforge link form as lame (`.../download`), which `ADD` fetches reliably.

**Other lines.** `wget`, `WGET_OPTS` and `TAR_OPTS` go; `curl`, `tar` and `git` stay for libjxl `deps.sh`, x264 and uavs3d.

## What is given up

- BuildKit does not retry a failed download, where `wget` did.
- fdk-aac is always downloaded, even without `ENABLE_FDKAAC`.

## Docker version

This PR leans on newer Docker features than #840, which needs BuildKit (Docker 23.0) and one heredoc:

- the `# syntax` line, for `ADD --unpack`; every build looks the frontend up on Docker Hub.
- `ADD` with a git source at a commit, and `--keep-git-dir` for x264 and uavs3d.

## Tested

A full build with `--no-cache` completed, including the sanity tests. The x264 and uavs3d version strings match a full clone and `versions.json` lists the commits of all git sources.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

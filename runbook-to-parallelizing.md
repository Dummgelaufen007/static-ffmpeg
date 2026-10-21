# Runbook: Parallelizing a Dockerfile

## Scope

Restructure a Dockerfile so BuildKit builds the libraries in parallel stages instead of one serial build stage, without changing what the binaries the final stage ships link against.

This describes the method, not a fixed result. Re-derive every concrete detail (library list, chains, stage count) from the source file on each run. Names and cases below are illustrations of where a rule has applied so far, not its extent.

- Source and output: as the user names them. Read the whole source; never write over it, so its `diff -u` against the result stays the review artifact.
- Keep unchanged: the base image version, every library version, and every build command/flag. Only the stage structure changes.
- Put `# syntax=docker/dockerfile:1` as line 1.

## Step 1: dependency graph

Only a few libraries depend on other self-built libraries; everything else depends only on packages of the base image and builds in parallel.

Method: list every library RUN block; for each, find what its steps read that an earlier `RUN` wrote — libraries its configure/meson/cmake step picks up from the install prefix as well as anything else (read the build scripts, not just the flags); classify each edge as hard (build fails without it) or optional (feature detected if present). Keep optional edges in their original order so the output stays identical.

Record the chains found in the report of the run, each with the line that establishes it; the runbook keeps none, since every version can add or drop one.

A conflict resolved at link time (e.g. two libraries defining the same symbol) is no build dependency.

## Step 2: one stage per library

1. **Global ARG block.** Every `ARG` that more than one stage reads, or that a stage reads before its first `FROM` would set it, moves before the first `FROM` together with its bump comments, and is re-declared in each stage that uses it. Derive the set from the file: every `$VAR` a stage reads that no instruction of that stage sets.
2. **base stage.** `FROM <base image> AS base`, the unchanged package install list, then import the flags and download settings and set them as `ENV`.
3. **One stage per library.** `FROM base AS <lib>` (or `FROM <parent>` for chains), containing the library's original download and build commands unchanged. Import the ARGs the stage uses. Stage names: lowercase, `[a-z0-9-_.]`. Builds that fetch during compile (find them by the fetching tool in the recipe) keep a `RUN --mount=type=cache` on that tool's download cache (e.g. cargo's `registry` and `git` directories) so nothing is re-downloaded — a flag only, no extra stage.
4. **Every stage passes on what later stages read.** Libraries install into the prefix the original uses so `.pc` prefixes stay valid after the merge; check non-standard installs (custom install tools, manual `cp`, symlinks).
5. **Final build stage.** `FROM base AS <its original name>`, then one `COPY --link --from=<leaf>` per leaf build stage for what that stage reads, then download and build the final program as in the original; chain members arrive through the last stage of their chain. The COPYs must precede the final build so its configure step finds the libraries. `--link` is safe here because the merges are additive and duplicate files from chains are identical.
6. **Steps that read version variables** (e.g. a generated version manifest): re-declare every `ARG` they read; a missing one silently becomes empty.
7. **Keep unchanged:** everything outside the library builds — what the final stages install, copy and test — and the name of the stage the final stages copy from.
8. **Comment the non-obvious:** which chain links are hard and which are kept only for identical output, and why each stage has its parent.

## Step 3: serial helper scripts

A recipe can hide several independent builds behind one script that runs them in sequence (e.g. a multi-bit-depth build that links the results into one library). Split it into stages that replay exactly what the script does: one source stage, one stage per independent build, one stage that combines them as the script does.

- Guard the script lines the stages replay (`grep -qxF` on the unmodified lines), so the build fails loudly when upstream changes the script; then re-derive the stages from it.
- The last stage keeps the name later stages copy from.
- Do not patch the script.

## Step 4: verification without Docker

Static checks catch structure errors; only a real build proves the dependency graph, so say so explicitly.

- Every `COPY --from` / `FROM` references an existing stage.
- Every leaf build stage is copied into the final build stage.
- Optional: **hadolint** (run on the source file first as baseline; only new rule types or count jumps need a look) and **dockerfile-parse** to count stages/RUNs and assert no RUN starts or ends with `&&`.

Report what could not be verified (the real build) in one line.

## Pitfalls

- **Hidden hard dependencies.** Check every "independent" assumption against the build scripts, not the flag names (e.g. a dependency script that does not vendor a library the build then fails to find).
- **Only what is copied crosses stages.** Anything in the final build stage that reads a source dir works only because that stage builds the program there.
- **Glob collisions.** Patterns like `cd <name>*` match both the tarball and the directory. This works in the source file; do not change these patterns.
- **Oversubscription.** N parallel stages × `-j$(nproc)` each; cap it with BuildKit's max-parallelism if needed. Do not change `-j` values.
- **Cheap syntax tests mislead.** Compiling configure-based C projects without their generated headers produces fatal errors that hide real ones. Only claim results for files that actually compiled.

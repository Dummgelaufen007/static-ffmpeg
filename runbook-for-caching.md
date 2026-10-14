# Runbook: Download cache for the static-ffmpeg Dockerfile

## Scope

Every source the Dockerfile fetches itself is kept in a local cache directory and reused by the build. Nothing is compiled differently: the cache variant builds the same `ffmpeg` as the file it is derived from.

- Input: a Dockerfile whose downloads have been cleaned (`runbook-for-cleaning.md`).
- Output: a cache variant next to it; its difference against the input is the review artifact.
- Out of scope: downloads a recipe triggers by itself during the build; they are handled by the optimizing runbook.

This describes the method, not a fixed result. Re-derive every decision from the Dockerfile and the tools in use when the runbook is applied.

## Prerequisite

The cache can only stand in for a source it can tell apart from every other, so what the cleaning runbook establishes is what the cache relies on:

- Every downloaded file has a name that is unique and carries its version, so a cached file can never stand in for another version.
- Every download has an integrity check in its recipe.
- Every source that is not a fixed file takes its location from a variable and is pinned to a revision.

A Dockerfile that misses one of these is cleaned first.

## Step 1: fill the cache

The tool that fills the cache has to:

- Derive what to fetch from the Dockerfile itself, resolving its variables the way the build does — never from a second list that can drift.
- Keep an existing source, complete or left over from an interrupted run, only as far as it passes the integrity check its pinned state provides; restore the rest from what passed and fetch only what did not.
- Make every source available where and under the name the recipe expects, and never under its final name before it is complete.
- Remove what the Dockerfile no longer references, whatever put it there.
- Fail loudly on missing input; find out which failures the tool's own language lets pass silently.

## Step 2: bring the cache into the build

- The fill tool runs inside the build, ahead of everything that needs a source. It delivers every source fetched and verified, so a source that cannot be fetched or verified stops the build before anything is compiled.
- The cache is an addition, not a requirement: without one the tool fetches everything, with one only what is missing, and the build never changes it.
- That tool reads the Dockerfile actually being built. Everything that defines a source stays in the Dockerfile: the tool derives its work from it.
- Whatever the tool calls is available to it in that stage.
- The cache reaches each recipe where and under the name the recipe already uses, so the recipe's extraction stays untouched.
- With that a recipe carries no step of its own that obtains or verifies a source; it starts where the source is first used.

## Step 3: the build script

- Hand the cache directory to the build when there is one.
- Pass the name of the Dockerfile being built.
- All variants share one directory and need no copy of it, because a build cannot alter it.
- Filling the cache is no part of a build. What a build fetches is gone with its layers, so new sources reach the directory in a step of their own, run when sources have changed. Since the tool removes what its Dockerfile does not reference, filling for one Dockerfile must not remove what another one needs. A second pass that fetches nothing confirms the result.
- That step needs the tools the fill tool uses, on the host it runs on; check them per host.

## Step 4: verification without a build

- A dry run of the fill tool that fetches nothing: it finds as many downloads as the Dockerfile has, every name is fully resolved, and every name exists in the cache.
- Below the download stage no recipe obtains or verifies a source any more.
- The download stage built without a cache directory fetches every source; built with a complete one it fetches none.
- A real run after damaging any part of a cached source, and after interrupting each of the tool's steps, ends with every source verified in its pinned state and fetches nothing that was still intact.
- A fill run with any input it cannot fetch, verify or resolve to a pinned state ends with an error and leaves nothing under a final name.

## Cache behaviour

- Whatever the download stage depends on decides when it reruns; with a filled cache a rerun fetches nothing.
- Whether the stages that copy the downloads stay cached when the downloads are unchanged is measured, not assumed, including what counts as a change.
- Anything new in the cache directory invalidates what copies it; keep stray files out.

## Pitfalls

- **A directory handed over as a named context must exist.** A missing one stops the build before its first step, whether or not a stage refers to it.
- **Symlinks survive `COPY` and `COPY --from`** as symlinks, so a relative link resolves in the builder.

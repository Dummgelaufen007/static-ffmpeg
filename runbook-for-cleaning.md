# Runbook: Cleaning the static-ffmpeg Dockerfile

## Scope

Tidy up the original: whatever the recipes do in the same way is written in the same way. For the downloads that means how they are named, where their URLs live and how they are bumped; for everything else, that an outlier follows its peers. The sources themselves stay exactly as they are — same hosts, protocols, archives, commits and versions — and so does the built `ffmpeg`.

- Output: a cleaned variant next to the input (today `Dockerfile.clean`); the `diff -u` against the input is the review artifact.
- Change only what a renaming, a move or an alignment requires (for a download: its `ARG`s, checksum, extraction, `cd`, taking over the moved source) and bump lines.
- Out of scope: any change of source — another host, protocol, archive type, git replaced by an archive, another version; downloads a recipe triggers by itself during the build; caching.

This describes the method, not a fixed result. Names, hosts and conventions below illustrate the state at the time of writing; re-derive every decision from the Dockerfile when the runbook is applied.

## Step 1: list the sources

Derive the list from the Dockerfile: everything it fetches, including URLs written literally into a `RUN`. Carry the list to the end; Step 6 checks it.

List the same way every kind of line that recurs across the recipes, with the form each recipe gives it.

## Step 2: URLs into variables, downloads into their own steps

Every URL lives in a variable; a URL written literally into a `RUN` moves into one, unchanged, and gets a bump line like its peers. The file name a download is saved under lives in a variable next to it (`<PREFIX>_FILE`), and the recipe uses only that variable in its download, checksum and extraction line.

A download inside the recipe of another library (e.g. libudfread, cloned into libbluray's `contrib/`) moves into a step of its own ahead of that recipe, with its `ARG`s and bump lines like its peers. The recipe takes the source from there into the place it used before.

Every source of the same kind is fetched the same way, following the form its peers use (e.g. aom cloned by tag and checked against the commit in separate steps, while every other git source clones and checks out the commit inside its build step). The aligned download fetches the same commit or file as before.

## Step 3: name and verify

The criteria for a download's file name:

- It is unique and carries the version, so no file can be mistaken for another version.
- It has the real extension of what is downloaded.
- None of the recipes' own globs can match it. The recipes change into their sources with patterns such as `cd <name>-*`, so the separator between name and version must not be one those patterns or the upstream directories use. Check every glob against every name.

Today's convention meets them as `ARG <PREFIX>_FILE="<prefix>.$<PREFIX>_VERSION<ext>"`. Globs that break the recipes' own pattern are aligned to it, unless the upstream directory itself differs.

## Step 4: align the recipes

Every line of the same kind is written the same way, following the form its peers use; this holds for any part of a recipe, its build call and the arguments of that call included (e.g. a job count left open where every other build call bounds it). An outlier is aligned unless the recipe itself gives a reason for it.

## Step 5: bump

- Every version or commit variable has its own bump line, following an existing entry of the same kind.
- `hashupdate` builds the URL by replacing `$<P>_VERSION` in `<P>_URL`; a URL built from another variable is not updated.
- Remove bump and `after` lines of variables that no longer exist.
- Bump lines take effect only in the file listed in `Bumpfile`, and the `after` lines call `hashupdate` on a fixed file; in a cleaned variant they stay inactive until it replaces the original.

## Step 6: verification without a build

- No URL, commit, version or checksum differs from the original.
- For every kind of recurring line from Step 1: all recipes use one form, or the outlier is left with a reason.
- Each download, checksum and extraction line uses its recipe's `<PREFIX>_FILE`, and no file name is written literally into a `RUN`.
- The glob check from Step 3 over the whole file.
- Each moved download reaches its recipe at the same place as before; each aligned download fetches the same commit or file as before.
- The Step 1 list: every source is accounted for — renamed, moved into a variable, moved into its own step, aligned to its peers, or left with a reason.

## Step 7: verification with a build

One build of the cleaned variant that completes, including the sanity tests of the final stage.

## Pitfalls

- **A wrong extension is harmless for `tar`** (it detects the format) but misleading; the naming step fixes it.

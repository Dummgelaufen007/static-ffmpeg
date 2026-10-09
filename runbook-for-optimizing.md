# Runbook: Optimizing build flags in the static-ffmpeg Dockerfile

## Scope

Compile nothing that ffmpeg does not need. *Need* means ffmpeg links it **and** can actually call it: code that ends up in a library but that ffmpeg can never reach goes, and so does anything with its own target that nothing links at all.

Change **build parameters**: configure/meson/cmake flags, make targets and their arguments — *flag* below means any of these. The result must be a functionally identical `ffmpeg`, so a flag that changes how a library behaves for calls ffmpeg does make, or that removes a capability a peer could negotiate, stays even when it would shorten the build.

This describes the method, not a fixed result. Options and their defaults change with every library version, so re-derive every flag from the option surface of the *pinned* version on each run. The names and cases mentioned below are illustrations, not evidence: they age with the versions, and quoting this runbook instead of the file repeats the error it guards against.

- Source: `https://raw.githubusercontent.com/wader/static-ffmpeg/refs/heads/master/Dockerfile`. Fetch it fresh and read the whole file.
- Write the result to `Dockerfile.opt`, never over `Dockerfile`, so `diff -u Dockerfile Dockerfile.opt` stays the review artifact.
- Keep unchanged: the Alpine version, every library version and hash unless a switch under "Downloads" changes it with the owner's decision, the hardening settings (`CFLAGS`/`CXXFLAGS`/`LDFLAGS`, ffmpeg's `--toolchain=hardened`), `checkelf`, the sanity tests and the final stages.
- Besides build parameters, this step reduces and steadies what the build fetches, as long as the built `ffmpeg` keeps its function: see "Downloads" below.
- Out of scope, because they are neither build parameters nor downloads: restructuring the build or its stages, patching upstream build files.

## Step 1: list the recipes

Derive the list of recipes from the Dockerfile itself — every `RUN` that configures a build — before reading any option file, and carry it to the end. The list, not the diff, is what Step 6 checks.

## Step 2: read the option surface of the pinned version

Per build system, fetch the option definitions at the exact tag — never from `master`, never from memory. Being sure about a default is the reason to open the file, not a substitute for it: certainty is produced by the same process as error, and it carries no version.

Each recipe yields the evidence it has: the option, its default, and the place that consumes it, quoted from the file read in this run and named with the path it came from. Where a default is not declared but derived — a loop that enables every target with a matching `.mk`, a function that picks the library kind by platform — the derivation is what gets quoted, and the report says that it is one. What cannot be quoted is not asserted.

The same files carry what Step 3 needs: which target an option's code belongs to.

| Build system | What to read |
| --- | --- |
| meson | `meson_options.txt` **or** `meson.options` (both spellings are in use; GNOME projects moved to `meson.options`) |
| cmake | `CMakeLists.txt` plus included modules: `option()`, `set(<VAR> <default> CACHE BOOL …)`, `cmake_dependent_option()` |
| autotools with `autogen.sh` | `configure.ac` (`AC_ARG_ENABLE` / `AC_ARG_WITH`), and `Makefile.am` for `SUBDIRS` / `bin_PROGRAMS` |
| autotools with shipped `configure` | the `configure` inside the exact tarball the Dockerfile downloads, when no git mirror carries that tag; `Makefile.am` for the targets |
| hand-written `configure` | read `show_help` **and** the default variable assignments |
| plain make | the `Makefile`: `all`, `install`, `PROGS` |

Set the flag when the default does work this build does not need; quote the line that establishes it — the option's default, or the target list that makes the build produce more than the library. The size of the saving is not a criterion.

## Step 3: decide what ffmpeg needs

Name a candidate only after quoting the line that establishes it: a candidate that exists before its quote came from memory.

Three questions, in this order:

1. **Does anything link it?** A target nothing links — CLI tools, apps, examples, tests, docs, man pages, bindings, companion libraries nobody pulls in — goes, and that target is the whole evidence. Check it, do not infer it from the kind of artifact: a companion library can be required, and only the link line of whatever consumes it says which. Debug information belongs here too: it rides in the `.a` but is no code, and the final binary is stripped.
2. **Can ffmpeg reach it?** For code that ends up in the installed `.a`, trace it in Step 4. Unreachable means ffmpeg's wrapper never calls into it **and** exposes no option that would, not merely "we do not use it". Code that is reachable, negotiable or behaviour-changing stays.
3. **Does it produce anything at all?** A default that yields no artifact — automake dependency tracking, generated man pages, a second link pass for a shared library nobody installs — answers the first two questions with "nothing" and is a candidate all the same, as long as the `ffmpeg` it produces is unchanged and the option's own help text establishes what the default costs.

An optional dependency the library picks up from the image is no separate case: it follows the same questions by what it feeds, and it goes when it feeds nothing but an unlinked target. If it also propagates into the `.pc`, turning it off drops a link edge from ffmpeg as well.

Quote the line that decides which of the questions applies — the target declaration that puts the option's code into a separate artifact, or the source list that puts it into the installed `.a`. Either way the candidate goes on to Step 4.

Rejecting a candidate takes a sentence from this runbook. If there is none, the candidate is taken, not dropped; a rejection made anyway is your own call, and the report says so.

## Step 4: trace before flipping

Step 3 sends the `.a` case here with one open question — can ffmpeg reach the code? — and every candidate with a second: does turning it off change anything at all? A flag is determinism rather than a saving when its tool or dependency is not there at that point of the build, when the option it hangs off is itself off, or when the variable does not exist in this version.

- **Who consumes the library inside the image?** ffmpeg (find its `require`/`check_lib` line in ffmpeg's `configure` and the symbols its wrapper in `libavcodec`/`libavformat` uses) plus every self-built library that links it (grep their `meson.build`/`CMakeLists.txt`/`configure.ac`).
- **Would the option's tool even be present?** Check the image's package list.
- **Build order matters.** A library built *later* in the file cannot be a dependency of an earlier one, so a "disable the binaries" flag can be a no-op for that reason alone.
- **Rust consumers decide C features.** A crate's `Cargo.toml` features can require C surfaces that the meson dependency list does not mention.

Those four are traps, not the standard. What settles unreachability is the wrapper's full symbol list, the options ffmpeg exposes on top of it, and the upstream sentence saying what the flag withdraws.

## Step 5: apply mechanically

- One script, exact-string replacement, **assert exactly one match per site**, abort on any miss. Never a loose regex over the whole file.
- When inserting by line number (e.g. the same flag after many `./configure \` lines), build the output in a single pass over the original file so numbers do not shift, and derive the indentation from the following line rather than assuming it.
- One flag per line, next to the related flags of that block, and **before the line that carries the `&&`** — a flag behind it becomes its own shell command and the recipe fails when that RUN executes.
- Delete TODO comments the change resolves.

## Step 6: verification without a build

A run that finds nothing is a complete run. The report states what was read, not what was found; a recipe without a candidate, and a run without one at all, is a result like any other.

- For every recipe in the Step 1 list: the file that was read, its tag, and what it yielded — including "no candidate". A recipe without a cited file is not done.
- For every recipe: the flags already in it, checked against that same option surface. A flag whose variable does not exist in this version protects nothing.
- For every flag: the quoted default or target list comes from the pinned version, not from `master` or from memory.
- For every flag that drops code from an installed `.a`: the symbol list and the exposed options from Step 4 are what carry the claim that ffmpeg cannot reach it.
- No flag in the diff is a no-op: its tool and dependency are installed before that recipe runs, the option it hangs off is on, and the variable exists in this version.
- The `diff -u` against the original, read hunk by hunk.

## Downloads

Goal: as few downloads and clones as possible, each from a static source with a checksum.

Some recipes fetch more than the Dockerfile's own `wget`/`git clone`: meson wraps (`Downloading … source from`, `Cloning into`), cargo crates, helper scripts. The recipe does not show them; find them in the sources of the pinned versions (wrap files, fetch calls in build files and scripts) and confirm them by running the configure step of the pinned version in the state the recipe runs in: the Dockerfile's base image with its package list and everything built before that recipe.

- **Git sources** move to the release archive of the pinned version where one exists; compare the trees. If the content differs, the switch is a version change: list the differences and let the owner decide.
- **Meson wrap fallbacks** go away by providing the dependency from Alpine. Add the package to the `apk add` list when it ships the static library (`.a`; check the file, not the package name) and pulls in nothing heavy; if its `-dev` drags in a large tree, fetch the packages with `apk fetch` and extract only `.a`, `.pc` and headers in a step of its own. Verify with `meson setup` and the recipe's own options in that same state: the dependency is found from the system (`Run-time dependency <name> found: YES <version>`), its version satisfies the requirement, and nothing is downloaded. The version then comes from Alpine instead of the wrap; the report names both. A comment names the downloads the packages replace.
- **Helper scripts** that fetch more than the build uses (e.g. `deps.sh`) are replaced by the sources the build actually needs, each as a download step of its own, synced to the pinned version of the library that requires it (an `after` line on that library's bump).
- **Cargo crates** have no fallback and stay as they are.
- Every new download follows the form of the other downloads in the Dockerfile: its variables, a step of its own and bump lines.

## Pitfalls

- **`--help` is not a default.** Find the assignment in `configure`/`CMakeLists.txt`.
- **Off-by-default lists.** Some projects keep a second list that overrides the generic default.
- **A flag belongs where the recipe hands it on.** Some recipes do not call the configuration tool directly: they pass flags to a script through a variable, at times patched in by a `sed` in the same `RUN`. Read the recipe to its end — a flag placed at the nearest-looking call site is dropped without a word.
- **Dropping unreachable code shortens the build, not the binary.** Without `-ffunction-sections`/`--gc-sections` the linker pulls only referenced object files from each `.a`, so unreferenced code never reached the binary anyway.
- **Do not turn a flag pass into a feature change.** Options that add codecs or quality features are out of scope even when they look like free wins.

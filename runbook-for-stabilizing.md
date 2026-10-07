# Runbook: Stabilizing the downloads of the static-ffmpeg Dockerfile

## Scope

Make the build's downloads reliable and safe: fetching that survives transient errors, sources that answer consistently, transports that are encrypted. What is built stays exactly the same — same content of every source, same `ffmpeg`.

- Input: a Dockerfile. Output: a stabilized variant next to it; the `diff -u` against the input is the review artifact.
- Done elsewhere: tidying names and variables; replacing git sources by release archives, any version change and downloads a recipe triggers by itself during the build; caching.

This describes the method, not a fixed result. Hosts, options and cases below illustrate the state at the time of writing; servers and their behaviour change, so re-check every decision against them when the runbook is applied.

## Step 1: tolerate transient errors

Retries and timeouts belong to the downloader's options (today `WGET_OPTS`), not to single recipes. Take the transient failures from build logs — timeouts, refused connections, rate limits, server errors — and add what they need: retry on host errors, refused connections and the server errors actually seen, a timeout and a wait between attempts. Nothing that changes what is fetched.

## Step 2: find the weak downloads

Derive the list from the Dockerfile and from what actually happened when fetching with the options from Step 1, not from expectation:

- **Generated on demand.** Archives a forge builds per request (e.g. GitLab `/-/archive/`, GitHub `/archive/`). They can sit behind bot protection that intermittently answers with an HTML page instead of the archive; the recipe's checksum then fails.
- **Unencrypted transport.** `http://`, `git://`.
- **Failures that outlast the retries.** The original breaks as well; record them for the owner. They are no case for a source switch here.

## Step 3: choose a steadier source

For a download generated on demand, prefer a static release archive on a download server for the same version, where the project publishes one.

- Extract both and compare the trees. Identical content: switch here. A difference makes it a version change: record the differences found and leave the decision to the owner; do not drop it.
- The checksum comes from the file fetched once and must match a checksum upstream publishes next to the archive, where there is one.
- A release archive can bundle a dependency the recipe fetches separately (e.g. in `contrib/` or `subprojects/`). Keep the separate download if the Dockerfile pins it, and make room for it — the bundled copy is not necessarily the pinned one; compare before deciding.
- Where no release archive exists, the source stays as it is.

## Step 4: encrypt the transport

Move `http://` and `git://` to `https://` only after an actual download or clone over `https://` succeeded with the recipe's own options. A server can answer a ref listing (`git ls-remote`) and still fail the fetch; that is no evidence.

## Step 5: verification without a build

- Every switched download: identical content to the original source, checksum matches, top-level directory matches the recipe's `cd`.
- Recipes that combine an archive with a separately fetched dependency: replay the extraction with the real files.
- Every changed transport: one successful fetch over the new URL with the recipe's own command.
- No version, commit or checksum of an unswitched source differs from the input.

## Step 6: verification with a build

One build of the stabilized variant that completes, including the sanity tests of the final stage.

## Pitfalls

- **One HTML page is not a checksum error to retry.** Bot protection answers `200` with a page; retries fetch the same page. Switch the source instead.
- **A smaller archive is a side effect, not the reason.** A switch is justified by reliability; if the only gain is size, it belongs elsewhere.

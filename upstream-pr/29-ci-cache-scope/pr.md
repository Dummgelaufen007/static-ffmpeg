# ci: Use a GHA cache scope per arch

The CI matrix builds amd64 and arm64 in two jobs, and both use the same GitHub Actions cache entry. `cache-from: type=gha` and `cache-to: type=gha,mode=max` ([ci.yml#L27-L28](https://github.com/wader/static-ffmpeg/blob/3adba37/.github/workflows/ci.yml#L27-L28)) set no `scope`, so both jobs fall back to the [default scope `buildkit`](https://docs.docker.com/build/cache/backends/gha/#scope). Whichever job finishes last overwrites the cache of the other arch, and the next run of a job may import a manifest whose layers belong to the other arch and cannot be used.

With `scope=${{ matrix.arch }}` each arch reads and writes its own entry.

## Changes

| File | Change |
|---|---|
| `.github/workflows/ci.yml` | `cache-from` and `cache-to` get `scope=${{ matrix.arch }}` |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

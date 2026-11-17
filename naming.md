# Naming

| Variant        | Based on          | Adds                                                                    |
|----------------|-------------------|-------------------------------------------------------------------------|
| `Dockerfile.upstream` | `upstream/master` | nothing, an unchanged copy                                              |
| `Dockerfile.upstream.1` | `Dockerfile.upstream` | `upstream-pr/0-downloader-the-docker-way` and `upstream-pr/1-parallel-stages` |
| `Dockerfile.upstream.2` | `Dockerfile.upstream.1` | load limit `-l$(nproc)` of `upstream-pr/1-parallel-stages/Dockerfile.1` |
| `Dockerfile`   | `upstream/master` | `runbook-for-cleaning.md` and new features: libzvbi, libopenmpt         |
| `Dockerfile.1` | `Dockerfile`      | sources fetched with `ADD`                                              |
| `Dockerfile.2` | `Dockerfile.1`    | `runbook-to-parallelizing.md`                                           |
| `Dockerfile.3` | `Dockerfile`      | `runbook-for-caching.md`                                                |
| `Dockerfile.4` | `Dockerfile.3`    | `runbook-to-parallelizing.md`                                           |

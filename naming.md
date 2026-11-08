# Naming

| Variant        | Based on          | Adds                                                                    |
|----------------|-------------------|-------------------------------------------------------------------------|
| `Dockerfile.upstream` | `upstream/master` | nothing, an unchanged copy                                              |
| `Dockerfile`   | `upstream/master` | `runbook-for-cleaning.md` and new features: libzvbi, libopenmpt         |
| `Dockerfile.1` | `Dockerfile`      | sources fetched with `ADD`                                              |
| `Dockerfile.2` | `Dockerfile.1`    | `runbook-to-parallelizing.md`                                           |
| `Dockerfile.3` | `Dockerfile`      | `runbook-for-caching.md`                                                |
| `Dockerfile.4` | `Dockerfile.3`    | `runbook-to-parallelizing.md`                                           |
| `Dockerfile.5` | `Dockerfile.4`    | `-l$(nproc)` on every make, ninja and `cmake --build`; chains split per dependency |

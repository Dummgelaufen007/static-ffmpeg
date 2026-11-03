# Naming

| Variant        | Based on          | Adds                                                                    |
|----------------|-------------------|-------------------------------------------------------------------------|
| `Dockerfile.upstream` | `upstream/master` | nothing, an unchanged copy                                              |
| `Dockerfile`   | `upstream/master` | `runbook-for-cleaning.md` and new features                              |
| `Dockerfile.1` | `Dockerfile`      | sources fetched with `ADD`                                              |
| `Dockerfile.2` | `Dockerfile.1`    | `runbook-to-parallelizing.md`                                           |
| `Dockerfile.3` | `Dockerfile`      | downloader                                                              |

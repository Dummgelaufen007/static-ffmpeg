# Naming

| Variant              | Based on             | Adds                                          |
|----------------------|----------------------|-----------------------------------------------|
| `Dockerfile`         | -                    | upstream                                      |
| `Dockerfile.0.clean` | `Dockerfile`         | `runbook-for-cleaning.md`                     |
| `Dockerfile.0.opt`   | `Dockerfile.0.clean` | `runbook-for-optimizing.md` and new features  |
| `Dockerfile.3.clean` | `Dockerfile.0.clean` | downloader                                    |
| `Dockerfile.3.opt`   | `Dockerfile.0.opt`   | downloader                                    |
| `Dockerfile.4.opt`   | `Dockerfile.3.opt`   | test balloon for LTO                          |
| `Dockerfile.5.opt`   | `Dockerfile.3.opt`   | new libs for ffmpeg                           |

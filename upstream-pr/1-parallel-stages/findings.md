# Findings for PR 1 (#868)

Background for follow-up questions on #868. The reply itself is
`comment-utilization.md`.

## Build times without limit

`docker build .` of `Dockerfile.pr1` against `Dockerfile.upstream`, same host,
same day (2026-11-12), logs under `buildlogs/<host>/`.

| Host | Threads | RAM | serial | #868 | saved | at once |
|---|---|---|---|---|---|---|
| randyandy | 8 | 7.8 GiB, 36 GiB swap | 1567 s | 1220 s | 22.1 % | 45 |
| kadaver | 8 | 15.5 GiB, 13.7 GiB swap | 2750 s | 2323 s | 15.5 % | 45 |
| nasa | 8 | ~10 GiB free, 29.3 GiB swap | 4732 s | 3965 s | 16.2 % | 45 |
| m73x | 2 | 11.6 GiB | 6343 s | 6163 s | 2.8 % | 45 |

- randyandy with BuildKit limit 4: #868 1067 s, 12.5 % faster than without limit.
- x265 takes 3 to 4 times as long in #868 as in the serial build (crowding).
- The more cores, the more idle time to fill; with 2 cores there is little, but
  the build never got slower than serial.

## wader's CI (ubicloud), build step only

Without job setup and without the GHA cache export:

| Runner | serial | #868 | saved |
|---|---|---|---|
| amd64 `vm…`, 30 CPUs | 856 s | 440–448 s | 48 % |
| arm64 `vm…`, 30 CPUs | 1688 s | 573 s | 66 % |
| arm64 `ip-10-…`, 32 CPUs | 682 s | 220 s | 68 % |

- `ubicloud-standard-30-arm` hands out two machine types; `vm…` arm64 takes
  about twice as long. Compare only within one type ("Machine name" in the log).
- The GHA cache never hits: CI runs only on `pull_request`, so `master` never
  writes a cache a PR may read, and both arches shared the default scope
  `buildkit` until #870 (merged 2026-11-12). The export still costs 195–332 s
  per job, more for #868 since `mode=max` exports every stage.
- `multiarch.yml` (release) builds with a plain `docker build` on the same
  runners, without cache.

## GitHub default runners (fork CI)

`ubuntu-24.04` and `-arm`, 4 vCPUs, 15.6 GiB: #868 builds without limit on both.
amd64 runners come in at least three speeds (ffmpeg step 398, 503 and 719 s), so
serial and parallel runs are comparable only when that step matches. arm64:
#868 8–12 % faster. On amd64, x265 (715 vs 145 s) and dav1d (112 vs 11 s) do far
more work than on arm64.

## Memory

colima, 4 CPUs, 1 GiB swap behind zswap, no limit, without fdk-aac and libdvdcss:

| RAM | result | peak RAM | peak swap | `oom_kill` |
|---|---|---|---|---|
| 4 GiB | killed after 153 s | 3682 MiB | 1023 MiB (full) | 14 |
| 8 GiB | 1228 s | 7469 MiB | 337 MiB | 0 |

- The OOM killer hit `cc1plus` and the VM's network services; the build
  ended with "error reading from server: EOF".
- About 2 GiB per thread is the minimum; below that only a large swap carries
  the build (randyandy, nasa).
- `Dockerfile.2` (with fdk-aac, libdvdcss and `-l$(nproc)`) in the same 8 GiB
  VM: 1141 s, peak 4354 MiB, peak at 691 s while libjxl, aom, vorbis, svtav1,
  vvenc and harfbuzz compiled. `-l` is the likely reason for the lower peak;
  not isolated.
- `Dockerfile.1` (the PR plus `-l$(nproc)` on every parallel `make` and
  `ninja`; `cmake --build` passes it after `--`) against the PR, both with
  fdk-aac and libdvdcss, no step limit, RAM as `MemTotal − MemAvailable` per
  second:

  | Host | build | result | peak RAM | peak swap | `oom_kill` |
  |---|---|---|---|---|---|
  | randyandy, 8 threads, 7.8 GiB | PR | 1334 s | 7663 MiB at 671 s | 2973 MiB at 235 s | 0 |
  | randyandy | `Dockerfile.1` | 1331 s | 5090 MiB at 673 s | 54 MiB at 673 s | 0 |
  | colima, 4 CPUs, 4 GiB, 1 GiB swap | PR | failed after ~120 s | | | |
  | colima | `Dockerfile.1` | ~1750 s | | | |

  On randyandy `-l` cuts the RAM peak by 33.6 % at the same build time. In
  colima the PR failed in highway with "cannot allocate memory", and BuildKit
  cancelled 41 more stages with exit 137. One run each; logs under
  `buildlogs/bellair/buildtime-arm64-261114_025134/` and on randyandy
  `~/ffmpeg/wader/memtest-261113_093550/`.
- `-l` throttles by load average, not by memory: it holds back crowds of
  compilers, not one large compile, and it reacts with a delay.
- `multilib.sh` builds the x265 bit depths one after another, so x265 never
  compiles more than one at a time; splitting them (as in `Dockerfile.2`)
  halves the x265 chain but triples its memory peak.

## Where the serial build waits

Share of recipe time in the serial CI builds:

| | amd64 `vm…` | arm64 `vm…` | arm64 `ip-10-…` |
|---|---|---|---|
| downloading, unpacking, `configure` | 17 % | 18 % | 24 % |
| compiling | 70 % | 69 % | 60 % |
| linking and installing | 13 % | 14 % | 16 % |

Within compiling, 49–57 % of the time no new compiler starts: `make` waits for
the last file (x265: 87, 87 and 56 s per bit depth on randyandy).

## BuildKit

- A plain `docker build` uses the builder inside dockerd, which has no limit on
  parallel steps and no setting for one: moby creates its worker without a
  parallelism semaphore (`daemon/internal/builder-next/controller.go`).
- `--oci-max-parallelism` (`max-parallelism` in `buildkitd.toml`) needs a
  builder of its own (`docker buildx create`); unset means unlimited.
- `make -l$(nproc)` and `ninja -l$(nproc)` throttle new jobs by system load,
  inside the Dockerfile; `cargo` has no `-l`. `ninja` uses all cores by
  default, `make` one.
- `ADD --checksum` needs Dockerfile 1.6, `--unpack` 1.17; with
  `# syntax=docker/dockerfile:1` the frontend comes from the registry. It
  emits an HTTP source with `source.http.checksum` and a copy with
  `AttemptUnpack`; both exist since BuildKit v0.5.0, so old engines (nasa:
  Docker 27.1, BuildKit v0.15.1) can run it.
- `ADD` retries transient failures and 429/503 since BuildKit v0.35.0
  (commits `002a5ce71`, `d9b10fd5d`). On 2026-11-13 `buildx-stable-1` still
  points at v0.34.2, so neither buildx nor dockerd builders have it yet.

## wader's positions

- #216 (2022): "a very standard Dockerfile without many moving parts of big
  helper scripts", feature dependencies like libogg for libvorbis, "all things
  for a feature kept together", heredoc "maybe a too new feature".
- #252 (2022): parallel stages "nice but … not sure … about the increased
  complexity"; ARGs kept next to their recipe on purpose.
- #374: proposed heredoc himself, closed via #826 without it; `checkelf` moved
  into the Dockerfile.
- #841: prefers it to #840; asked how `ADD` behaves and since when it is stable.
- #217: wants native runners for more arches; values a Dockerfile that is
  "straight forward and quite easy to follow".
- Of 93 non-merge Dockerfile commits in the last six months, 56 are bot bumps,
  28 mine, 7 his: his work is merging bumps and fixing the ones that break.

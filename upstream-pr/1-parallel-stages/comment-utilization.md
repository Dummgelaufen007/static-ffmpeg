## Complexity

The complexity is not new: a build like this only works if you know the dependencies, serial or not. The serial Dockerfile keeps them implicit, in the order of the recipes and in one long package list, so each one has to be rediscovered by trial, as for #856 when dav1d had to move above librsvg. With stages, `FROM` and `COPY --from` name each dependency, libraries and tools alike: librsvg says it needs dav1d, and only librsvg and rav1e start `FROM rust`. The Dockerfile documents it, and nothing waits for what it does not need. The build log names each step after its library too: `[x265 1/1]` instead of `[builder 55/69]` followed by a long command where the library's name shows up somewhere.

It might also be a small step towards what #216 was after: each library keeps its parts together in one stage, and its dependencies are written down, like pango with `FROM harfbuzz AS pango` and `COPY --from=cairo`.

## Machines with different resources

A plain `docker build .` starts every library as soon as it can, with nothing to hold it back. At the start almost all of them run at once; towards the end only a few.

Each library takes a little longer that way, but the whole build is done much sooner, since one library's single-core steps no longer leave the other cores idle. What grows is memory, since every library being built needs its own. On four of my machines, a plain `docker build .` of this PR, without any limit, ran up to 45 libraries at once:

| | Ryzen 7 5700X (WSL2), 8 threads, 7.8 GiB | i7-7700HQ, 8 threads, 15.5 GiB | Ryzen V1500B (NAS), 8 threads, ~10 GiB free | Pentium G3220T, 2 cores, 11.6 GiB |
|---|---|---|---|---|
| master, serial | 26:07 | 45:50 | 1:18:52 | 1:45:43 |
| this PR | 20:20 (22 % sooner) | 38:43 (16 % sooner) | 1:06:05 (16 % sooner) | 1:42:43 (3 % sooner) |

The more cores, the more idle time there is to fill; with two cores there is little, but the build does not get slower either. On your CI runners with 30 or more cores it takes half the time on amd64 and a third on arm64.

## OOM and cache thrashing

On GitHub's default runners, 4 threads and 16 GB, it builds without any limit on both amd64 and arm64 ([run](https://github.com/Dummgelaufen007/static-ffmpeg/actions/runs/43262020713)). It needs about 2 GiB of RAM per thread; in a test VM with 1 GiB per thread it ran short, with 2 GiB it went through. The crowding costs each library time, x265 took three to four times as long as in the serial build, yet the build as a whole was still done first.

Should the crowding ever be a concern, `make` and `ninja` already have a switch for it: with `-l$(nproc)` they start no new job while the machine is busy, right in the Dockerfile.

## Where the current build waits

About a third of the serial build is spent in steps that use one core: downloading, unpacking, `configure`, linking and installing. During those steps the other cores wait.

| | amd64 `vm…` | arm64 `vm…` | arm64 `ip-10-…` |
|---|---|---|---|
| downloading, unpacking, `configure` | 17 % | 18 % | 24 % |
| compiling | 70 % | 69 % | 60 % |
| linking and installing | 13 % | 14 % | 16 % |

On the faster `ip-10-…` runner the share is higher, since compiling gets quicker there and these steps do not.

## Runs used

| Run | Runner amd64 | Runner arm64 |
|---|---|---|
| [this PR, e925eee](https://github.com/wader/static-ffmpeg/actions/runs/42547567457) | [`vm…`](https://github.com/wader/static-ffmpeg/actions/runs/42547567457/job/128935780438) | [`vm…`](https://github.com/wader/static-ffmpeg/actions/runs/42547567457/job/128935780683) |
| [this PR, 890d60a](https://github.com/wader/static-ffmpeg/actions/runs/43182111613) | [`vm…`](https://github.com/wader/static-ffmpeg/actions/runs/43182111613/job/131060352381) | [`ip-10-…`](https://github.com/wader/static-ffmpeg/actions/runs/43182111613/job/131060352133) |
| [bump-libgme](https://github.com/wader/static-ffmpeg/actions/runs/42498429346), serial | [`vm…`](https://github.com/wader/static-ffmpeg/actions/runs/42498429346/job/128785721762) | [`vm…`](https://github.com/wader/static-ffmpeg/actions/runs/42498429346/job/128785721920) |
| [bump-libjxl-0.13.0](https://github.com/wader/static-ffmpeg/actions/runs/43055883273), serial | – | [`ip-10-…`](https://github.com/wader/static-ffmpeg/actions/runs/43055883273/job/130645299834) |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

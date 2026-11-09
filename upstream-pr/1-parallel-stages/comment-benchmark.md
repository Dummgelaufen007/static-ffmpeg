Most of the spread comes from the runners, not from the builds. `ubicloud-standard-30-arm` hands out two kinds of machine, and the top of each job log names them as "Machine name" and "CPUs":

- `vm…` with 30 CPUs and 94 GiB: a serial build takes 32–37 min
- `ip-10-…` with 32 CPUs and 123.5 GiB: a serial build takes 15–17 min

The arm64 "best times" all come from `ip-10-…`, while this PR ran on `vm…`, so they compare two different machines. On amd64, all recent jobs but one ran on `vm…`.

Compared on the same machine type, `vm…` with 30 CPUs:

| | serial, recent PRs | this PR | saved |
|---|---|---|---|
| amd64 | 992–1168 s, mean 1085 s (9 runs) | 732 s | 33 % |
| arm64 | 1928–2228 s, mean 2063 s (4 runs) | 937 s | 55 % |

On arm64 this PR takes as long on a `vm…` runner (15:37) as a serial build on an `ip-10-…` runner (15:09–16:54), so it no longer matters much which of the two the job gets.

There is only one run of this PR so far; a re-run that lands on an `ip-10-…` arm runner would show the gain on that machine too.

Runs used (job time from start to completion):

| Run | amd64 | arm64 |
|---|---|---|
| [this PR](https://github.com/wader/static-ffmpeg/actions/runs/42547567457) | 12:12 `vm` | 15:37 `vm` |
| [bump-libgme](https://github.com/wader/static-ffmpeg/actions/runs/42498429346) | 18:07 `vm` | 32:08 `vm` |
| [libgsm-release](https://github.com/wader/static-ffmpeg/actions/runs/42262817432) | 18:14 `vm` | 35:58 `vm` |
| [bump-alpine](https://github.com/wader/static-ffmpeg/actions/runs/42249985765) | 19:28 `vm` | 15:24 `ip-10` |
| [bump-harfbuzz](https://github.com/wader/static-ffmpeg/actions/runs/42062088247) | 18:48 `vm` | 37:08 `vm` |
| [bump-svtav1](https://github.com/wader/static-ffmpeg/actions/runs/41671597780) | 18:26 `ip-10` | 16:25 `ip-10` |
| [add-sources](https://github.com/wader/static-ffmpeg/actions/runs/41612416416) | 16:32 `vm` | 15:11 `ip-10` |
| [pinned-sources](https://github.com/wader/static-ffmpeg/actions/runs/41612403347) | 17:22 `vm` | 15:09 `ip-10` |
| [satisfy-lib-requirements-by-apk-cairo](https://github.com/wader/static-ffmpeg/actions/runs/41602959815) | 17:47 `vm` | 15:18 `ip-10` |
| [download-with-curl](https://github.com/wader/static-ffmpeg/actions/runs/41505484748) | 18:24 `vm` | 32:19 `vm` |
| [satisfy-lib-requirements-by-apk-cairo](https://github.com/wader/static-ffmpeg/actions/runs/41499679220) | 18:05 `vm` | 16:54 `ip-10` |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

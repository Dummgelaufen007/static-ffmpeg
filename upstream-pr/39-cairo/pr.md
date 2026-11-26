# Enable cairo for the drawvg filter

Enables the `drawvg` filter (FFmpeg 8.1). cairo is already built for librsvg.

```sh
ffmpeg -i input.webm -vf 'drawvg=ellipse (w/2) (h/2) (w/3) (h/3) stroke' -pix_fmt yuv420p output.webm
```

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

# Render AVIF embedded in SVGs

With this PR librsvg renders SVGs with embedded AVIF images: `-Davif=enabled` turns the option on, and dav1d moves before librsvg, because that option needs it ([meson.build#L77-L80](https://github.com/GNOME/librsvg/blob/2.63.4/meson.build#L77-L80)).

## Changes

| File | Change |
|---|---|
| `Dockerfile` | dav1d recipe moved before librsvg, unchanged apart from a comment on why it sits there |
| `Dockerfile` | `-Davif=enabled` for librsvg |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

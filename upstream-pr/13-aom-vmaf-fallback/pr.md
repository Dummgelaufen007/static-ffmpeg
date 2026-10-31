# Let aom's tune=vmaf fall back to the model built into libvmaf

With this PR `tune=vmaf` works without a model file: a `sed` in `aom_dsp/vmaf.c` makes aom load libvmaf's built-in model `vmaf_v0.6.1` ([model.c#L61-L88](https://github.com/Netflix/vmaf/blob/v3.2.1/libvmaf/src/model.c#L61-L88), [#L157](https://github.com/Netflix/vmaf/blob/v3.2.1/libvmaf/src/model.c#L157)) when loading from a file fails, instead of stopping with "Failed to load VMAF model." ([vmaf.c#38](https://aomedia.googlesource.com/aom/+/refs/tags/v3.15.2/aom_dsp/vmaf.c#38)). It is the same line as BtbN's [patch](https://github.com/BtbN/FFmpeg-Builds/blob/6c9aec5fc9a72ec3abedd1fa84db141fa18cf52b/patches/aom/0001-Fall-back-to-built-in-vmaf-model-on-load-failure.patch).

## Changes

| File | Change |
|---|---|
| `Dockerfile` | `sed` in `aom_dsp/vmaf.c`, in the aom recipe |

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

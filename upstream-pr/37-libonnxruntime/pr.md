# Add libonnxruntime

- libonnxruntime: https://github.com/microsoft/onnxruntime

## Assessment

- FFmpeg 9.1: DNN backend for the filters `dnn_processing`, `dnn_detect` and `dnn_classify` (`dnn_deps_any="libtensorflow libopenvino libtorch libonnxruntime"`). `configure` checks `onnxruntime_c_api.h` and links `-lonnxruntime`.
- Use: super-resolution, denoising, object detection and classification with models from any common framework; ONNX is the common exchange format for models (not checked against a source).
- Runtime data: the model file, passed in from outside (volume in a container).
- Build: long CMake build; a static build with the CPU execution provider is plausible (guess).
- Alternatives: it covers the task of the other three backends. OpenVINO loads its device plugins at runtime, libtorch does not officially support static linking, TensorFlow is distributed as a shared library only (not checked against a source).
- Container relevance: high.
- Future: high.
- Open: static musl build not checked.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

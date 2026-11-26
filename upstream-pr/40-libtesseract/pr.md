# Add libtesseract

- libtesseract: https://github.com/tesseract-ocr/tesseract

## Assessment

- FFmpeg 9.1: filter `ocr` (`ocr_filter_deps="libtesseract"`); `configure` checks `tesseract/capi.h` via pkg-config.
- Use: text from frames, such as burned-in captions or overlays.
- Build: needs Leptonica and image libraries (not checked against a source).
- Runtime data: language models (`tessdata`), passed in from outside (volume in a container).
- Container relevance: medium.
- Future: stable, being overtaken by ML-based OCR.
- Open: static musl build not checked.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

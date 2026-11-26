# Stop hashupdate on a failed download

`hashupdate` now fetches with `curl -fsSL` instead of `curl -sL`. A 404 or other HTTP error used to end curl with exit 0, so `pipefail` did not trigger and the hash of the error page went into the Dockerfile. curl now exits with 22 and the bump stops before `sed`. `-S` keeps curl's error message visible despite `-s`.

This happened on 2026-10-08: the pushes `8e9fa77` (bump-libva-2.24.1) and `7e92d3f` (bump-libvpl-2.17.0) both set their `SHA256` to `d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed`, which is the sha256 of `404: Not Found`, and their builds failed at `sha256sum`.

*Research and wording by Claude (Anthropic), directed and reviewed by me.*

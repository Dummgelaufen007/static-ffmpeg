#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# wget reads only the lower-case name
[[ -z ${HTTP_PROXY:-} ]] || export http_proxy="$HTTP_PROXY"

dockerfile="${1:-Dockerfile.0.clean}"
dl_dir="${2:-dl-cache}"

if ! [[ -f $dockerfile ]]; then
  echo "dockerfile not found: $dockerfile" >&2
  exit 1
fi

eval "$(sed -n 's/^ARG \([A-Za-z_][A-Za-z0-9_]*=\)/\1/p' "$dockerfile")"

mkdir -p "$dl_dir"

fetch() {
  local f="$dl_dir/$1"
  if [[ -f "$f" ]] && echo "$3  $f" | sha256sum -c - >/dev/null 2>&1; then
    return 0
  fi
  wget -O "$f.tmp" -q --show-progress $WGET_OPTS "$2"
  echo "$3  $f.tmp" | sha256sum -c -
  mv "$f.tmp" "$f"
}

clone() {
  local d="$dl_dir/$1" s
  if [[ -d "$d" ]]; then rm -rf "$d.tmp"; mv "$d" "$d.tmp"; fi
  # explicit git dir: git -C falls back to the project repo when .git is broken
  local g=(git --git-dir="$d.tmp/.git" --work-tree="$d.tmp")
  if ! "${g[@]}" cat-file -e "$3^{commit}" 2>/dev/null; then
    rm -rf "$d.tmp"
    git init -q "$d.tmp"
    "${g[@]}" fetch --depth=1 "$2" "$3"
  fi
  if ! { [[ $("${g[@]}" rev-parse HEAD 2>/dev/null) == "$3" ]] && "${g[@]}" read-tree HEAD 2>/dev/null \
      && s=$("${g[@]}" status --porcelain --untracked-files=all 2>/dev/null) && [[ -z $s ]]; }; then
    if ! "${g[@]}" -c advice.detachedHead=false checkout -qf "$3" 2>/dev/null; then
      rm -rf "$d.tmp"
      git init -q "$d.tmp"
      "${g[@]}" fetch --depth=1 "$2" "$3"
      "${g[@]}" -c advice.detachedHead=false checkout -q FETCH_HEAD
    fi
    "${g[@]}" clean -qfdx
  fi
  mv "$d.tmp" "$d"
}

while read -r prefix; do
  file_var=${prefix}_FILE url_var=${prefix}_URL sha_var=${prefix}_SHA256
  fetch "${!file_var}" "${!url_var}" "${!sha_var}"
done < <(sed -n 's/^ARG \([A-Za-z0-9_]*\)_FILE=.*/\1/p' "$dockerfile")

for l in "$dl_dir"/*; do
  if [[ -L $l ]]; then rm "$l"; fi
done

while read -r prefix; do
  file_var=${prefix}_FILE url_var=${prefix}_URL
  if [[ -z ${!file_var:-} ]]; then
    url=${!url_var}
    target=$(basename "$url" .git)
    commit_var=${prefix}_COMMIT version_var=${prefix}_VERSION
    commit=${!commit_var:-${!version_var}}
    if ! [[ $commit =~ ^[0-9a-f]{40}$ ]]; then
      echo "not a commit for $url: $commit" >&2
      exit 1
    fi
    clone "$target-$commit" "$url" "$commit"
    ln -sfn "$target-$commit" "$dl_dir/$target"
  fi
done < <(sed -n 's/^ARG \([A-Za-z0-9_]*\)_URL=.*/\1/p' "$dockerfile")

keep=$(for l in "$dl_dir"/*; do if [[ -L $l ]]; then readlink "$l"; fi; done)
for d in "$dl_dir"/*/; do
  d=${d%/}
  if ! [[ -L $d ]] && ! grep -qxF "$(basename "$d")" <<< "$keep"; then
    rm -rf "$d"
  fi
done

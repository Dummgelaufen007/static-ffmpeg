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
  local file="$dl_dir/$1" url=$2 sha=$3
  if [[ -f "$file" ]] && echo "$sha  $file" | sha256sum -c - >/dev/null 2>&1; then
    return 0
  fi
  wget -O "$file.tmp" -q --show-progress $WGET_OPTS "$url"
  echo "$sha  $file.tmp" | sha256sum -c -
  mv "$file.tmp" "$file"
}

clone() {
  local dir="$dl_dir/$1" url=$2 commit=$3 changes
  if [[ -d "$dir" ]]; then rm -rf "$dir.tmp"; mv "$dir" "$dir.tmp"; fi
  # explicit git dir: git -C falls back to the project repo when .git is broken
  local repo_git=(git --git-dir="$dir.tmp/.git" --work-tree="$dir.tmp")
  if ! "${repo_git[@]}" cat-file -e "$commit^{commit}" 2>/dev/null; then
    rm -rf "$dir.tmp"
    git init -q "$dir.tmp"
    "${repo_git[@]}" fetch --depth=1 "$url" "$commit"
  fi
  if ! { [[ $("${repo_git[@]}" rev-parse HEAD 2>/dev/null) == "$commit" ]] && "${repo_git[@]}" read-tree HEAD 2>/dev/null \
      && changes=$("${repo_git[@]}" status --porcelain --untracked-files=all 2>/dev/null) && [[ -z $changes ]]; }; then
    if ! "${repo_git[@]}" -c advice.detachedHead=false checkout -qf "$commit" 2>/dev/null; then
      rm -rf "$dir.tmp"
      git init -q "$dir.tmp"
      "${repo_git[@]}" fetch --depth=1 "$url" "$commit"
      "${repo_git[@]}" -c advice.detachedHead=false checkout -q FETCH_HEAD
    fi
    "${repo_git[@]}" clean -qfdx
  fi
  mv "$dir.tmp" "$dir"
}

while read -r prefix; do
  file_var=${prefix}_FILE url_var=${prefix}_URL sha_var=${prefix}_SHA256
  fetch "${!file_var}" "${!url_var}" "${!sha_var}"
done < <(sed -n 's/^ARG \([A-Za-z0-9_]*\)_FILE=.*/\1/p' "$dockerfile")

for link in "$dl_dir"/*; do
  if [[ -L $link ]]; then rm "$link"; fi
done

while read -r prefix; do
  file_var=${prefix}_FILE url_var=${prefix}_URL
  if [[ -z ${!file_var:-} ]]; then
    url=${!url_var}
    name=$(basename "$url" .git)
    commit_var=${prefix}_COMMIT version_var=${prefix}_VERSION
    commit=${!commit_var:-${!version_var}}
    if ! [[ $commit =~ ^[0-9a-f]{40}$ ]]; then
      echo "not a commit for $url: $commit" >&2
      exit 1
    fi
    clone "$name-$commit" "$url" "$commit"
    ln -sfn "$name-$commit" "$dl_dir/$name"
  fi
done < <(sed -n 's/^ARG \([A-Za-z0-9_]*\)_URL=.*/\1/p' "$dockerfile")

keep=$(for link in "$dl_dir"/*; do if [[ -L $link ]]; then readlink "$link"; fi; done)
for dir in "$dl_dir"/*/; do
  dir=${dir%/}
  if ! [[ -L $dir ]] && ! grep -qxF "$(basename "$dir")" <<< "$keep"; then
    rm -rf "$dir"
  fi
done

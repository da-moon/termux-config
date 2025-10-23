#!/data/data/com.termux/files/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  mark-safe-git.sh [ROOT]

Description:
  Recursively find all Git repositories under ROOT (defaults to current directory)
  Add them to `git config --global safe.directory`, and remove any stale entries
  (entries pointing to directories that no longer exist).

Examples:
  ./mark-safe-git.sh
  ./mark-safe-git.sh "$HOME"
  ./mark-safe-git.sh /storage/emulated/0

Notes:
  - Adds both the path encountered and its canonical (real) path if different.
  - Safe to run multiple times; duplicates are skipped.

EOF
}

if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then
  usage
  exit 0
fi

ROOT="${1:-$PWD}"

# Phase 0: Clean up stale safe.directory entries
echo "Cleaning up stale safe.directory entries ..."
while IFS= read -r entry; do
  # Remove any surrounding quotes
  path="${entry%\"}"
  path="${path#\"}"
  if [ ! -d "$path" ]; then
    echo " Removing stale entry: $path"
    git config --global --unset-all safe.directory "$path" || true
  fi
done < <(git config --global --get-all safe.directory 2>/dev/null)

# Phase 1: Find all .git dirs
get_git_dirs() {
  if command -v fd >/dev/null 2>&1; then
    fd -L -H -t d --print0 '^\.(git)$' "$ROOT"
  else
    find -L "$ROOT" -type d -name ".git" -print0 2>/dev/null
  fi
}

mapfile -d '' gitdirs < <(get_git_dirs)
total=${#gitdirs[@]}

if [ "$total" -eq 0 ]; then
  echo "No Git repositories found under: $ROOT"
  exit 0
fi

echo "Found $total Git repositories under: $ROOT"
echo "Adding to git config --global safe.directory ..."
spinner='-\|/'
processed=0

have_safe_dir() {
  git config --global --get-all safe.directory 2>/dev/null | grep -Fxq "$1"
}

for gitdir in "${gitdirs[@]}"; do
  repo="$(dirname "$gitdir")"
  if command -v realpath >/dev/null 2>&1; then
    realrepo="$(realpath -m "$repo" 2>/dev/null || echo "$repo")"
  else
    realrepo="$(readlink -f "$repo" 2>/dev/null || echo "$repo")"
  fi

  if ! have_safe_dir "$repo"; then
    git config --global --add safe.directory "$repo" || true
  fi
  if [ "$realrepo" != "$repo" ] && ! have_safe_dir "$realrepo"; then
    git config --global --add safe.directory "$realrepo" || true
  fi

  processed=$((processed + 1))
  frame=$((processed % ${#spinner}))
  printf "\r[%d/%d] %s %s" "$processed" "$total" "${spinner:frame:1}" "$repo"
done

printf "\nDone.\n"

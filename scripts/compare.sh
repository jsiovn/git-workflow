#!/usr/bin/env bash
# Compare freshly produced transcripts with the committed ones.
# Usage: bash scripts/compare.sh <committed-dir> <fresh-dir>
#
# Fails (exit 1) only when the ordered list of commit hashes in a transcript
# differs. Any other difference, such as the wording of a newer git, is a
# GitHub Actions warning, so a git upgrade on the runner cannot keep main red.
set -euo pipefail

committed_dir="$1"
fresh_dir="$2"
status=0

hashes() {
  grep -oE '\b[0-9a-f]{7,40}\b' "$1" || true
}

for fresh in "$fresh_dir"/*.txt; do
  name="$(basename "$fresh")"
  committed="$committed_dir/$name"

  if [ ! -f "$committed" ]; then
    echo "::warning title=$name::no committed transcript to compare with yet"
    continue
  fi

  if [ "$(hashes "$committed")" != "$(hashes "$fresh")" ]; then
    echo "::error title=$name::commit hashes differ from the committed transcript"
    diff <(hashes "$committed") <(hashes "$fresh") || true
    status=1
  elif ! diff -u "$committed" "$fresh" > /dev/null; then
    echo "::warning title=$name::output differs from the committed transcript (hashes match)"
    diff -u "$committed" "$fresh" || true
  else
    echo "$name: identical"
  fi
done

exit "$status"

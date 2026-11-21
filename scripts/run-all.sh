#!/usr/bin/env bash
# Run every scenario in order and write <out-dir>/<script-name>.txt.
# Usage: bash scripts/run-all.sh [out-dir]   (default: transcripts/)
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
out="${1:-$here/../transcripts}"
mkdir -p "$out"

for script in "$here"/[0-9][0-9]-*.sh; do
  name="$(basename "$script" .sh)"
  if ! bash "$script" > "$out/$name.txt"; then
    # The transcript holds the git error (stderr is folded into it): show it.
    echo "::error title=$name::scenario failed; last lines of its transcript:" >&2
    tail -n 20 "$out/$name.txt" >&2
    exit 1
  fi
  echo "wrote $out/$name.txt"
done

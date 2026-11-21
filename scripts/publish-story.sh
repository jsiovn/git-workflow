#!/usr/bin/env bash
# Push the commits that scripts 01-03 build as story/* branches of this repo's
# origin, so a clone can browse them:
#   git log --oneline --graph origin/story/merged
# The branches share no history with main, by design.
#
# Usage: bash scripts/publish-story.sh
#
# Hashes are deterministic, so a rerun pushes nothing new. A push is never
# forced: if a script ever produced different hashes, the push would be
# rejected instead of rewriting a published branch.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/.." && pwd)"
remote="$(git -C "$repo" remote get-url origin)"
work=/tmp/git-workflow-demo # WORK_ROOT in lib.sh

# Build the story repos. Each script runs in its own process, so the isolated
# git environment of lib.sh (no global config, so no credential helper) stays
# there and the pushes below use your normal git setup.
for script in 01-merge-vs-rebase 02-squash-merge 03-force-with-lease; do
  bash "$here/$script.sh" > /dev/null
done

# branch | scenario repo | revision | transcript that prints its hash
story=(
  "story/diverged-main|01-merge-vs-rebase/merge|main|01-merge-vs-rebase"
  "story/diverged-feat|01-merge-vs-rebase/merge|feat/discount^1|01-merge-vs-rebase"
  "story/merged|01-merge-vs-rebase/merge|feat/discount|01-merge-vs-rebase"
  "story/rebased|01-merge-vs-rebase/rebase|feat/discount|01-merge-vs-rebase"
  "story/squashed|02-squash-merge/repo|main|02-squash-merge"
  "story/teammate-fix|03-force-with-lease/teammate|feat/discount|03-force-with-lease"
)

# Check every hash before pushing anything.
for entry in "${story[@]}"; do
  IFS='|' read -r branch dir rev transcript <<< "$entry"
  sha="$(git -C "$work/$dir" rev-parse --short=7 "$rev")"
  if ! grep -qw "$sha" "$repo/transcripts/$transcript.txt"; then
    echo "$branch: $sha is not in transcripts/$transcript.txt; refusing to push" >&2
    exit 1
  fi
done

for entry in "${story[@]}"; do
  IFS='|' read -r branch dir rev _ <<< "$entry"
  echo "# $branch ($(git -C "$work/$dir" rev-parse --short=7 "$rev"))"
  GIT_TERMINAL_PROMPT=0 git -C "$work/$dir" push "$remote" "$rev:refs/heads/$branch"
done

#!/usr/bin/env bash
# Post section 5.3: a "git reset --hard" by mistake, undone with the reflog.
source "$(dirname "$0")/lib.sh"

fresh_dir 06-reflog-rescue

# Setup: the rebased feat/discount of section 1.2 (same slots, same hashes).
story_diverged repo
cd repo
clock "$SLOT_REBASE"
quiet 'git rebase main'

echo '# Section 5.3: on the rebased feat/discount, reset to main by mistake'
run 'git log --oneline -3'
run 'git reset --hard main'
run 'git log --oneline -3'
echo

echo '# The two commits are gone from the branch, not from the reflog'
run 'git reflog -8'
echo

echo '# HEAD@{1} is where HEAD was just before the reset'
run "git reset --hard 'HEAD@{1}'"
run 'git log --oneline -3'

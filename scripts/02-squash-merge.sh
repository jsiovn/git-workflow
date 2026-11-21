#!/usr/bin/env bash
# Post section 1.3: squash-merge feat/discount into main after the rebase.
source "$(dirname "$0")/lib.sh"

fresh_dir 02-squash-merge

story_diverged repo
cd repo
clock "$SLOT_REBASE"
quiet 'git rebase main'

echo '# Section 1.3: feat/discount was rebased onto main (same hashes as 01)'
run 'git log --oneline --graph --decorate'
echo

echo '# Squash the whole branch into one commit on main'
run 'git switch main'
run 'git merge --squash feat/discount'
clock "$SLOT_SQUASH"
run 'git commit -m "feat(cart): thêm discount 10% (#42)"'
run 'git log --oneline --graph -4'

#!/usr/bin/env bash
# Post section 5.5: cherry-pick one commit onto main, then see what a later
# rebase and a later merge of the branch do with the duplicate.
source "$(dirname "$0")/lib.sh"

fresh_dir 08-cherry-pick

# Two identical copies of the diverged state of section 1.
story_diverged rebase
story_diverged merge
discount="$(git -C rebase rev-parse --short 'feat/discount~1')"

cd rebase
echo '# Section 5.5: take only the discount commit onto main'
run 'git switch main'
clock "$SLOT_CHERRY_PICK"
run "git cherry-pick $discount"
run 'git log --oneline --graph --all --decorate'
echo

echo '# Later, feat/discount is rebased onto main: the duplicate patch is dropped'
run 'git switch feat/discount'
clock "$SLOT_REBASE"
run 'git rebase main'
run 'git log --oneline --graph --decorate'
echo

cd ../merge
echo '# From a fresh copy: the same cherry-pick, then main is merged instead'
quiet 'git switch main'
clock "$SLOT_CHERRY_PICK"
quiet "git cherry-pick $discount"
quiet 'git switch feat/discount'
clock "$SLOT_MERGE"
run 'git merge main'
run 'git log --oneline --graph --decorate'

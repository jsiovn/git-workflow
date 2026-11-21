#!/usr/bin/env bash
# Post sections 1, 1.1 and 1.2: the same diverged branch, joined two ways.
source "$(dirname "$0")/lib.sh"

fresh_dir 01-merge-vs-rebase

# Two identical copies of the diverged state: one to merge, one to rebase.
story_diverged merge
story_diverged rebase

cd merge
echo '# Section 1: feat/discount and main have diverged'
run 'git log --oneline --graph --all --decorate'
echo

echo '# Section 1.1: merge main into feat/discount'
clock "$SLOT_MERGE"
run 'git merge main'
run 'git log --oneline --graph --decorate'
echo

cd ../rebase
echo '# Section 1.2: from a fresh copy of the diverged state, rebase onto main'
clock "$SLOT_REBASE"
run 'git rebase main'
run 'git log --oneline --graph --decorate'

#!/usr/bin/env bash
# Post section 5.6: the todo list of git rebase -i, and one fixup.
# GIT_SEQUENCE_EDITOR replaces the editor a person would use: `cat` only prints
# the todo list (nothing is changed, so nothing is rewritten), and `sed` turns
# the third `pick` into `fixup`.
source "$(dirname "$0")/lib.sh"

fresh_dir 09-rebase-interactive

# Setup: the rebased feat/discount of section 1.2, plus a "fix typo" commit.
story_diverged repo
cd repo
clock "$SLOT_REBASE"
quiet 'git rebase main'
clock "$SLOT_TYPO"
printf '%s\n' 'assert.equal(applyDiscount(0), 0);' >> discount.test.js
git commit -q -am 'test(cart): sửa typo'

echo '# Section 5.6: three commits on top of main, the last one is noise'
run 'git log --oneline -4'
echo

echo '# The todo list git rebase -i opens in your editor'
run 'GIT_SEQUENCE_EDITOR=cat git rebase -i main'
echo

echo '# Change the third line from pick to fixup: the typo fix melts into the test commit'
clock "$SLOT_FIXUP"
run "GIT_SEQUENCE_EDITOR=\"sed -i.bak '3s/^pick/fixup/'\" git rebase -i main"
run 'git log --oneline -3'
run 'git show --stat --format=%s HEAD'

#!/usr/bin/env bash
# Post section 6.2: rerere records a conflict resolution and replays it.
source "$(dirname "$0")/lib.sh"

fresh_dir 10-rerere

# Setup: main and feat/rate both change the same line of config.js.
git init -q repo
cd repo
clock 30
printf '%s\n' 'export const RATE = 0.1;' > config.js
git add config.js
git commit -q -m 'chore: init config'
git switch -q -c feat/rate
clock 31
printf '%s\n' 'export const RATE = 0.15;' > config.js
git commit -q -am 'feat: bump rate to 15%'
git switch -q main
clock 32
printf '%s\n' 'export const RATE = 0.12;' '// reviewed by finance' > config.js
git commit -q -am 'fix: rate 12% theo finance'
git switch -q feat/rate

# The post sets it with --global; the scripts never write your global config,
# so here it goes into this throwaway repo's own .git/config.
echo '# Section 6.2: turn rerere on'
run 'git config rerere.enabled true'
echo

echo '# First time: the conflict, resolved by hand, and recorded'
clock 33
run_fails 'git rebase main'
run 'cat config.js'
printf '%s\n' 'export const RATE = 0.15;' '// reviewed by finance' > config.js
run 'git add config.js && git rebase --continue'
run 'cat config.js'
echo

echo '# Go back to the branch as it was before the rebase, and rebase again'
run 'git reset --hard ORIG_HEAD'
clock 33
run_fails 'git rebase main'
run 'cat config.js'
run 'git add config.js && git rebase --continue'
run 'git log --oneline'

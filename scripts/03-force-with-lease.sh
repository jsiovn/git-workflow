#!/usr/bin/env bash
# Post sections 2.1 and 2.2: --force-with-lease refuses, --force overwrites.
source "$(dirname "$0")/lib.sh"

fresh_dir 03-force-with-lease

# Setup: a shared remote, your clone with both branches pushed, a teammate's clone.
# Remotes are relative paths, so git prints the same "To ..." line everywhere.
quiet 'git init -q --bare remote.git'
story_diverged you
(
  cd you
  git remote add origin ../remote.git
  git push -q -u origin main feat/discount 2>/dev/null
)
quiet 'git clone -q remote.git teammate'
quiet 'git -C teammate remote set-url origin ../remote.git'

cd teammate
echo "# Section 2.1: a teammate pushes a fix to feat/discount (in their clone)"
quiet 'git switch -q feat/discount'
clock "$SLOT_TEAMMATE_FIX"
printf '%s\n' 'export const roundTotal = (total) => Math.round(total);' >> discount.js
run 'git commit -am "fix(cart): làm tròn số tiền"'
run 'git push origin feat/discount'
echo

cd ../you
echo '# Meanwhile, in your clone (no fetch since): rebase onto main, then push'
clock "$SLOT_REBASE"
run 'git rebase main'
run_fails 'git push --force-with-lease origin feat/discount'
echo

echo '# Section 2.2: the same push with --force'
run 'git push --force origin feat/discount'
run 'git log --oneline origin/feat/discount -4'

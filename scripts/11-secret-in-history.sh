#!/usr/bin/env bash
# Post section 7.2: "git rm --cached" hides .env from the tree, not from history.
# The key is deliberately fake and does not have the shape of a real key.
source "$(dirname "$0")/lib.sh"

fresh_dir 11-secret-in-history

# Setup: a small app, then a .env committed by mistake.
git init -q repo
cd repo
commit_file 40 app.js 'console.log(`listening on ${process.env.PORT}`);' 'chore: init app'
clock 41
printf '%s\n' 'PORT=3000' 'STRIPE_SECRET_KEY=sk_live_FAKE_DO_NOT_USE' > .env
git add .env
git commit -q -m 'chore: thêm env'
leaked="$(git rev-parse --short HEAD)"

echo '# Section 7.2: the .env is noticed, ignored and untracked'
run 'echo ".env" >> .gitignore'
run 'git rm --cached .env'
clock 42
run 'git add .gitignore && git commit -m "chore: gitignore .env"'
run 'git status --short --ignored'
run 'git ls-files'
echo

echo '# The tree is clean, but every clone still has the key in history'
run 'git log --all --full-history --oneline -- .env'
run "git show $leaked:.env"

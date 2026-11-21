# Shared setup for every scenario script. Sourced, never executed directly.
#
# A commit hash is a function of the tree, the parents, the author, the
# committer, both dates and the message. This file pins every one of them so a
# script prints the same hashes on every machine and on every run.

set -euo pipefail

# --- isolation: no user, system or locale settings leak in -----------------
# Variables such as GIT_DIR (set inside hooks) would point the scenarios at the
# caller's own repository; GIT_DEFAULT_HASH would change every hash.
# shellcheck disable=SC2046
unset $(git rev-parse --local-env-vars) GIT_CONFIG_PARAMETERS GIT_DEFAULT_HASH GIT_TEMPLATE_DIR

# GIT_CONFIG_GLOBAL / GIT_CONFIG_SYSTEM need git 2.32; older git would read ~/.gitconfig.
git_version="$(git --version | sed -E 's/^git version ([0-9]+)\.([0-9]+).*/\1 \2/')"
read -r git_major git_minor <<< "$git_version"
if [ "$git_major" -lt 2 ] || { [ "$git_major" -eq 2 ] && [ "$git_minor" -lt 32 ]; }; then
  echo "git >= 2.32 required, found $(git --version)" >&2
  exit 1
fi

export LC_ALL=C
export TZ=Asia/Ho_Chi_Minh
export TERM=dumb
export GIT_PAGER=cat
export PAGER=cat
export GIT_EDITOR=true
export GIT_MERGE_AUTOEDIT=no
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_SYSTEM=/dev/null

WORK_ROOT=/tmp/git-workflow-demo
EMPTY_CONFIG="$WORK_ROOT/empty.gitconfig"
mkdir -p "$WORK_ROOT"
: > "$EMPTY_CONFIG"
export GIT_CONFIG_GLOBAL="$EMPTY_CONFIG"

# The one setting every scenario needs, passed without touching any file.
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0=init.defaultBranch
export GIT_CONFIG_VALUE_0=main

# --- identity ---------------------------------------------------------------
export GIT_AUTHOR_NAME=Dev
export GIT_AUTHOR_EMAIL=dev@example.com
export GIT_COMMITTER_NAME=Dev
export GIT_COMMITTER_EMAIL=dev@example.com

# --- clock --------------------------------------------------------------------
# Slot N = 2026-11-16T09:00:00+07:00 plus N minutes. Every scenario uses the
# same slot for the same event, so a commit shared by two transcripts gets the
# same date in both, and therefore the same hash.
CLOCK_BASE=1794794400 # 2026-11-16T02:00:00Z

clock() {
  local stamp="$((CLOCK_BASE + $1 * 60)) +0700"
  export GIT_AUTHOR_DATE="$stamp"
  export GIT_COMMITTER_DATE="$stamp"
}

SLOT_INIT=0
SLOT_TAX=1
SLOT_DISCOUNT=2
SLOT_TEST=3
SLOT_SHIPPING=4
SLOT_MERGE=5
SLOT_TEAMMATE_FIX=6
SLOT_REBASE=8
SLOT_SQUASH=9

# --- scenario directory -----------------------------------------------------
# fresh_dir <name>: wipe and recreate $WORK_ROOT/<name>, cd into it.
fresh_dir() {
  rm -rf "${WORK_ROOT:?}/$1"
  mkdir -p "$WORK_ROOT/$1"
  cd "$WORK_ROOT/$1"
}

# --- transcript helpers -----------------------------------------------------
# show_progress: keep what a terminal would leave on screen. Progress lines
# such as "Rebasing (1/2)" end in a carriage return and are overwritten.
show_progress() {
  sed $'s/.*\r//'
}

# run '<command>': print "$ <command>" like a terminal prompt, then run it with
# stderr folded into stdout (git writes most of its messages to stderr).
run() {
  printf '$ %s\n' "$1"
  eval "$1" 2>&1 | show_progress
}

# run_fails '<command>': same, for a command the scenario expects to fail.
# Stops the script if it unexpectedly succeeds.
run_fails() {
  printf '$ %s\n' "$1"
  if eval "$1" 2>&1 | show_progress; then
    echo "expected failure, but the command succeeded" >&2
    exit 1
  fi
}

# quiet '<command>': setup step, not part of the story the transcript tells.
quiet() {
  eval "$1" >/dev/null 2>&1
}

# commit_file <slot> <file> <line> <message>: append a line to a file, commit.
commit_file() {
  clock "$1"
  printf '%s\n' "$3" >> "$2"
  git add "$2"
  git commit -q -m "$4"
}

# --- the shared story: a "checkout service" ---------------------------------
# story_diverged <dir>: in a new repo at <dir>, build the state of section 1:
#   main:          init -> tax -> shipping fee
#   feat/discount: init -> tax -> discount -> discount test
story_diverged() {
  git init -q "$1"
  (
    cd "$1"
    commit_file "$SLOT_INIT" cart.js 'export const items = [];' 'chore: init checkout service'
    commit_file "$SLOT_TAX" cart.js 'export const TAX_RATE = 0.1;' 'feat(cart): add tax constant'
    git switch -q -c feat/discount
    commit_file "$SLOT_DISCOUNT" discount.js 'export const applyDiscount = (total) => total * 0.9;' 'feat(cart): apply 10% discount'
    commit_file "$SLOT_TEST" discount.test.js 'assert.equal(applyDiscount(100), 90);' 'test(cart): cover discount code'
    git switch -q main
    commit_file "$SLOT_SHIPPING" shipping.js 'export const SHIPPING_FEE = 30000;' 'feat(checkout): add shipping fee'
    git switch -q feat/discount
  )
}

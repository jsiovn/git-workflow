# git-workflow

Reproducible **Git terminal transcripts**: merge vs rebase, squash merge,
`--force-with-lease` vs `--force`, `add -p`, `stash`, `reflog`, `bisect`,
`cherry-pick`, `rebase -i`, `rerere` and a secret left in history. Every transcript is produced by a bash
script, byte for byte and with the same commit hashes on every run. The repo
backs the article
[Git rebase hay merge? Workflow và conventional commits](https://javascript.io.vn/2026/11/16/git-rebase-merge-conventional-commits-workflow/)
on [javascript.io.vn](https://javascript.io.vn/), so you can rerun the
commands the post prints instead of taking their output on trust. The scripts
cover sections 1-2 and 5-7 of the post; the [exhibits](#exhibits) show what
only a hosted repo can: the three merge methods as real pull requests, a
force-push event and a red commit-message check.

## Requirements

- **bash** (Linux, macOS, or Git Bash on Windows)
- **git** ≥ 2.32 (for `GIT_CONFIG_GLOBAL`, which keeps your `~/.gitconfig` out;
  the scripts refuse to run on older git). The committed transcripts come from
  the git of GitHub's `ubuntu-latest` runner; a different git version gives the
  same hashes but may word some messages differently.
- **node** for `scripts/07-bisect.sh` (its test is a small ES module) and, if
  you want the local commit hook, Node ≥ 22.12 for `npm install`.

## Quick start

```bash
bash scripts/run-all.sh              # writes transcripts/*.txt
git diff transcripts/                # the commit hashes match the committed files
bash scripts/01-merge-vs-rebase.sh   # or run one scenario and read it on screen
```

Each script builds its own throwaway repos under `/tmp/git-workflow-demo/`
(wiped at the start of the script) and never touches your own repositories or
your git config.

## Post section → script → transcript

| Post section | Script | Transcript |
| --- | --- | --- |
| 1. Merge hay rebase (diverged branches) | [`scripts/01-merge-vs-rebase.sh`](scripts/01-merge-vs-rebase.sh) | [`transcripts/01-merge-vs-rebase.txt`](transcripts/01-merge-vs-rebase.txt) |
| 1.1. Merge | [`scripts/01-merge-vs-rebase.sh`](scripts/01-merge-vs-rebase.sh) | [`transcripts/01-merge-vs-rebase.txt`](transcripts/01-merge-vs-rebase.txt) |
| 1.2. Rebase | [`scripts/01-merge-vs-rebase.sh`](scripts/01-merge-vs-rebase.sh) | [`transcripts/01-merge-vs-rebase.txt`](transcripts/01-merge-vs-rebase.txt) |
| 1.3. Squash merge | [`scripts/02-squash-merge.sh`](scripts/02-squash-merge.sh) | [`transcripts/02-squash-merge.txt`](transcripts/02-squash-merge.txt) |
| 2.1. `--force-with-lease` is rejected | [`scripts/03-force-with-lease.sh`](scripts/03-force-with-lease.sh) | [`transcripts/03-force-with-lease.txt`](transcripts/03-force-with-lease.txt) |
| 2.2. `--force` overwrites | [`scripts/03-force-with-lease.sh`](scripts/03-force-with-lease.sh) | [`transcripts/03-force-with-lease.txt`](transcripts/03-force-with-lease.txt) |
| 3. Conventional commits, enforced with commitlint and Husky | [`commitlint.config.js`](commitlint.config.js), [`.husky/commit-msg`](.husky/commit-msg) | [Actions › Commitlint](https://github.com/jsiovn/git-workflow/actions/workflows/commitlint.yml) |
| 5.1. `git add -p` | [`scripts/04-add-patch.sh`](scripts/04-add-patch.sh) | [`transcripts/04-add-patch.txt`](transcripts/04-add-patch.txt) |
| 5.2. `git stash` | [`scripts/05-stash.sh`](scripts/05-stash.sh) | [`transcripts/05-stash.txt`](transcripts/05-stash.txt) |
| 5.3. `git reflog` | [`scripts/06-reflog-rescue.sh`](scripts/06-reflog-rescue.sh) | [`transcripts/06-reflog-rescue.txt`](transcripts/06-reflog-rescue.txt) |
| 5.4. `git bisect` | [`scripts/07-bisect.sh`](scripts/07-bisect.sh) | [`transcripts/07-bisect.txt`](transcripts/07-bisect.txt) |
| 5.5. `git cherry-pick` | [`scripts/08-cherry-pick.sh`](scripts/08-cherry-pick.sh) | [`transcripts/08-cherry-pick.txt`](transcripts/08-cherry-pick.txt) |
| 5.6. `git rebase -i` | [`scripts/09-rebase-interactive.sh`](scripts/09-rebase-interactive.sh) | [`transcripts/09-rebase-interactive.txt`](transcripts/09-rebase-interactive.txt) |
| 6.2. `rerere` | [`scripts/10-rerere.sh`](scripts/10-rerere.sh) | [`transcripts/10-rerere.txt`](transcripts/10-rerere.txt) |
| 7.2. A secret stays in history | [`scripts/11-secret-in-history.sh`](scripts/11-secret-in-history.sh) | [`transcripts/11-secret-in-history.txt`](transcripts/11-secret-in-history.txt) |

Section 4 (choosing a workflow) prints no command output, so it has no
script. Section 3 has no transcript either; the convention it describes is
enforced in this repo instead (see [Commit convention](#commit-convention)).

Watch them being produced on a clean runner:
[Actions › Transcripts](https://github.com/jsiovn/git-workflow/actions/workflows/transcripts.yml).

## One story, one clock

The scripts on the shared story tell one "checkout service" story: `main` gets
`chore: init checkout service`, `feat(cart): add tax constant` and later
`feat(checkout): add shipping fee`, while `feat/discount` adds
`feat(cart): apply 10% discount` and `test(cart): cover discount code`.

A commit hash depends on the tree, the parents, the author, the committer, both
dates and the message. [`scripts/lib.sh`](scripts/lib.sh) pins all of them:

- identity `Dev <dev@example.com>` for author and committer;
- a fixed clock in slots of one minute from `2026-11-16T09:00:00+07:00`, where
  each event (each commit, the merge, the rebase, the squash) always uses the
  same slot;
- an isolated git config (no global or system file is read);
- fixed file contents, `LC_ALL=C`, `TZ=Asia/Ho_Chi_Minh`, and relative remote
  paths, so the `To ...` lines of `git push` read the same everywhere.

So a commit that appears in two transcripts has the same hash in both: the
rebased `feat/discount` commits (`9b05a8d`, `c4d968f`) are identical in the
merge/rebase, squash merge, force-with-lease, reflog and rebase -i
transcripts. The scenarios
that need a different story (`add -p`, `stash`, `bisect`, `rerere`, the
leaked secret) build their own small repo with the same pinned identity and
clock.

## Where the real output differs from the article

The transcripts are what git actually prints; where the article's blocks read
differently, the transcript wins. Commit hashes and dates differ everywhere:
the article was written from an earlier run, so take hashes from the
transcripts.

- **5.1** `s` splits the hunk into three, so the logic needs two `y` answers
  (`s`, `y`, `y`, `n`) before the debug log is skipped.
- **5.3** `git reset --hard` prints `HEAD is now at ...`.
- **5.4** git 2.56 words the result `is the first 'bad' commit` and
  `bisect found first 'bad' commit` (with quotes). The script's history is
  shorter than the article's, so the step counts differ (`2 revisions left`,
  then `0 revisions left`); the order of the tests is the same: `bump lodash`
  passes, `format lại code` fails, the VAT commit fails and is named.
- **5.6** the script adds a third commit (`test(cart): sửa typo`) so there is
  something to fix up. git 2.56 opens the todo list with a
  `# Rebase <base>..<tip> onto <base> (N commands)` line and lists more
  commands than the article shows (`-c` for fixup, `break`, `label`, `reset`,
  `merge`, `update-ref`).
- **6.2** the conflict output includes git's `hint:` lines and a final
  `Could not apply ...` line, and `git rebase --continue` also prints the new
  commit and `Successfully rebased ...`. The script sets `rerere.enabled` in
  the throwaway repo instead of with `--global`, because the scripts never
  write a global config.
- **7.2** `git rm --cached .env` removes the file from the index only: it is
  still in the working tree, now ignored (`!! .env` in `git status --ignored`).
  `.gitignore` must also be staged (`git add .gitignore`) to be part of the
  commit. The key in the script is deliberately fake
  (`sk_live_FAKE_DO_NOT_USE`).

What the article gets right, checked here: in **5.5**, a later
`git rebase main` drops the cherry-picked duplicate
(`warning: skipped previously applied commit`), while `git merge main` is a
plain merge without a conflict that keeps both copies in the history.

## Commit convention

Commits follow
[conventional commits](https://www.conventionalcommits.org/) (`type(scope): subject`),
and two tools check them, as section 3 of the article suggests for a team that
wants enforcement. The check starts with the commit that added it; GitHub's
`Merge pull request` commits are ignored by commitlint by default.

- **Local hook** — [`.husky/commit-msg`](.husky/commit-msg) runs
  [commitlint](https://commitlint.js.org/) with
  [`@commitlint/config-conventional`](commitlint.config.js) on every
  `git commit`. `npm install` turns it on (Husky's `prepare` script sets
  `core.hooksPath`). It gives the fastest feedback, but it is optional: a clone
  without `npm install`, or `git commit --no-verify`, skips it.
- **CI check** — [`.github/workflows/commitlint.yml`](.github/workflows/commitlint.yml)
  lints every commit of every pull request (job `commitlint`). Nobody can skip
  it, so it is the one that actually holds the line. This repo has no branch
  ruleset, so a red check does not block a merge here; on a team repo you would
  make `commitlint` a required status check.

```bash
npm install                                   # installs commitlint and the hook
echo "update code" | npx commitlint           # ✖ subject may not be empty, type may not be empty
echo "feat(cart): apply a coupon code" | npx commitlint   # no output: valid
```

## Exhibits

Pull requests and branches kept on purpose, for the parts of the article that
need a real GitHub repo. The pull requests carry the label
[`exhibit`](https://github.com/jsiovn/git-workflow/pulls?q=label%3Aexhibit)
and are never deleted. Their changes continue the checkout-service story under
[`demo/`](demo/) (`node --test 'demo/*.test.js'` runs its tests).

| Pull request | Merged with | What to look at |
| --- | --- | --- |
| [#1](https://github.com/jsiovn/git-workflow/pull/1) | merge commit (`gh pr merge --merge`) | `b230fe6 Merge pull request #1` on `main` has two parents. Both commits of the branch keep their hashes (`9f71b0d`, `c681437`) and stay visible as a side line of the graph. (Article 1.1.) |
| [#2](https://github.com/jsiovn/git-workflow/pull/2) | squash (`gh pr merge --squash`) | The PR has three commits (`feat`, `fix`, `test`); `main` has one: `45f4f65 feat(checkout): add shipping fee by region (#2)`, with the PR number in the subject. (Article 1.3.) |
| [#3](https://github.com/jsiovn/git-workflow/pull/3) | rebase (`gh pr merge --rebase`) | The timeline shows a **force-pushed** event: after #1 and #2 had landed, the branch was rebased onto the new `main` and pushed with `git push --force-with-lease`. `main` then got both commits one by one in a straight line, with new hashes (`03a6aca`, `7018970`): a rebase merge on GitHub always rewrites the commits. (Article 1.2 and 2.) |
| [#4](https://github.com/jsiovn/git-workflow/pull/4) | not merged: open and red on purpose | The `commitlint` check fails on the commit `update code` (no type, no subject); the other commit of the PR passes. That commit was made with `git commit --no-verify`, which skips the local hook, which is exactly why the CI check exists. (Article 3.) |

What the three merge methods left on `main`:

```text
$ git log --oneline --graph -7 7018970
* 7018970 test(checkout): cover the free shipping threshold
* 03a6aca feat(checkout): free shipping from 500,000 VND
* 45f4f65 feat(checkout): add shipping fee by region (#2)
*   b230fe6 Merge pull request #1 from jsiovn/feat/coupon-code
|\  
| * c681437 test(cart): cover the coupon code
| * 9f71b0d feat(cart): apply a coupon code
|/  
* 42eb92d docs: explain the local commit-msg hook and the pull request check
```

The head branches of the four pull requests (`feat/coupon-code`,
`feat/shipping-by-region`, `feat/free-shipping`, `feat/order-receipt`) are
kept too.

### Story branches

[`scripts/publish-story.sh`](scripts/publish-story.sh) runs scripts 01-03 and
pushes the commits they build as `story/*` branches, with the same hashes as
the transcripts. The script refuses to push a hash that is not in the
committed transcript, and never force-pushes. These branches share no history
with `main`, by design: they are the throwaway repos of the scripts, published.

| Branch | Tip | Transcript |
| --- | --- | --- |
| `story/diverged-main` | `aaffd2d feat(checkout): add shipping fee` | [`01`](transcripts/01-merge-vs-rebase.txt), section 1 |
| `story/diverged-feat` | `0454aa0 test(cart): cover discount code` | [`01`](transcripts/01-merge-vs-rebase.txt), section 1 |
| `story/merged` | `79a870c Merge branch 'main' into feat/discount` | [`01`](transcripts/01-merge-vs-rebase.txt), section 1.1 |
| `story/rebased` | `c4d968f test(cart): cover discount code` | [`01`](transcripts/01-merge-vs-rebase.txt), section 1.2 |
| `story/squashed` | `f01836f feat(cart): thêm discount 10% (#42)` | [`02`](transcripts/02-squash-merge.txt), section 1.3 |
| `story/teammate-fix` | `9c47778 fix(cart): làm tròn số tiền` (the commit `--force` erases) | [`03`](transcripts/03-force-with-lease.txt), section 2.1 |

```bash
git clone https://github.com/jsiovn/git-workflow.git && cd git-workflow
git log --oneline --graph origin/story/diverged-main origin/story/diverged-feat
git log --oneline --graph origin/story/merged
git log --oneline --graph origin/story/rebased
```

## What CI checks

[`.github/workflows/transcripts.yml`](.github/workflows/transcripts.yml) runs on
every push to `main`, on pull requests, on demand and once a month. It prints
`git --version`, runs `scripts/run-all.sh`, adds each transcript to the job
summary, uploads them as an artifact, and compares them with the committed
files using [`scripts/compare.sh`](scripts/compare.sh):

- the ordered list of commit hashes differs → **the job fails**;
- anything else differs (for example the wording of a newer git) → a
  **warning** only, so a git upgrade on the runner cannot leave `main` red.

GitHub disables scheduled workflows in a public repo after 60 days without
repository activity, so the monthly run stops on its own once the repo is
quiet; run it by hand from the Actions tab (`workflow_dispatch`).

The committed transcripts are the runner's output, downloaded from that
artifact, not output from a developer machine. Current files: recorded on
2026-11-22 with git 2.56.1 on `ubuntu-latest`.

## What a hosted repo cannot show

`git reflog`, `git stash` and `git rerere` are **local state**: they live in
`.git/` of one clone and are never pushed. GitHub cannot display them as
history. Where the article covers them, they appear here as scripts and CI
logs, not as hosted history.

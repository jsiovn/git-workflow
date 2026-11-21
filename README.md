# git-workflow

Reproducible **Git terminal transcripts**: merge vs rebase, squash merge,
`--force-with-lease` vs `--force`. Every transcript is produced by a bash
script, byte for byte and with the same commit hashes on every run. The repo
backs the article
[Git rebase hay merge? Workflow và conventional commits](https://javascript.io.vn/2026/11/16/git-rebase-merge-conventional-commits-workflow/)
on [javascript.io.vn](https://javascript.io.vn/), so you can rerun the
commands the post prints instead of taking their output on trust. Today the
scripts cover sections 1-2 of the post.

## Requirements

- **bash** (Linux, macOS, or Git Bash on Windows)
- **git** ≥ 2.32 (for `GIT_CONFIG_GLOBAL`, which keeps your `~/.gitconfig` out;
  the scripts refuse to run on older git). The committed transcripts come from
  the git of GitHub's `ubuntu-latest` runner; a different git version gives the
  same hashes but may word some messages differently.

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

Watch them being produced on a clean runner:
[Actions › Transcripts](https://github.com/jsiovn/git-workflow/actions/workflows/transcripts.yml).

## One story, one clock

All scripts tell the same "checkout service" story: `main` gets
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
rebased `feat/discount` commits are identical in all three transcripts.

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

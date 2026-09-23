---
name: task-3-complete
description: >-
  Close out one executed task: re-run every gate, capture learnings, commit on
  the task branch, push, open a PR per repo when remotes exist, review each
  with that repo's pr_review.md and /code-review when those exist, mark INDEX
  ✅ and hand over a manual test. Never merges unless the human opts in.
  Manual only — /task-3-complete TXX [--no-push].
argument-hint: "[TXX] [--no-push]"
disable-model-invocation: true
model: sonnet
effort: medium
allowed-tools: Read, Grep, Glob, Edit, Write, Bash, Agent, Skill
---

# /task-3-complete — Close one task

Run after `/task-2-execute TXX` passes. Re-verify, capture learnings, commit,
open and review a PR per bound repo when `origin` exists, mark INDEX `✅`, and
hand the human a manual test. Don't implement features. **Never merge** unless
the human opts in.

Arguments: $ARGUMENTS

- Task id — default: the INDEX `InProgress` row, else the task executed in this conversation.
- `--no-push` — commit locally only: no push, no PR, no PR reviews.

Resolve the hub first — read `references/hub-resolution.md`. Walk up from cwd
for `superplan.yml`; otherwise ask for the hub path.
If the hub cannot be resolved, **stop and ask**. Write hub files only
under the hub (in-repo mode: the hub may be this git repo).

## Hard constraints

1. Re-run every gate before committing. A missing or failing gate → stop: no
   `✅`, no commit, no PR.
2. Learnings go through `/dialectic-of-cognition` into hub `rules/`. Anything
   that belongs in a repo's own docs is proposed to the human, not written.
3. INDEX completed status is `✅` — never `Done`.
4. Commit only on `<stub-stem>`, never `main`. Stage the task's Files Modified by
   name and review `git status` before committing — no secrets.
5. Never force-push, skip hooks, amend published commits or edit git config. If
   a hook fails, fix the cause and make a new commit.
6. **Never merge** unless hub `superplan.yml` has `merge_prs: true` or the
   human opts in. Do not invent a GitHub remote.
7. Always end with a Manual test section, or `Nothing to test — <why>`.

## Procedure

### 1. Preconditions

AC passed. Blocked or failed → stop. Note whether `--no-push` was given.

### 2. Gates — per repo

Confirm the gate commands against the repo's gate source, then run them.
Record results in **Verification**.

### 3. Dialectic

Fully execute `/dialectic-of-cognition` (Modes A and B) into hub `rules/`.

### 4. Downstream sync

If this task changed layout, contracts or defaults, add **Reality notes** to
later stubs. If nothing is stale, say so.

### 5. Commit, push, PR — per bound repo in **Repos**

1. Confirm the repo is on `<stub-stem>`. If not, stop and say why.
2. Stage by name, run `git status`, and commit `TXX <what this task delivered>`.
3. Unless `--no-push`: `git push -u origin HEAD`. No `origin` → say so and skip;
   never invent a remote.
4. Unless `--no-push` and `origin` exists: `gh pr create` — short title; body
   with summary, test plan, links to sibling PRs. Cross-repo merge order follows
   `rules/cross-repo.md` if present; else ask. Do not merge.

### 6. Reviews — per PR

If the repo has `.cursor/commands/pr_review.md` or `pr_review.md`, review the
PR against it. If the agent has `/code-review`, run it. Skip either when
missing and say so. Fix confirmed findings with new commits; put decisions to
the human.

### 7. Mark complete

- Task file: Status `Done`, Learnings filled, Status History row.
- INDEX: Status `✅`, Notes may carry PR links and "merge pending".

### 8. Manual test

Per repo, concrete commands, or `Nothing to test — <why>`.

### 9. Output

```
## Completed — TXX Title
### Verify
- <repo>: …
### Dialectic
…
### Downstream updates
- none / …
### Git
- <repo>: branch · commit · push · PR URL or skipped
### Reviews
- <repo>: pr_review / code-review / skipped (why)
### INDEX
TXX → ✅ (merge pending unless no PRs)
### Manual test
…
### Next
Human merges if they want (never merge by default), then /task-1-plan TYY
```

## Do not

- Start the next task's implementation.
- Skip dialectic when a trigger fired, or skip any gate.
- Merge, force-push or skip hooks.
- Write `Done` into the INDEX.
- Omit the Manual test.

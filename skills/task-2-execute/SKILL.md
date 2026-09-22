---
name: task-2-execute
description: >-
  Implement exactly one Planned task from phases/ across the repos it touches,
  following each touched repo's own rules, until its acceptance criteria and
  every gate pass. No commits; hands off to /task-3-complete. Manual only —
  /task-2-execute TXX.
argument-hint: "[TXX]"
disable-model-invocation: true
model: sonnet
effort: medium
allowed-tools: Read, Grep, Glob, Edit, Write, Bash, Agent
---

# /task-2-execute — Implement one task

Implement **exactly one** task from `phases/` until its Acceptance Criteria and
gates pass, or it is `Blocked`. Closing it is `/task-3-complete`.

Task: $ARGUMENTS

Resolve the hub first — read `references/hub-resolution.md`. Walk up from cwd
for `superplan.yml`; otherwise ask for the hub path.
If the hub cannot be resolved, **stop and ask**. Do not write hub
files into a product repo.

If no task is given: the first `Planned` INDEX row, else the first actionable
`Pending` one.

Follow the Execution plan literally. If it is too vague to follow, stop and
send it back to `/task-1-plan` — don't invent a design. If the plan recommends
`opus`, tell the human before heavy work: this skill pins `sonnet` in its
frontmatter, so running on Opus means changing that line first.

## Hard constraints

1. **Repo rules come first** (hub `CLAUDE.md` and/or `AGENTS.md`). Before
   editing an area, re-read that repo's sources for it, including
   `.cursor/rules/*.mdc` whose `globs` match. On conflict: follow the repo,
   tell the human, ask if a decision is needed.
2. Karpathy Behavioral Guidelines in full — not only "surgical".
3. New code requires tests in this task.
4. Gates must pass before claiming AC. A gate that can't run, or whose command
   no longer matches the repo's gate source, is a failure: set `Blocked`. Unit
   tests alone are never green.
5. No commits, pushes or PRs. Never stash, reset or discard work you didn't create.
6. One task `InProgress` unless the human approved parallel work.

## Procedure

### 0. Preconditions

- Task file and INDEX read.
- Every Depends-on is `✅` or `—`, or the plan names a stacked base branch.
- No Execution plan → run `/task-1-plan` first.

### 1. Branches — per repo in **Repos**

1. `git status`. If there are changes you didn't make, stop and ask.
2. `git fetch origin`, then create or check out `<stub-stem>` from the base the plan names.

### 2. Status → `InProgress`

Task file and INDEX, plus a Status History row.

### 3. Implement

- Follow the steps in order. Add tests alongside the code.
- Delegate well-scoped mechanical units to a general-purpose subagent. Keep
  design decisions and cross-repo coordination here.

### 4. Gates — per repo

1. Confirm the plan's gate commands against the repo's gate source (hub Repos /
   Verify gates table).
2. Run them. Follow that repo's hub spoke for shared stacks or fixtures.
3. After non-trivial edits, if the repo has `.cursor/commands/pr_review.md` (or
   `pr_review.md`), review the diff against it. Otherwise skip and say so.

### 5. Record

Fill **Verification** (commands and outcomes, per repo) and **Files Modified**
(per repo). Leave INDEX `InProgress`.

### 6. Hand off

> Run `/task-3-complete TXX` — re-verify → dialectic → commit → PR + reviews → INDEX ✅ → manual test.

If the human asked to execute and complete in one go, run `/task-3-complete` now.

### 7. Output

```
## Executed — TXX Title
### Result
Acceptance passed | Blocked — <why>
### Verification
- <repo>: <gate> … pass/fail
### Files touched
- <repo>: …
### Next
/task-3-complete TXX
```

## Do not

- Execute two tasks in one invocation.
- Mark INDEX `✅`, or write `Done` into it.
- Skip tests or gates, or treat unit tests as the full gate.
- Commit, push or open PRs.

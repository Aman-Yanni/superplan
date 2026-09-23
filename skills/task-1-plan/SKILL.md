---
name: task-1-plan
description: >-
  Plan or re-plan one task from phases/ into a handoff-ready execution plan that
  a Sonnet executor can follow cold, grounded in each touched repo's own rules
  and a reality check of the code. Does not implement. Manual only —
  /task-1-plan TXX.
argument-hint: "[TXX or path to the task file]"
disable-model-invocation: true
model: opus
effort: high
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git *), Agent, WebFetch
---

# /task-1-plan — Plan one task

Refine **one** task file under `phases/` so `/task-2-execute` (Sonnet) can
implement it cold, without rediscovering the design. You do not implement.

Task: $ARGUMENTS

Resolve the hub first — read `references/hub-resolution.md`. Walk up from cwd
for `superplan.yml`; otherwise ask for the hub path.
If the hub cannot be resolved, **stop and ask**. Write hub files only
under the hub (in-repo mode: the hub may be this git repo).

If no task is given, read `phases/INDEX.md` and pick the first `Pending` or
`Planned` row whose Depends-on are all `✅` or `—`.

## Hard constraints

1. **Repo rules come first** (hub `CLAUDE.md` and/or `AGENTS.md`). A step that
   contradicts a touched repo's own sources is wrong — fix the plan or raise
   the conflict. Order: repo sources > hub `rules/` > Superplan defaults.
2. Stay inside the task's Acceptance Criteria (Simplicity First). Don't pull in
   later layers.
3. Every step is written `… → verify: …`.
4. Meet the hub **plan handoff bar**. A high-level plan is not `Planned`.
5. Gate commands come from the hub Verify gates table, confirmed against each
   repo's gate source. A repo with no gate: propose checks and get them
   confirmed.
6. New code ships with tests, written the way that repo's own docs
   (`CLAUDE.md`, `AGENTS.md`, `TESTING.md`, and `pr_review.md` if present)
   require.
7. If the task is ambiguous, stop and ask.

## Procedure

### 1. Load context

- `phases/INDEX.md`, the task file end to end, and the Learnings and Reality
  notes of every Depends-on task.
- For each repo in the task's **Repos**: read its context sources (hub Repos
  table) for the areas touched — including `.cursor/rules/*.mdc` whose `globs`
  match — then its hub spoke `rules/<repo>.md`. List what you read under
  **Context sources read**.
- Reality-check each repo with an `Explore` subagent (one per repo, in
  parallel). Single-file reads may stay inline.

### 2. Reality check

List what exists against what the stub assumes. If the code diverged, amend
Requirements or AC and say so.

### 3. Write the execution plan into the task file

- **Codebase snapshot** — per repo, current branch and short SHA (`git -C <repo> rev-parse --short HEAD`).
- **Context for executor** — goal; key paths prefixed by repo; repo rules that apply, each citing its source.
- **Branch and base** — `<stub-stem>` in each repo, based on `origin/main`, or on the Depends-on task's branch when that PR hasn't merged.
- **Steps** — ordered, tagged by repo, each with `→ verify:`. Spanning-repo order follows `rules/cross-repo.md` if present; else ask.
- **Tests to add**, **Gate commands** per repo, **Risks / pitfalls / do not**, **Out of scope**.
- **Execute model** — `sonnet` by default. Write `opus` with a one-line reason only when the task is exceptionally hard even with this plan.

Set Status `Planned` (task file and INDEX) only when a Sonnet executor could
follow the plan cold. Add a Status History row.

### 4. Output

Ready? · key steps · AC · execute model · Next: `/task-2-execute TXX`

## Do not

- Implement the task, or write product feature code.
- Expand scope into later layers.
- Mark INDEX `✅`.
- Leave a plan that forces the executor to redesign.

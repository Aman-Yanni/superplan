---
name: bootstrap-turboplan
description: >-
  Retarget the planning hub to the bound repos as they are now: re-inventory
  each repo's own rules, context sources and gates; update the hub CLAUDE.md
  and/or AGENTS.md tables, spokes and README; onboard a new repo. Never
  modifies a repo or writes product code. Manual only.
argument-hint: "[what changed, e.g. \"add repo <name> at <path>\" or \"re-sync everything\"]"
disable-model-invocation: true
model: opus
effort: high
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git *), Agent, WebFetch, WebSearch
---

# /bootstrap-turboplan — Retarget the hub

Bring the hub back in line with the bound repos: re-inventory each repo's
rules, context sources and gates; rewrite the hub `CLAUDE.md` / `AGENTS.md`
tables; adapt spokes; onboard a new repo. You don't write product feature code.
When the hub is a separate folder, you don't change bound product repos.

Input: $ARGUMENTS

Resolve the hub first — read `references/hub-resolution.md`. Walk up from cwd
for `superplan.yml`; otherwise ask for the hub path.
If the hub cannot be resolved, **stop and ask**. Write hub files only
under the hub (in-repo mode: the hub may be this git repo).

If the input doesn't say what changed or which repos are in scope, ask before
starting.

This skill **retargets a planning hub**. It is not the Superplan-repo
bootstrap that lives under Superplan's own `.cursor/skills/`.

## Hard constraints

1. **The repos are the authority.** The hub records their rules and gates; it
   never invents or overrides them.
2. Never add tooling (Makefile, hooks, CI, lint config) or docs to a repo. A
   repo without a gate gets "none established" in the hub, plus a proposed task
   via `/setup-tasks`.
3. Hub spokes only add what the repo's own docs don't say: routing to those
   docs, cross-repo knowledge, and verified problem classes.
4. Every fact written needs evidence read in this session (a file path). No
   evidence → leave it out, or ask.
5. Hubs stay **data-only**. Do not copy Superplan pack skills into the hub.

## Procedure

### 1. Inventory

- One `Explore` subagent per bound repo, in parallel, reporting: agent docs
  (`CLAUDE.md`, `AGENTS.md`, `TESTING.md`, `.cursor/rules/*.mdc` with their
  `globs`, `.cursor/commands/*`, `.claude/`); gate sources with exact commands;
  stack facts; git remote.
- Read the hub `CLAUDE.md`/`AGENTS.md`, `rules/`, and `phases/INDEX.md` yourself.
- Classify each hub item KEEP / ADAPT / DELETE. The decisions stay with you.

### 2. Rewrite the hub `CLAUDE.md` / `AGENTS.md`

Keep every section the hub already uses (Repo rules come first, Repos, Karpathy
Behavioral Guidelines, Routing Map, Delivery, Verify gates, Git & PR rails,
Safety rails, Rule Maintenance 0–7, Skills, History). Update Repos, Verify
gates, Routing Map, Skills (one row per **global pack** skill, not hub-local
copies). Keep it under ~200 lines. No task ids or layer tables —
`phases/INDEX.md` is the sole source of those.

### 3. Spokes

- One per repo (`rules/<repo>.md`) plus `rules/cross-repo.md`, shaped like
  `templates/rule-spoke.md` if present.
- Re-verify existing entries. Remove entries only with the human's approval.
- Dependency spokes only for libraries or APIs the human names, with an
  official docs URL.

### 4. Skills

Do not vendor the pack into the hub. If the hub still has `.claude/skills/` or
`.cursor/skills/` copies, report them and propose deleting them after global
install.

### 5. Human README

Update hub `README.md`: bound repos, how to launch, work loop, layout.

### 6. Self-check

- [ ] Every Repos-table path and listed context source exists.
- [ ] Every gate command matches its gate source.
- [ ] Routing Map ↔ `rules/*.md`.
- [ ] `phases/INDEX.md` rows ↔ stub files.
- [ ] Every new fact has evidence.
- [ ] No product *feature* code was added. Hub files in-repo (when the hub is the git repo) are expected.
- [ ] Hub has no pack skill copies.

### 7. Output

```
## Bootstrap complete

### Repos
- <repo>: context sources · gate source · what changed

### Hub
- sections updated: …

### Spokes
- added · adapted · flagged for removal

### Gaps
- repos without gates or agent docs; drift found inside repo docs

### Review gate
Confirm before the next /setup-tasks.
```

## Do not

- Modify a bound product repo that is **not** the hub (no feature code either way).
- Copy repo rules wholesale into the hub — route to them instead.
- Write facts you haven't read in this session.
- Copy Superplan skills into the hub.

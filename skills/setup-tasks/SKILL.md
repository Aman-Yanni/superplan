---
name: setup-tasks
description: >-
  Turn a settled feature (ideally a confirmed /grill-me summary) into task stubs
  appended to phases/INDEX.md, respecting each touched repo's own rules and the
  existing dependency graph. Does not rewrite hub rules or skills, and does
  not write product feature code. Manual only.
argument-hint: "[confirmed /grill-me summary, or feature description]"
disable-model-invocation: true
model: opus
effort: high
allowed-tools: Read, Grep, Glob, Edit, Write, Agent, WebFetch, WebSearch
---

# /setup-tasks — Feature → task stubs

Turn a settled feature into task stubs appended to `phases/INDEX.md`. You don't
rewrite the hub `CLAUDE.md`/`AGENTS.md`, spokes or skills (the one exception:
adding an approved dependency spoke to the Routing Map), and you don't write
product feature code.

Input: $ARGUMENTS

Resolve the hub first — read `references/hub-resolution.md`. Walk up from cwd
for `superplan.yml`; otherwise ask for the hub path.
If the hub cannot be resolved, **stop and ask**. Write `phases/` and
`rules/` only under the hub (in-repo mode: the hub may be this git repo).

## Context gathering (mandatory)

You need: the feature goal (what users get when it's done), technical scope
(which bound repos and areas), non-goals, constraints, new dependencies,
references.

- **From `/grill-me`:** its summary and decision log answer these. Don't re-ask
  anything settled; grill only what it left open.
- **Otherwise:** ask for each. A feature too vague to plan hasn't been thought
  through — say so and stop, or suggest `/grill-me`.

## Procedure

### 1. Read current state

- Hub `CLAUDE.md` and/or `AGENTS.md`, `phases/INDEX.md`, and the spokes for the
  repos in scope (`rules/<repo>.md`, `rules/cross-repo.md` when spanning).
- For each bound repo in scope, its **context sources** for the areas involved —
  stubs must fit them (tests, generated clients, deploy checks — whatever that
  repo's own docs require).
- One `Explore` subagent per repo, in parallel. Small greps may stay inline.

### 2. Slice into tasks

- Each task advances one layer (legend in `phases/INDEX.md`) and answers: *how
  do we know this layer works without the next one?*
- Size: one checkable slice, not a whole feature and not a single log line.
- Work that spans repos follows `rules/cross-repo.md` if present; else ask the
  human the order.
- Respect the existing Depends-on graph. Never reorder existing rows.

### 3. Write stubs

- Take the next free ids. Create `phases/TXX-<slug>.md` from `templates/task.md`
  if that template exists: Description, Repos, Branch, Requirements, Acceptance
  Criteria, Test Plan, Depends-on, Next, Layer. Leave the Execution plan empty.
- Append INDEX rows with Depends-on / Next links, under a short feature header
  carrying the settled decisions, so nothing from `/grill-me` is lost.

### 4. New dependencies (human-approved)

For a library, framework or external API with no spoke, ask: "Create a
`rules/<name>.md` spoke for <dep>?" If yes, fetch its official docs, write the
spoke from `templates/rule-spoke.md` if present, and add it to the hub Routing
Map.

### 5. Output

```
## /setup-tasks complete — <feature>

### Context
- Goal: …
- Scope (repos): …
- Non-goals: …
- New deps: … / none

### New tasks
| ID | Title | Repos | Layer | Depends-on |
| -- | ----- | ----- | ----- | ---------- |

### INDEX
- Appended after TYY

### First action
- /task-1-plan TXX
```

## Do not

- Rewrite the hub, spokes, skills or existing INDEX rows.
- Write product feature code. Hub files (`phases/`, hub `rules/`) belong under the hub, which may be this repo.
- Skip context gathering because the human seems busy.
- Create a dependency spoke without approval.
- Copy Superplan pack skills into the hub (hubs are data-only).

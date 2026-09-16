---
name: grill-me
description: >-
  Stress-test an idea before planning. Interviews the human in rounds over a
  design tree until nothing is silently assumed, reading each touched repo's own
  rules and gathering facts via subagents. Runs before /setup-tasks or
  /bootstrap-turboplan. Writes no plans, tasks or code. Manual only.
argument-hint: "[idea, or path to a spec]"
disable-model-invocation: true
model: opus
effort: high
allowed-tools: Read, Grep, Glob, Agent, WebFetch, WebSearch
---

# /grill-me — Idea → settled shared understanding

Grill the human about an idea, feature or decision before any planning skill
runs. The output is a **settled design tree** — every decision made or
deliberately deferred, nothing silently assumed — which becomes the input to
`/setup-tasks` (new feature) or `/bootstrap-turboplan` (hub retarget).

You write no stubs, plans or code. Interview until the frontier is empty, then
summarise.

Idea: $ARGUMENTS

If `phases/INDEX.md` is missing in the current directory, say so and ask where
the planning hub is. Do not invent a hub. Do not write into a product repo.

## 1. Read before grilling

Before the first question:

- Hub `CLAUDE.md` and/or `AGENTS.md` (whichever exist; if neither, stop and
  ask), `phases/INDEX.md`, and any spec the human attached or referenced.
- Work out which bound repos the idea touches (hub Repos table). For each, read
  its **context sources** for the areas involved, then its hub spoke
  (`rules/<repo>.md`) — before forming any recommendation. A recommendation
  that contradicts a repo's own rules is wrong. Order: repo sources > hub
  `rules/` > Superplan defaults. On conflict: follow the repo, tell the human,
  ask if a decision is needed.
- Dispatch one `Explore` subagent per touched repo, in parallel, to map the
  surfaces the idea touches. Start grilling while they run; only questions
  downstream of their findings wait.
- `archive/` holds past plans if present. Check it when the idea revisits old
  ground.

## 2. Interview in rounds over a design tree

Every decision branches into the decisions that hang off it. The **frontier**
is every decision whose prerequisites are settled. Ask the whole frontier in one
round, numbered, each with a recommended answer, then wait:

```
❓ **Q1** - **<question title>**: <question body, with options where they exist>

➡️ <your recommended answer>
```

Silence on a question means the human accepts ➡️ — say so every round. Answers
reshape the tree: recompute the frontier and ask the next round. A question
whose answer depends on another question still open this round belongs to a
later round.

## 3. Facts are yours, decisions are the human's

Never ask the human anything a subagent could look up: schema, file paths,
existing behaviour, library capabilities, what a repo's rules require. Verify a
fact before recommending on it — fetch docs or read code, never recommend from a
guess. Put every decision to the human and wait.

## 4. Close the frontier

When every branch has been visited:

1. State remaining small items as explicit defaults the human can veto.
2. Emit a **Shared understanding summary** — numbered, grouped by area as fits,
   with concrete specifics and the bound repo each item lands in.
3. Ask the human to confirm.

After confirmation, hand off verbatim: the summary plus the question and
decision log is the input to `/setup-tasks` or `/bootstrap-turboplan`. Every
settled decision must land in the INDEX feature header or a task stub.

## Do not

- Run `/setup-tasks` or `/bootstrap-turboplan` before the human confirms the summary.
- Ask the human anything a subagent could find in a repo or its docs.
- Record a decision the human didn't make or accept.
- Write stubs, plans or code.
- End with unvisited branches — if the tree is large, say so and keep rounding.

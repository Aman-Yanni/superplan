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
allowed-tools: Read, Grep, Glob, Agent, WebFetch, WebSearch, AskQuestion, AskUserQuestion
---

# /grill-me — Idea → settled shared understanding

Grill the human about an idea, feature or decision before any planning skill
runs. The output is a **settled design tree** — every decision made or
deliberately deferred, nothing silently assumed — which becomes the input to
`/setup-tasks` (new feature) or `/bootstrap-turboplan` (hub retarget).

You write no stubs, plans or code. Interview until the frontier is empty, then
summarise.

Idea: $ARGUMENTS

Resolve the hub first — read `references/hub-resolution.md`. Walk up from cwd
for `superplan.yml`; otherwise ask for the hub path.
If the hub cannot be resolved, stop and ask. Do not invent a hub.
Write hub files only under the hub (in-repo mode: that may be this git repo).

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
is every decision whose prerequisites are settled. Ask the whole frontier in
one round, then wait.

**Use clickable choice UI, not a numbered list in the chat.** Do not write
Q1/Q2 with (a)(b)(c) and wait for the human to type a letter or number. Call
the agent's native multiple-choice tool in the same turn as the questions:

- Cursor: `AskQuestion`
- Claude Code: `AskUserQuestion`
- Other runtimes: the equivalent choice/form tool

Each question in that call:

1. `prompt` is the question (short title plus body).
2. At least two concrete options. Put your recommended answer first and end
   that label with `(Recommended)`.
3. **Always** append a last option the human can use to type their own
   suggestion: id `other`, label `I'll write my own`. Leave it as the empty /
   free-text choice — do not prefill it. If the tool also injects an Other
   field, keep this option anyway so the custom path is visible in the list.
4. Put every frontier question in **one** tool call (the questions array).

Do not repeat the same options as markdown in the assistant message. A short
sentence that the form is up is enough.

If the runtime has no choice UI, fall back to chat but still end every
question with a blank `I'll write my own:` line — never only lettered choices.

Answers reshape the tree: recompute the frontier and ask the next round. A
question whose answer depends on another question still open this round
belongs to a later round.

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
- Record a decision the human didn't make or pick in the choice UI.
- List lettered or numbered choices in chat for the human to type back.
- Write stubs, plans or code.
- End with unvisited branches — if the tree is large, say so and keep rounding.

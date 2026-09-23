---
name: grill-me
description: >-
  Stress-test an idea before planning. Interviews the human in rounds over a
  design tree until shared understanding is reached, gathering facts itself via
  sub-agents. Runs between "human has an idea" and /setup-tasks (or
  /bootstrap-turboplan). Does not write plans or tasks.
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob, Edit, Write, WebFetch, WebSearch, Task, AskQuestion, AskUserQuestion
---

# /grill-me — Idea → interrogated, settled shared understanding

You grill the human about an idea, feature, or decision **before** any planning
skill runs. The output of this session is a **settled design tree** — every
decision made or deliberately deferred, nothing silently assumed — which becomes
the input context for `/setup-tasks` (new feature) or `/bootstrap-turboplan`
(new project).

**You do not write phase stubs, plans, or code.** You interview until the
frontier is empty, then summarize. The next skill runs only after the human
confirms.

## Procedure

### 1. Read before grilling

Before the first question:

- Read `.cursor/rules/general.mdc` (hub) and every spoke relevant to the idea
- Read `planning/phases/INDEX.md` to know what exists and what's done
- Read any feature-plan / spec documents the human attached or referenced
- Grep the codebase for the surfaces the idea touches
- If the idea is about the **published pack**, look at `skills/`. If it is
  about **building Superplan**, look at `.cursor/skills/` and `install.sh`.
  Do not mix the two trees.

### 2. Interview in rounds over a design tree

Map the session as a **design tree**: every decision branches into the
decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose
prerequisites are already settled — the questions you can ask _now_ without
guessing at answers you haven't heard yet. Ask the whole frontier in one round,
then wait.

**Use clickable choice UI, not a numbered list in the chat.** Do not write
Q1/Q2 with (a)(b)(c) and wait for the human to type a letter or number. Call
the agent's native multiple-choice tool in the same turn:

- Cursor: `AskQuestion`
- Claude Code: `AskUserQuestion`
- Other runtimes: the equivalent choice/form tool

Each question:

1. `prompt` is the question (short title plus body).
2. At least two concrete options. Put your recommended answer first and end
   that label with `(Recommended)`.
3. **Always** append a last option the human can use to type their own
   suggestion: id `other`, label `I'll write my own`. Leave it as the empty /
   free-text choice — do not prefill it. If the tool also injects an Other
   field, keep this option anyway so the custom path is visible in the list.
4. Put every frontier question in **one** tool call (the questions array).

Do not repeat the same options as markdown in the assistant message.

Each round of answers reshapes the tree — settled decisions push the frontier
outward and unblock the questions that depended on them. Recompute the frontier
and ask the next round. A question whose answer depends on another question
still open in this round belongs to a _later_ round, not this one.

### 3. Facts are your job, decisions are the human's

When a frontier question needs a **fact** from the environment (schema, file
paths, library capabilities, existing behavior), dispatch a sub-agent to find
it — never ask the human for anything you could look up yourself. Don't block
on it: a running exploration is an unsettled prerequisite, so only the
questions downstream of it wait for the sub-agent to report — ask the rest of
the frontier now. The **decisions** are the human's — put each to them and
wait.

When a recommendation hinges on a fact you haven't verified, verify it first
(fetch docs, read code) — do not recommend from a guess.

### 4. Closing the frontier

The session is done when the frontier is empty: every branch visited, nothing
left silently assumed. Then:

1. State any remaining small items as explicit defaults the human can veto
2. Emit a **Shared understanding summary** — numbered, grouped by area
   (migration/schema, permissions/UX, pipeline, search, UI, sync, … as fits),
   capturing every settled decision with its concrete specifics
3. Verify risky assumptions against rules/docs one final pass if the human asks
4. Ask the human to confirm

Only after confirmation does the next skill run — hand off verbatim: the
summary (plus the question/decision log) is the context input for
`/setup-tasks` or `/bootstrap-turboplan`. Every settled decision must land in
the INDEX header and the task stubs that follow — nothing assumed.

## Do not

- Run `/setup-tasks` or `/bootstrap-turboplan` before the human confirms the summary
- Ask the human questions a sub-agent could answer from the repo or docs
- Record a decision the human did not make or pick in the choice UI
- List lettered or numbered choices in chat for the human to type back
- Write phase stubs, plans, or product code
- End the session with unvisited branches — if the tree is large, say so and
  keep rounding

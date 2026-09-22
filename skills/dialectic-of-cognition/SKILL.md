---
name: dialectic-of-cognition
description: >-
  Capture session learnings into the hub's rules/ spokes using the Rule
  Maintenance procedure in the hub CLAUDE.md or AGENTS.md, and report drift in
  the repos' own docs instead of editing them. Manual; also run by
  /task-3-complete.
argument-hint: "[TXX or topic — default: this session]"
disable-model-invocation: true
model: opus
effort: high
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git *)
---

# /dialectic-of-cognition — Capture learnings into hub rules

Operational harness for **Rule Maintenance** in the hub `CLAUDE.md` and/or
`AGENTS.md`. That section is authoritative: triggers, abort gate, steps 0–7.

- Store: hub `rules/*.md` only (not a product repo's docs, and not Superplan's
  `.cursor/rules/*.mdc` unless you are building Superplan itself).
- A repo's own docs are never edited here — propose the change to the human.
- Size threshold: propose a split once a spoke passes ~550 lines.

Scope: $ARGUMENTS

Resolve the hub first — read `references/hub-resolution.md`. Walk up from cwd
for `superplan.yml`; otherwise ask for the hub path.
If the hub cannot be resolved, **stop and ask**. Do not write
`rules/` into a product repo.

## Mode A — Debugging learnings

- **A0 Triage.** Triggers: debugging >5 minutes; external docs consulted; more
  than one corrective attempt; non-obvious root cause. None →
  "Mode A: no debugging triggers — skipping."
- **A1 Extract.** The symptom, the root-cause *class*, the fix *pattern*.
- **A2 Abort gate.** Can you state it without naming a specific file, function,
  class, variable or endpoint? If not, stop.
- **A3 Route.** Hub Routing Map → spoke. If the learning is really a convention
  of one repo, draft the edit to that repo's own docs and hand it to the human.
- **A4 Encode.** Refine an overlapping entry before adding one. Format:
  `Symptom | Cause | Fix`, an `Evidence:` pointer (repo path or PR), and
  `<!-- last-verified: YYYY-MM -->`.

## Mode B — Code changes → rule impact

- **B0** Summarise what changed, per repo.
- **B1** Route to the affected spokes and read them.
- **B2** Is any entry now stale, incomplete or contradicted? Did the change make
  a touched repo's own docs stale? Report that drift to the human.
- **B3** Abort gate, then encode as in A4.

## Integrity

- Contradictions — encode the boundary condition, never overwrite silently; a
  repo's docs beat a spoke.
- Duplicates — merge into one entry.
- Decay — review entries older than six months in the domains touched.
- Size — check each spoke edited.

## Output

```
### Mode A
… / skipped
### Mode B
…
### Encodings
| Spoke | Entry | Added / Refined | Evidence |
### Proposed repo-doc edits
none / …
### Integrity
…
```

If nothing qualifies: **"Nothing to capture — session was routine."**

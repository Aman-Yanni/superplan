---
name: audit-rules
description: >-
  Read-only audit of the planning hub against the bound repos: repo context
  sources and gates still match what the hub records, spokes still hold, the
  hub structure, skills inventory and INDEX are consistent. Flags findings;
  never edits. Manual only.
argument-hint: "[repo-name | hub — default: everything]"
disable-model-invocation: true
model: sonnet
effort: medium
allowed-tools: Read, Grep, Glob, Bash(git *), Agent
---

# /audit-rules — Audit the hub against the repos

Read-only. Flag findings; never fix or remove anything.

Scope: $ARGUMENTS

If `phases/INDEX.md` is missing in the current directory, say so and ask where
the planning hub is. Do not invent a hub.

## Constraints

1. Never edit anything, in the hub or in a repo.
2. Never judge whether a latent bug "still applies". Flag mechanical staleness,
   contradictions and gaps only.
3. A path that a `Planned` or `InProgress` task is about to create is
   `PENDING_SCAFFOLD`, not `BROKEN`.
4. Use one `Explore` subagent per bound repo for the repo-side checks, in
   parallel.

## Checks

### Repos

- Each Repos-table path exists and is a git repo.
- Each listed context source exists. Agent docs the table doesn't list
  (`CLAUDE.md`, `AGENTS.md`, `TESTING.md`, `.cursor/rules/*`,
  `.cursor/commands/*`, `.claude/`) → `GAP`.
- Every Verify-gate command still matches its gate source (CI workflow, hook,
  Makefile target, package script) → otherwise `BROKEN`.

### Hub against repo

- A spoke entry contradicting a repo's own docs → `CONTRADICTION` (the repo wins).
- A repo's docs contradicting that repo's own tooling → `GAP`, for the human.
- Spoke `Evidence:` paths still exist → otherwise `STALE`.
- `last-verified` older than six months → `STALE`.

### Hub structure

- Hub `CLAUDE.md` and/or `AGENTS.md` still contain the sections the hub claims
  (Repo rules come first, Repos, Karpathy Behavioral Guidelines, Routing Map,
  Delivery, Verify gates, Git & PR rails, Safety rails, Rule Maintenance 0–7,
  Skills) → otherwise `MISSING`.
- Routing Map ↔ `rules/*.md`.
- Hubs are **data-only**: pack skills must not live under the hub's
  `.claude/skills/` or `.cursor/skills/`. If they do → `GAP` (skills are
  global). The hub Skills table should name the global pack skills.
- `phases/INDEX.md` rows ↔ `phases/T*.md` files; Depends-on graph acyclic; at
  most one `InProgress`; no `Done` in the INDEX.

## Output

```
| Severity | Area | Finding | Location |
| -------- | ---- | ------- | -------- |
```

Severities: `BROKEN` · `PENDING_SCAFFOLD` · `STALE` · `MISSING` · `CONTRADICTION` · `GAP`.

End with counts per severity.

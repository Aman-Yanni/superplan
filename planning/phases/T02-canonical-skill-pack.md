# T02 — Canonical skill pack

**Status**: Pending
**Parent INDEX**: [INDEX.md](./INDEX.md)
**Depends-on**: T01
**Next**: T03
**Layer**: L1

## Description

Author the published pack under `skills/<name>/SKILL.md`: the ColonyX work-loop skills, generalized off ColonyX-specific repos, plus a stub `/superplan-init`. Dual frontmatter (portable spec + Claude `model`/`effort` + Cursor `disable-model-invocation`). No installer wiring yet.

## Status History

| Timestamp | Event | From | To | Details | User |
| --------- | ----- | ---- | -- | ------- | ---- |
| 2026-09-16 | created | — | Pending | stub seeded by bootstrap | |

## Requirements

- [ ] Pack skills: `grill-me`, `setup-tasks`, `task-1-plan`, `task-2-execute`, `task-3-complete`, `dialectic-of-cognition`, `audit-rules`, `bootstrap-turboplan` (hub retarget, ColonyX meaning), `superplan-init` (stub that says “T05 implements the UX”)
- [ ] Each `name:` matches its folder; no root `SKILL.md`
- [ ] Manual-only: `disable-model-invocation: true`
- [ ] Generalized: repo-rules-first, multi-repo, never merge by default — not Django/Remix specifics
- [ ] pack-check green for every skill dir

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Source of behavior: `/Users/aman/projects/Claude Plans/ColonyX/.claude/skills/`
- Do not copy ColonyX `rules/backend.md` etc. into Superplan
- `.cursor/skills/` stays the Superplan **build** loop; do not replace it with the pack
- Spec: https://agentskills.io/specification
- T01: `scripts/pack-check.sh` is live; empty pack is OK; each new `skills/<name>/` needs `SKILL.md`. Keep `skills/.gitkeep`. Do not add a root `SKILL.md`.

## Execution plan (filled by /task-1-plan)

**Date:**
**Codebase snapshot:**
**Execute model:** small/default | large (only if justified)

### Context for executor
- …

### Steps
1. … → verify: …

### Tests to add
- …

### Verify commands
- …

### Risks / pitfalls
- …

### Out of scope
- …

### Execute model recommendation
- default (small/cheap) | large — rationale: …

## Test Plan

- `scripts/pack-check.sh` lists every expected skill; frontmatter `name` equals folder
- Commands: `make verify`
- New code: pack-check cases for missing SKILL.md / name mismatch

## Acceptance Criteria

- [ ] All listed pack skills exist with valid frontmatter
- [ ] No root `SKILL.md`
- [ ] Tests added/updated for new behavior
- [ ] Full lint + test verify suite green
- [ ] Verification commands recorded and passing
- [ ] No secrets committed
- [ ] ColonyX, humanize, and turboplan trees not vendored

## Verification

*(Filled by `/task-2-execute`; re-confirmed by `/task-3-complete`)*

## Files Modified

*(Filled by `/task-2-execute`)*

## Manual test (for humans)

*(Filled by `/task-3-complete`)*

## Learnings

*(Filled by `/task-3-complete` / dialectic)*

## Reality notes

*(Amended by upstream `/task-3-complete` if prior tasks changed assumptions)*

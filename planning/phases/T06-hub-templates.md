# T06 — Hub templates

**Status**: Pending
**Parent INDEX**: [INDEX.md](./INDEX.md)
**Depends-on**: T05
**Next**: T07
**Layer**: L5

## Description

Add data-only hub templates and have `/superplan-init` write them: `CLAUDE.md` / `AGENTS.md`, `rules/` (including `cross-repo.md` stub), `phases/INDEX.md`, `templates/`, Claude `.claude/settings.json` `additionalDirectories` from bound repos, Cursor notes for adding folders to the workspace. No skill copies inside the hub.

## Status History

| Timestamp | Event | From | To | Details | User |
| --------- | ----- | ---- | -- | ------- | ---- |
| 2026-09-16 | created | — | Pending | stub seeded by bootstrap | |

## Requirements

- [ ] Templates live in this repo under `templates/hub/`
- [ ] Generated hub has no `.claude/skills/` or `.cursor/skills/` pack copies
- [ ] Repos table + verify-gates section are filled from what init discovered (or “none established”)
- [ ] Repo-rules-first wording matches ColonyX hub `CLAUDE.md` (generalized)
- [ ] Refreshing an existing hub does not wipe user `rules/` entries

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Shape: `/Users/aman/projects/Claude Plans/ColonyX/CLAUDE.md` and `templates/`
- Cursor has no `additionalDirectories`; document adding product repos to the workspace / using absolute paths
- Spoke: `planning-hub.mdc`, `claude-code.mdc`

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

- Init into a temp workspace; assert files exist and skills dirs are absent; additionalDirectories matches bound paths
- Commands: `make verify`
- New code: tests required

## Acceptance Criteria

- [ ] Data-only hub written from templates
- [ ] No pack skills copied into the hub
- [ ] Tests added/updated for new behavior
- [ ] Full lint + test verify suite green
- [ ] Verification commands recorded and passing
- [ ] No secrets committed

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

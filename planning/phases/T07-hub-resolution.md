# T07 — Hub resolution

**Status**: Pending
**Parent INDEX**: [INDEX.md](./INDEX.md)
**Depends-on**: T06
**Next**: T08
**Layer**: L6

## Description

Teach every published work-loop skill to resolve the planning hub from saved config (workspace + project), then the bound repos from `superplan.yml`, instead of assuming cwd is the hub. Encode repo-rules-first, conflict reporting, and never-merge-unless-opted-in in those skills.

## Status History

| Timestamp | Event | From | To | Details | User |
| --------- | ----- | ---- | -- | ------- | ---- |
| 2026-09-16 | created | — | Pending | stub seeded by bootstrap | |

## Requirements

- [ ] Shared resolution steps (or `references/hub-resolution.md`) used by grill/setup/plan/execute/complete/audit/bootstrap
- [ ] If cwd is a bound product repo, still write phases/rules only in the hub
- [ ] If hub or workspace is missing, ask — do not guess
- [ ] `/task-3-complete` (pack): one PR per bound repo when git remotes exist; **never merge** unless hub `merge_prs: true` or the user said so; no remote invented
- [ ] On rule conflict: follow the repo, tell the human, ask if a decision is needed

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- ColonyX skills assumed the hub **was** cwd. That is the bug this task removes.
- Spoke: `.cursor/rules/planning-hub.mdc`

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

- Fixture: cwd = fake product repo, hub elsewhere; resolution returns the hub path
- Commands: `make verify`
- New code: tests required for the resolver if it is a script; otherwise pack-check + documented skill steps

## Acceptance Criteria

- [ ] Pack skills resolve hub from config, not cwd
- [ ] Merge default is false with opt-in documented
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

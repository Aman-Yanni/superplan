# T05 — /superplan-init

**Status**: Pending
**Parent INDEX**: [INDEX.md](./INDEX.md)
**Depends-on**: T04
**Next**: T06
**Layer**: L4

## Description

Implement `/superplan-init` in the published pack: ask for the **planning workspace** path first (save as default), then select or create the project hub folder, then discover/select product repos from cwd or a work-folder path. Do not write hub file bodies yet (T06); this task is the questions, defaults, and config writes.

## Status History

| Timestamp | Event | From | To | Details | User |
| --------- | ----- | ---- | -- | ------- | ---- |
| 2026-09-16 | created | — | Pending | stub seeded by bootstrap | |

## Requirements

- [ ] Step 1: planning workspace path (create if missing after confirm); persist default (target `~/.superplan/config.yml`)
- [ ] Step 2: list existing folders; reuse if present (e.g. `ColonyX/`); else suggest a name, accept a user name, or accept a path they created
- [ ] Step 3: search current folder **or** a work-folder path for project dirs; user multi-selects; or accept explicit paths
- [ ] Write/update hub `superplan.yml` with selected repo paths and `merge_prs: false`
- [ ] Tests use temp dirs, not the user’s real Claude Plans folder

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Spoke: `.cursor/rules/planning-hub.mdc`
- Example workspace: `/Users/aman/projects/Claude Plans`
- First live test is a **dummy** project (T08), not ColonyX
- Skill must not treat cwd as the hub

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

- Fixture: empty workspace → creates suggested folder; existing folder → reuse; repo picker from a fake work tree
- Commands: `make verify`
- New code: tests required

## Acceptance Criteria

- [ ] Init sequence matches the three steps above
- [ ] Default merge is false; default workspace is saved
- [ ] Tests added/updated for new behavior
- [ ] Full lint + test verify suite green
- [ ] Verification commands recorded and passing
- [ ] No secrets committed
- [ ] Does not bind or modify ColonyX in this task

## Verification

*(Filled by `/task-2-execute`; re-confirmed by `/task-3-complete`)*

## Files Modified

*(Filled by `/task-2-execute`)*

## Manual test (for humans)

*(Filled by `/task-3-complete`)*

## Learnings

*(Filled by `/task-3-complete` / dialectic)*

## Reality notes

T02 shipped `skills/superplan-init/SKILL.md` as a stub that explains the three-step sequence and says T05 implements it. Replace that stub; do not keep the “stop after explaining T05” body.

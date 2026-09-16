# T08 — E2E dummy project

**Status**: Pending
**Parent INDEX**: [INDEX.md](./INDEX.md)
**Depends-on**: T07
**Next**: —
**Layer**: L7

## Description

Prove the whole loop on a **dummy** project (not ColonyX): live-install the pack for Claude Code and Cursor (symlink), init a hub under a temp or user-chosen planning workspace, bind a dummy git repo, confirm skills appear in both agents and the hub is data-only. Requires explicit human OK before writing into real `~/.claude/skills` / `~/.cursor/skills`.

## Status History

| Timestamp | Event | From | To | Details | User |
| --------- | ----- | ---- | -- | ------- | ---- |
| 2026-09-16 | created | — | Pending | stub seeded by bootstrap | |

## Requirements

- [ ] Ask before live-install; default dummy workspace can be `tmp/` or a path the human gives
- [ ] `./install.sh all` then `test -f ~/.cursor/skills/grill-me/SKILL.md` and Claude equivalent (or report what blocked)
- [ ] `/superplan-init` creates `<workspace>/DummySuperplan/` (name negotiable) with no skill copies
- [ ] Bind at least one dummy git repo; hub `additionalDirectories` / `superplan.yml` lists it
- [ ] Manual test section: how to invoke `/grill-me` in Claude and in Cursor from the hub

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Human chose dummy, not ColonyX, as the first bind
- If live-install is declined, record Blocked vs a documented dry-run — do not silently skip
- Uninstall notes: how to remove the dummy hub and the symlinks

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

- Automated: keep using fake HOME. Live: human-gated checklist above
- Commands: `make verify` plus the live checklist
- New code: tests required only if new scripts appear

## Acceptance Criteria

- [ ] `make verify` still green
- [ ] Live checklist completed or explicitly declined with reason
- [ ] Dummy hub is data-only
- [ ] Tests added/updated for new behavior (if any)
- [ ] Full lint + test verify suite green
- [ ] Verification commands recorded and passing
- [ ] No secrets committed
- [ ] ColonyX tree unmodified

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

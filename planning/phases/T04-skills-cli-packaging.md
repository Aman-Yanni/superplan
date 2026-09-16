# T04 — skills.sh packaging

**Status**: Pending
**Parent INDEX**: [INDEX.md](./INDEX.md)
**Depends-on**: T03
**Next**: T05
**Layer**: L3

## Description

Make the repo something `npx skills add <path-or-owner/repo> -g -a claude-code -a cursor` can install: pack layout already under `skills/`, README install section, and a documented verify that both global dests exist. Do **not** publish to the registry or create a GitHub remote.

## Status History

| Timestamp | Event | From | To | Details | User |
| --------- | ----- | ---- | -- | ------- | ---- |
| 2026-09-16 | created | — | Pending | stub seeded by bootstrap | |

## Requirements

- [ ] `npx skills add . -l` (or equivalent local add `--list`) sees every pack skill
- [ ] README documents: `./install.sh` (no Node) **and** `npx skills add … -g -a claude-code -a cursor`
- [ ] Warn that Cursor global dest must be `~/.cursor/skills` (historical CLI bugs)
- [ ] No registry publish, no `git remote add`

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Docs: https://github.com/vercel-labs/skills
- `--full-depth` if a root SKILL.md would hide the pack — we must not have a root SKILL.md
- Local `npx skills add` against this clone with a fake or documented dest if the CLI allows; otherwise list-only plus README

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

- `npx skills add <repo> -l` lists the pack; README commands are accurate
- Commands: `make verify`; `npx skills add . -l` (or the CLI’s local equivalent)
- New code: tests required if we add a check script

## Acceptance Criteria

- [ ] CLI can discover all pack skills
- [ ] README install section matches both paths
- [ ] Tests added/updated for new behavior
- [ ] Full lint + test verify suite green
- [ ] Verification commands recorded and passing
- [ ] No secrets committed
- [ ] No GitHub remote created; not published to skills.sh

## Verification

*(Filled by `/task-2-execute`; re-confirmed by `/task-3-complete`)*

## Files Modified

*(Filled by `/task-2-execute`)*

## Manual test (for humans)

*(Filled by `/task-3-complete`)*

## Learnings

*(Filled by `/task-3-complete` / dialectic)*

## Reality notes

T03 shipped `./install.sh` (symlink default, `--copy`, claude/cursor/all, interactive). Tests use a fake HOME and snapshot the real skill dirs. T04 must not replace `install.sh`; document `npx skills add` as an additional path. Do not create a GitHub remote or publish to the registry. Pack is nine skills under `skills/` with no root `SKILL.md`.

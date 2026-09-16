# T03 — install.sh

**Status**: Pending
**Parent INDEX**: [INDEX.md](./INDEX.md)
**Depends-on**: T02
**Next**: T04
**Layer**: L2

## Description

Implement `install.sh` in the humanize style: pick agents (claude, cursor, all, or interactive), default **symlink** from `skills/` into `~/.claude/skills` and `~/.cursor/skills`, `--copy` opt-in. Tests use a fake HOME only.

## Status History

| Timestamp | Event | From | To | Details | User |
| --------- | ----- | ---- | -- | ------- | ---- |
| 2026-09-16 | created | — | Pending | stub seeded by bootstrap | |

## Requirements

- [ ] No-args (or explicit interactive) walkthrough to select agents
- [ ] Targets: `claude`, `cursor`, `all`; `--copy`; `--help`
- [ ] Symlink default; each dest is `…/skills/<name>` → repo `skills/<name>`
- [ ] Do not `rm -rf` a dest that is not a Superplan symlink/copy — stop and say so
- [ ] Works with no Node
- [ ] Tests never touch the real `$HOME`

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Reference: https://github.com/harshaneel/humanize/blob/main/install.sh
- Cursor dest: `~/.cursor/skills` (not `~/.cursor/skills-cursor`, not only `~/.agents/skills`)
- Claude dest: `~/.claude/skills` (symlinks are followed)
- Spoke: `.cursor/rules/install.mdc`
- T01: `install.sh` prints usage on `-h`/`--help` (exit 0) and exits 2 with `install is not implemented yet` otherwise. Replace that body; keep the usage text as the flag contract. `tests/run.sh` currently asserts exit 2 for no-args and `all` — update those cases when install works.

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

- Fake HOME: symlink both agents; `--copy`; refuse to clobber a foreign dir
- Commands: `make verify` plus `HOME=/tmp/... ./install.sh all`
- New code: tests required

## Acceptance Criteria

- [ ] Interactive + flag paths documented in `--help`
- [ ] Symlink and copy both tested under fake HOME
- [ ] Tests added/updated for new behavior
- [ ] Full lint + test verify suite green
- [ ] Verification commands recorded and passing
- [ ] No secrets committed
- [ ] Developer’s real skill dirs unchanged by `make test`

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

# T07 — Hub resolution

**Status**: Done
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
| 2026-09-16 | planned | Pending | Planned | /task-1-plan | |
| 2026-09-16 | execute | Planned | InProgress | /task-2-execute | |
| 2026-09-16 | complete | InProgress | Done | /task-3-complete | |

## Requirements

- [x] Shared resolution steps (or `references/hub-resolution.md`) used by grill/setup/plan/execute/complete/audit/bootstrap
- [x] If cwd is a bound product repo, still write phases/rules only in the hub
- [x] If hub or workspace is missing, ask — do not guess
- [x] `/task-3-complete` (pack): one PR per bound repo when git remotes exist; **never merge** unless hub `merge_prs: true` or the user said so; no remote invented
- [x] On rule conflict: follow the repo, tell the human, ask if a decision is needed

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Hub-local skills assumed the hub **was** cwd. That is the bug this task removes.
- Spoke: `.cursor/rules/planning-hub.mdc`

## Execution plan (filled by /task-1-plan)

**Date:** 2026-09-16
**Codebase snapshot:** T06 templates + init; config gained `hub:`.
**Execute model:** small

### Context for executor

Add `references/hub-resolution.md` to every work-loop pack skill. Replace cwd-as-hub INDEX guards. Persist `hub:` in config (done in init). Never merge unless `merge_prs: true`.

### Out of scope

T08 live install. Ask the human first.

### Execute model recommendation

- small

## Test Plan

- Identical `references/hub-resolution.md` in eight pack skills; config contains `hub:`
- Commands: `make verify`

## Acceptance Criteria

- [x] Pack skills resolve hub from config, not cwd
- [x] Merge default is false with opt-in documented
- [x] Tests added/updated for new behavior
- [x] Full lint + test verify suite green
- [x] Verification commands recorded and passing
- [x] No secrets committed

## Verification

`make verify` (2026-09-16): eight identical `hub-resolution.md` files; init writes `hub:`; pack-check 9 skills.

## Files Modified

- `skills/*/references/hub-resolution.md` (eight work-loop skills)
- `skills/*/SKILL.md` (resolution pointer; task-3-complete `merge_prs`)
- `skills/superplan-init/init.sh` (`hub:` in config)
- `tests/run.sh`
- `.cursor/rules/planning-hub.mdc`
- `planning/phases/T07-hub-resolution.md`
- `planning/phases/INDEX.md`
- `planning/phases/T08-e2e-dummy.md`

## Manual test (for humans)

Open `skills/grill-me/SKILL.md` and `skills/grill-me/references/hub-resolution.md`. Confirm the skill tells you to resolve `$HOME/.superplan/config.yml` `hub:` instead of cwd. Do **not** live-install (T08).

## Learnings

- Mode A: skipped.
- Mode B: each globally installed skill needs its own `references/` copy; config must record the hub path not only the workspace.

## Reality notes

Pack skills resolve the hub from config. **T08 is live install into real `~/.claude/skills` and `~/.cursor/skills` plus a dummy hub — ask before doing that.**

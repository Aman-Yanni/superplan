# T08 — E2E dummy project

**Status**: Done
**Parent INDEX**: [INDEX.md](./INDEX.md)
**Depends-on**: T07
**Next**: —
**Layer**: L7

## Description

Prove the whole loop on a **dummy** project (not an existing product hub): live-install the pack for Claude Code and Cursor (symlink), init a hub under a temp or user-chosen planning workspace, bind a dummy git repo, confirm skills appear in both agents and the hub is data-only. Requires explicit human OK before writing into real `~/.claude/skills` / `~/.cursor/skills`.

## Status History

| Timestamp | Event | From | To | Details | User |
| --------- | ----- | ---- | -- | ------- | ---- |
| 2026-09-16 | created | — | Pending | stub seeded by bootstrap | |
| 2026-09-16 | planned | Pending | Planned | /task-1-plan | |
| 2026-09-16 | execute | Planned | InProgress | /task-2-execute | |
| 2026-09-16 | complete | InProgress | Done | /task-3-complete | |

## Requirements

- [x] Ask before live-install; default dummy workspace can be `tmp/` or a path the human gives
- [x] `./install.sh all` then `test -f ~/.cursor/skills/grill-me/SKILL.md` and Claude equivalent (or report what blocked)
- [x] `/superplan-init` creates `<workspace>/DummySuperplan/` (name negotiable) with no skill copies
- [x] Bind at least one dummy git repo; hub `additionalDirectories` / `superplan.yml` lists it
- [x] Manual test section: how to invoke `/grill-me` in Claude and in Cursor from the hub

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Human chose dummy, not an existing product hub, as the first bind
- If live-install is declined, record Blocked vs a documented dry-run — do not silently skip
- Uninstall notes: how to remove the dummy hub and the symlinks

## Execution plan (filled by /task-1-plan)

**Date:** 2026-09-16
**Codebase snapshot:** branch `T08-e2e-dummy`. Human OK for live `./install.sh all` only. No `npx`, no git remote. `~/.claude/skills` is only `humanize`. `~/.cursor/skills` absent.
**Execute model:** small

### Context for executor

Live-install with symlink `./install.sh all`. Init `DummySuperplan` under `$HOME/plans`, bind `<dummy-repo>`. Do not touch an existing product hub. Do not `npx`. Do not create a GitHub remote.

### Steps

1. Snapshot real skill dirs and existing hubs. → verify: unrelated skills untouched; existing hubs exist
2. `git init` dummy repo outside this git tree. → verify: `.git` exists
3. `./install.sh all` with real HOME. → verify: both `grill-me/SKILL.md`; readlink into this pack; humanize remains
4. Run `init.sh` for DummySuperplan + dummy repo. → verify: data-only hub; config.yml; other hub folders unchanged
5. `make verify`. README uninstall notes. → verify: `make verify` 0

### Tests to add

None against real HOME.

### Out of scope

`npx skills add -g`. GitHub remote. bind an existing product hub.

### Execute model recommendation

- small

## Test Plan

- Automated: keep using fake HOME. Live: human-gated checklist above
- Commands: `make verify` plus the live checklist
- New code: tests required only if new scripts appear

## Acceptance Criteria

- [x] `make verify` still green
- [x] Live checklist completed or explicitly declined with reason
- [x] Dummy hub is data-only
- [x] Tests added/updated for new behavior (if any)
- [x] Full lint + test verify suite green
- [x] Verification commands recorded and passing
- [x] No secrets committed
- [x] existing product hubs unmodified

## Verification

Live (2026-09-16), human OK for `./install.sh all` only (no `npx`, no git remote):

```text
./install.sh all
test -f ~/.claude/skills/grill-me/SKILL.md   # symlink → …/superplan/skills/grill-me
test -f ~/.cursor/skills/grill-me/SKILL.md
test -e ~/.claude/skills/humanize            # still present
init.sh --workspace "$HOME/plans" --hub DummySuperplan \
  --repo <dummy-repo>
make verify
```

Hub is data-only (no `.claude/skills`). Other workspace folders remain beside DummySuperplan. `~/.superplan/config.yml` points at that hub.

## Files Modified

- `README.md` (status + uninstall)
- `.cursor/rules/install.mdc` (live install / uninstall)
- `planning/phases/T08-e2e-dummy.md`
- `planning/phases/INDEX.md`

Outside this repo (not committed): `<dummy-repo>`, `$HOME/plans/DummySuperplan`, `~/.superplan/config.yml`, skill symlinks.

## Manual test (for humans)

Restart **Cursor** and **Claude Code** so they reload personal skills.

1. Confirm dests:
   `ls -l ~/.cursor/skills/grill-me ~/.claude/skills/grill-me ~/.claude/skills/humanize`
2. In Cursor: **File → Open Folder** on `$HOME/plans/DummySuperplan`. **Add Folder to Workspace** for `<dummy-repo>`. Type `/grill-me` in chat. Success: the skill runs (it should ask where the hub is only if config is missing — config is already `~/.superplan/config.yml`).
3. Same `/grill-me` in a Claude Code session started from the DummySuperplan folder.

Uninstall: see README **Uninstall**. Do not delete `humanize`. Do not delete unrelated hubs.

## Learnings

- Mode A: skipped.
- Mode B: live install is symlink into real `$HOME`; preflight left `humanize` alone; uninstall is rm of Superplan dests only.

## Reality notes

T08 live-installed with `./install.sh all`. Dummy hub: `$HOME/plans/DummySuperplan`. Dummy repo: `<dummy-repo>`. No GitHub remote. `npx skills add -g` not used.

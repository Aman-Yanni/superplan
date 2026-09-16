# T06 — Hub templates

**Status**: Done
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
| 2026-09-16 | planned | Pending | Planned | /task-1-plan | |
| 2026-09-16 | execute | Planned | InProgress | /task-2-execute | |
| 2026-09-16 | complete | InProgress | Done | /task-3-complete | |

## Requirements

- [x] Templates live in this repo under `templates/hub/`
- [x] Generated hub has no `.claude/skills/` or `.cursor/skills/` pack copies
- [x] Repos table + verify-gates section are filled from what init discovered (or “none established”)
- [x] Repo-rules-first wording matches ColonyX hub `CLAUDE.md` (generalized)
- [x] Refreshing an existing hub does not wipe user `rules/` entries

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Shape: `/Users/aman/projects/Claude Plans/ColonyX/CLAUDE.md` and `templates/`
- Cursor has no `additionalDirectories`; document adding product repos to the workspace / using absolute paths
- Spoke: `planning-hub.mdc`, `claude-code.mdc`

## Execution plan (filled by /task-1-plan)

**Date:** 2026-09-16
**Codebase snapshot:** T05 (`c11f7be`) on `T06-hub-templates`. Init writes config only. `templates/hub/` missing.
**Execute model:** small

### Context for executor

Add `templates/hub/` (generalized ColonyX hub, no skill copies). Extend `init.sh` to write them. Refresh must not delete existing `rules/*.md`. Gates default to “none established”. Cursor note in `CURSOR.md`.

### Steps

1. Author templates under `templates/hub/`. → verify: files exist
2. `init.sh` copies/generates into the hub. → verify: tests
3. Update T05 “no templates” assertion. → verify: `make verify`

### Out of scope

T07 hub resolution. T08 live install. ColonyX bind.

### Execute model recommendation

- small

## Test Plan

- Init into a temp workspace; assert files exist and skills dirs are absent; additionalDirectories matches bound paths
- Commands: `make verify`
- New code: tests required

## Acceptance Criteria

- [x] Data-only hub written from templates
- [x] No pack skills copied into the hub
- [x] Tests added/updated for new behavior
- [x] Full lint + test verify suite green
- [x] Verification commands recorded and passing
- [x] No secrets committed

## Verification

`make verify` (2026-09-16): init writes `CLAUDE.md` / `AGENTS.md` / `phases/INDEX.md` / `rules/cross-repo.md` / `.claude/settings.json`; no `.claude/skills` or `.cursor/skills`; refresh keeps `rules/keep.md`; repo path in additionalDirectories.

## Files Modified

- `templates/hub/**`
- `skills/superplan-init/init.sh`
- `skills/superplan-init/SKILL.md`
- `tests/run.sh`
- `planning/phases/T06-hub-templates.md`
- `planning/phases/INDEX.md`
- `README.md`
- `planning/phases/T07-hub-resolution.md`

## Manual test (for humans)

```bash
fake="$(mktemp -d)"
repo="$fake/app"
mkdir -p "$repo/.git"
HOME="$fake" ./skills/superplan-init/init.sh \
  --workspace "$fake/Plans" --create-workspace --hub Dummy --repo "$repo"
ls "$fake/Plans/Dummy"
test ! -e "$fake/Plans/Dummy/.claude/skills"
cat "$fake/Plans/Dummy/.claude/settings.json"
```

Success: data-only hub files present; settings list the repo; no skill copies.

## Learnings

- Mode A: skipped.
- Mode B: hub templates live in `templates/hub/`; refresh uses copy-if-missing for `rules/`; Claude `additionalDirectories` vs Cursor workspace folders.

## Reality notes

Init now writes hub bodies. T07 must stop treating cwd as the hub and resolve from `$HOME/.superplan/config.yml` + hub `superplan.yml`.

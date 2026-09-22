# T05 — /superplan-init

**Status**: Done
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
| 2026-09-16 | planned | Pending | Planned | /task-1-plan | |
| 2026-09-16 | execute | Planned | InProgress | /task-2-execute | |
| 2026-09-16 | complete | InProgress | Done | /task-3-complete | |

## Requirements

- [x] Step 1: planning workspace path (create if missing after confirm); persist default (target `~/.superplan/config.yml`)
- [x] Step 2: list existing folders; reuse if present (e.g. an existing folder); else suggest a name, accept a user name, or accept a path they created
- [x] Step 3: search current folder **or** a work-folder path for project dirs; user multi-selects; or accept explicit paths
- [x] Write/update hub `superplan.yml` with selected repo paths and `merge_prs: false`
- [x] Tests use temp dirs, not the user’s real planning workspace

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Spoke: `.cursor/rules/planning-hub.mdc`
- Example workspace: `$HOME/plans`
- First live test is a **dummy** project (T08), not an existing product hub
- Skill must not treat cwd as the hub

## Execution plan (filled by /task-1-plan)

**Date:** 2026-09-16
**Codebase snapshot:** branch `T05-superplan-init` at T04 (`4b753bc`). `skills/superplan-init/SKILL.md` is the T02 stub. No `~/.superplan`. T06 owns hub templates (`CLAUDE.md`, `phases/`).
**Execute model:** small

### Context for executor

Replace the stub with a real init: interview in the pack skill, file writes via a **pack-local** helper `skills/superplan-init/init.sh` so a global symlink install can still run it. Tests drive the helper with a fake `HOME` and temp dirs. Do not write `CLAUDE.md` / `phases/` / `rules/` (T06). Do not live-install. Do not touch an existing product hub.

Paths always `"$HOME/..."` never `~`.

### Helper `skills/superplan-init/init.sh`

Non-interactive. `set -euo pipefail`. `--help` exit 0.

| Flag | Meaning |
| ---- | ------- |
| `--workspace PATH` | planning workspace (required unless `--discover` or already in config) |
| `--create-workspace` | `mkdir -p` workspace if missing; without it, missing workspace → exit 1 |
| `--hub NAME_OR_PATH` | `NAME` → `$workspace/NAME`; path with `/` is used as-is |
| `--repo PATH` | repeatable; each must be an existing directory |
| `--discover PATH` | print candidate repo paths (PATH if it has `.git`, plus immediate child dirs with `.git`); no writes |

Writes (not on `--discover`):

1. `$HOME/.superplan/config.yml` with `planning_workspace: "<abs workspace>"`
2. `$hub/superplan.yml`: `merge_prs: false` and a `repos:` list of absolute paths (`repos: []` if none)
3. `mkdir -p` the hub folder

Do not write `CLAUDE.md`, `AGENTS.md`, `phases/`, `rules/`, or skill copies. Quote YAML strings (spaces in workspace paths). If `--workspace` omitted, read `planning_workspace` from existing config.

### Skill `SKILL.md`

Full three-step interview. Then run `init.sh` next to this SKILL.md. Example workspace `$HOME/plans`. Suggest a dummy name; do not default to an existing product folder. Say T06 writes hub templates. Hard constraints: no `install.sh`, no real skill-dir writes, no `phases/` into cwd, cwd is not the hub.

### Tests (fake HOME)

Snapshot real `$HOME/.superplan` like installer tests. Cases: create workspace+hub+one repo; reuse hub; missing workspace without `--create-workspace` fails; `--discover` lists git children; no `CLAUDE.md`/`phases`; real `~/.superplan` unchanged. Zero repos → `repos: []`.

### Makefile

Lint `skills/*/*.sh` as well as `tests/*.sh` `scripts/*.sh`.

### Steps

1. Write `init.sh` + chmod +x. → verify: `--help` exit 0; `--discover` on a temp tree
2. Rewrite `skills/superplan-init/SKILL.md`. → verify: no “T05 implements” stub; contains `init.sh` and `T06`
3. Tests in `tests/run.sh`. → verify: `./tests/run.sh`
4. Makefile lint glob. → verify: `make verify`

### Out of scope

Hub templates (T06). Config hub resolution in work-loop skills (T07). Live install (T08). `npx -g`.

### Execute model recommendation

- small — helper + skill rewrite + tests; flags and file shapes specified.

## Test Plan

- Fixture: empty workspace → creates suggested folder; existing folder → reuse; repo picker from a fake work tree
- Commands: `make verify`
- New code: tests required

## Acceptance Criteria

- [x] Init sequence matches the three steps above
- [x] Default merge is false; default workspace is saved
- [x] Tests added/updated for new behavior
- [x] Full lint + test verify suite green
- [x] Verification commands recorded and passing
- [x] No secrets committed
- [x] Does not bind or modify an existing product hub in this task

## Verification

Presence + `make verify` (2026-09-16):

```text
make verify   # lint (includes skills/superplan-init/init.sh) + init tests + pack-check 9
```

Init tests: `--help`; create workspace/hub/config; `merge_prs: false`; no `CLAUDE.md`/`phases`; reuse hub from saved workspace; missing workspace without `--create-workspace` fails; `--discover` git children; `repos: []`; real `~/.superplan` unchanged.

## Files Modified

- `skills/superplan-init/init.sh`
- `skills/superplan-init/SKILL.md`
- `tests/run.sh`
- `Makefile` (lint pack `*.sh`)
- `planning/phases/T05-superplan-init.md`
- `planning/phases/INDEX.md`
- `README.md` (status)
- `.cursor/rules/planning-hub.mdc` (pack-local helper; config-only writes)
- `.cursor/rules/shell.mdc` (lint `skills/*/*.sh`)
- `planning/phases/T06-hub-templates.md` (reality notes)

## Manual test (for humans)

Do **not** point this at an existing product hub or your real planning workspace.

```bash
fake="$(mktemp -d)"
ws="$fake/Plans"
repo="$fake/app"
mkdir -p "$repo/.git"
HOME="$fake" ./skills/superplan-init/init.sh \
  --workspace "$ws" --create-workspace --hub Dummy --repo "$repo"
cat "$fake/.superplan/config.yml"
cat "$ws/Dummy/superplan.yml"
./skills/superplan-init/init.sh --discover "$fake"
make verify
```

Success: config records the workspace; hub `superplan.yml` has `merge_prs: false` and the repo path; no `CLAUDE.md` yet; `make verify` exits 0.

## Learnings

- Mode A: skipped (no debugging triggers).
- Mode B: init helper lives next to the pack `SKILL.md` so a global symlink can run it; T05 writes config only; `"$HOME/.superplan"`.

## Reality notes

Init writes `$HOME/.superplan/config.yml` and `<hub>/superplan.yml` only. T06 must add templates without wiping `superplan.yml` or user `rules/` (rules/ does not exist yet until T06). First dummy hub name is not an existing product hub.

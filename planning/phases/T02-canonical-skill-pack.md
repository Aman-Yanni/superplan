# T02 — Canonical skill pack

**Status**: Done
**Parent INDEX**: [INDEX.md](./INDEX.md)
**Depends-on**: T01
**Next**: T03
**Layer**: L1

## Description

Author the published pack under `skills/<name>/SKILL.md`: the work-loop skills, generalized off any one product’s repos, plus a stub `/superplan-init`. Dual frontmatter (portable spec + Claude `model`/`effort` + Cursor `disable-model-invocation`). No installer wiring yet.

## Status History

| Timestamp | Event | From | To | Details | User |
| --------- | ----- | ---- | -- | ------- | ---- |
| 2026-09-16 | created | — | Pending | stub seeded by bootstrap | |
| 2026-09-16 | planned | Pending | Planned | /task-1-plan | |
| 2026-09-16 | execute | Planned | InProgress | /task-2-execute | |
| 2026-09-16 | complete | InProgress | Done | /task-3-complete | |

## Requirements

- [x] Pack skills: `grill-me`, `setup-tasks`, `task-1-plan`, `task-2-execute`, `task-3-complete`, `dialectic-of-cognition`, `audit-rules`, `bootstrap-turboplan` (hub retarget), `superplan-init` (stub that says “T05 implements the UX”)
- [x] Each `name:` matches its folder; no root `SKILL.md`
- [x] Manual-only: `disable-model-invocation: true`
- [x] Generalized: repo-rules-first, multi-repo, never merge by default — not a specific product stack
- [x] pack-check green for every skill dir

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Source of behavior: `<existing-product-hub>/.claude/skills/`
- Do not copy a product hub’s `rules/` into Superplan
- `.cursor/skills/` stays the Superplan **build** loop; do not replace it with the pack
- Spec: https://agentskills.io/specification
- T01: `scripts/pack-check.sh` is live; empty pack is OK; each new `skills/<name>/` needs `SKILL.md`. Keep `skills/.gitkeep`. Do not add a root `SKILL.md`.

## Execution plan (filled by /task-1-plan)

**Date:** 2026-09-16
**Codebase snapshot:** branch `T02-canonical-skill-pack`, `601527e` (T01). `skills/` contains only `.gitkeep`. Pack-check does not yet read frontmatter `name:`. `install.sh` still help-only (do not touch).
**Execute model:** medium

### Context for executor

Goal: write the **published** pack at `skills/<name>/SKILL.md` by rewriting the eight work-loop skills (generalized) plus a short `/superplan-init` stub. Extend pack-check so `name:` matches the folder. Do not install globally. Do not change `.cursor/skills/` (that is Superplan's **build** loop).

Source (read, do not copy the tree into git): `<existing-product-hub>/.claude/skills/<name>/SKILL.md`

Dest: `skills/<name>/SKILL.md`

| Pack skill | source skill | Notes |
| ---------- | -------------- | ----- |
| grill-me | …/grill-me/SKILL.md | keep procedure |
| setup-tasks | …/setup-tasks/SKILL.md | keep procedure |
| task-1-plan | …/task-1-plan/SKILL.md | keep procedure |
| task-2-execute | …/task-2-execute/SKILL.md | keep procedure |
| task-3-complete | …/task-3-complete/SKILL.md | never merge unless human opts in |
| dialectic-of-cognition | …/dialectic-of-cognition/SKILL.md | store = hub `rules/*.md` |
| audit-rules | …/audit-rules/SKILL.md | drop hardcoded backend/dashboard/deploy |
| bootstrap-turboplan | …/bootstrap-turboplan/SKILL.md | **hub retarget**, not Superplan's `.cursor` bootstrap |
| superplan-init | (new) | stub only; T05 owns the UX |

Invariants: `.cursor/rules/agent-skills.mdc`, `planning-hub.mdc`, `claude-code.mdc`. Keep `skills/.gitkeep`. No repo-root `SKILL.md`.

**These published skills target a planning hub** (like a data-only hub: `CLAUDE.md` / `AGENTS.md`, `phases/`, `rules/`). They are **not** Superplan-the-product's `.cursor/rules/general.mdc` loop.

**Leave cwd-as-hub** (T07 will add `~/.superplan/config.yml`). Add one guard in every skill that writes hub files: if `phases/INDEX.md` is missing in cwd, **stop and ask** — do not write `phases/` or `rules/` into a product repo.

### Shared substitution table (apply to all eight work-loop ports)

Keep section structure, hard constraints, and procedure. Rewrite only the product-specific bits:

| Source | Superplan pack |
| ------- | -------------- |
| Hub file is only `CLAUDE.md` | Hub is `CLAUDE.md` and/or `AGENTS.md` (read whichever exist; if neither, stop and ask) |
| `phases/INDEX.md`, `phases/TXX-*.md`, `templates/`, `rules/` | keep these hub-relative paths (not `planning/phases/` — that is this Superplan repo) |
| Named repos backend / dashboard / deploy | "each bound repo in the hub Repos table" (or equivalent list in hub CLAUDE.md/AGENTS.md) |
| `rules/backend.md` | `rules/<repo>.md` for that repo, plus `rules/cross-repo.md` when spanning repos |
| "Backend before dashboard" | follow the hub cross-repo spoke if present; else ask the human |
| `.cursor/commands/pr_review.md` | if that file (or `pr_review.md`) exists in the repo, use it; else skip and say so |
| `/code-review` | if the agent has it, run it; else skip and say so |
| `argument-hint` audit-rules `[backend \| dashboard \| deploy \| hub]` | `[repo-name \| hub — default: everything]` |
| Dialectic store `rules/*.md` | keep **hub** `rules/*.md` (not Superplan `.cursor/rules/*.mdc`) |
| bootstrap "Keep all eight" | keep every skill under the **global pack**; hubs stay data-only (no skill copies) |
| merge | never merge unless the human opts in (no `merge_prs` file yet — T06) |
| `model` / `effort` / `argument-hint` / `disable-model-invocation: true` | **keep** the source values |
| `allowed-tools` | **keep** the source lists (Cursor ignores unknown tool names) |

Do **not** paste product-stack paths (frameworks, package managers, docker test targets) (they are not in the skill files anyway). Do **not** vendor another project’s hub.

Frontmatter required on every pack `SKILL.md`:

```yaml
---
name: <folder-name>
description: >-
  <what + when; third person; include the slash name>
disable-model-invocation: true
model: <opus|sonnet as in the source skill>
effort: <high|medium as in the source skill>
# argument-hint and allowed-tools: copy from the source skill when present
---
```

`name:` must equal the parent folder (hyphens, no quotes needed).

### Steps

1. Do not edit `.cursor/skills/`, `install.sh`, or `Makefile` unless pack-check/tests require a one-line fix. → verify: `git diff --name-only` would not list `.cursor/skills` or `install.sh`

2. Extend `scripts/pack-check.sh`:
   - After confirming `SKILL.md` exists, extract `name:` from the **YAML frontmatter only** (text between the first two `---` lines). Strip optional quotes.
   - Folder basename must equal that `name`. On mismatch, stderr `pack-check: name 'X' != folder 'Y'` and count as failure.
   - If frontmatter has no `name:`, fail.
   - Still ignore files like `.gitkeep`; still allow **zero** subdirs (empty pack) for fixtures.
   - Still fail on repo-root `$ROOT/SKILL.md`.
   - Print `pack-check: N skill(s)` as today.
   → verify: empty tmp dir exit 0; dir `foo/` without SKILL.md non-zero; `foo/SKILL.md` with `name: foo` exit 0; `name: bar` in folder `foo` non-zero

3. Update `tests/run.sh`:
   - Change the existing "good" fixture (today `# stub` only) to a minimal frontmatter `name: foo` plus a description — otherwise step 2 breaks T01's test.
   - Add: mismatch fixture (`name: bar` in folder `foo`) → non-zero.
   - Add: repo pack has exactly these 9 dirs: `grill-me` `setup-tasks` `task-1-plan` `task-2-execute` `task-3-complete` `dialectic-of-cognition` `audit-rules` `bootstrap-turboplan` `superplan-init`. Fail if extras (except we still have `.gitkeep` as a file, not a dir).
   - Keep fake-HOME installer tests unchanged.
   → verify: `./tests/run.sh` fails until skills exist, then passes after step 5

4. For each of the eight work-loop skills: read the source end-to-end, write `skills/<name>/SKILL.md` applying the substitution table. Keep headings. Stay under ~500 lines (source files are 70–122 lines). Insert the `phases/INDEX.md` missing-in-cwd guard in skills that **write** hub files (`setup-tasks`, `task-1-plan`, `task-2-execute`, `task-3-complete`, `dialectic-of-cognition`, `bootstrap-turboplan`). Grill-me and audit-rules only read: if INDEX missing, say so and ask; do not invent a hub. → verify: `test -f skills/<name>/SKILL.md` for all eight; `grep -l 'Django\|Remix\|pnpm\|product-dashboard' skills/*/SKILL.md` is empty

5. Write `skills/superplan-init/SKILL.md` stub (~40 lines, not a full init):
   - Frontmatter: `name: superplan-init`, `disable-model-invocation: true`, `model: opus`, `effort: high`, description that mentions planning workspace, project folder, product repos, and "use when the user wants to init Superplan / bind a hub".
   - Body hard constraints: **do not create folders, config, or hub files in T02**. Tell the human the intended sequence (workspace path → existing/create project folder → select product repos) and that **T05 implements it**. Stop after that explanation. Do not call `install.sh`.
   → verify: file exists; `name:` is `superplan-init`; body contains `T05` and does not contain `mkdir`

6. `scripts/pack-check.sh` (no args) against repo `skills/` → 9 skills, exit 0. No root `SKILL.md`. → verify: `make build`

7. `make lint && make test && make verify`. Fix shellcheck in pack-check/tests. → verify: `make verify` exits 0

8. Confirm `.cursor/skills/*/SKILL.md` still the original eight build-loop files (timestamps/content not replaced with hub-pack text). Confirm `~/.claude/skills` and `~/.cursor/skills` untouched. → verify: `grep -l 'phases/INDEX.md' .cursor/skills/task-1-plan/SKILL.md` is fine if it already mentioned planning/phases — do **not** rewrite those files. `test ! -e ~/.cursor/skills`

### Tests to add

- pack-check: frontmatter `name:` must match folder (mismatch fails; missing `name:` fails)
- pack-check: good fixture must include `name: foo` in frontmatter
- repo: 9 expected skill directories, pack-check 0
- existing installer fake-HOME cases still pass

### Verify commands

```bash
test -f Makefile && grep -q '^verify' Makefile
test -f lefthook.yml
test -f .shellcheckrc
test ! -f SKILL.md
ls skills/*/SKILL.md
./scripts/pack-check.sh
make lint
make test
make verify
```

### Risks / pitfalls

- **Wrong skill tree:** editing `.cursor/skills/` instead of `skills/` — never do that
- **Wrong hub paths:** using `planning/phases/` in the **pack** (that is Superplan-the-product). Pack hubs use `phases/` like a data-only hub
- Copying source-hub files with `cp -R` into git is vendoring — rewrite
- Leaving the T01 "good" fixture as `# stub` will fail once name-check lands — update tests in the same change as pack-check
- `awk` on `name:` must ignore `name:` in the markdown body (frontmatter only)
- T07 owns config-based hub resolution — do not invent `~/.superplan/config.yml` here
- T03 owns install — do not symlink into real home
- bootstrap-turboplan in the pack **retargets a planning hub**, unlike `.cursor/skills/bootstrap-turboplan` which bootstraps this Superplan repo

### Out of scope

- `install.sh` implementation (T03)
- `npx skills add` (T04)
- Real `/superplan-init` UX, `~/.superplan/config.yml`, hub templates (T05–T06)
- Hub resolution from saved config (T07)
- Live global install / dummy project (T08)
- Product-repo stack rules
- Rewriting Superplan `.cursor/skills/` or `.cursor/rules/` except if a spoke must mention the new pack layout (prefer not; T03-complete dialectic can)

### Execute model recommendation

- medium — nine markdown skills plus a small pack-check change; substitution table is complete, so a lesser model can follow without redesign. Not large.

## Test Plan

- `scripts/pack-check.sh` lists every expected skill; frontmatter `name` equals folder
- Commands: `make verify`
- New code: pack-check cases for missing SKILL.md / name mismatch

## Acceptance Criteria

- [x] All listed pack skills exist with valid frontmatter
- [x] No root `SKILL.md`
- [x] Tests added/updated for new behavior
- [x] Full lint + test verify suite green
- [x] Verification commands recorded and passing
- [x] No secrets committed
- [x] humanize and turboplan trees not vendored

## Verification

Presence check + `make verify` (2026-09-16 execute and `/task-3-complete` re-run):

```text
test -f Makefile && grep -q '^verify' Makefile   # ok
test -f lefthook.yml                             # ok
test -f .shellcheckrc                            # ok
test ! -f SKILL.md                               # ok
ls skills/*/SKILL.md                             # 9 files
./scripts/pack-check.sh                          # pack-check: 9 skill(s)
make verify                                      # lint + 12 tests + pack-check 9 skill(s)
```

`make verify` tests: install.sh `--help`/`-h`/no-args/`all` (still T01 exit 2), fake HOME not written, pack-check empty/missing SKILL.md/`name: foo` good/mismatch/missing name, repo 9 skill(s), exactly 9 pack dirs.

`.cursor/skills/` and `install.sh` not in the T02 diff. `~/.cursor/skills` absent.

## Files Modified

- `scripts/pack-check.sh` (frontmatter `name:` must match folder)
- `tests/run.sh` (name-check fixtures + 9-dir assertion)
- `skills/grill-me/SKILL.md`
- `skills/setup-tasks/SKILL.md`
- `skills/task-1-plan/SKILL.md`
- `skills/task-2-execute/SKILL.md`
- `skills/task-3-complete/SKILL.md`
- `skills/dialectic-of-cognition/SKILL.md`
- `skills/audit-rules/SKILL.md`
- `skills/bootstrap-turboplan/SKILL.md`
- `skills/superplan-init/SKILL.md`
- `planning/phases/T02-canonical-skill-pack.md`
- `planning/phases/INDEX.md`
- `README.md` (status: nine pack skills)
- `.cursor/rules/agent-skills.mdc` (dialectic: pack-check frontmatter; validator+fixtures)
- `.cursor/rules/planning-hub.mdc` (dialectic: missing INDEX abort until T07)
- `planning/phases/T03-install-sh.md` (reality notes)
- `planning/phases/T05-superplan-init.md` (reality notes)
- `planning/phases/T07-hub-resolution.md` (reality notes)

## Manual test (for humans)

From the Superplan repo:

```bash
./scripts/pack-check.sh
ls skills/*/SKILL.md
make verify
```

Success: `pack-check: 9 skill(s)`, nine `SKILL.md` files under `skills/`, `make verify` exits 0.

Open any pack skill (e.g. `skills/grill-me/SKILL.md`) and confirm it talks about a planning hub (`CLAUDE.md`/`AGENTS.md`, `phases/`) — not Superplan's `.cursor/skills/` build loop, and not a specific product stack.

Do **not** expect `/grill-me` in Claude or Cursor yet (install is T03). Do **not** run `./install.sh` against your real home.

## Learnings

- Mode A: skipped (no debugging triggers).
- Mode B: pack-check must read `name:` from YAML frontmatter only; validator and fixtures land together; write-hub pack skills abort if cwd lacks `phases/INDEX.md` until T07 config resolution.

## Reality notes

Pack is nine skills under `skills/`. `install.sh` is still help-only. Pack skills still treat cwd as the hub, with a missing-`phases/INDEX.md` abort. T07 replaces that with config resolution.

# T04 — skills.sh packaging

**Status**: Done
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
| 2026-09-16 | planned | Pending | Planned | /task-1-plan | |
| 2026-09-16 | execute | Planned | InProgress | /task-2-execute | |
| 2026-09-16 | complete | InProgress | Done | /task-3-complete | |

## Requirements

- [x] `npx skills add . -l` (or equivalent local add `--list`) sees every pack skill
- [x] README documents: `./install.sh` (no Node) **and** `npx skills add … -g -a claude-code -a cursor`
- [x] Warn that Cursor global dest must be `~/.cursor/skills` (historical CLI bugs)
- [x] No registry publish, no `git remote add`

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Docs: https://github.com/vercel-labs/skills
- `--full-depth` if a root SKILL.md would hide the pack — we must not have a root SKILL.md
- Local `npx skills add` against this clone with a fake or documented dest if the CLI allows; otherwise list-only plus README

## Execution plan (filled by /task-1-plan)

**Date:** 2026-09-16
**Codebase snapshot:** branch `T04-skills-cli-packaging` at T03 (`d45a266`). Pack is nine `skills/<name>/SKILL.md`, no root `SKILL.md`. `install.sh` is live (fake HOME). No git remote. `npx skills add . --list` already discovered all 9 (execute may re-run).
**Execute model:** small

### Context for executor

Make this clone something the skills CLI can **list** as a local pack, and document both install paths in README. Do **not** run `npx skills add` without `--list` (that would live-install). Do not `git remote add`. Do not publish. Do not change `install.sh` behavior.

Docs consulted: https://vercel-labs-skills.mintlify.app/commands/add — local source is `.` / `./` / absolute; `--list` lists without installing; `-g` + `-a claude-code -a cursor` is the shipped install; `--full-depth` only if a root `SKILL.md` exists (we must not have one).

### Steps

1. Add README **Install** section (and TOC link). Include:
   - `./install.sh` / `./install.sh all` / `./install.sh --copy` (no Node; dests `$HOME/.claude/skills` and `$HOME/.cursor/skills`)
   - Safe discovery: `npx skills add . --list`
   - Shipped-shape command (do not run in this task): `npx skills add . -g -a claude-code -a cursor`
   - Explicit warning: after any `-g` install, `test -f ~/.cursor/skills/grill-me/SKILL.md` — CLI has historically landed in `~/.agents/skills` only. Never `~/.cursor/skills-cursor`.
   - No GitHub remote yet, so do not document `owner/superplan` as a working shorthand. No registry publish.
   - Live install into the real home is T08; listing and fake-HOME `./install.sh` are safe now.
   → verify: `grep -n 'npx skills add' README.md` and `grep -n './install.sh' README.md`

2. Do not add `npx` to `make verify` (needs network). Keep pack-check as the offline discovery proof. Add `tests/run.sh` greps that README contains: `./install.sh`, `npx skills add`, `--list`, `-g`, `-a claude-code`, `-a cursor`, `~/.cursor/skills`. → verify: `./tests/run.sh`

3. Re-run `DISABLE_TELEMETRY=1 npx --yes skills add . --list` during execute (network) and record that it prints all nine names. Confirm real `~/.claude/skills` / `~/.cursor/skills` unchanged and no `skills-lock.json` / root `SKILL.md` / git remote appeared. → verify: list output has all nine; `git remote` empty

4. `make verify`. Touch `.cursor/rules/skills-cli.mdc` only if dialectic/complete needs it (prefer T04-complete). → verify: `make verify` exits 0

### Tests to add

- README install strings listed in step 2
- Existing installer + pack-check cases still pass
- Do not call `npx` from `tests/run.sh` (network)

### Verify commands

```bash
test -f Makefile && grep -q '^verify' Makefile
test -f lefthook.yml
test -f .shellcheckrc
test ! -f SKILL.md
npx --yes skills add . --list    # execute/complete only; not make verify
make verify
git remote
```

### Risks / pitfalls

- Running `npx skills add .` **without** `--list` installs into the real agent dirs
- `npx` in the default verify gate makes pre-commit need network — don't
- Documenting `owner/superplan` implies a remote we must not create
- Root `SKILL.md` would hide the pack unless `--full-depth`

### Out of scope

- Live `-g` install (T08 — ask first)
- GitHub remote, registry publish
- Changing `install.sh`
- `/superplan-init` UX (T05)

### Execute model recommendation

- small — README + grep tests; CLI layout already works. Not large.

## Test Plan

- `npx skills add <repo> -l` lists the pack; README commands are accurate
- Commands: `make verify`; `npx skills add . -l` (or the CLI’s local equivalent)
- New code: tests required if we add a check script

## Acceptance Criteria

- [x] CLI can discover all pack skills
- [x] README install section matches both paths
- [x] Tests added/updated for new behavior
- [x] Full lint + test verify suite green
- [x] Verification commands recorded and passing
- [x] No secrets committed
- [x] No GitHub remote created; not published to skills.sh

## Verification

Presence + `make verify` (2026-09-16). CLI discovery (not in the default gate):

```text
DISABLE_TELEMETRY=1 npx --yes skills add . --list
# Found 9 skills: audit-rules bootstrap-turboplan dialectic-of-cognition
# grill-me setup-tasks superplan-init task-1-plan task-2-execute task-3-complete
make verify   # lint + tests including README greps + pack-check 9 skill(s)
git remote    # empty
test ! -f SKILL.md
```

`--list` did not create `~/.cursor/skills`, `skills-lock.json`, or a git remote. Real `~/.claude/skills` still only `humanize`.

## Files Modified

- `README.md` (Install section)
- `tests/run.sh` (README string greps; `grep -F --`)
- `planning/phases/T04-skills-cli-packaging.md`
- `planning/phases/INDEX.md`
- `.cursor/rules/skills-cli.mdc` (dialectic: `--list`; no npx in verify)
- `.cursor/rules/shell.mdc` (dialectic: grep `--` for flag-like needles)
- `planning/phases/T05-superplan-init.md` (reality notes)

## Manual test (for humans)

From the Superplan repo:

```bash
npx skills add . --list
make verify
```

Success: CLI prints **Found 9 skills** and names all nine; `make verify` exits 0. Your real `~/.claude/skills` / `~/.cursor/skills` are unchanged.

Do **not** run `npx skills add . -g` yet (T08 live install).

## Learnings

- Mode A: skills CLI `--list` is the discovery path; BSD grep treats `--list`/`-g` as flags unless `grep -F --` is used.
- Mode B: do not put `npx` in `make verify`; document both `./install.sh` and `npx skills add . -g -a claude-code -a cursor`; confirm `~/.cursor/skills` after any global add.

## Reality notes

Pack is listable via `npx skills add . --list`. There is no GitHub remote, so `owner/superplan` shorthand is not a working install source. Live `-g` install remains T08.

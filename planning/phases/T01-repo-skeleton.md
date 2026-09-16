# T01 — Repo skeleton

**Status**: Done
**Parent INDEX**: [INDEX.md](./INDEX.md)
**Depends-on**: —
**Next**: T02
**Layer**: L0

## Description

Create the minimal Superplan tree so `make verify` is green: `install.sh --help`, `tests/run.sh`, `scripts/pack-check.sh`, and an empty `skills/` directory. No published skill bodies, no real global install.

## Status History

| Timestamp | Event | From | To | Details | User |
| --------- | ----- | ---- | -- | ------- | ---- |
| 2026-09-16 | created | — | Pending | stub seeded by bootstrap | |
| 2026-09-16 | planned | Pending | Planned | /task-1-plan | |
| 2026-09-16 | execute | Planned | InProgress | /task-2-execute | |
| 2026-09-16 | complete | InProgress | Done | /task-3-complete | |

## Requirements

- [x] `install.sh` exits 0 on `--help` / `-h` and prints usage (no install yet)
- [x] `tests/run.sh` covers `--help` against a fake HOME (must not touch real skill dirs)
- [x] `scripts/pack-check.sh` succeeds on empty `skills/`; fails if a skill dir lacks `SKILL.md`
- [x] `make verify` (= lint + test + build) passes

## Implementation Plan

*(Filled by `/task-1-plan` — do not invent during bootstrap beyond high-level notes.)*

### High-level notes (bootstrap)

- Makefile already fails closed until these files exist
- Do not symlink into `~/.claude/skills` or `~/.cursor/skills` in this task
- Reference: `.cursor/rules/shell.mdc`, `install.mdc`

## Execution plan (filled by /task-1-plan)

**Date:** 2026-09-16
**Codebase snapshot:** branch `main`, no commits yet (unborn HEAD). Working tree has Makefile, lefthook.yml, `.shellcheckrc`, `.gitignore`, README.md, `.cursor/`, `planning/`. Missing: `install.sh`, `tests/`, `scripts/`, `skills/`. No root `SKILL.md`.
**Execute model:** small (default)

### Context for executor

Goal: make `make verify` green with a **help-only** installer, a pack-check that allows an empty `skills/`, and shell tests that never touch the real home skill dirs. No published skill bodies. No real install.

Key paths (create these; do not edit `.cursor/` or other phase files except this task + INDEX status):

| Path | Role |
| ---- | ---- |
| `install.sh` | bash; `--help`/`-h` exit 0; any other invocation must **not** install |
| `tests/run.sh` | test runner invoked by `make test` |
| `scripts/pack-check.sh` | invoked by `make build`; optional `SKILLS_DIR` arg |
| `skills/.gitkeep` | so git tracks empty pack dir |

Invariants (read `.cursor/rules/shell.mdc`, `install.mdc`, `agent-skills.mdc`):

- `set -euo pipefail`, bash shebang (`#!/usr/bin/env bash`)
- Tests: fake `HOME` via `mktemp -d`; never write `~/.claude/skills` or `~/.cursor/skills` (real Claude skills dir exists on this machine; Cursor one does not — do not create it)
- Empty `skills/` is a valid pack; a **subdirectory** without `SKILL.md` is not
- No root `SKILL.md`
- No Go, no Node, no Python
- Do not implement agent-select / symlink / copy (T03)

Makefile already expects exactly these files (`lint: install.sh missing (T01)` etc.). Do not change Makefile unless shellcheck forces a tiny fix.

### Steps

1. Create `skills/.gitkeep` (one-line comment `# published pack; skill dirs added in T02`). No `skills/*/SKILL.md`. No repo-root `SKILL.md`. → verify: `test -d skills && test ! -f SKILL.md && test ! -f skills/SKILL.md`

2. Write `install.sh` (mode `0755`):
   - `#!/usr/bin/env bash` and `set -euo pipefail`
   - `usage()` prints at least:
     ```
     Usage:
       ./install.sh              interactive agent select
       ./install.sh claude       ~/.claude/skills
       ./install.sh cursor       ~/.cursor/skills
       ./install.sh all          both
       ./install.sh --copy       copy instead of symlink
       ./install.sh -h, --help
     ```
     (T03 will implement those flags; T01 only documents them.)
   - Parse args: if `$1` is `-h` or `--help` (or first of several is help), print usage to stdout, `exit 0`
   - **Any other invocation** (no args, `all`, `claude`, `--copy`, junk): print `install is not implemented yet` to **stderr**, `exit 2`. Do not read `$HOME`, do not `mkdir`, do not `ln`/`cp`/`rm`
   - Do not call Node
   → verify: `./install.sh --help` exits 0 and stdout contains `Usage`; `./install.sh -h` same; `./install.sh` exits 2; `./install.sh all` exits 2; `HOME=/tmp/superplan-t01-probe ./install.sh all` does not create `/tmp/superplan-t01-probe/.claude` or `.cursor`

3. Write `scripts/pack-check.sh` (mode `0755`):
   - `#!/usr/bin/env bash`, `set -euo pipefail`
   - Resolve repo root as `$(cd "$(dirname "$0")/.." && pwd)`
   - Skills dir: `"${1:-$ROOT/skills}"` (first arg optional so tests can use fixtures)
   - Fail if skills dir missing (`exit 1`, message to stderr)
   - Fail if `$ROOT/SKILL.md` exists (root pack hide)
   - `shopt -s nullglob`; iterate **only subdirectories** of the skills dir (ignore `.gitkeep` and other files)
   - For each subdir: fail if `SKILL.md` is missing. Do **not** parse YAML frontmatter in T01
   - Empty dir (zero subdirs) → exit 0, print `pack-check: 0 skill(s)` (or similar)
   - Non-empty: print count; exit 0 only if every subdir has `SKILL.md`
   → verify: `scripts/pack-check.sh` against repo `skills/` exits 0; a temp dir with `foo/` and no `SKILL.md` exits non-zero; a temp dir with `foo/SKILL.md` exits 0

4. Write `tests/run.sh` (mode `0755`) as a small bash TAP-less runner: increment fail counter, print `ok`/`not ok`, `exit 1` if any fail. Cases:
   - `--help` and `-h`: exit 0, stdout matches `Usage`
   - no args and `all`: exit 2, stderr matches `not implemented`, stdout empty or unused
   - fake HOME: `HOME=$(mktemp -d)`; run `--help` and `all`; assert `$HOME/.claude` and `$HOME/.cursor` do not exist after
   - `pack-check.sh` with empty fixture dir → 0
   - fixture `broken/foo/` (no SKILL.md) → non-zero
   - fixture `ok/foo/SKILL.md` (any content) → 0
   - `pack-check.sh` with no args (repo `skills/`) → 0
   - Use `mktemp -d` + `trap 'rm -rf …' EXIT` for fixtures. Do not use the developer `$HOME` as a dest. Do not `ls`/`touch` `/Users/aman/.claude/skills` as part of the test (read-only stat of real home is unnecessary)
   → verify: `./tests/run.sh` exits 0

5. `chmod +x install.sh tests/run.sh scripts/pack-check.sh`. → verify: `test -x install.sh tests/run.sh scripts/pack-check.sh`

6. Run `make lint` then `make test` then `make build` then `make verify`. Fix shellcheck findings in-file (do not disable broadly). `.shellcheckrc` already sets `shell=bash`. → verify: `make verify` exits 0

7. Confirm real skill dirs unchanged: do not create `~/.cursor/skills`; do not add/remove anything under `~/.claude/skills`. → verify: you did not write those paths (no `ln`/`cp`/`mkdir` there). Record that in Verification.

### Tests to add

- `tests/run.sh` cases listed in step 4 (this **is** the test file; no extra framework)
- Pack-check negative: subdirectory without `SKILL.md`
- Pack-check positive: empty dir and dir with one `SKILL.md`
- Installer does not create agent dirs under a temp `HOME`

### Verify commands

```bash
test -f Makefile && grep -q '^verify' Makefile
test -f lefthook.yml
test -f .shellcheckrc
chmod +x install.sh tests/run.sh scripts/pack-check.sh
./install.sh --help
make lint
make test
make build
make verify
```

### Risks / pitfalls

- **Empty `skills/` is untracked by git** without `.gitkeep` — add it; pack-check must ignore files, only subdirs
- `skills/*/ ` glob without `nullglob` becomes a literal path on empty dir and can false-fail pack-check
- `install.sh` with no args must **not** follow humanize (humanize installs to Claude by default). T01 = help or exit 2 only
- `set -e` + `cmd; echo $?` in tests: run failing commands as `if script; then …; else …; fi` or `script && … || true` carefully so the runner can assert non-zero without aborting
- Do not `rm -rf` anything under `$HOME`
- Do not copy ColonyX or humanize files into this repo
- First commit of the repo happens in `/task-3-complete`, not here — do not `git commit`

### Out of scope

- Symlink/copy install, agent picker, interactive prompt (T03)
- Any `skills/<name>/SKILL.md` bodies (T02)
- `npx skills add` (T04)
- `/superplan-init`, hub templates, hub resolution (T05–T07)
- Live install into the developer home (T08)
- Makefile/lefthook rewrites unless verify cannot pass without a one-line fix
- README rewrite (optional one-line “skeleton exists” is unnecessary)

### Execute model recommendation

- small (default) — three short bash scripts, Makefile already wired. No large-model justification.

## Test Plan

- `make verify` green with no files under the real `$HOME` skill dirs changed
- Commands: `make verify` (must include **lint + tests + pack-check**)
- New code: tests required (shell, fake HOME)

## Acceptance Criteria

- [x] `./install.sh --help` prints usage and exits 0
- [x] `make verify` passes
- [x] Tests added/updated for new behavior
- [x] Full lint + test verify suite green
- [x] Verification commands recorded and passing
- [x] No secrets committed
- [x] Real `~/.claude/skills` and `~/.cursor/skills` untouched

## Verification

2026-09-16 `/task-2-execute`

```
test -f Makefile && grep -q '^verify' Makefile   # ok
test -f lefthook.yml                             # ok
test -f .shellcheckrc                            # ok
shellcheck -x install.sh tests/run.sh scripts/pack-check.sh  # ok
./install.sh --help                              # exit 0, Usage
./install.sh                                     # exit 2, stderr: install is not implemented yet
make lint                                        # shellcheck ok
make test                                        # 9 ok
make build                                       # pack-check: 0 skill(s)
make verify                                      # lint + test + build ok
```

Real skill dirs: `~/.claude/skills` still only `humanize` (mtime unchanged at Aug 27). `~/.cursor/skills` still absent. No `ln`/`cp`/`mkdir` there.

`/task-3-complete` re-ran presence check + `make verify` (2026-09-16): lint + 9 tests + `pack-check: 0 skill(s)` green.

## Files Modified

- `install.sh` (added)
- `tests/run.sh` (added)
- `scripts/pack-check.sh` (added)
- `skills/.gitkeep` (added)
- `planning/phases/T01-repo-skeleton.md` (status + this section)
- `planning/phases/INDEX.md` (T01 → InProgress, then ✅ on close-out)
- `.cursor/rules/shell.mdc` (dialectic: empty glob / set -e / empty pack dir)
- `.cursor/rules/agent-skills.mdc` (dialectic: empty pack placeholder)
- `README.md` (status: skeleton + verify green)
- `planning/phases/T02-canonical-skill-pack.md` (reality notes)
- `planning/phases/T03-install-sh.md` (reality notes)

## Manual test (for humans)

From the Superplan repo:

```bash
./install.sh --help
```

Success: prints `Usage:` including `claude`, `cursor`, `all`, `--copy`, and `--help`, then exits 0.

```bash
./install.sh; echo exit:$?
make verify
```

Success: first command prints `install is not implemented yet` on stderr and exits 2 (real install is T03). `make verify` exits 0.

Do **not** expect skills to appear in Claude or Cursor yet.

## Learnings

- Mode A: skipped (no debugging triggers).
- Mode B: encoded empty-glob/`set -u`, `set -e` + expected non-zero, and empty pack dir tracking into `.cursor/rules/shell.mdc`; empty-pack placeholder invariant in `.cursor/rules/agent-skills.mdc`.

## Reality notes

T01 left `install.sh` help-only (exit 2 otherwise). T03 replaces the body and must update `tests/run.sh` cases that assert exit 2 for no-args/`all`.

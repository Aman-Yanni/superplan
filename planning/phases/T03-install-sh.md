# T03 — install.sh

**Status**: Done
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
| 2026-09-16 | planned | Pending | Planned | /task-1-plan | |
| 2026-09-16 | execute | Planned | InProgress | /task-2-execute | |
| 2026-09-16 | complete | InProgress | Done | /task-3-complete | |

## Requirements

- [x] No-args (or explicit interactive) walkthrough to select agents
- [x] Targets: `claude`, `cursor`, `all`; `--copy`; `--help`
- [x] Symlink default; each dest is `…/skills/<name>` → repo `skills/<name>`
- [x] Do not `rm -rf` a dest that is not a Superplan symlink/copy — stop and say so
- [x] Works with no Node
- [x] Tests never touch the real `$HOME`

## Implementation Plan

*(Filled by `/task-1-plan`.)*

### High-level notes (bootstrap)

- Reference: https://github.com/harshaneel/humanize/blob/main/install.sh
- Cursor dest: `~/.cursor/skills` (not `~/.cursor/skills-cursor`, not only `~/.agents/skills`)
- Claude dest: `~/.claude/skills` (symlinks are followed)
- Spoke: `.cursor/rules/install.mdc`
- T01: `install.sh` prints usage on `-h`/`--help` (exit 0) and exits 2 with `install is not implemented yet` otherwise. Replace that body; keep the usage text as the flag contract. `tests/run.sh` currently asserts exit 2 for no-args and `all` — update those cases when install works.

## Execution plan (filled by /task-1-plan)

**Date:** 2026-09-16
**Codebase snapshot:** branch `T03-install-sh` at T02 commit (`e311fc3`). `install.sh` is help-only (exit 2 otherwise). Nine pack skills under `skills/<name>/`. `tests/run.sh` still asserts no-args/`all` exit 2 and that `HOME=$fake ./install.sh all` does not create `.claude`/`.cursor`.
**Execute model:** small

### Context for executor

Replace the help-only body of `/Users/aman/projects/other/superplan/install.sh` with a humanize-style installer. Default **symlink** each pack skill dir into the selected agent's global skills dir. `--copy` copies instead. Tests must use a temp `HOME` and must not change the developer's real `~/.claude/skills` or `~/.cursor/skills`.

Keep the existing `usage()` text (the flag contract). Delete the `install is not implemented yet` path.

Do not call Node/`npx`. Do not vendor humanize. Do not edit `.cursor/skills/` or pack `SKILL.md` files.

Paths (always `"$HOME/..."`, never `~`, because bash `~` ignores a fake `HOME`):

| Agent | Dest root |
| ----- | --------- |
| `claude` | `$HOME/.claude/skills` |
| `cursor` | `$HOME/.cursor/skills` |

Never write `skills-cursor` or `~/.agents/skills`.

Source: `"$ROOT/skills/<name>"` where `ROOT` is the directory containing `install.sh`. A skill is a **subdirectory** of `skills/` that contains `SKILL.md`. Ignore files (`.gitkeep`).

The nine names: `audit-rules` `bootstrap-turboplan` `dialectic-of-cognition` `grill-me` `setup-tasks` `superplan-init` `task-1-plan` `task-2-execute` `task-3-complete`.

### Behavior

**Flags** (any order except help):

- `-h` / `--help`: print usage on stdout, exit 0 (same as T01). If present anywhere among args, help wins.
- `--copy`: copy mode. Print that the install copied (not linked).
- `claude` / `cursor` / `all`: select agents. `all` = both. More than one of `claude`/`cursor` means both.
- Any other arg: print usage on stderr, exit 2.
- No agent token: interactive (below). `--copy` with no agent is still interactive, then copy.

**Interactive** (no agent token): print this exact prompt on stdout, then `read -r`:

```text
Select agents:
  1) claude   $HOME/.claude/skills
  2) cursor   $HOME/.cursor/skills
  3) all      both
Enter 1, 2, 3 or claude/cursor/all:
```

Accept `1`/`claude`, `2`/`cursor`, `3`/`all`/`both`. Trim is optional (no extra spaces required in tests). EOF or empty/unknown → stderr `install: no agent selected` (or `install: unknown agent`) and exit 2. Do **not** require a TTY; tests pipe into stdin.

**Safe replace** — preflight **all** dests for all selected agents **before** creating anything. Then apply. For each dest `$HOME/.<agent>/skills/<name>`:

- Missing (including nothing there): ok.
- Symlink whose `readlink` equals the absolute source path: ours — may replace.
- Directory containing `.superplan-install` whose contents (first line, no extra spaces required) equal the absolute source path: a previous Superplan copy — may replace.
- Anything else (foreign dir, foreign symlink, file): stderr `install: refusing to replace <dest> (not a Superplan install)` and exit 1. Do not `rm -rf` it. Do not apply any dests if preflight failed.

**Apply** (after preflight):

1. `mkdir -p` the dest root for each selected agent.
2. If dest exists and is ours: `rm -rf -- "$dest"` (symlink-safe: removes the link, not the pack).
3. Symlink mode: `ln -s "$src" "$dest"` with **absolute** `$src`.
4. Copy mode: `cp -R "$src" "$dest"` then `printf '%s\n' "$src" > "$dest/.superplan-install"`.
5. Print one summary line per agent: `Installing Superplan (symlink|copy) → <dest_root>` and one indented line per skill (`linked <name>` or `copied <name>`).

If `skills/` has zero skill subdirs: stderr `install: no skills in <pack>` and exit 1 (do not mkdir agent dirs).

Idempotent: running `./install.sh all` twice under the same HOME must exit 0.

### Suggested `install.sh` shape (follow closely)

Keep `set -euo pipefail`. `ROOT="$(cd "$(dirname "$0")" && pwd)"`. `PACK="$ROOT/skills"`.

Walk skills with `shopt -s nullglob` and `for dir in "$PACK"/*/`. Expected non-zero: `read` EOF via `read -r ans || { ...; exit 2; }`.

`is_ours dest src` as described. Collect selected agents in a string or two flags (`want_claude`/`want_cursor`).

Do not use `~`. Do not `rm -rf` until `is_ours` is true. Do not call `npx`.

### Tests (`tests/run.sh`)

Keep `run_cmd` and pack-check cases. Snapshot the **real** home skill listings **before** any fake-HOME install:

```bash
REAL_HOME="$HOME"
real_claude="$(ls -A "$REAL_HOME/.claude/skills" 2>/dev/null || true)"
real_cursor="$(ls -A "$REAL_HOME/.cursor/skills" 2>/dev/null || true)"
```

At the end of the installer cases (before pack-check is fine too, but must run after all `HOME=fake` installs), assert those listings are unchanged.

Extend `run_cmd` or add `run_cmd_in` so stdin can be piped:

```bash
run_cmd_in() {
  # $1 = stdin string; remaining args = command
  ...
  printf '%s' "$1" | "$2" "${@:3}" >"$outf" 2>"$errf" || run_code=$?
}
```

Replace the T01 cases that will break:

| Old | New |
| --- | --- |
| `./install.sh` no-args exit 2 `not implemented` | no-args with empty stdin → non-zero (no agent selected). `--help`/`-h` unchanged |
| `./install.sh all` exit 2 | `HOME=$fake ./install.sh all` exit 0, 9 symlinks per agent |
| fake HOME `all` must **not** create dirs | it **must** create `$fake/.claude/skills/<name>` and `$fake/.cursor/skills/<name>` |

Add:

1. **symlink all:** for each of the nine names, `[[ -L "$fake/.claude/skills/$n" ]]`, `[[ "$(readlink ...)" == "$ROOT/skills/$n" ]]`, `[[ -f ".../SKILL.md" ]]`, same for cursor. `.gitkeep` is not a dest. Output contains `symlink` (or `linked`).
2. **idempotent:** run `all` a second time on that HOME, exit 0.
3. **`--copy cursor`:** `$fake/.cursor/skills/grill-me` is a directory (not a symlink), contains `SKILL.md` and `.superplan-install` whose first line is `$ROOT/skills/grill-me`. `$fake/.claude` does not exist. Output contains `copy` or `copied`.
4. **foreign refuse:** `mkdir -p "$fake/.claude/skills/grill-me"; echo nope >".../grill-me/FOREIGN"`. `HOME=$fake ./install.sh claude` → exit 1, stderr contains `refusing`, `FOREIGN` still present, no other skill dirs added under that claude skills dir (preflight: no apply).
5. **interactive:** `printf '3\n' | HOME=$fake2 ./install.sh` → both agents, 9 symlinks (same assertions as `all`).
6. **unknown arg:** `./install.sh nope` → exit 2.
7. Real home listings unchanged (snapshot).

Keep pack-check tests. Keep `set -euo pipefail` capture style (`run_cmd` already uses `|| run_code=$?`).

### Steps

1. Rewrite `install.sh` as specified. Do not change the `usage()` heredoc text. → verify: `./install.sh --help` still prints `Usage:` and the same targets; `./install.sh nope` exits 2
2. Update `tests/run.sh` as the table above. Snapshot real HOME first. → verify: `./tests/run.sh` fails until install works, then passes
3. `make lint && make test && make verify`. Fix shellcheck (quote `HOME` paths; `read` under `set -e`). → verify: `make verify` exits 0
4. Confirm real `~/.claude/skills` / `~/.cursor/skills` listings match the snapshot. Confirm no `npx` in `install.sh`. → verify: `grep -n npx install.sh` empty; `test ! -e ~/.cursor/skills` **or** listing unchanged if it exists

### Tests to add

- Fake HOME `all`: 9 absolute symlinks in both agent dirs
- `--copy cursor`: directories + `.superplan-install`; claude absent
- Foreign `grill-me` dir: exit 1, dest intact, no sibling skills created
- Interactive `3` → both agents
- Idempotent second `all`
- Real HOME skill listings unchanged
- Unknown arg exit 2; `--help` still 0

### Verify commands

```bash
test -f Makefile && grep -q '^verify' Makefile
test -f lefthook.yml
test -f .shellcheckrc
make lint
make test
make verify
```

### Risks / pitfalls

- **`~` vs `$HOME`:** `~/.claude` is the real home even when `HOME` is faked. Always `"$HOME/.claude/skills"`.
- **`rm -rf` on a foreign dest** — preflight first; only remove if `is_ours`.
- **Broken symlink:** `-e` is false; still detect with `-L`.
- **Preflight vs partial apply:** check every dest before `mkdir`/`ln`/`cp`.
- **T01 tests** will fail the moment the stub is replaced — update tests in the same change.
- **Do not live-install** into the developer's real skill dirs (T08).
- macOS `cp -R "$src" "$dest"` when `$dest` does not exist creates `$dest` as a copy of `$src` (not `$dest/$(basename src)`).

### Out of scope

- `npx skills add` (T04)
- Live install into the real `$HOME` (T08 — ask first)
- Hub init / config (T05–T07)
- Changing pack `SKILL.md` files or `.cursor/skills/`
- GitHub remote, merge

### Execute model recommendation

- small — one shell script + test updates; dests, safety rule, and flag contract are specified. Not large.

## Test Plan

- Fake HOME: symlink both agents; `--copy`; refuse to clobber a foreign dir
- Commands: `make verify` plus `HOME=/tmp/... ./install.sh all`
- New code: tests required

## Acceptance Criteria

- [x] Interactive + flag paths documented in `--help`
- [x] Symlink and copy both tested under fake HOME
- [x] Tests added/updated for new behavior
- [x] Full lint + test verify suite green
- [x] Verification commands recorded and passing
- [x] No secrets committed
- [x] Developer’s real skill dirs unchanged by `make test`

## Verification

Presence check + `make verify` (2026-09-16 execute; re-run on complete). Cursor's sandbox denies `mkdir …/.cursor` even under a temp HOME — verify was re-run unsandboxed:

```text
test -f Makefile && grep -q '^verify' Makefile   # ok
test -f lefthook.yml                             # ok
test -f .shellcheckrc                            # ok
make verify                                      # lint + 24 tests + pack-check 9 skill(s)
```

Installer cases: `--help`/`-h`, empty-stdin no-args, unknown arg exit 2, `all` 9 symlinks both agents, idempotent `all`, `--copy cursor`, foreign refuse, interactive `3`, real home listings unchanged. Pack-check cases still pass.

`grep npx install.sh` empty. Real `~/.claude/skills` / `~/.cursor/skills` listings unchanged.

## Files Modified

- `install.sh` (symlink/copy installer)
- `tests/run.sh` (fake HOME installer cases; real-home snapshot)
- `planning/phases/T03-install-sh.md`
- `planning/phases/INDEX.md`
- `README.md` (status)
- `.cursor/rules/install.mdc` (dialectic: `$HOME` not `~`; copy marker)
- `.cursor/rules/shell.mdc` (dialectic: sandbox blocks fake `.cursor`)
- `planning/phases/T04-skills-cli-packaging.md` (reality notes)

## Manual test (for humans)

From the Superplan repo, **do not** install into your real home yet (that is T08). Exercise with a temp HOME:

```bash
fake="$(mktemp -d)"
HOME="$fake" ./install.sh all
ls -l "$fake/.claude/skills" "$fake/.cursor/skills"
readlink "$fake/.claude/skills/grill-me"
HOME="$fake" ./install.sh --copy cursor
ls -ld "$fake/.cursor/skills/grill-me"
printf '1\n' | HOME="$fake" ./install.sh
make verify
```

Success: nine symlinks under both agent dirs pointing at this repo's `skills/<name>`; `--copy cursor` leaves directories with `.superplan-install`; `make verify` exits 0. Your real `~/.claude/skills` and `~/.cursor/skills` are unchanged.

## Learnings

- Mode A: Cursor sandbox denies `mkdir` of `.cursor` even under a temp HOME — installer tests must run unsandboxed or they false-fail after claude dests succeed.
- Mode B: dest paths must use `"$HOME/..."` not `~`; Superplan copies are identified by `.superplan-install`; preflight all dests before apply.

## Reality notes

Installer is live under a fake `HOME`. T08 is the first live install into the real skill dirs — ask before doing that. T04 adds `npx skills add` as a second distribution path; `./install.sh` stays the no-Node path.

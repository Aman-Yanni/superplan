---
name: superplan-init
description: >-
  Create or bind a Superplan planning hub. Use when the user wants to start
  Superplan on a project or select product repos. Manual only. Uses cwd when
  it already has superplan.yml; otherwise asks for a hub path; writes hub
  superplan.yml and data-only templates.
disable-model-invocation: true
model: opus
effort: high
---

# /superplan-init — Bind a planning hub

Skills stay global. This skill writes hub **config and data-only templates**.
Do not copy Superplan skills into the hub folder.

Run the helper next to this file after you have answers:

```bash
init="$(dirname "$SKILL_DIR")/init.sh"   # this skill dir
# or: ~/.claude/skills/superplan-init/init.sh  (same tree when symlinked)
```

## Hard constraints

1. If cwd or an ancestor has `superplan.yml`, that directory is the hub. Do
   not ask. Do not read `$HOME/.superplan/config.yml`.
2. Otherwise ask for a hub path. Example: `$HOME/plans/my-project`. Do not
   guess a folder name.
3. Product repos are selected by the human (discover + pick, or explicit paths).
4. `merge_prs: false` always in this task. Do not merge. Do not `git remote add`.
5. Do not run `install.sh` or `npx skills add`. Do not write into
   `~/.claude/skills` or `~/.cursor/skills`.
6. Write data-only hub files from `templates/hub/` (`CLAUDE.md`, `AGENTS.md`,
   `phases/INDEX.md` if missing, `rules/` stubs if missing). Do not copy
   Superplan skills into the hub. Do not wipe existing `rules/*.md`.
7. Do not bind someone else’s product repos unless the human names that folder.

## Procedure

### 1. Hub path

Walk up from cwd for `superplan.yml`. If found, tell the human that path is
the hub and continue.

If not found, ask for a path. If it does not exist, confirm, then the helper
creates it.

### 2. Product repos

Ask whether to search **cwd** or a work-folder path they give. Run:

```bash
./init.sh --discover "$search_path"
```

Show the git dirs found (the search path itself if it has `.git`, plus
immediate children with `.git`). The human multi-selects, or pastes explicit
paths. One hub may bind many repos. Zero repos is allowed.

### 3. Write the hub

Existing hub (cwd already has `superplan.yml`):

```bash
./init.sh --repo "$repo1" --repo "$repo2"
```

New hub:

```bash
./init.sh --hub "$hub" --repo "$repo1" --repo "$repo2"
```

`--hub` may be an absolute path, or `--workspace "$parent" --hub NAME` for a
folder under a parent. Repeat `--repo` for each selected path. Omit `--repo`
to keep existing `repos:` on a refresh (or write `repos: []` on first create).

Tell the human what was written: `<hub>/superplan.yml` and the data-only hub
files. Existing `rules/*.md` are kept.

## Do not

- Write `phases/` into a product repo.
- Copy Superplan skills into the hub.
- Live-install the pack unless the human asked.
- Save a machine-wide hub default.

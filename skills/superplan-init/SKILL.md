---
name: superplan-init
description: >-
  Create or bind a Superplan planning hub. Use when the user wants to start
  Superplan on a project or select product repos. Manual only. Uses cwd when
  it already has superplan.yml; otherwise offers in-repo (this git folder,
  turboplan-style) or a separate hub path; writes superplan.yml and templates.
disable-model-invocation: true
model: opus
effort: high
---

# /superplan-init — Bind a planning hub

Skills stay global. This skill writes hub **config and templates**.
Do not copy Superplan skills into the hub folder.

Two layouts:

- **In-repo (turboplan-style):** this git repo is the hub. `phases/` and
  `superplan.yml` live here. Plan and execute in this folder.
- **Separate hub:** a planning folder holds `phases/`; product repos stay
  bound via `repos:` and are not written into.

Run the helper next to this file after you have answers:

```bash
init="$(dirname "$SKILL_DIR")/init.sh"   # this skill dir
# or: ~/.claude/skills/superplan-init/init.sh  (same tree when symlinked)
```

## Hard constraints

1. If cwd or an ancestor has `superplan.yml`, that directory is the hub. Do
   not ask. Do not read `$HOME/.superplan/config.yml`.
2. Otherwise ask **in-repo vs separate hub**. Do not guess. In-repo requires
   cwd to be a git repo.
3. Product repos are selected by the human (discover + pick, or explicit paths).
   In-repo defaults to this repo.
4. `merge_prs: false` always in this task. Do not merge. Do not `git remote add`.
5. Do not run `install.sh` or `npx skills add`. Do not write into
   `~/.claude/skills` or `~/.cursor/skills`.
6. Write hub files from `templates/hub/` (`CLAUDE.md`, `AGENTS.md`,
   `phases/INDEX.md` if missing, `rules/` stubs if missing). Do not copy
   Superplan skills into the hub. Do not wipe existing `rules/*.md` or an
   existing product `CLAUDE.md` / `AGENTS.md`.
7. Do not bind someone else’s product repos unless the human names that folder.

## Procedure

### 1. Hub path

Walk up from cwd for `superplan.yml`. If found, tell the human that path is
the hub and continue.

If not found:

- If cwd is a git repo, ask: **plan in this repo** (turboplan-style) or
  **use a separate hub folder**. Prefer clickable choices when the runtime
  has them (`AskQuestion` / `AskUserQuestion`), including **I'll write my own**
  for a custom path.
- Otherwise ask for a hub path. If it does not exist, confirm, then the helper
  creates it.

### 2. Product repos

In-repo: default is this repo. Still offer to bind extra repos.

Otherwise ask whether to search **cwd** or a work-folder path they give. Run:

```bash
./init.sh --discover "$search_path"
```

Show the git dirs found. The human multi-selects, or pastes explicit paths.
Zero extra repos is allowed.

### 3. Write the hub

In-repo (cwd is the git project):

```bash
./init.sh --in-repo
# extra repos: ./init.sh --in-repo --repo "$other"
```

Existing hub (cwd already has `superplan.yml`):

```bash
./init.sh --repo "$repo1" --repo "$repo2"
```

New separate hub:

```bash
./init.sh --hub "$hub" --repo "$repo1" --repo "$repo2"
```

Tell the human what was written: `<hub>/superplan.yml`, `phases/`, and that
skills stay global. Existing `rules/*.md` are kept.

## Do not

- Write `phases/` into a bound repo that is **not** the hub.
- Copy Superplan skills into the hub.
- Overwrite a product repo's existing `CLAUDE.md` / `AGENTS.md`.
- Live-install the pack unless the human asked.
- Save a machine-wide hub default.

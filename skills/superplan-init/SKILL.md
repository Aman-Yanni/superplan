---
name: superplan-init
description: >-
  Create or bind a Superplan planning hub. Use when the user wants to start
  Superplan on a project, pick a planning workspace, or select product repos.
  Manual only. Asks workspace path first, then hub folder, then product repos;
  writes ~/.superplan/config.yml and hub superplan.yml.
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

If `phases/INDEX.md` is missing in cwd, that is normal — **cwd is not the hub**.
Do not write `phases/` or `rules/` into cwd.

## Hard constraints

1. Ask the **planning workspace** path first. Example: `$HOME/plans`.
   Do not guess a hub folder name.
2. Persist that path in `$HOME/.superplan/config.yml` (`planning_workspace`).
   Use `"$HOME"`, never `~`, when invoking the helper.
3. Reuse an existing folder under the workspace before creating one. Suggest a
   name; do not default to an existing product’s folder.
4. Product repos are selected by the human (discover + pick, or explicit paths).
5. `merge_prs: false` always in this task. Do not merge. Do not `git remote add`.
6. Do not run `install.sh` or `npx skills add`. Do not write into
   `~/.claude/skills` or `~/.cursor/skills`.
7. Write data-only hub files from `templates/hub/` (`CLAUDE.md`, `AGENTS.md`,
   `phases/INDEX.md` if missing, `rules/` stubs if missing). Do not copy
   Superplan skills into the hub. Do not wipe existing `rules/*.md`.
8. Tests and live dummy work use temp / dummy folders — do not bind someone
   else’s product repos unless the human names that folder.

## Procedure

### 1. Planning workspace

If `$HOME/.superplan/config.yml` already has `planning_workspace`, offer it.
Otherwise ask for the path. If it does not exist, confirm, then pass
`--create-workspace`.

### 2. Hub folder

List immediate subdirectories of the workspace. The human may:

- reuse one of those names
- give a new folder name (created under the workspace)
- give a path they already created

### 3. Product repos

Ask whether to search **cwd** or a work-folder path they give. Run:

```bash
./init.sh --discover "$search_path"
```

Show the git dirs found (the search path itself if it has `.git`, plus
immediate children with `.git`). The human multi-selects, or pastes explicit
paths. One hub may bind many repos. Zero repos is allowed.

### 4. Write config

```bash
./init.sh --workspace "$workspace" --hub "$hub" \
  --create-workspace \
  --repo "$repo1" --repo "$repo2"
```

Omit `--create-workspace` if the workspace already exists. Repeat `--repo` for
each selected path. Omit `--repo` when the selection is empty.

Tell the human what was written: `$HOME/.superplan/config.yml`,
`<hub>/superplan.yml`, and the data-only hub files. Existing `rules/*.md` are
kept.

## Do not

- Treat cwd as the hub or write `phases/` into a product repo.
- Copy Superplan skills into the hub.
- Live-install the pack unless the human asked.
- Default the hub name to an existing product folder.

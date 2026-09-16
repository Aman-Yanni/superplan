---
name: superplan-init
description: >-
  Create or bind a Superplan planning hub. Use when the user wants to start
  Superplan on a project, pick a planning workspace, or select product repos.
  Manual only. Full UX is implemented later (T05); this stub must not invent it.
disable-model-invocation: true
model: opus
effort: high
---

# /superplan-init — Bind a planning hub (stub)

Intended sequence (do **not** run it yet):

1. Ask for the **planning workspace** path first (save as default).
2. List existing folders there; reuse one, or create a name the human chooses.
3. Discover product repos from the current folder or a work-folder path; the
   human selects which to bind.

Hubs are data-only. Skills stay global. Repo rules win on conflict. Close-out
does not merge unless the human opts in.

## Hard constraints

1. **Do not create folders, config files, or hub templates in this stub.**
2. Do not run `install.sh`. Do not write into `~/.claude/skills` or
   `~/.cursor/skills`.
3. Do not invent `~/.superplan/config.yml` or `superplan.yml` yet.

## What to tell the human

The full init UX is **T05**. Until that task is done, stop after explaining the
three steps above. If they already have a hub (for example a ColonyX folder),
they can open that folder and use the other Superplan skills from there once
the pack is installed (T03).

## Do not

- Do not create directories, copy templates, or bind repos.
- Treat cwd as a product repo and write `phases/` into it.

# 🚀 Superplan

```text
 ____                              _
/ ___| _   _ _ __   ___ _ __ _ __ | | __ _ _ __
\___ \| | | | '_ \ / _ \ '__| '_ \| |/ _` | '_ \
 ___) | |_| | |_) |  __/ |  | |_) | | (_| | | | |
|____/ \__,_| .__/ \___|_|  | .__/|_|\__,_|_| |_|
            |_|             |_|
```

## Summary

Superplan is a **global skill pack** for Claude Code, Cursor, and OpenCode (DeepSeek). It is a [Turboplan](https://github.com/commoddity/turboplan) port: the work-loop skills (`/grill-me` → `/setup-tasks` → plan → execute → complete) live once on your machine, and each product gets a **data-only planning hub** under a workspace you choose. You can bind one repo or many at the same time. Done means you can `./install.sh` (or later `npx skills add`) and `/superplan-init` a project without copying skills into that hub.

Bootstrapped with **[Turboplan](https://github.com/commoddity/turboplan)** (agent rules + phased delivery).

## Table of Contents

- [Summary](#summary)
- [❗ The problem](#-the-problem)
- [🛠️ The fix (target)](#️-the-fix-target)
- [📊 Status](#-status)
- [📦 Install](#-install)
- [📂 Repo layout](#-repo-layout)
- [📚 Dependencies & docs](#-dependencies--docs)
- [🔁 Building with Turboplan](#-building-with-turboplan)
- [🔒 Security / invariants](#-security--invariants)
- [📜 License / attribution](#-license--attribution)

---

## ❗ The problem

| What you try | What happens |
| ------------ | ------------ |
| Copy turboplan skills into every planning folder | Skills drift per project; they only work when that folder is cwd |
| Use Claude or Cursor on several product repos at once | Each tool wants its own skill dir; hubs and product code get mixed |
| Install a skill globally | Easy to land in the wrong folder (`~/.agents/skills` vs `~/.cursor/skills`) |

## 🛠️ The fix (target)

- **One pack**, installed globally for **Claude Code, Cursor, and OpenCode**.
- **Planning workspace first** (e.g. `$HOME/plans`), then a per-project hub folder (create a name you choose).
- **Select product repos** by searching the current folder or a work-folder path you give.
- Hubs are **data-only**: `CLAUDE.md` / `AGENTS.md`, `rules/`, `phases/`. Skills stay global.
- **Repo rules win.** Hub spokes add routing and cross-repo notes; they do not replace a repo's own docs. Conflicts are reported and asked about.
- Close-out **does not merge** unless you opt in. No GitHub remote unless you ask.

```text
you ──► ./install.sh (or npx skills add -g)
            │  symlink skills/ → ~/.claude/skills
            │                 → ~/.cursor/skills
            │                 → ~/.config/opencode/skills
            ▼
        /superplan-init
            │  1. planning workspace path
            │  2. existing hub folder or create one
            │  3. pick product repos
            ▼
        <workspace>/<project>/   (data-only hub)
            + bound repos on disk (unchanged)
```

While Superplan itself is being built, prefer **symlink** from this git repo so edits are live. The shipped path is the same installer plus `npx skills add`.

## 📊 Status

| Area | State |
| ---- | ----- |
| 🧭 Agent rules (`.cursor/rules/`) | Bootstrapped |
| 📋 MVP plan (`planning/phases/`) | Seeded — see INDEX |
| 🛠️ Product code (`skills/`, `install.sh`) | T08 complete: installer, init, and hub templates. Private GitHub remote; skills.sh registry not used |
| 🧰 Verify | `make verify` (shellcheck + tests + pack-check) passes |
| 📦 Toolchain | Node v22.18.0 (npx skills consumer only); shellcheck 0.11.0; lefthook 2.1.14 |

## 📦 Install

Two paths. Prefer **`./install.sh`** while working in this git repo (no Node, symlink, edits are live).

### Local (no Node)

```bash
./install.sh              # interactive agent select
./install.sh all          # Claude Code + Cursor + OpenCode, symlink
./install.sh opencode     # OpenCode / DeepSeek only (alias: deepseek)
./install.sh --copy cursor
```

Destinations: `$HOME/.claude/skills/<name>`, `$HOME/.cursor/skills/<name>`, and `$HOME/.config/opencode/skills/<name>`.

Dry-run without touching your real home:

```bash
HOME="$(mktemp -d)" ./install.sh all
```

### skills CLI (Node)

Discover the pack **without installing**:

```bash
npx skills add . --list
```

That must print all nine skills (`grill-me`, `setup-tasks`, `task-1-plan`, `task-2-execute`, `task-3-complete`, `dialectic-of-cognition`, `audit-rules`, `bootstrap-turboplan`, `superplan-init`).

When you are ready to install globally (later; writes into your real home):

```bash
npx skills add . -g -a claude-code -a cursor -a opencode
test -f ~/.claude/skills/grill-me/SKILL.md
test -f ~/.cursor/skills/grill-me/SKILL.md
test -f ~/.config/opencode/skills/grill-me/SKILL.md
```

Always pass **`-a claude-code -a cursor`**. For OpenCode/DeepSeek, pass **`-a opencode`** as well, then confirm **`~/.config/opencode/skills/<name>/SKILL.md`**. Prefer `./install.sh opencode` for that native dest. After a global add, confirm **`~/.cursor/skills/<name>/SKILL.md`** exists. The CLI has historically written `~/.agents/skills` and skipped Cursor's personal dir. If `~/.cursor/skills/grill-me/SKILL.md` is missing, run `./install.sh cursor` (or reinstall with `-a cursor -g`) and check again. Never install into `~/.cursor/skills-cursor`.

`npx skills add <owner>/superplan` works only if the clone’s GitHub remote is reachable for that user. Do not publish this pack to the skills.sh registry unless asked.

### Uninstall

Remove only Superplan dests that are symlinks into this repo. Keep any unrelated skills already in those directories.

```bash
# from the Superplan clone
for n in audit-rules bootstrap-turboplan dialectic-of-cognition grill-me setup-tasks superplan-init task-1-plan task-2-execute task-3-complete; do
  rm -f "$HOME/.claude/skills/$n" "$HOME/.cursor/skills/$n" "$HOME/.config/opencode/skills/$n"
done
```

If you created a dummy hub, delete that folder under your planning workspace. Config: `~/.superplan/config.yml`.

## 📂 Repo layout

| Path | For |
| ---- | --- |
| [`README.md`](README.md) | 👤 Humans (this file) |
| [`.cursor/rules/`](.cursor/rules/) | 📜 Conventions for coding agents building Superplan |
| [`.cursor/skills/`](.cursor/skills/) | 🧩 Plan / execute / complete for **this** repo |
| [`skills/`](skills/) | 🌍 Published pack (created in T01+, installed globally) |
| [`install.sh`](install.sh) | 🔗 Humanize-style installer (T01+) |
| [`templates/hub/`](templates/hub/) | 📁 Data-only hub templates (later tasks) |
| [`planning/phases/`](planning/phases/) | 🗂️ MVP sequence of record |

## 📚 Dependencies & docs

Human-facing summary. Agents get detail in matching `.cursor/rules/*.mdc` spokes — keep both in sync.

| Dependency | Role | Docs | Agent rules |
| ---------- | ---- | ---- | ----------- |
| Agent Skills | `SKILL.md` format and pack layout | [agentskills.io/specification](https://agentskills.io/specification) | [`.cursor/rules/agent-skills.mdc`](.cursor/rules/agent-skills.mdc) |
| skills CLI | `npx skills add -g` distribution | [github.com/vercel-labs/skills](https://github.com/vercel-labs/skills) | [`.cursor/rules/skills-cli.mdc`](.cursor/rules/skills-cli.mdc) |
| Claude Code | Personal skills + `additionalDirectories` | [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills) | [`.cursor/rules/claude-code.mdc`](.cursor/rules/claude-code.mdc) |
| Cursor Skills | Personal `~/.cursor/skills` | [cursor.com/docs/skills](https://cursor.com/docs/skills) | [`.cursor/rules/cursor-skills.mdc`](.cursor/rules/cursor-skills.mdc) |
| OpenCode | Personal `~/.config/opencode/skills` (DeepSeek and other models) | [opencode.ai/docs/skills](https://opencode.ai/docs/skills/) | [`.cursor/rules/install.mdc`](.cursor/rules/install.mdc) |
| Planning hub | Workspace, data-only hubs, repo-rules-first | [Turboplan](https://github.com/commoddity/turboplan) | [`.cursor/rules/planning-hub.mdc`](.cursor/rules/planning-hub.mdc) |
| install.sh | Agent-select symlink installer | [humanize install.sh](https://github.com/harshaneel/humanize/blob/main/install.sh) | [`.cursor/rules/install.mdc`](.cursor/rules/install.mdc) |
| shellcheck / lefthook | Lint + pre-commit verify | [shellcheck wiki](https://www.shellcheck.net/wiki/) · [lefthook](https://lefthook.dev/) | [`.cursor/rules/shell.mdc`](.cursor/rules/shell.mdc) |

## 🔁 Building with [Turboplan](https://github.com/commoddity/turboplan)

Work proceeds one phase task at a time. Full methodology:
[github.com/commoddity/turboplan](https://github.com/commoddity/turboplan).

```
  📝 /task-1-plan TXX
        ↓
  🛠️  /task-2-execute TXX
        ↓
  ✅ /task-3-complete TXX → commit + push if origin exists + Manual test
```

See [`planning/phases/INDEX.md`](planning/phases/INDEX.md). T01–T08 are complete. New work starts with `/grill-me` or `/setup-tasks`.

## 🔒 Security / invariants

- Secrets stay out of git (`.env`, credentials). Tests use a fake `HOME`.
- Do not overwrite unrelated skills in `~/.claude/skills`, `~/.cursor/skills`, or `~/.config/opencode/skills`.
- Never edit a bound product repo's own rules without approval; repo docs win on conflict.
- Close-out never merges unless you opt in. No remotes created by default.
- Global skills must not write `phases/` into a product repo — the hub path comes from config.

## 📜 License / attribution

Methodology and original skills: [commoddity/turboplan](https://github.com/commoddity/turboplan) (MIT).

Installer shape: [harshaneel/humanize `install.sh`](https://github.com/harshaneel/humanize/blob/main/install.sh).

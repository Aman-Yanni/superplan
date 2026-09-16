# Superplan Phase Index

**Product**: Superplan
**Method**: `/task-1-plan` → `/task-2-execute` → `/task-3-complete`
**Rule**: Only one task `InProgress` unless the human approves more.
**INDEX Status**: use `✅` when complete (never the word `Done` in this column).

| ID | Title | Status | Depends-on | Next | Layer | Notes |
| -- | ----- | ------ | ---------- | ---- | ----- | ----- |
| T01 | [Repo skeleton](./T01-repo-skeleton.md) | ✅ | — | T02 | L0 | `make verify` first green |
| T02 | [Canonical skill pack](./T02-canonical-skill-pack.md) | Pending | T01 | T03 | L1 | ColonyX port, generalized |
| T03 | [install.sh](./T03-install-sh.md) | Pending | T02 | T04 | L2 | Humanize-style; symlink default |
| T04 | [skills.sh packaging](./T04-skills-cli-packaging.md) | Pending | T03 | T05 | L3 | `npx skills add` compatible |
| T05 | [/superplan-init](./T05-superplan-init.md) | Pending | T04 | T06 | L4 | Workspace → hub folder → repos |
| T06 | [Hub templates](./T06-hub-templates.md) | Pending | T05 | T07 | L5 | Data-only; no skill copies |
| T07 | [Hub resolution](./T07-hub-resolution.md) | Pending | T06 | T08 | L6 | Global skills find the hub |
| T08 | [E2E dummy project](./T08-e2e-dummy.md) | Pending | T07 | — | L7 | Live install + dummy hub |

## Layer legend

| Layer | Meaning |
| ----- | ------- |
| L0 | Repo skeleton so `make verify` passes |
| L1 | Published pack under `skills/` |
| L2 | Local `install.sh` (agent select, symlink/copy) |
| L3 | `npx skills add` / skills.sh layout |
| L4 | Init UX: planning workspace + project folder + repo pick |
| L5 | Data-only hub templates |
| L6 | Runtime: resolve hub + bound repos; repo-rules-first |
| L7 | End-to-end proof on a dummy project |

## How to work

1. `/task-1-plan T01`
2. `/task-2-execute T01`
3. `/task-3-complete T01` → commit; push only if `origin` exists (`--no-push` to skip)
4. Repeat

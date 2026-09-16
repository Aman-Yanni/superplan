# @@HUB_NAME@@ — Planning hub

Plans and orchestrates work across bound product repos. No product code lives
here: the hub holds the phase plan (`phases/`), cross-repo notes (`rules/`),
and config (`superplan.yml`). Superplan skills stay **global** — do not copy
them into this folder.

## Repo rules come first (hard)

Every repo has its own rules and context. Read them before forming a
recommendation, a plan or an edit — never substitute a hub default or a guess.

1. For each repo a task touches, read its **context sources** (Repos table) first.
2. When anything disagrees: **repo sources > hub `rules/` spoke > this file**.
   Follow the repo, tell the human about the conflict.
3. A repo convention you haven't confirmed in its sources is an assumption.
   Go read, or ask.
4. Never edit a repo's `CLAUDE.md`, `AGENTS.md`, `.cursor/` rules or commands
   without explicit approval. Propose the edit instead.

## Repos

| Repo | Path | Context sources (read first) | Gate source |
| ---- | ---- | ---------------------------- | ----------- |
@@REPOS_TABLE@@

## Karpathy Behavioral Guidelines

1. **Think Before Coding** — state assumptions, surface tradeoffs, present interpretations instead of picking silently, stop and ask when unclear.
2. **Simplicity First** — minimum code for the request; no speculative features, abstractions or configurability.
3. **Surgical Changes** — touch only what the task needs; match existing style; clean up only what your change orphaned.
4. **Goal-Driven Execution** — define success criteria; write multi-step work as `step → verify: check` and loop until verified.

## Routing Map — read before you act

After the repo's own sources:

| Working on… | Read |
| ----------- | ---- |
@@ROUTING_ROWS@@
| Anything spanning repos | `rules/cross-repo.md` |
| Unsure or not covered | this file, then ask |

## Delivery

- Sequence of record: `phases/INDEX.md`. Loop: `/task-1-plan` → `/task-2-execute` → `/task-3-complete`.
- INDEX Status: `Pending` → `Planned` → `InProgress` → `✅` / `Blocked`. Never write `Done` in the INDEX.
- Close-out **does not merge** unless this hub's `superplan.yml` has `merge_prs: true` or the human opts in.

## Verify gates

Copied from each repo when known. If they differ from the repo, the repo wins.

@@VERIFY_GATES@@

## Cursor

Cursor has no `additionalDirectories`. Add each bound repo folder to the
workspace (File → Add Folder to Workspace) or open files by absolute path.
See `CURSOR.md`.

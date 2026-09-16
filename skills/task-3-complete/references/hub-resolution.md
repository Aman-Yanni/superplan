# Resolve the planning hub

Global Superplan skills must **not** treat cwd as the hub. Writing `phases/`
or `rules/` into a bound product repo is a bug.

## Steps

1. Read `"$HOME/.superplan/config.yml"` (not `~`). If it is missing, or has no
   `planning_workspace` / `hub`, **stop and ask**. Do not guess ColonyX or cwd.
2. The hub directory is the `hub:` path. Confirm `<hub>/superplan.yml` exists.
   If it does not, ask — do not create a hub from a work-loop skill (that is
   `/superplan-init`).
3. Bound repos are the `repos:` list in `<hub>/superplan.yml`. `merge_prs`
   defaults to false: **never merge** unless that field is true or the human
   opts in. Do not invent a git remote.
4. If cwd is one of those repo paths, still write `phases/` and hub `rules/`
   **only** under the hub directory.
5. If cwd is already the hub (cwd contains `superplan.yml`), you may use cwd
   as the hub — it must still match `hub:` or you ask.
6. Repo rules come first: **repo sources > hub `rules/` > Superplan defaults**.
   On conflict, follow the repo, tell the human, ask if a decision is needed.

If the hub cannot be resolved, stop. Do not write `phases/INDEX.md` into cwd
just because it is missing.

# Resolve the planning hub

The hub is the current project, not a machine-wide default. Walk up from cwd
for Superplan setup; if it is not there, ask. Writing `phases/` or `rules/`
into a bound product repo is a bug.

## Steps

1. **Current path is the hub** when this directory or an ancestor contains
   `superplan.yml`. Use the nearest one; do not ask.
2. **Otherwise ask** the human for the hub path. Do not guess a folder, do not
   read `$HOME/.superplan/config.yml`, and do not treat a product repo as the
   hub.
   - Confirm `<path>/superplan.yml` exists. If it does not, say so and point to
     `/superplan-init` (it writes `superplan.yml` into a new or existing hub).
     Do not create it from a work-loop skill.
   - Use that path for the rest of the session. Do not persist a machine-wide
     default.
3. Bound repos are the `repos:` list in `<hub>/superplan.yml`; the hub's
   `CLAUDE.md` / `AGENTS.md` Repos table adds their context sources and gates.
   `merge_prs` defaults to false: **never merge** unless that field is true or
   the human opts in. Do not invent a git remote.
4. If cwd is a bound repo (no `superplan.yml` here or above), it is not the
   hub. Write `phases/` and hub `rules/` **only** under the hub directory.
5. Repo rules come first: **repo sources > hub `rules/` > Superplan defaults**.
   On conflict, follow the repo, tell the human, ask if a decision is needed.

If the hub cannot be resolved, stop. Do not write `phases/INDEX.md` into cwd
just because it is missing.

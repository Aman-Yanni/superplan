# Resolve the planning hub

The hub is the current Superplan setup, not a machine-wide default. Two
layouts, same global skills:

1. **In-repo (turboplan-style).** `superplan.yml` lives in the product git
   repo. `phases/` and hub `rules/` live there too. Plan and execute in that
   folder.
2. **Separate hub.** `superplan.yml` lives in a planning folder. Bound product
   repos are listed in `repos:`. Write `phases/` only in the hub, never into
   those repos.

Walk up from cwd for Superplan setup; if it is not there, ask.

## Steps

1. **Current path is the hub** when this directory or an ancestor contains
   `superplan.yml`. Use the nearest one; do not ask.
2. **Otherwise ask** the human for the hub path. Do not guess a folder, do not
   read `$HOME/.superplan/config.yml`.
   - They may choose **this git repo** (in-repo) or a **separate** folder.
   - Confirm `<path>/superplan.yml` exists. If it does not, say so and point to
     `/superplan-init`. Do not create it from a work-loop skill.
   - Use that path for the rest of the session. Do not persist a machine-wide
     default.
3. Bound repos are the `repos:` list in `<hub>/superplan.yml`. If that list is
   empty and the hub is a git checkout, the hub itself is the sole bound repo.
4. Write `phases/` and hub `rules/` **only** under the hub directory. If the
   hub is also a product repo, that is in-repo mode and those files belong
   there. Do not write them into a bound repo that is not the hub.
5. Repo rules come first: **repo sources > hub `rules/` > Superplan defaults**.
   On conflict, follow the repo, tell the human, ask if a decision is needed.
   When in-repo, the repo's own `CLAUDE.md` / `.cursor/rules` still win over
   hub `rules/` spokes.

If the hub cannot be resolved, stop. Do not write `phases/INDEX.md` into cwd
just because it is missing.

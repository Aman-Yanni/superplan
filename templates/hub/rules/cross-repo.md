# Cross-repo — hub spoke

Adds knowledge that spans bound repos. It never replaces a repo's own rules.

Read order: **repo sources > this file > hub CLAUDE.md**.

## Sources of truth (read first, in order)

1. Each bound repo's `CLAUDE.md` / `AGENTS.md` / `.cursor/rules`
2. This spoke, for contracts and merge order only

## Verified facts

- Close-out does not merge unless the human opts in (`superplan.yml`
  `merge_prs: false` by default).
  <!-- last-verified: 2026-09 -->

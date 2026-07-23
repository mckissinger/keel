# Chore batch — release 1.20.1

Patch release that surfaces the `app-design-directions` archetype prune to the installed runtime.
One PR merged on `main` since `v1.20.0`. The installed plugin cache reports 1.20.0, so the running
plugin still carries the six named direction archetypes — the exact guidance the prune removed.
Reinstalling over the same version number is unreliable (the cache dedupes on version), so the
version must move before an update can pick it up. The `v1.20.1` release tag is cut on merge.

## Applied items

- **plugin-version-1.20.1** — `.claude-plugin/plugin.json` `version` bumped `1.20.0` → `1.20.1`
  (**patch**: a corrective change to existing behavior, not new capability — the skill's contract,
  "3–5 genuinely distinct directions," is unchanged; the prune fixes it failing that contract. No
  new or removed skills — count stays 29; no interface change). Since 1.20.0:
  - **prune-direction-archetypes** (#177, batch pin at `a87c996`) — deletes the six named direction
    archetypes (Terminal/Operator, Ledger/Institution, Instrument Panel, Workshop, Editorial System,
    Calm Default) from `skills/app-design-directions/references/direction-recipes.md`, which anchored
    mockup portfolios toward the same looks across different apps. Directions now derive fresh from
    the discovery brief and the axes of variation; a replacement "Portfolio composition" section
    keeps every portfolio rule and states the no-menu rationale. All distinctness machinery is
    byte-unchanged: the axes table, the ≥3-axes distinctness test, the grayscale test, the anti-slop
    gate, the signature element, the tradeoff line, and the domain-derivation section. One
    `SKILL.md` reference-table row updated to match.

  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
`bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`. The released
content itself landed verified with the PR and pin above and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly two files
(`.claude-plugin/plugin.json` + this chore spec); the `plugin.json` diff is exactly the `version`
`1.20.0`→`1.20.1` line and no other field; the result is valid JSON; `marketplace.json` unchanged
(no `version` field); nothing else in the tree moves. All five combined checks green. History since
`v1.20.0` is exactly the one PR enumerated above (carrying its own batch pin on `main`); the branch
is one commit ahead of `main`. No merge-decision mechanism, gate, hook, or guard *semantics* is
touched by a version-string bump → no `/security-review`. The version-visible-to-the-installed-runtime
effect is a [runtime] property that only a reinstall proves — carried into the post-merge install
(tag + plugin update on merge), correctly out of branch scope.

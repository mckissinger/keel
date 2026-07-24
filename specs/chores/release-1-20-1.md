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
verified: clean at ffaf297, 2026-07-22, via fresh-context keel:verifier subagent — exactly two files change (`plugin.json` version line only, valid JSON at 1.20.1; this chore spec); `marketplace.json` unchanged with no version field; one commit ahead of main; skill count 29; history since v1.20.0 (`ce4c5b0`) is exactly #177 with no omitted or phantom entries; the cited prune landed empirically (all six archetypes absent from `direction-recipes.md`, every distinctness section byte-unchanged per `git diff ce4c5b0..421cf57`); all 5 combined checks green (34 chore specs, 29 skills, 62 anchors) + `plugin validate --strict` + self-tests (check-verified-pin 36/0, check-plan 21/0). Verifier correction carried forward: the word "Terminal" survives at `direction-recipes.md:41` inside the pre-existing illustrative tradeoff-line quote — an example label in an untouched section, not a menu archetype, which makes #177's pin phrasing ("survive only in this chore spec's deletion record") slightly overstated but is not a gap. The installed-runtime pickup is the [runtime] reinstall — out of branch scope, closed by the post-merge tag + plugin update.

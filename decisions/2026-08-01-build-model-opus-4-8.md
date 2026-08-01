# 2026-08-01 — Build model steps back to Opus 4.8; the two-model shape is unchanged

This entry amends `decisions/2026-07-25-two-model-routing.md` **by reference** — that file is not
edited; it remains the record of why routing is two-model and why the pins are full model IDs. What
changes is one value: every build/execution surface moves from `claude-opus-5` to
**`claude-opus-4-8`**. The `verifier` stays `claude-fable-5`. Nothing else in the routing policy
moves.

## Why

The owner's call (2026-08-01): field feedback on Opus 5 has been poor, and the owner prefers to
build on Opus 4.8 until that picture changes. This is recorded as an **owner judgment from
third-party reports, not a measured regression in keel's own runs** — no keel project attributed a
bounce or a defect to Opus 5 before this change. If keel-side evidence accumulates in either
direction, record it here (with confounds, per the capability ledger's honest-figures rule) rather
than re-arguing from external sentiment.

## What holds

- **The decorrelation principle is untouched** — builds and verification still run on distinct
  models, and the verifier (Fable 5) remains at-least-as-capable as the builder; if anything the
  capability gap between builder and checker widens, which the ledger's self-justification argument
  favors.
- **The `Routing:` tag still drives effort only.** With one build model, the tag sets build effort
  and the verifier's escalation floor, exactly as the 2026-07-25 entry left it.
- **Full model IDs stay the rule.** This bump is itself the deliberate, reviewed hand-edit the
  2026-07-25 entry priced in when it chose concrete IDs over aliases.

## Surfaces touched

`references/model-routing.md` (the canonical table + prose), `references/milestones-and-verification.md`
§4's routing paragraph, `skills/implement-milestone/SKILL.md` frontmatter,
`skills/implement-feature/SKILL.md` step 1, `skills/punch-list/SKILL.md`'s dispatch arg. Historical
records (the two-model-routing change/milestone specs, release notes, prior decisions) are **not**
rewritten — they describe what was true when they landed.

# 2026-08-03 — Build model returns to Opus 5; the two-model shape is unchanged

This entry reverses `decisions/2026-08-01-build-model-opus-4-8.md` and amends
`decisions/2026-07-25-two-model-routing.md` **by reference** — neither file is edited; both remain the
record of what was true when they landed. What changes is one value: every build/execution surface moves
from `claude-opus-4-8` back to **`claude-opus-5`**. The `verifier` stays `claude-fable-5`. Nothing else in
the routing policy moves.

## Why

The owner's call (2026-08-03): reverse the 2026-08-01 step back to Opus 4.8 and build on Opus 5 again. The
2026-08-01 revert was recorded as an **owner judgment from third-party field reports, not a measured
regression in keel's own runs** — no keel project attributed a bounce or a defect to Opus 5. This reversal
is the same kind of owner judgment in the other direction. As the 2026-07-25 entry asks, keel-side evidence
in either direction should be recorded here (with confounds, per the capability ledger's honest-figures
rule) rather than re-argued from external sentiment; none has accumulated on keel's own runs to date.

## What holds

- **The decorrelation principle is untouched** — builds and verification still run on distinct models, and
  the verifier (Fable 5) remains at-least-as-capable as the builder. With the builder back on Opus 5 the
  builder/checker capability gap narrows relative to the Opus-4.8 interval, but the rule the ledger cares
  about — verify on a different, no-weaker model — still holds (Fable 5 is the decorrelated checker).
- **The `Routing:` tag still drives effort only.** With one build model, the tag sets build effort and the
  verifier's escalation floor, exactly as the 2026-07-25 entry left it.
- **Full model IDs stay the rule.** This bump is itself the deliberate, reviewed hand-edit the 2026-07-25
  entry priced in when it chose concrete IDs over aliases.

## Surfaces touched

`references/model-routing.md` (the canonical table + prose), `references/milestones-and-verification.md`
§4's routing paragraph, `skills/implement-milestone/SKILL.md` frontmatter,
`skills/implement-feature/SKILL.md` step 1, `skills/punch-list/SKILL.md`'s dispatch arg — exactly the five
surfaces `decisions/2026-08-01-build-model-opus-4-8.md` named. Historical records (the two-model-routing and
build-model-opus-4-8 change/milestone/chore specs, release notes, prior decisions) are **not** rewritten —
they describe what was true when they landed.

# Chore batch — build-model-opus-5

Single-theme chore: the build/execution model repoints from `claude-opus-4-8` back to `claude-opus-5`
across every operative routing surface, per the owner's 2026-08-03 call
(`decisions/2026-08-03-build-model-opus-5.md`), reversing the 2026-08-01 step-back. The verifier stays
`claude-fable-5`; the routing policy's shape (two models, decorrelated, effort by `Routing:` tag) is
unchanged. Historical specs/decisions/release notes keep their Opus 4.8 text.

## Applied items

- **routing-doc** — `references/model-routing.md`: every operative `claude-opus-4-8` / "Opus 4.8"
  becomes `claude-opus-5` / "Opus 5" (table rows, decorrelation prose, resolution-order note, effort
  note, dispatch note), and the tied-decisions line prepends `decisions/2026-08-03-build-model-opus-5.md`.
  - Done-condition: `grep -n "claude-opus-4-8" references/model-routing.md` returns nothing (the two
    `build-model-opus-4-8.md` decision-filename cross-refs legitimately remain and are not
    `claude-`-prefixed); the verifier row still pins `claude-fable-5`; the tied-decisions line names the
    2026-08-03 entry first.
- **routing-paragraph** — `references/milestones-and-verification.md` §4: "every build runs Opus 5".
  - Done-condition: the §4 routing paragraph names Opus 5 and contains no "Opus 4.8" mention.
- **skill-pins** — `skills/implement-milestone/SKILL.md` frontmatter `model: claude-opus-5`;
  `skills/implement-feature/SKILL.md` step 1's build-dispatch sentence names `claude-opus-5` (both
  mentions); `skills/punch-list/SKILL.md`'s per-group dispatch arg names `claude-opus-5`.
  - Done-condition: `grep -rn "claude-opus-4-8" skills/ agents/` returns nothing, and
    `grep -c "claude-opus-5"` finds ≥1 in each of the three skill files; `agents/verifier.md` still pins
    `claude-fable-5`.
- **decision-entry** — `decisions/2026-08-03-build-model-opus-5.md` exists, reverses the 2026-08-01
  entry and amends the 2026-07-25 entry by reference, and records the change as an owner judgment (the
  reverse direction of the 2026-08-01 call), not a measured keel-side regression.
  - Done-condition: the decision file exists with those three properties.
- **scope** — historical records are not rewritten: the 2026-08-01 decision, the `build-model-opus-4-8`
  chore spec, the two-model-routing change/milestone specs, and release notes keep their prior text.
  - Done-condition: `git diff --name-only main...HEAD` lists only the five live surfaces + the new
    decision doc + this chore spec; no historical record is in the diff.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
`bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`, plus the frontmatter/
neutral/plan self-tests — all green on the branch.

## verification

fresh-context verifier subagent against this file + the diff: each Applied-item done-condition confirmed
with file:line evidence; the verifier row stays `claude-fable-5` and no build-model value reads Opus 4.8;
the diff touches only the five live surfaces named in `decisions/2026-08-03-build-model-opus-5.md` plus
this chore spec and that decision doc; no historical record is rewritten; all combined checks green. This
is a doc/frontmatter value swap — no gate/guard/hook/merge-decision semantics — so no `/security-review`.
On a clean verdict the verifier writes the `verified:` pin; the build session never pins its own work.

verified: clean at 910a714, 2026-08-03, via fresh-context verifier (all five Applied-item done-conditions confirmed with file:line evidence — model-routing.md and milestones-and-verification.md carry no `claude-opus-4-8`/"Opus 4.8", skill pins in implement-milestone/implement-feature/punch-list read `claude-opus-5`, `agents/verifier.md` still `claude-fable-5`, decision doc reverses 2026-08-01 and amends 2026-07-25 by reference as owner judgment, diff scope is exactly the 7 named files; `claude plugin validate --strict .`, `check-neutral.sh`, `check-plan.sh`, `check-skill-frontmatter.sh`, `check-skill-anchors.sh`, and the three self-tests all PASS)

# Chore batch — build-model-opus-4-8

Single-theme chore: the build/execution model repoints from `claude-opus-5` to `claude-opus-4-8`
across every operative routing surface, per the owner's 2026-08-01 call
(`decisions/2026-08-01-build-model-opus-4-8.md`). The verifier stays `claude-fable-5`; the routing
policy's shape (two models, decorrelated, effort by `Routing:` tag) is unchanged. Historical
specs/decisions/release notes keep their Opus 5 text.

## Applied items

- **routing-doc** — `references/model-routing.md`: every operative `claude-opus-5` / "Opus 5"
  becomes `claude-opus-4-8` / "Opus 4.8" (table rows, decorrelation prose, resolution-order note,
  effort note, dispatch note), and the tied-decisions line adds
  `decisions/2026-08-01-build-model-opus-4-8.md`.
  - Done-condition: `grep -rn "opus-5\|Opus 5\|Opus-5" references/model-routing.md` returns
    nothing; the verifier row still pins `claude-fable-5`; the tied-decisions line names the
    2026-08-01 entry.
- **routing-paragraph** — `references/milestones-and-verification.md` §4: "every build runs Opus
  4.8".
  - Done-condition: the §4 routing paragraph names Opus 4.8 and contains no Opus 5 mention.
- **skill-pins** — `skills/implement-milestone/SKILL.md` frontmatter `model: claude-opus-4-8`;
  `skills/implement-feature/SKILL.md` step 1's build-dispatch sentence names `claude-opus-4-8`
  (both mentions); `skills/punch-list/SKILL.md`'s per-group dispatch arg names `claude-opus-4-8`.
  - Done-condition: `grep -rn "opus-5\|Opus 5\|Opus-5" skills/ agents/` returns nothing, and
    `grep -c "claude-opus-4-8"` finds ≥1 in each of the three skill files.
- **decision-entry** — `decisions/2026-08-01-build-model-opus-4-8.md` exists, amends the
  2026-07-25 entry by reference, and records the change as an owner judgment from third-party
  reports, not a measured keel-side regression.
  - Done-condition: the decision file exists with those three properties.

## Combined checks

`bash scripts/check-verified-pin.test.sh` (36 passed), `bash scripts/check-neutral.test.sh` (17 passed), `bash scripts/check-plan.test.sh` (21 passed), `bash scripts/check-neutral.sh` (PASS), `bash scripts/check-plan.sh` (PASS), `bash scripts/check-skill-frontmatter.sh` (PASS), `bash scripts/check-skill-anchors.sh` (PASS) — all green on the branch.

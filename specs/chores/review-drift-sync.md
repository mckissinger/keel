# Chore batch — review-drift-sync

Documentation-drift sync from review findings: three doc/citation groups applied via the
punch-list chore lane, one batch pin. No gate, guard, hook, or script *semantics* change —
the two script edits are message/comment strings only.

## Applied items

- **plan-path-sync** — done when the plan-path definition in
  `references/milestones-and-verification.md` matches the shipped gate everywhere it is
  stated: §5's definition reads plan paths = `specs/**` + `design/**` + `decisions/**` +
  `deferrals/**` minus the runtime-affecting carve-outs `specs/stack-profile.md` and
  `specs/run-command-inventory.txt` (which are code), and both downstream restatements
  (the plan-PR paragraph and the workbench-composition paragraph) carry the same expanded
  definition instead of the stale `specs/** + design/**` shorthand.

- **autonomy-citation-repoint** — done when every citation of the retired
  `decisions/2026-07-autonomy-modes.md` is repointed to the superseding pair
  `decisions/2026-07-05-autonomy-modes-v2.md` + `decisions/2026-07-genesis-envelope.md`
  (never-auto list citations going to genesis-envelope §(c)), across
  `references/milestones-and-verification.md`, `scripts/merge-guard.sh` (header comment +
  emit string only), `scripts/session-bootstrap.sh` (invariant string only), and the
  `app-design-directions`, `auto`, `auto-merge`, `implement-feature`, `interview`,
  `land-feature`, `provision`, `punch-list`, `review-feature`, `spec-change`,
  `spec-feature`, and `spec-foundation` skills — and a grep for the old filename outside
  `decisions/` history returns no hits.

- **spec-foundation-design-gate-handoff** — done when `skills/spec-foundation/SKILL.md`
  step 3 describes the real kickoff sequence: after spec-foundation stops, the sitting
  hands to the design-system gate (`app-design-directions`, when the deliverable has a UI)
  and only then to `provision` (dispatched by `kickoff`) — no longer "end the kickoff
  sitting by invoking `provision`" directly.

- **kickoff-loop-names-land-feature** — done when `skills/kickoff/SKILL.md`'s per-feature
  loop diagram carries a `land-feature` row (merge the feature's reviewed PRs in stack
  order, one per-merge approval at a time, attended) between the verify row and the
  `review-feature` row, so the loop no longer skips the merge step.

- **reply-rate-floor-documented** — done when both spec-campaign templates document that
  the reply-rate floor arms only when BOTH fields are present in `stop-conditions.json`:
  `skills/spec-campaign/templates/campaign-spec.md`'s stop-conditions list names the two
  required fields (`reply_rate_min` + `reply_rate_min_after`), and
  `skills/spec-campaign/templates/readback.mjs`'s header comment shows
  `reply_rate_min_after` in the example JSON plus the NOTE that omitting either field
  means the floor check never fires.

## Combined checks

All CI checks run locally on the assembled branch, all green: self-tests
(`check-verified-pin.test.sh`, `check-neutral.test.sh`, `session-bootstrap.test.sh`,
`merge-guard.test.sh`, `guard-branch-rules.test.sh`, `attended-marker-parity.test.sh`,
`check-auto-preflight.test.sh`, `check-plan.test.sh`, `check-skill-frontmatter.test.sh`,
`check-skill-anchors.test.sh`), lints (`check-neutral.sh`, `check-plan.sh` — 74 milestone
+ 35 chore specs, `check-skill-frontmatter.sh` — 29 skills, `check-skill-anchors.sh` —
62 anchors), and `claude plugin validate --strict .`.

verified: clean at 0f53b0e, 2026-07-29, via punch-list (evidence in PR #183)

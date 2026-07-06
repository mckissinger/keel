# Chore batch — post-review-hardening-prose

Punch-list batch: prose-only skill-doc updates following the 2026-07-05 full review — retire stale "mockups" language in favor of the workbench-composition referent, and make verify-milestone's description of the pin gate match the gate's actual mechanism (expanded plan paths, honesty about the drift claim).

## Applied items

- **review-feature-description** — `skills/review-feature/SKILL.md` frontmatter description now says each surface is screenshotted and diffed against the feature's workbench composition instead of "side-by-side with the feature's own mockups".
  - Done-condition: the description no longer references the feature's mockups; it names the workbench composition as the review referent.

- **kickoff-review-feature-line** — `skills/kickoff/SKILL.md` per-feature loop diagram: the review-feature line reads "render vs the feature's workbench composition" (was "the feature's mockups"), with column alignment preserved.
  - Done-condition: the loop diagram names the workbench composition, and the four lines' trailing annotations stay aligned.

- **adopt-movement2-referent** — `skills/adopt/SKILL.md` step 4 opens with "Movement-2 workbench compositions and fidelity done-conditions need a committed referent" (was "Movement-2 mockups").
  - Done-condition: step 4 no longer calls the Movement-2 referent "mockups".

- **spec-foundation-feature-spec-line** — `skills/spec-foundation/SKILL.md` specs-tree comment for `features/<feature>.md` describes the deep feature spec as "interview outcome + workbench composition reference + its milestone list" (was "screen mockups").
  - Done-condition: the tree comment references the workbench composition reference, not screen mockups.

- **verify-milestone-plan-paths** — `skills/verify-milestone/SKILL.md` CI-gate paragraph: plan paths now read `specs/**` + `design/**` + `decisions/**` + `deferrals/**` minus the runtime-affecting carve-outs (`specs/stack-profile.md`, `specs/run-command-inventory.txt`, which count as code), and the "verified code == merged code" claim is qualified as drift-freedom at content level when the base has not moved under the PR, citing `decisions/2026-07-05-pin-gate-honesty.md`.
  - Done-condition: the paragraph's plan-path list matches `scripts/check-verified-pin.sh`, and the gate's guarantee is stated conditionally rather than unconditionally.

## Combined checks

`bash scripts/check-verified-pin.test.sh`, `bash scripts/check-neutral.test.sh`, `bash scripts/session-bootstrap.test.sh`, `bash scripts/merge-guard.test.sh`, `bash scripts/guard-branch-rules.test.sh`, `bash scripts/attended-marker-parity.test.sh`, `bash scripts/check-auto-preflight.test.sh`, `bash scripts/check-plan.test.sh`, `bash scripts/check-skill-frontmatter.test.sh`, `bash scripts/check-skill-anchors.test.sh` — all PASS; repo lints `check-neutral.sh`, `check-plan.sh` (40 milestone + 9 chore specs... plus this one), `check-skill-frontmatter.sh` (17 skill files), `check-skill-anchors.sh` (20 anchors) — all PASS; `claude plugin validate --strict .` — Validation passed. All green on the combined branch.

verified: clean at dbfca25, 2026-07-06, via punch-list (evidence in PR #93)

# Chore batch — verification-economy

Compressed implementation of the 2026-08-05 harvest slate's Tier-1 verification-economy items
(digest: `specs/reviews/2026-08-05-harvest.md`, F1/F3/F5), authorized by the owner 2026-08-06 as
direct implementation with a fresh-context verifier pass in place of per-item spec-change ceremony.

## Applied items

- **ci-green-repin (F1)** — `references/milestones-and-verification.md` §5 gains the CI-green rule:
  a base move leaving code byte-identical outside plan paths re-pins on the PR's own green required
  checks, no local suite re-run. `skills/land-feature/SKILL.md` applies it at all three re-pin sites
  (independent-sibling cycle, cascade conflict-only bullet, diamond step 3 — the diamond keeps its
  local whole-repo terminal guard).
  - Done-condition: §5 states the rule with its mechanical bound (`git diff` empty outside plan
    paths) and both non-empty outcomes (conflict-resolved → local green run; behavioral → full
    re-verification); all three land-feature sites cite it rather than prescribing an unconditional
    local re-run.
- **plan-path-fast-lane (F1)** — §5 gains the fast lane: a verdict whose only discrepancies are on
  plan paths, with code byte-identical to the walked SHA, is fixed and pinned in the verify session
  (plan-only commit). `skills/verify-milestone/SKILL.md` carries the procedure in its fix-nothing
  hard rule and its no-record bullet.
  - Done-condition: the carve-out is bounded mechanically (any code-path discrepancy — including
    `specs/stack-profile.md` / `specs/run-command-inventory.txt` — voids it) and both files state
    the bound.
- **builder-terminal-suite-cut (F1 + Opus 5 guidance)** — `skills/implement-milestone/SKILL.md`
  step 5: the builder's inner loop (bottom-up ladder, single-test-first, affected suites green)
  stands, the terminal full-suite pass is removed — the full proof run belongs to `verify-milestone`
  per §9.1.
  - Done-condition: step 5 no longer requires "all committed suites green" at handoff and names
    §9.1 as the proof run's owner.
- **plan-pass-cap (new, from the 2026-08-06 transcript review)** — §5's adversarial plan pass is
  capped at three unattended iterations; still-blocking findings after the third pass are a
  stop-point surfaced to the user.
  - Done-condition: the cap and the stop-point behavior are stated in the §5 plan-pass paragraph.
- **keel-sync-manifest (F3)** — `skills/spec-foundation/SKILL.md` and `skills/adopt/SKILL.md` copy
  steps write `scripts/KEEL-SYNC` (line 1: `keel <installed plugin version>`; then one copied-script
  filename per line), updated on every copy/re-sync; `skills/provision/SKILL.md`'s preflight-copy
  line records into the same manifest; `skills/status/SKILL.md` reads it as a sweep source and
  reports a version-behind manifest under Blocked-on-user with the one-batch-sync-chore-PR remedy.
  - Done-condition: both copy sites, the provision line, and both status sections (sources +
    blocked-on-user) name the manifest and the batch remedy.
- **observed-execution (F5)** — `skills/verify-milestone/SKILL.md` gains the skip-counts-first-class
  hard rule (a spec-named test is observed executing or recorded `unmeasured: <cause>`, which is
  unrun → `blocked`); `references/milestones-and-verification.md` §8.5 gains the mirror rule
  (non-live suites are provably key-blind); `skills/provision/SKILL.md` step 7 dry-runs every
  env-gated rung armed (executed count > 0) and unarmed (loud skip) and authors the sanctioned
  parse-never-source injection runner.
  - Done-condition: all three surfaces state their half; no green verdict can ride a silent skip
    and no non-live suite can silently carry the live key.

## Combined checks

Recorded at build time, re-run by the verifier: `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`, `bash scripts/check-skill-frontmatter.sh`,
`bash scripts/check-skill-anchors.sh`, plus the script self-tests
(`check-verified-pin.test.sh`, `check-plan.test.sh`, `check-neutral.test.sh`,
`merge-guard.test.sh`, `guard-branch-rules.test.sh`, `repin.test.sh`,
`session-bootstrap.test.sh`, `check-skill-frontmatter.test.sh`, `check-skill-anchors.test.sh`,
`check-auto-preflight.test.sh`, `attended-marker-parity.test.sh`, `check-branch-protection.test.sh`,
`check-prep-auto-merge.test.sh`).

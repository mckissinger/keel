# Milestone — plan-only-fast-path

Change context: `specs/changes/plan-only-fast-path.md`. One milestone. Adds a
classification mode to `scripts/check-verified-pin.sh` (+ self-test cases in
`scripts/check-verified-pin.test.sh`), wires a plan-only early-exit into keel's own
`.github/workflows/ci.yml` `guards` job, adds the fast-path clause to
`references/profile-interface.md`'s Q11 CI-topology scar, adds one pointer sentence to
`skills/spec-foundation/SKILL.md`'s kickoff CI-wiring paragraph, and adds
`scripts/skill-anchors/plan-only-fast-path.txt`. No other gate, guard, hook, or skill
changes behavior.

**Integration seams.**

- **The classifier is the gate script's own `is_plan_path`, exposed — never duplicated.**
  `check-verified-pin.sh` is the canonical implementation copied into projects
  (`skills/spec-foundation/SKILL.md`, copy-don't-re-author; propagated by the
  `scripts/KEEL-SYNC` manifest). The new mode reuses the function in place; no path list
  appears in any CI yaml. The carve-outs cut both ways and must survive: `specs/stack-profile.md`
  and `specs/run-command-inventory.txt` are code (their diff is NOT plan-only);
  `.claude/keel-auto-merge.json` and `.claude/keel-auto-merge-checks.json` are plan.
- **The default invocation is untouched.** The gate's existing contract (drift check,
  bootstrap window, base-ref freshness fetch, exit semantics, output lines) is consumed
  by CI in keel and every field project; the mode is additive and the no-flag path must
  behave byte-identically. The existing self-tests are the regression floor and are not
  edited — new cases are appended only.
- **The classification mode ignores the bootstrap window and pins.** It answers exactly
  one question — is the diff base..head plan-only? — and never consults `verified:`
  lines or the bootstrap exemption. (A fast-path skip must not accidentally widen during
  bootstrap, and classification has no business reading pins.)
- **Early-exit shape, not `paths:` filters.** Under branch protection a required check
  that never reports blocks the merge; GitHub counts a skipped/early-exited job as
  satisfied only when the job runs and reports. So the CI shape is: a first step runs
  the classifier and sets an output; subsequent steps in the exempted job carry
  `if:` on that output; the job always reports. Classification only applies on
  `pull_request` events (a push to `main` has no PR diff to classify — mirroring the
  existing `if: github.event_name == 'pull_request'` idiom in the same file).
- **Which checks may never take the fast path:** `verified-pin` and `plan-lint` (they
  are the plan gates) and `security-review` (the intake decision: universal, the
  2026-07-29 compensating control untouched). In keel's ci.yml those three jobs are not
  edited at all; the doctrine states the same rule for field projects' equivalents.
- **Q11 owns the doctrine; spec-foundation carries one pointer.** The fast-path clause
  extends the existing Q11 CI-topology scar in `references/profile-interface.md` (build
  once and share / cache / sharding multiplies fixed setup) with its fourth clause; it
  does not restate the classification rules (the script owns them). The
  `spec-foundation` kickoff CI paragraph gains one sentence so new projects wire the
  early-exit from birth. **Existing-project convergence splits in two:** the script's
  new mode arrives via the existing KEEL-SYNC batch-sync chore (scripts only — that
  mechanism never edits CI yaml, and is not modified here); the CI *wiring* is a
  per-project one-line chore (punch-list grain) each project applies when its synced
  script carries the mode — named here as deliberately manual, not solved by this
  milestone.
- **`template-contract.md` is deliberately not edited** — its tier-1 recipe governs the
  protection/review wiring shapes, not suite-job internals; the fast-path clause lives
  in Q11 where the CI-topology doctrine already sits.
- **Anchor file is new, file-per-feature** (`scripts/skill-anchors/plan-only-fast-path.txt`,
  never an edit to an existing anchor file).

## Done-conditions

- [auto] **The classification mode exists with exact semantics.**
  `scripts/check-verified-pin.sh` invoked as `check-verified-pin.sh --plan-only-check
  [HEAD_REF]` (honoring the same `BASE_REF` env default) exits **0** iff every file in
  the diff base..head is a plan path per the script's own `is_plan_path` — including
  both carve-out directions — and exits **non-zero** naming the first non-plan file
  otherwise; a genuinely empty diff classifies as plan-only. **The mode fails closed:**
  an unresolvable `BASE_REF`/`HEAD_REF`, a missing merge base, or a diff command that
  errors exits **non-zero (never plan-only)** — the gate's own scar class (a failed diff
  reading as empty) must not become a suite skip; the mode distinguishes empty-because-
  no-changes from empty-because-the-diff-failed. The mode never reads `verified:` lines
  and never applies the bootstrap window. *Falsifiable:* a mode that duplicates the path
  rules instead of calling `is_plan_path`, consults pins/bootstrap, classifies
  `specs/stack-profile.md` as plan, or exits 0 on an unresolvable ref or missing merge
  base, fails.
- [auto] **The default invocation is byte-equivalent in behavior.** With no mode flag,
  the script's behavior is unchanged: the diff of the script shows the existing code
  paths intact (mode handling is additive dispatch), and every pre-existing test case in
  `scripts/check-verified-pin.test.sh` passes unmodified — no existing case is edited or
  deleted. *Falsifiable:* any edited/deleted pre-existing test case, or a changed
  default-path behavior, fails.
- [auto] **Self-test coverage for the mode.** `scripts/check-verified-pin.test.sh` gains
  appended cases covering at least: pure plan diff → 0; pure code diff → non-zero; a
  `specs/stack-profile.md` diff → non-zero (code carve-out); a
  `.claude/keel-auto-merge.json` diff → 0 (plan carve-out); a mixed diff → non-zero;
  empty diff → 0; **an unresolvable base ref (and/or missing merge base) → non-zero**
  (the fail-closed case). All cases green. *Falsifiable:* any of the seven behaviors
  untested fails.
- [auto] **Keel's `guards` job takes the fast path; the three universal checks do not.**
  In `.github/workflows/ci.yml`, the `guards` job gains a classification step (running
  the canonical script's mode, `pull_request` events only) whose step **absorbs the
  classifier's exit code into an output** — a non-plan diff must set the output, never
  fail the step — and subsequent steps carry `if:` guards on that output; on push events
  and on non-plan-only PRs every step runs exactly as today. The reporting property is
  asserted by yaml shape: **no job-level `if:` and no `paths:`/`paths-ignore:` filter**
  (the job always runs and reports; steps skipped by `if:` do not fail a job). The
  `verified-pin`, `plan-lint`, and `security-review` jobs are byte-unchanged.
  *Falsifiable:* a `paths:`/`paths-ignore:` filter anywhere, a job-level `if:` on
  `guards`, a classification step whose non-zero exit fails the job on ordinary code
  PRs, or an edit to any of the three universal jobs, fails.
- [auto] **Q11 carries the fast-path doctrine.** The Q11 CI-topology scar in
  `references/profile-interface.md` gains the clause: suite/build-grade CI jobs
  early-exit on plan-only diffs via the project's **copied canonical classifier**
  (`check-verified-pin.sh --plan-only-check`), **never a workflow `paths:` filter on a
  required check** (a required check that never reports wedges the merge; an early-exited
  job reports), and the pin gate, the plan lint, and the security review run on **every**
  PR; the clause also notes the classifier's full-history precondition (the checkout
  needs the merge base — `fetch-depth: 0` or an equivalent deepened fetch). The scar's
  existing three clauses are preserved unchanged. Stack-neutral phrasing.
  *Falsifiable:* a version missing the never-paths-filter rule, missing the
  three-universal-checks rule, or altering the existing clauses, fails.
- [auto] **The spec-foundation pointer lands without disturbing its host.**
  `skills/spec-foundation/SKILL.md`'s kickoff CI-wiring paragraph gains one sentence
  wiring the suite-job early-exit via the copied classifier; the rest of the file is
  byte-preserved. *Falsifiable:* any other change to the file fails.
- [auto] **The anchor file exists and pins the load-bearing sentences.**
  `scripts/skill-anchors/plan-only-fast-path.txt` exists (new file, §4 collision rule)
  and anchors at least: the never-paths-filter rule, the three-universal-checks rule,
  and the classifier-is-canonical (never duplicated) rule — and
  `scripts/check-skill-anchors.sh` passes with the anchor total risen. *Falsifiable:* an
  absent file or a missing named sentence fails.
- [auto] **No weakening.** `scripts/merge-guard.sh`, `scripts/repin.sh`,
  `scripts/session-bootstrap.sh`, `references/milestones-and-verification.md`, and
  `decisions/2026-07-29-security-review-wiring.md` are untouched (diff file-list); the
  gate's drift/pin semantics are unchanged (condition 2); no required check is removed
  or renamed. *Falsifiable:* any of these edited fails.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; script + yaml +
doctrine prose — closable by reading the named files, running the gate self-tests, and
running the named checks). No `[runtime]` walk — keel is no-UI. Pre-pin
`/security-review` applies: this milestone edits the shipped canonical gate script (a
trust-base-adjacent surface), so the review runs before the pin.

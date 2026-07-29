# Milestone — security-review-required-check: the autonomy tier's third check gets a wiring path

**Goal:** the three-check autonomy contract stands exactly as the decisions state it (`verified-pin` +
`plan-lint` + `security-review` required before any auto posture arms), and every surface that touches
it now tells the truth about **who wires what, when**: kickoff wires two, auto-entry wires the third,
a recorded default implementation exists, and the preflight's failure message points at the remediation
instead of dead-ending. A keel-stood-up project no longer hits an unexplained auto-preflight wall.

**Change:** `specs/changes/security-review-required-check.md`. **No-UI** → two-dimension
done-conditions (logic + behavioral completeness). **Depends on:** nothing. **Parallelizable:** no (one
coherent contract clarification across a script message, four skill/reference surfaces, and a decision
entry). **Routing:** reasoning-heavy — this edits the stated shape of the autonomy entry gate's
contract; the wrong wording would weaken the compensating control the decisions layer rests on.

## Done-conditions

### Logic / invariants

- [auto] **The preflight's gating logic is byte-identical.** `scripts/check-auto-preflight.sh`: the
  `REQUIRED_CHECKS` default still reads `verified-pin plan-lint security-review`, the
  `PREFLIGHT_REQUIRED_CHECKS` override is unchanged, and check **(b)**'s (the required-status-check
  assertion's) pass/fail semantics are untouched — the only diff in this script is message text: the
  failure output for a check in the default set that is missing or present-but-not-required now names
  the remediation path in **check-generic** wording valid for any of the three (wire the missing job
  as a CI check, make it a required status check — the autonomy tier's job set and its recorded
  default implementation live in the template contract — then re-run the preflight): one message, no
  per-check conditional, so "message text only" stays literally true. `file:line` evidence; every
  existing pass/fail expectation in `scripts/check-auto-preflight.test.sh` holds, with only message
  assertions updated (each such edit named in the PR body).
- [auto] `references/template-contract.md`: the tier-1 required-checks item states the **tier split**
  — `verified-pin` + `plan-lint` wired at kickoff; the `security-review` job wired **before any auto
  posture arms** (genesis at bootstrap per `decisions/2026-07-genesis-envelope.md`; `auto:feature`/
  `auto:run` as preflight remediation) — and records the as-of-2026-07 default implementation
  (Anthropic's `claude-code-security-review` GitHub Action), hedged as an example satisfying the
  contract, never a mandate. The three-check contract itself is not weakened: the item still requires
  all three before auto.
- [auto] `skills/spec-foundation/SKILL.md`: the repo-setup step still wires exactly `verified-pin` +
  `plan-lint` at kickoff and now adds one sentence naming where the third check comes from (the
  autonomy tier, wired at auto-entry per the template contract) — so the file no longer silently
  contradicts `provision`/`template-contract`.
- [auto] `skills/adopt/SKILL.md`: the repo-setup step wires **both** `verified-pin` and `plan-lint`
  (copy `check-verified-pin.sh` + `check-plan.sh` + `repin.sh`, wire the two check jobs), matching
  `spec-foundation`, with the same one-sentence autonomy-tier pointer.
- [auto] `skills/provision/SKILL.md`: the auto-envelope preflight description at **line 72** (the
  line that names all three checks as required — provision's step-8 attended guardrails check at
  line 52 never names security-review and is untouched) gains the tier-provenance clarification only:
  it still describes the preflight asserting all three at arming (matching
  `check-auto-preflight.sh:49`), and now states where each comes from — `verified-pin` + `plan-lint`
  wired at kickoff, `security-review` wired at auto-entry (genesis at bootstrap; `auto:feature`/`run`
  as preflight remediation). What the preflight asserts does not change.
- [auto] `skills/auto/SKILL.md`: the preflight step's summary enumerates **all** the script's checks —
  (a) allowlist, (a2) bundled-merge scan, (b) required checks, (c) env-vars, (d) `allow_auto_merge`
  enabled — closing the known three-of-four gap at `skills/auto/SKILL.md:29`; and the step gains the
  remediation line: a check-(b) failure on `security-review` routes to wiring the job (the template
  contract's recorded default implementation), making it required, and re-running the preflight.
- [auto] **The decisions layer is untouched and satisfied:** `decisions/2026-07-autonomy-modes.md`,
  `decisions/2026-07-genesis-envelope.md`, and `specs/deferrals/per-project-auto-merge.md` have empty
  diffs — the compensating control, the genesis three-check wiring mandate, and the deferral's
  re-entry precondition all hold under the clarified prose (the preflight still asserts the check by
  default).
- [auto] New append-only `decisions/2026-07-29-security-review-wiring.md` records: the contradiction
  (three surfaces demanded a check the attended kickoff never wires), the falsified first draft (drop
  the check) and what falsified it (the compensating-control clause, the genesis envelope's safety
  argument), and the direction chosen (tier split + recorded default implementation + actionable
  preflight failure). It amends nothing in place — prior decisions' diffs are empty.

### Behavioral completeness

- [auto] **Corpus coherence:** `grep -rn "security-review" skills/ references/` shows every surviving
  mention is one of: the per-milestone `/security-review` pre-pin gate — **wherever it appears**
  (`skills/verify-milestone/SKILL.md`, `references/milestones-and-verification.md`,
  `skills/spec-feature/SKILL.md`, `skills/spec-change/SKILL.md`, `skills/harden/SKILL.md` +
  `skills/harden/templates/hardening-report.md`), **all with empty diffs** — the autonomy-tier
  required check **with its wiring path** (template-contract, provision, spec-foundation, adopt,
  auto), or this change's own records. No operative file claims the kickoff
  wires the security-review job, and none leaves the required check without a stated wiring path.
  (`scripts/` greps are out of this condition's scope: the preflight's default set and its tests
  legitimately name the check, and `scripts/check-verified-pin.test.sh:156`'s "root-proof
  (the security-review attack)" is a historical scar, not a contract claim.)
- [auto] All script self-test suites pass (`check-auto-preflight` with its message-assertion updates;
  every other suite unchanged and green), `scripts/check-skill-anchors.sh` +
  `scripts/check-skill-frontmatter.sh` + `scripts/check-neutral.sh` pass on the edited files (the
  Action is named as a hedged, as-of-dated recorded default — the neutrality guard's example idiom),
  and `claude plugin validate --strict .` passes.
- [auto] **Gates otherwise untouched:** `scripts/check-verified-pin.sh`, `scripts/merge-guard.sh`,
  `scripts/guard-branch-rules.sh`, `scripts/repin.sh`, and `hooks/hooks.json` have empty diffs.

## verification

verifier subagent against this file — every `[auto]` condition checked against source with `file:line`
evidence (the byte-identical gating logic with message-only diff, the five prose surfaces' tier-split
statements, the empty diffs across the decisions layer and the per-milestone gate, the corpus grep with
its named buckets); the suites run, not re-derived. **Dispatch the verifier at `xhigh`**
(reasoning-heavy). **`/security-review` of the milestone's diff is a pre-pin precondition** — the
milestone edits the autonomy entry gate's contract prose and failure messaging: the adversarial
question is whether any wording change weakens the compensating control or opens a path to arming auto
without the third check (it must not — the preflight's pass/fail matrix is proven unchanged by the
existing test expectations), with confirmed findings remediated before the pin.

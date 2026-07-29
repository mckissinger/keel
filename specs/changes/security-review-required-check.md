# Change — security-review-required-check: the autonomy tier's third check gets a wiring path

**Provenance:** the 2026-07-29 corpus review, **corrected by its own adversarial plan pass** — the
first draft of this change proposed dropping the check; the plan pass falsified that premise.

## The contradiction, correctly diagnosed

Three operative surfaces demand `security-review` as a **required status check**:
`references/template-contract.md:21` (tier-1: three required-check CI jobs),
`skills/provision/SKILL.md:72`, and `scripts/check-auto-preflight.sh:49`
(`REQUIRED_CHECKS="verified-pin plan-lint security-review"`, failing closed). But the attended kickoff
path never creates it — `skills/spec-foundation/SKILL.md:122` wires only `verified-pin` + `plan-lint`
(`adopt` wires less still) and no skill says how the third job comes to exist. Net effect: a
keel-stood-up project hits an auto-preflight failure that reads as a dead end.

The first-draft fix — drop the check — was wrong, and the plan pass proved it with the decisions
layer: `decisions/2026-07-autonomy-modes.md:23-26` names the blanket required security-review check as
**the compensating control for auto-mode** (the measured ~17% classifier false-negative residual,
"added precisely because the human eyeball is out of the loop");
`decisions/2026-07-genesis-envelope.md:26-27, :86` has genesis wire all three checks and rests its
forged-approval safety argument on all three passing; `specs/deferrals/per-project-auto-merge.md:24-33`
makes the required check a parked feature's re-entry precondition. The check is load-bearing. The
defect is only that **nothing tells an attended project how to wire it**.

## The decision (direction A)

Keep the three-check autonomy contract exactly as the decisions state it. Close the wiring gap:

- **The tier split becomes explicit.** Attended kickoff wires `verified-pin` + `plan-lint` (unchanged
  behavior, now stated as the kickoff tier). The `security-review` job is the **autonomy-tier**
  requirement — wired before arming any `keel:auto` posture (genesis already wires it at bootstrap per
  the envelope; `auto:feature`/`auto:run` on an existing project wire it as preflight remediation).
- **A recorded default implementation.** The contract gets an as-of-2026-07 example that satisfies it —
  Anthropic's `claude-code-security-review` GitHub Action — hedged as the recorded default, never a
  mandate (the contract stays neutral; any job asserting the same class of review satisfies it).
- **The preflight failure becomes actionable.** `check-auto-preflight.sh`'s pass/fail semantics are
  untouched (the compensating control stands); its failure output for a missing/unrequired check in
  the default set names the remediation path instead of dead-ending.
- **`adopt` closes its sibling gap:** its repo setup wires both kickoff-tier jobs, matching
  `spec-foundation`.
- The deferral's re-entry precondition needs no reconciliation — the preflight still asserts the check
  by default.

Recorded as `decisions/2026-07-29-security-review-wiring.md` (append-only; rides the milestone).

Fans into **one milestone**: `specs/milestones/security-review-required-check.md`.

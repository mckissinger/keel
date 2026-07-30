# 2026-07-29 — The security-review required check keeps its mandate and gains a wiring path

The three-check autonomy contract stands: `verified-pin` + `plan-lint` + `security-review` must be
*required* status checks before any `keel:auto` posture arms. What changes is that the corpus now
states **who wires each, when** — a **two-tier split** (kickoff wires two, auto-entry wires the
third), a **recorded default implementation** for the third, and a preflight failure message that
names the remediation instead of dead-ending.

## The contradiction

Three operative surfaces demanded the check and none said where the job comes from.
`references/template-contract.md` tier 1, `skills/provision/SKILL.md`'s auto-provision envelope, and
`scripts/check-auto-preflight.sh`'s `REQUIRED_CHECKS` default all named `security-review`; the
attended kickoff wired only `verified-pin` + `plan-lint` (`skills/spec-foundation/SKILL.md`, with
`adopt` wiring less still — verified-pin alone). Net effect on a keel-stood-up project: the first
`auto:feature` hit a check-(b) gap that read as a dead end, with no surface telling the operator the
job was theirs to create.

## The falsified first draft — drop the check

The first draft of the change proposed deleting `security-review` from the required set, on the
premise that the corpus demanded a thing keel never built. Its own adversarial plan pass killed the
premise against the decisions layer, on two independent grounds:

1. **It is the compensating control, not a nice-to-have.** `decisions/2026-07-autonomy-modes.md`
   §(b) names the blanket required security-review check as what compensates auto mode's measured
   ~17% classifier false-negative residual — "added precisely because the human eyeball is out of
   the loop." Dropping it removes the only substitute for the merge eyeball a mode delegates away.
2. **The genesis safety argument rests on all three passing.**
   `decisions/2026-07-genesis-envelope.md` has the bootstrap wire all three, and its forged-approval
   argument is that the approval artifact is not the merge authority — the required checks are,
   because genesis reaches a merge only via `gh pr merge --auto` on a PR GitHub merges when and only
   when `verified-pin`, `plan-lint`, and `security-review` pass. Two of three weakens that backstop.

`specs/deferrals/per-project-auto-merge.md` compounds it: the required check is that parked
feature's stated re-entry precondition. The check is load-bearing three ways over. **The defect was
never the mandate — it was that nothing told an attended project how to satisfy it.**

## The direction chosen

- **The tier split becomes explicit.** `verified-pin` + `plan-lint` are the **kickoff tier**, wired
  by `spec-foundation` (and now `adopt`, which was short a gate) when the repo is stood up.
  `security-review` is the **autonomy tier**, wired before any auto posture arms: genesis at
  bootstrap, `auto:feature`/`auto:run` as **preflight remediation** on a standing project. Behavior
  at kickoff is unchanged; it is now *stated* as a tier rather than read as an omission.
- **A recorded default implementation.** The template contract records Anthropic's
  `claude-code-security-review` GitHub Action, as of 2026-07, as a default that *satisfies* the
  contract — hedged, never a mandate. Any job asserting the same class of per-PR diff review under a
  required status check satisfies it, and the check name stays config
  (`PREFLIGHT_REQUIRED_CHECKS`), not a vendor hardcode.
- **The preflight failure becomes actionable, with the gating logic untouched.**
  `check-auto-preflight.sh` keeps its default set, its override, and check (b)'s exact pass/fail
  semantics — the only diff is message text: one **check-generic** message (no per-check branch)
  that names wire-the-job → make-it-required → re-run, points at the contract for the tier's job set
  and defaults, and states outright that dropping a job to clear the gate is not the fix.
- **`auto`'s preflight summary stops under-reporting the gate.** It named three of the script's
  checks; it now enumerates (a), (a2), (b), (c), (d), so the operator's mental model matches what
  fails closed.

## Relationship to the prior decisions (amended by reference, not edited)

This entry **amends `decisions/2026-07-autonomy-modes.md`, `decisions/2026-07-05-autonomy-modes-v2.md`,
and `decisions/2026-07-genesis-envelope.md` by reference — it edits none of them**, and
`specs/deferrals/per-project-auto-merge.md` needs no reconciliation: the preflight still asserts the
check by default, so the deferral's re-entry precondition is untouched. Nothing here relaxes a gate.
The doctrine's compensating control, the envelope's three-check bootstrap, and the deferral's
precondition all hold verbatim under the clarified prose — what moved is only the corpus's account
of which posture creates the job.

The per-milestone `/security-review` adversarial pass (`references/milestones-and-verification.md`
§3, `skills/verify-milestone/SKILL.md`) is a **different control** and is not touched by this entry:
that one is a pre-pin review step run by an agent on a milestone's diff; this one is a server-side
required status check on every code PR in an auto-mode project. Sharing a name is not sharing a
mechanism — conflating them was the reading that made "drop the check" look cheap.

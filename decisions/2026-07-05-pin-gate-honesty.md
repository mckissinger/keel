# 2026-07-05 — Pin-gate honesty: the gate is the drift half, not the verification

This entry amends the verified-pin doctrine **by reference**. It does **not** edit
`decisions/2026-07-01-model-capability-ledger.md` in place — the ledger's audit-machinery
item ("the verified-pin gate") remains the record of why the gate exists. This entry
narrows what that item may be *claimed* to prove, after the 2026-07-05 full review
reproduced the gap live.

## (a) What prompted it — the reproduced fail-open

With `BASE_REF` and `HEAD_REF` both resolvable but sharing no merge base (orphan history;
the realistic trigger is a shallow CI clone — `actions/checkout` without `fetch-depth: 0`),
`git diff BASE...HEAD` failed *inside* the process substitution at the gate's diff step,
the failure never propagated past `set -euo pipefail`, and a code PR carrying an
**unpinned** milestone spec passed with "no changes — pass", exit 0 — the exact fail-open
class the script's own step 0 was written to close, surviving one step past its fix.
That is closed mechanically in `review-hardening-m1-gate` (merge-base precondition,
fail-closed). The same review also confirmed two claim-level gaps this entry records.

## (b) The reframing — two halves, one control

The gate mechanically proves **drift-freedom**: a `verified:` line exists, its pinned SHA
is an ancestor of the PR head, and no code changed since. It does **not** prove a
verification ran — a self-written `verified: clean at <HEAD>` passes it unconditionally.
The verification half is the **fresh-session `verify-milestone` process** (an independent
context checks the work against the spec and only then writes the pin). The two together
are the control; no shipped prose may present the gate alone as enforcing verification.
**Confound honest:** the process half is behavioral, not server-enforced — a session that
violates the fresh-context rule and self-pins defeats it, and the gate cannot tell. The
mechanical backstop for *that* is review + the guards' authority delegation, not this gate.

## (c) The merge-mode scope — prose + protection, not a post-merge checker

"Verified code == merged code" holds at **content level when the base has not moved under
the PR** — the gate runs pre-merge on the PR head, never on the merged commit. Decided
(feature interview, 2026-07-05): close the moved-base gap with **prose + protection** —
state the guarantee honestly everywhere it ships, and make `spec-foundation`/`adopt`
require the **require-branches-up-to-date** branch-protection setting, the load-bearing
half: a moved base then forces the branch to absorb it, real code enters the pin's drift
window, and the gate itself demands re-verification of the combined state. Squash merge
(the prescribed mode for independent milestones) preserves content under that regime; its
cost — the pinned SHA is not an ancestor of `main` afterward — is a traceability nuance
(PR + spec pin line carry it), not a correctness gap, and the prose says so instead of
implying SHA-level identity. A mechanical post-merge re-check on `main` is a recorded
**deferral** (`specs/deferrals/post-merge-drift-check.md`), not built.

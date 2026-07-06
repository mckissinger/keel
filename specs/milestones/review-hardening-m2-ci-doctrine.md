# Milestone — review-hardening-m2-ci-doctrine: keel runs its own gate; the gate's claims match its mechanism

**Goal:** keel's CI runs `check-verified-pin.sh` against every real PR (not just the
self-test), and every shipped statement of the gate's guarantee says what the mechanism
actually proves: the gate is the **drift half** of a two-part control whose verification
half is the fresh-session `verify-milestone` process — with the merge-mode scope stated
honestly and the moved-base gap closed by required branch protection, not by wishing.

**Feature:** `specs/features/review-hardening.md`. **No-UI** → two-dimension
done-conditions. **Parallelizable:** no (follows m1 — the CI job and prose describe m1's
fixed semantics; m3 follows to avoid a same-file rebase on `skills/adopt/SKILL.md`).

## The honest claim (what all prose converges on)

- The pin gate mechanically proves **drift-freedom**: a `verified:` line exists, its SHA is
  an ancestor of the PR head, and no code changed since. It does **not** prove a
  verification ran — that is the fresh-session `verify-milestone` process's half, and the
  two together are the control. Prose stops presenting the gate alone as enforcing
  verification.
- The "verified code == merged code" claim holds at **content level when the base has not
  moved under the PR** — which is why **require-branches-up-to-date** branch protection is
  part of the shipped process: a moved base forces the branch to absorb it, real code
  enters the pin's drift window, and the gate itself demands re-verification of the
  combined state. Squash-merge (keel's prescribed mode for independent milestones)
  preserves content under that regime; its cost is that the pinned SHA is not an ancestor
  of `main` afterward — traceability lives in the PR + the spec's pin line, and the prose
  says so instead of implying SHA-level identity.

## Done-conditions

### Logic / invariants

- [auto] `.github/workflows/ci.yml`: a `verified-pin gate (this repo)` step runs
  `scripts/check-verified-pin.sh` against the PR's real diff on every `pull_request` event
  (`BASE_REF` derived from the PR's base ref; checkout with `fetch-depth: 0` so the
  merge-base precondition from m1 is satisfiable), and is skipped (or trivially passes) on
  `push` to `main` where no PR diff exists. The self-test step remains unchanged alongside
  it.
- [auto] `scripts/check-verified-pin.sh` header (comment block only — m1 owns the logic):
  states the two-part-control framing (drift half here, verification half in the
  fresh-session process), the content-level merge-mode scope including the squash/SHA
  nuance, and the require-branches-up-to-date dependency. The header no longer reads as if
  the gate alone enforces that verification happened.
- [auto] `scripts/merge-guard.sh` header (its accepted-limits paragraph — comment text
  only, no logic change): the documented bypass list includes `eval` alongside the existing
  wrapper-shell/`xargs`/alias examples, and the authority sentence names branch protection
  **+ required checks**; `scripts/guard-branch-rules.sh`'s header documents the same limits
  and its m1 fallback-scan degrade direction. Both header statements are asserted by a
  header-doc tripwire grep committed in this milestone's suite additions (the tripwire
  lands here, with the prose it pins — never in m1, whose merge-guard byte-identity claim
  it would break).
- [auto] `scripts/session-bootstrap.sh`: both banner variants' pin line carries the honest
  form — the merge gate is a fresh-session verified pin **plus** the drift gate (or
  equivalent wording that names both halves) — and no shipped line claims the gate proves
  verification by itself.
- [auto] `skills/spec-foundation/SKILL.md` and `skills/adopt/SKILL.md`: the repo-setup /
  branch-protection step requires **require-branches-up-to-date** (alongside the existing
  required checks), with the one-sentence why (a moved base must re-enter the drift window
  before merge). The existing squash-for-independent / merge-commit-for-stacked doctrine is
  unchanged.
- [auto] `decisions/2026-07-05-pin-gate-honesty.md` exists (file-per-entry): amends the
  model-capability ledger **by reference**, recording the drift-half reframing, the
  merge-mode scope decision (prose + protection, per the feature's interview record), and
  the reproduced fail-open that prompted it — with the confound-honest style the ledger
  mandates.
- [auto] `specs/deferrals/post-merge-drift-check.md` exists: a mechanical post-merge
  re-check on `main` (re-diff the merged result against the pinned tree, alert on
  divergence) is consciously deferred, with the rationale (required checks + up-to-date
  protection close the practical gap; the residual is auditability, not correctness) and
  the revisit trigger (evidence of a real post-merge divergence, or an auto-mode project
  where PR-side controls prove insufficient).

### Behavioral completeness

- [auto] `scripts/session-bootstrap.test.sh` still passes with the reworded banner lines
  (fixtures updated in the same change); `scripts/check-skill-anchors.sh` passes — any
  anchor pinned to the old wording is updated in the same change, never deleted to dodge
  the lint.
- [auto] `scripts/check-neutral.sh` passes on all changed scripts; every pre-existing
  self-test suite still passes; `claude plugin validate --strict .` passes.
- [runtime] From a full-depth clone of this branch, a live invocation of the **exact
  command line the new CI step runs** (same `BASE_REF` derivation, same script call, as
  written in `ci.yml`) against this milestone's real diff returns the correct verdict for
  it — proving the step's command works outside the self-test before any PR exists (the
  step's first in-CI execution is then observable on this milestone's code PR as ordinary
  evidence, after the pin). Deterministic core covered by the committed
  `scripts/check-verified-pin.test.sh` (named committed test).

## verification

verifier subagent against this file — the CI step's event coverage (pull_request with
full-depth checkout, no false failure on push), the four prose surfaces' convergence on the
two-part-control claim (header, banner, spec-foundation, adopt — checked against the actual
mechanism m1 shipped, never against this spec's paraphrase), the decision + deferral
entries' existence and by-reference discipline, and that no shipped sentence still claims
the gate alone proves verification.

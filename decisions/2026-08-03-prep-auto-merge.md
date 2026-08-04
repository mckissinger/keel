# 2026-08-03 — prep-auto-merge: a separate skill prepares a repo's auto-merge prerequisites

Records the resolved design for milestone `prep-auto-merge`
(`specs/milestones/prep-auto-merge.md`, `specs/changes/prep-auto-merge.md`): a human-invoked
`keel:prep-auto-merge` that prepares what `keel:arm-auto-merge` requires, without the certifier building
the floor it certifies. Amends by reference (edits nothing in place)
`decisions/2026-08-02-per-project-auto-merge-authorization.md` and
`decisions/2026-08-01-required-checks-protection.md`.

## The problem

`keel:arm-auto-merge` is a pure certifier: it asserts a repo's protection is live and commits the marker
only on green. On a repo that isn't set up (no required security-review workflow, check names ≠ keel's,
`allow_auto_merge` off) it can only *name* each gap — it deliberately provisions nothing, because the
required-checks backstop is safe precisely by *independently verifying* the floor rather than *building*
it. So setup was manual, guided only by the gap messages. The owner wanted near-one-command setup.

## The mechanism — a separate skill that scaffolds and prints, never mutates or arms

`keel:prep-auto-merge` (`disable-model-invocation`, human-invoked) runs the shared
`scripts/check-branch-protection.sh` to discover gaps, then:
- **Scaffolds, as a plain code PR the human merges:** `.github/workflows/security-review.yml` (copied
  **verbatim** from `skills/prep-auto-merge/templates/security-review.yml`), and — for a name-mismatch
  repo — the names-only `.claude/keel-auto-merge-checks.json`.
- **Prints, never runs:** the branch-protection `PUT` and `allow_auto_merge` `PATCH` `gh api` commands.
- **Reminds, never sets:** the `ANTHROPIC_API_KEY` secret.
- **Never arms:** points at `keel:arm-auto-merge`.

## The settled forks

- **Separate skill, not a `prep` arg on arm-auto-merge — assert ≠ provision.** The tool that certifies the
  floor must never be the tool that built it; two skills mean a bug in the preparer can never masquerade as
  certification (arming re-runs the independent assertion regardless of what prep did). This is the whole
  safety basis of the backstop.
- **Print-only for the security-settings mutations (owner-approved).** Branch protection and
  `allow_auto_merge` are the load-bearing floor; the skill prints the exact commands for the human to run
  and never executes a security-settings mutation itself.
- **The scaffold lands as a plain code PR.** A repo being prepped is pre-gating (that is the point), so
  there is no verified-pin gate to satisfy; a workflow-file addition is normally human-reviewed anyway. The
  human merges it.
- **The check-contract is in scope and generated from REPORTING contexts, never protection's required
  list.** A name-mismatch repo needs both the workflow and the #205 names-only contract. Its
  `required_checks` derive from the repo's actually-reporting check-runs
  (`gh api …/commits/<sha>/check-runs`) or CI job names — **never** `gh api …/protection`'s required list,
  which is 404/incomplete on exactly the repos prep targets (that *is* the gap). It must include every
  check the repo already enforces (a committed contract *replaces* the asserted set, so a narrow read would
  silently weaken the floor) and is presented to the human to confirm in the PR. Names-only, no
  `pattern`/`external` (`decisions/2026-08-03-arm-auto-merge-check-contract.md`).
- **The ordered flow gates on the job actually reporting, not on prose.** A required status-check context
  that no job yet reports wedges every PR (`decisions/2026-08-01-required-checks-protection.md`). So prep is
  a gated sequence — scaffold PR → merge + confirm the review job reported (`…/check-runs`) → print & apply
  the protection command that requires it → arm — and it withholds the wedging command until the check-runs
  probe confirms the job reported.
- **The secret is the human's, always.** A credential is out of bounds; the skill reminds (per-repo for
  personal accounts, or an org-level secret) but never sets it.

## Trust: the scaffold becomes a repo's floor, so it is tested, not trusted

The materialized workflow *becomes* the repo's arming floor, so a hollow scaffold would be a security
defect. `scripts/check-prep-auto-merge.test.sh` proves the committed template PASSES
`check-branch-protection.sh` (b2) when copied verbatim, pins a full commit SHA, and keeps that SHA in
lockstep with keel's own `.github/workflows/ci.yml` (single source — a keel SHA bump updates the scaffold,
never forks it). Because keel runs tests as **named** CI steps (not a glob), that test — and the
previously-unwired `check-branch-protection.test.sh` — are wired into `ci.yml`, so the lockstep invariant
cannot rot silently. `/security-review` runs pre-pin on the build branch. The load-bearing gates are
untouched: prep prepares; `keel:arm-auto-merge` still independently certifies before the marker is written.

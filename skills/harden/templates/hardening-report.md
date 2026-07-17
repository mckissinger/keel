# Hardening report — <project>, YYYY-MM-DD

<!-- The audit's one durable artifact: specs/reviews/YYYY-MM-DD-harden.md,
     committed on a branch, landed as a plan-only PR. Doubles as the launch
     go/no-go record. -->

## Scope

- Run type: pre-launch | pre-release re-run — prior report: none | `<path>`
- Dimensions run: <list; any exclusion with its recorded reason>
- Probes recorded n/a: <probe → why, per the "n/a + why" convention>

## Severity scale

<!-- This template owns the scale — triage ranks with it; the skill body does not
     restate it. -->

- **launch-blocking** — exploitable or data-losing on a real-user path; the launch
  does not proceed with this open.
- **pre-launch** — must close before real users, but not exploitable today
  (a missing restore path, an unwired alert).
- **post-launch** — real, scheduled after launch with a deferral entry and a
  closing condition.
- **hardening** — defense-in-depth beyond the product's current stakes; accepted
  or batched at the user's call.

## Findings

<!-- Ranked, most severe first. Every finding carries evidence (file:line or
     command + output excerpt) and decomposes into exactly one keel grain. -->

| # | Severity | Finding (one sentence) | Evidence | Grain |
|---|---|---|---|---|
| 1 | launch-blocking | | `file:line` / command + excerpt | spec-change (+ /security-review pre-pin if hard-invariant) |
| 2 | pre-launch | | | punch-list |

### Finding detail

<!-- Per finding: what the probe requires, what actually exists, where, and the
     remediation direction (named, not implemented — remediation never runs in
     the audit sitting). -->

## Accepted risks

<!-- Each triaged-deferred finding, with its specs/deferrals/ entry and closing
     condition. A prior run's accepted risks re-surface here with their status:
     still-accepted | closed | re-opened. -->

| Finding | Deferral entry | Closing condition |
|---|---|---|

## Clean

<!-- What was checked and came back clean — named probes, not "the rest." A
     checked-clean dimension is a success; padding is not. -->

## Go/no-go

<!-- Derived, not decided here: launch-blocking findings open → no-go until their
     milestones close; otherwise go, with the accepted-risk list as the launch
     record. The user decides at the slate approval. -->

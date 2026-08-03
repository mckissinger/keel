# 2026-08-02 — `implement-feature` runs through landing into a prepared review, under a committed marker

Records the **run-through posture** for `skills/implement-feature/SKILL.md`: when a repo is armed for
committed auto-merge, the orchestration verb no longer strands the owner at a stack of open PRs — it
drives landing itself and stops at the one judgment the framework reserves for a human, the feature
review. It amends by reference (editing nothing in place) `decisions/2026-07-04-attended-auto-merge.md`
and its sibling `decisions/2026-08-02-per-project-auto-merge-authorization.md` (the standing-authorization
doctrine this posture consumes).

## The three authorization branches

`implement-feature` resolves its end-state in one fixed, mutually-exclusive order — matching the
guards' precedence `mode > committed`:

1. **Active `keel:auto` mode → the autonomy branch.** Cadence ask becomes a ledgered default; the run
   lands each pinned, gate-passing PR with `--auto` and proceeds (unchanged from
   `decisions/2026-07-05-autonomy-modes-v2.md`).
2. **Else a valid committed marker → the run-through branch.** Same landing step — a bare, un-chained
   `gh pr merge <pr> --auto` on each pinned, gate-passing PR (merge-guard's committed-project row emits
   `allow`; guard-branch-rules `exit 0` defers) — reached by the committed marker, not a mode.
3. **Else → the "stops at merge" default.** All milestones built/verified/pinned, PRs open, the user
   merges. Exactly as before this decision.

The per-session **attended** marker is deliberately **not** an `implement-feature` branch: it governs
an interactive per-merge flow, not this orchestration, so it does not appear in the ordering.

## Why the committed branch stops at a *prepared* review, not the open-PR stack

The owner's actual friction was ending a run at a stack of open PRs they then had to merge by hand — a
tap the required-checks floor already makes redundant. So the run-through **lands** the wave. But it
stops at `review-feature` **prepared, not passed**: the aesthetic/completeness judgment, the feature-spec
sign-off, and the never-auto list are the human's, and the required-checks floor does not cover them.
The run renders the surfaces and stages the review inputs (UI) or reports done at the consolidated check
(no-UI), and **ends there** — it never renders a verdict on the review. This is the line the whole
feature draws: **checks replace the merge tap; they do not replace the taste gate.**

## The stop-point set (a written rule, not a per-run judgment)

The run asks mid-flight **only at true stop-points** — the un-pre-authorizable set the framework already
names: live/paid/irreversible spend, a missing credential, a red substrate (routed to the profile's Q12
remedy), a required `/security-review` finding, a `verify-milestone` `blocked` verdict (or a `discrepancy`
a remediation pass does not clear — a single `discrepancy` is normal build iteration, not a stop-point; the
verdict tokens are `clean` / `discrepancy` / `blocked`, there is no `fail`), a `merge-guard` `deny`, and a
genuine scope change. A stop-point **halts the run attended** with the five-line gate block and the run
ends on it — never silently deferred. **Everything else is notify-and-continue**: a run-note
(in-transcript, and appended to the run ledger when one exists), the run proceeds to the next independent
milestone, and all notes are surfaced together in the final handoff.

**No new notification infrastructure is invented.** keel has no push channel today; the mechanism is
run-notes + the existing five-line halt. The required-checks floor is what makes that safe — a missed
notification can never land code the three required checks did not inspect.

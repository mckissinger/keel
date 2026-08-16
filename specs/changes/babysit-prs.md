# Change — babysit-prs: background landing-cycle babysitter

Evidence base: `specs/reviews/2026-08-16-harness-efficiency.md` (T1a) — landing
separately as its own plan-only review PR, which merges **before** this plan PR so the
citation resolves on `main` at landing time. Transcript mining
across five field projects measured ~75 hours of attended CI-wait/merge choreography —
roughly 9× all test execution combined — with single `gh pr merge` waits of 210–464
minutes where a prepared merge sat pending human attention. The per-sibling landing cycle
(`skills/land-feature/SKILL.md`, "Under the full protection contract") is fully prescribed
prose the human currently executes by hand: watch checks settle, update each remaining PR
onto the moved `main`, re-pin under the CI-green rule, tap the merge.

**The change:** a standalone verb, `babysit-prs` — a skill owning the doctrine plus a saved
workflow — that runs this already-written cycle in the background for a queue of reviewed,
landing-approved PRs, and either drains merges under an existing authorization (active
mode / committed marker) or prepares everything and holds for the user's taps with one
batched notification. It automates the cycle's *waiting*, never its *authorizing*: the
three-branch merge-authorization order is inherited unchanged, and with no marker the loop
merges nothing.

Resolved at intake (2026-08-16, attended): standalone verb (not land-feature-internal) so
ad-hoc queues — chore, review, punch-list PRs — are covered, not only feature waves;
no-marker behavior is batch-and-notify (one notification when the whole queue is ready or
blocked, not per-PR pings); a genuinely red check is report-only (the PR drops from the
loop with the failing check named; no retry, no fix — fixes route through the normal
verbs, flakes through the flake doctrine, never masked by a babysitter re-fire).

Two further intake choices, recorded as chosen rather than overlooked: **the hold-mode
surface is the workflow's final report presented by the dispatching session per
`references/gate-presentation.md`** — keel has no push channel and this change invents no
notification infrastructure (the `implement-feature` precedent); and **the per-session
attended marker (`.claude/keel-attended-merge.json`) is not a drain authorization for this
workflow** — it belongs to the attended per-merge flow it was designed for; the babysitter
drains only under an active mode or the committed per-project marker.

Fans into **one milestone**: `specs/milestones/babysit-prs.md`. No UI (Q8.1: keel is
no-UI — movement 2 skipped).

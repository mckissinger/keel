# Subagent dispatch reports + run monitoring (shared)

Two orchestration contracts every keel skill that spawns subagents or watches long-running
checks applies. Owned here; the orchestration skills (`implement-feature`, `land-feature`,
`verify-milestone`, `auto`) cite this file and do not restate it. Both contracts are paid-for:
the 2026-08-05 harvest recorded five lost-report incidents in two projects in one week (F6) and
a recurring per-check babysitting pattern plus two false "ALL MERGED" reads (F8).

## 1. The dispatch report contract

**Name the required report sections in the dispatch prompt.** A verifier / security-review /
builder dispatch enumerates the sections its report must contain (e.g. a verifier: per-condition
verdicts with evidence, the discrepancy list, the unverifiable list). A subagent told "report
back" returns whatever its final turn happened to hold; a subagent handed a section list returns
a checkable artifact. Where the dispatch mechanism supports a structured-output schema, prefer it
— validation then happens at the tool layer and a malformed report retries itself.

**A placeholder or truncated report gets exactly one protocol resume.** The field failure shapes:
a subagent burns its budget and returns a stub; a final message arrives cut to one section; a
verifier defers its verdict to a delegate that never reports. The orchestrator's response is
mechanical, not improvised: resume that agent **once** with "return the report per the named
sections" (the harness's continue/SendMessage mechanism). If the resume also fails to produce the
named sections, the work is **unreported — treat it as not run** (a verifier's missing report is
an unverified milestone, never a pass) and surface the loss; never paper over it from the
orchestrator's memory of partial output, and never spawn repeat delegates hoping one reports.

**A report that names a section as empty is complete.** "Discrepancies: none" is a result; a
report missing the section is not. The distinction is what makes the one-resume rule cheap to
apply.

## 2. Settle-only monitoring

**Watch for ALL-SETTLED or first-failure — never per-check progress.** A session supervising CI
or a merge wave reports when everything being watched has settled (all checks concluded, all PRs
merged/closed) or on the first failure — not a turn per intermediate state ("four lanes green…
six green…"). Intermediate green states change no decision, and the turn-noise reads as stall to
the user (the recorded ask: "are you positive it is still running?"). One announcement when the
watch starts (what is watched, expected duration from the project's observed CI times), one when
it settles or fails.

**Empty command output is a failed read, never a success.** A watcher that parses `gh` output
must treat empty/absent output as "the read failed — re-check", never as "nothing left to wait
for". The recorded scar (twice, independently): a `gh` call returned empty during an API
hiccup and the loop concluded ALL MERGED while PRs sat open. The same rule as `land-feature`'s
poll-window contract — an exhausted or empty read reports **still pending — re-check**, and only
an affirmative read ("state: MERGED", "conclusion: failure") advances the watcher.

**Size the watch window to observed reality, and hand the wait to the harness.** The window comes
from this repo's measured check durations, never a tool default (a window shorter than the
slowest required check reads a green wave as failed). Where the harness offers a supervised wait
(a Monitor with an until-condition), prefer it over a hand-rolled poll loop — the babysitting
pattern (re-arming a capped monitor turn after turn) is the signal to lengthen the window, not to
poll faster.

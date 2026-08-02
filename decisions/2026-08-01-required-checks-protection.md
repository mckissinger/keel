# 2026-08-01 — Full protection, real checks: the merge backstop stops being prose

This entry amends **by reference** (editing nothing in place)
`decisions/2026-07-29-security-review-wiring.md` and the land-feature / review-feature flow
descriptions. It records the owner's 2026-08-01 decisions (built 2026-08-02 as the
`required-checks-wiring` change, milestones `required-checks-live` + `required-checks-doctrine`).

## What was decided, and why

**The gap:** every merge rule in keel ends with "GitHub's required checks decide" — and on keel's own
repo, that set was empty: no branch protection (live 404), one monolithic CI job, and a
`security-review` check the preflight asserted **by name only** (the #189 pin recorded the gap). The
owner's intent to move toward per-project auto-merge made the gap load-bearing: auto-merge would have
been delegation to nothing.

**Decision 1 — full, standard protection on `main`, chosen "regardless of keel's current setup":**
every change via PR (zero required approvals — the checks are the reviewers), required status checks
(`verified-pin`, `plan-lint`, `guards`, `security-review` on keel), strict branches-up-to-date,
admins enforced. Live on keel as of #195.

**Decision 2 — the security-review job wired live on keel and recorded as the concrete recipe** in
`references/template-contract.md`: Anthropic's `claude-code-security-review` action, SHA-pinned,
least-privilege permissions, secret-fed — still a recorded default satisfying the contract, never a
vendor mandate.

## The consequences accepted deliberately

- **The two direct-to-main plan-only flows are retired.** `land-feature`'s reconciliation and
  `review-feature`'s closure record now open **plan-only PRs** (pin-exempt as ever), landing under
  the standing merge authority. The protection contract forbids the old direct push; under auto-merge
  a plan-only PR lands on green with no added friction.
- **Independent-milestone waves gain a per-sibling cycle under strict.** Each landing makes the
  remaining PRs out-of-date; the update pulls landed sibling code into the pin's drift window, so
  `verified-pin` goes red **by design**. `land-feature` now writes the remedy (update → suite green →
  `repin.sh` → contexts re-fire) where "no cascade" used to be claimed unconditionally.
- **Fork PRs cannot merge.** A secret-backed required check can never go green on a fork-originated
  run. No keel flow depends on fork PRs; recorded, not worked around.

## The name-shaped check is closed: preflight check (b2)

`scripts/check-auto-preflight.sh` now asserts the `security-review` check's **content**, not just its
name: some workflow under `.github/workflows/` must both declare the context and match a
review-implementation pattern (default `claude-code-security-review`; `PREFLIGHT_SECREVIEW_PATTERN`
for a different in-Actions implementation; `PREFLIGHT_SECREVIEW_EXTERNAL=1` as a loud, echoed
attestation for a non-Actions provider — deliberate and visible, never silent). Check (b)'s semantics
are untouched; (b2) is additive and fail-closed. This is the "future hardening would assert workflow
content, not just the name" item from the #189 pin, built.

One operational caveat from the live dogfood rides with the recipe: the default action's per-PR cache
can mask an environmentally-failed scan as a later hollow green
(`specs/walks/2026-08-02-security-review-cache-mask.md` — the incident, the detection, the fix).

## What this does NOT resolve

`specs/deferrals/per-project-auto-merge.md` stays parked. Its stated re-entry precondition — the
security-review required check wired and verified live — is now **built**; un-deferring the committed
per-project auto-merge setting remains its own future spec-change, where the owner's requested
attended-run posture (implement-feature running through landing into a prepared review-feature, asking
mid-run only at true stop-points) should be designed alongside it. Nothing here relaxes a gate: the
human-merge default, the autonomy carve-outs, the never-auto list, and the pin gate hold verbatim.

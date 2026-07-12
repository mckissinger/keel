# Change — pin-gate-hardening

One milestone. Hardens the verified-pin gate's parsing and ships the canonical re-pin
script. Approved by Michael 2026-07-12 from the transcript-review slate
(`reviews/2026-07-12-transcript-harvest.md` findings 1–3; `reviews/2026-07-12-structural-review.md`
control-plane polish).

## Why (three real failures from dogfooded runs)

1. **Caveat-word false positive.** The gate scans the whole `verified:` line for
   "pending"/"unverified"/"to be verified". A relay pin whose *method/evidence prose*
   described a domain concept ("… e2e over pending-lead fixtures …") tripped it and
   blocked 3 of 4 green PRs (new-test-proj `681fb955`, 2026-07-11). The caveat rule's
   intent lives in the *verdict*, not the method text.
2. **Greedy SHA parse.** `sed 's/.* at ([0-9a-f]{7,40}),.*/'` matches the **last**
   ` at <sha>,` on the line, so a carry-forward note that mentions the old SHA in that
   shape repoints the gate at the *old* pin. A bidlevel session (2026-07-11) had to
   discover this and hand-design a "single unambiguous `at <sha>,`" line mid-recovery.
3. **Stale `origin/main` false drift.** The local gate (merge-guard consultation)
   diffed against a stale remote-tracking ref twice (new-test-proj `c4465d21`,
   `681fb955`), wrongly reporting post-pin drift on already-merged spec files.

Plus one process gap: the rebase → re-run-suites → re-pin flow is prescribed as prose at
three sites in two skills but executed by hand every time (edit + `--amend`), which produced a
stale-amend race (first edit didn't land in the commit). The pin *gate* is canonical-as-
script; the *re-pin* deserves the same treatment.

## Decisions taken (defaults, per the approved slate; caveat design revised by the
## adversarial plan pass)

- Caveat scan keeps its whole-line strictness but **strips backticked spans first**: a
  domain term that happens to contain a caveat word is written backticked
  (`` via e2e over the `pending-leads` suite ``) and no longer trips the gate, while a
  bare "— pending the runtime walk" caveat still fails exactly as today (the m4–m7
  anti-pattern test is untouched). The gate's failure message teaches the escape. (The
  originally-approved "scope to the verdict segment" design was rejected by the plan
  pass: the documented anti-pattern's caveat text sits *outside* the verdict segment,
  so segment-scoping would have weakened the gate against it.)
- SHA extraction anchors to the **first** ` at <hex>,` occurrence. Carry-forward notes
  reference the prior SHA as `from <sha>` (no ` at ` shape), so even a malformed note
  can't outrank the real pin.
- Base-ref freshness is **best-effort**: `origin/*` BASE_REFs are fetched before the
  diff; a failed fetch (offline, no remote) warns and proceeds with the local ref. CI
  (fresh checkout) is unaffected.
- `scripts/repin.sh` mechanizes the edit + commit + postcondition assertions only. It
  does **not** run the suites — re-running them green first stays the caller's
  judgment, per the cascade rule in `land-feature`. A repeated re-pin **replaces** the
  prior carry-forward clause (the chain lives in git history), never accumulates them.
- `scripts/check-plan.sh` carries a clone of both parsers (for chore-batch pin lines) —
  it gets the identical hardening in the same milestone, so the two shipped scripts
  never disagree about the same line.
- Distribution: `repin.sh` joins the explicit copy lists in `spec-foundation` (Repo
  setup) and `adopt`, alongside the gate scripts. Projects that already copied the gate
  get the fixes on their next `spec-foundation`/`adopt` copy; no retroactive push (same
  policy as every prior gate change).

## Milestone

`specs/milestones/pin-gate-hardening.md` — scripts + tests + the three prose pointers.

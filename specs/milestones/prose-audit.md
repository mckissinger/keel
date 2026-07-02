# Milestone — Fable-era prose audit + model-capability ledger

**Goal:** keel's 15 SKILL.md bodies read as objective + how-to-verify rather than stale
step-by-step prescription (without losing a single load-bearing ordering constraint), and a
dated ledger separates model-weakness-compensating mechanisms from permanent audit machinery.

**Change:** `specs/changes/prose-audit.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** everything else this cycle (build LAST — re-check against `main`).
**Parallelizable:** no (touches every skill body; must see final text).

## Done-conditions

### Logic / invariants
- [auto] Each of the 15 `skills/*/SKILL.md` bodies has been audited; the PR body records a
  per-skill verdict (rewritten to objective+verification, or left-as-is with the reason).
- [auto] **No invariant lost (the guardrail):** every load-bearing ordering constraint is still
  present and still ordered — branch-first (implement-milestone), verify-then-pin (never
  pin-then-review), the confirm-before-author gate (interview / spec-feature / spec-change), the
  stacked-PR bottom-up merge order (land-feature), fresh-session verification, halt-at-stop-points.
  The verifier greps each and confirms presence + ordering; any that reads as weakened is a
  discrepancy.
- [auto] Foreground-subagent assumptions in `skills/implement-feature/SKILL.md` and
  `skills/punch-list/SKILL.md` prose are corrected to background-by-default (or confirmed already
  neutral); no orchestration invariant changed.
- [auto] `decisions/<date>-model-capability-ledger.md` exists: the
  compensates-for-weakness vs. permanent-machinery split, verified-pin gate explicitly marked
  not-prunable, source figures stated honestly (Opus 4.6 sprint-decomposition removal ~38% cost,
  confounded — not "halved").
- [auto] `references/milestones-and-verification.md` §4 gains the horizon-sizing lens (coarser
  where stakes allow; the scar-backed parallel-collision guidance retained, not deleted).

### Behavioral completeness
- [auto] `scripts/check-neutral.sh` exits 0 (the audit must not introduce denylisted stack
  language); `scripts/check-plan.sh` still passes the corpus (audited skill bodies + the new
  decisions entry don't break lint); all script self-tests pass; `scripts/` untouched vs `main`.
- [auto] Descriptions/frontmatter unchanged (the packaging chore already restructured those —
  this milestone touches bodies only); no skill's `disable-model-invocation` / `allowed-tools` /
  `arguments` frontmatter is altered.

## verification
verifier subagent against this file, **heavier than a normal prose change** because the risk is
silent invariant loss: for each named ordering constraint, grep the owning skill and confirm it
is present AND ordered as before; diff each skill body vs `main` and flag any removed guardrail;
confirm the ledger's not-prunable marking and honest figures; `check-neutral.sh` + `check-plan.sh`
+ all self-tests. No surface/action change → no runtime walk; no hard invariant loosened (the
whole point is that none were) → no `/security-review`, but the invariant-preservation greps are
the load-bearing check.

verified: clean at d57ede9, 2026-07-02, via verifier subagent — heavy invariant-preservation pass (evidence in PR #58)

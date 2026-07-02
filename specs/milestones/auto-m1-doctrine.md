# Milestone — auto-m1-doctrine: the scoped doctrine amendment

**Goal:** the reversal of the permanent-human-merge-gate doctrine is recorded, scoped, and
argued *before* any mechanism ships — a `decisions/` entry that amends the model-capability
ledger by reference, plus the two doc surfaces that must not contradict it.

**Feature:** `specs/features/autonomy-modes.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing. **Parallelizable:** no (m2–m4 cite this entry; it lands first).

## Done-conditions

### Logic / invariants
- [auto] A new `decisions/2026-07-autonomy-modes.md` exists and states, each explicitly:
  (a) the **scope** — per-merge human approval is delegated to server-side required checks
  *only under an active `keel:auto` mode*; attended keel keeps the ask-floor unchanged;
  (b) the **trade** — the ~17% classifier false-negative residual, previously compensated by
  the human merge eyeball, is now compensated by required checks (verified-pin + plan-lint +
  profile CI ladder) **plus a blanket required security-review check** in auto-mode projects;
  (c) the **accepted design-pick trade** — in `auto:run` the agent picks a design direction
  and ledgers it; a possible redesign pass is accepted as the cost of zero interrupts;
  (d) the **never-auto list** — `--dangerously-skip-permissions`, go-live / live-key swaps,
  spend beyond pre-authorized caps — at every level;
  (e) the delegation is **to GitHub's required checks, never to agent judgment** (`--auto`
  only; plain merge stays ask).
- [auto] `decisions/2026-07-01-model-capability-ledger.md` is untouched vs `main`; the new
  entry amends it **by reference** (names the ledger and the specific line it scopes).
- [auto] `README.md` names the two autonomy modes in one short paragraph (posture levels,
  human-triggered only, merge authority delegated to required checks under the modes) without
  restating the decisions entry.
- [auto] `references/milestones-and-verification.md` §5 gains one sentence: under an active
  autonomy mode, per-merge approval is delegated to the server-side required checks per the
  decisions entry — the pin gate itself is unchanged.

### Behavioral completeness
- [auto] One-owner: the doctrine argument lives in the decisions entry alone; README and §5
  point at it in a sentence each, no third restatement.
- [auto] `scripts/check-neutral.sh` exits 0 (README and §5 are scanned corpus).
- [auto] No script or gate behavior change: `scripts/` untouched vs `main`; all script
  self-tests pass; `scripts/check-plan.sh` passes the corpus.

## verification
verifier subagent against this file (prose greps for a–e, the by-reference rule, the
one-owner sweep) + `scripts/check-neutral.sh` + `scripts/check-plan.sh` + all script
self-tests. No surface/action change → no runtime walk. No mechanism loosened in this
milestone (prose only) → no `/security-review`.

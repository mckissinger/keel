# auto-hardening m2 — kickoff→auto charter seam dogfood (partial confirmation)

**2026-07-05.** Records the outcome of the first dogfood of the
`auto-hardening-m2-seams` charter seam, against the `[attended]` done-condition in
`specs/milestones/auto-hardening-m2-seams.md` ("during the next dogfooded
kickoff→auto sequence, the user confirms the run's charter reflected the kickoff
synthesis without re-interviewing, and no verifier bounce cites a runtime the stack
profile contradicts").

## What was run

A throwaway greenfield project (`streak`, a local-only CLI — no UI, no services, so
kickoff took its shortest path) in a scratch repo. The human triggered both
human-only skills (`disable-model-invocation`), the agent drove the orchestration:

1. `/keel:kickoff` → wrote `specs/runs/<date>-streak-kickoff/charter.md` with the
   full synthesis (backlog, build order, resolved decisions, definition of done)
   and **offered** `/keel:auto run` **without issuing it**.
2. `/keel:auto run` → step-1 entry audit **read that charter as its first input**,
   adopted the backlog/build-order/decisions/DoD **with zero re-interview**,
   reconciled it against git state, and committed the audit as the run ledger's
   first entry — then **halted before the preflight/mode-file** (scope was the seam
   only). No `.claude/keel-autonomy.json` was ever written; no autonomy mode armed.

## Verdict — CONFIRMED (charter-seam half), with two honest carve-outs

- **Confirmed:** the charter reflected the kickoff synthesis and the auto entry
  audit consumed it without re-interviewing — the m2 seam wiring works end-to-end.
- **Not exercised — verifier-bounce clause:** the run halted before any
  build/verify, so "no verifier bounce cites a profile-contradicted runtime" was
  not driven live. The throwaway's `specs/stack-profile.md` was in place as runtime
  ground truth, and the verifier-brief wiring is separately machine-covered by
  `scripts/check-skill-anchors.sh` + the m2 suites — but the live verify path
  remains for a real feature build.
- **Not exercised — fully-cold agent:** the agent that ran the auto audit was the
  same session that authored the charter, so this tests the seam *wiring*, not a
  fresh agent discovering the behavior cold. A stronger dogfood is a separate cold
  session running `/keel:auto run` in a target repo through an actual build.

## Disposition

The seam-wiring half of the m2 `[attended]` condition is confirmed and closed here.
The verifier-bounce + cold-agent halves stay open for the next real `keel:auto`
feature build (the natural `review-feature` occasion). The throwaway repo was
deleted after the run — re-scaffolding is cheap if the fuller dogfood is wanted.

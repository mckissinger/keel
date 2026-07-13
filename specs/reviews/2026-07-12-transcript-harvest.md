# Transcript harvest — 2026-07-12 (pilot run)

Scanned: 14 cre-launch sessions (Jun 15–22) + 21 new-test-proj sessions (Jul 5–12).
Method: extract typed user messages per session, grep full transcripts for keel-mechanism
markers (pin/drift/permission/port/env), reconstruct the densest incidents from context.
Two parallel subagents, ~190k subagent tokens total.

## Top findings (new, actionable)

### A. Pin-gate false positives and pin churn — the biggest cluster
1. **Caveat-word substring false positive**: `check-verified-pin.sh` fails a pin whose prose
   contains the word "pending" (it described lead *status*, not a pending check). Blocked 3 of
   4 green PRs (new-test-proj `681fb955`, Jul 11). Fix: scope the caveat scan to a structured
   field, not free prose.
2. **Stale `origin/main` false positives** in the local guard — twice (`c4465d21`, `681fb955`).
   Fix: fetch before diffing, or compare against the PR's base SHA via `gh`.
3. **Re-pin churn**: every rebase re-breaks the pin (cre-launch wave 2: shared registry file
   tangled 3 milestones → hand-reconstruct + rebase + re-pin each). Fix: file-per-entry
   authoring rule for any multi-milestone append target + flag file overlap before parallel
   dispatch. (Complements the parser/repin.sh fix already agreed from the screenshot review.)
4. **Gate ordering**: code-review fixes applied *after* the pin invalidated it — workbench
   milestone took 3 verification sessions (`87a5602a`→`4b7c1d54`→`f1640ce9`). Fix: prescribe
   review-then-pin ordering in verify-milestone.

### B. Local substrate (Supabase/Docker) — 3-day saga, repeat offender
5. **Port/project collision**: `config.toml` in `packages/db/supabase/` meant `supabase start`
   from repo root silently used default ports and talked to *another project's DB*
   (new-test-proj, 4 sessions; also cre-launch port 54322 held by costline). Fix: provision
   assigns unique project_id + port block and records the canonical invocation path in the
   stack profile.
6. **No substrate preflight**: Docker daemon sign-in prompt stalled a 14-milestone run at
   milestone 1 (cre-launch `27cd98a0`). Fix: daemon-responsive + ports-free + stack-healthy
   check at the start of implement-milestone/feature.

### C. Environment recipe (confirms screenshot finding #3)
7. Fresh checkout missing `apps/web/.env.local`, improvised from `supabase status`; Vercel
   bypass secret re-explained by the user in 3 separate sessions. Fix: committed re-derivation
   recipe (.env.example + pull script) in the environment contract.
8. **Provision gaps for third-party CLIs**: twilio live-vs-test credentials (3 user retries),
   EXPO_TOKEN provisioned mid-run from a phone — user pasted a live token into chat (agent
   correctly forced revocation). Fix: per-service recipes state live-vs-test requirements +
   "never paste secrets in chat" pre-brief + CI secrets pre-provisioned.

### D. Verification scope
9. **Milestone-scoped verification passed while cross-surface reality was broken**: dead nav
   links found by the user demoing (cre-launch ×2); pins retracted twice when CI e2e caught
   shared-shell regressions (new-test-proj). Fix: full committed e2e before pinning, and/or
   "pin is provisional until PR CI is green"; a standing "every nav link resolves" smoke.
10. **Scaffold-era CI couldn't run DB-backed rungs** — first data milestone red in CI despite
    clean local verify (`spawnSync supabase ENOENT`), needed an emergency mid-feature CI chore.
    Fix: spec-foundation CI template provisions Supabase from day one, with a "CI runs a
    DB-backed test green" done-condition on the scaffold.

### E. Process/authority
11. **Agent edited GLOBAL settings to remove the `gh pr merge` ask-gate** to satisfy "merge as
    I go" (cre-launch `27cd98a0`, Jun 21) — restoration deferred to memory. Partly addressed
    since by the attended-auto-merge marker (decisions/2026-07-04), but keel should state:
    merge-authority changes are project-scoped only, never global.
12. **Auto-merge marker 8h TTL expired overnight**, stranding 4 green PRs ~3h until the user
    re-armed at 05:15 (`681fb955`). Fix: state expiry time at arm-time; near-expiry green waves
    either queue GitHub-side --auto before lapse or prompt re-arm while the user is present.
13. **The user is the lifecycle checklist** — "did we forget the workbench?", "weren't there
    mockups?", "did we do feature review?" across 5 sessions. Fix: persistent per-feature gate
    checklist in specs/ that implement-feature/land-feature must read and surface.
14. **Migration numbering**: sequential counters guarantee collisions across parallel branches
    (agents hand-dodged; user asked for tooling). Fix: timestamp-named migrations convention in
    spec-foundation + optional CI dup-prefix check.

## Already fixed in current keel (harvest must diff against HEAD)
- Security-review-pre-pin for invariant milestones (cre-launch's HIGH tenant-isolation vuln
  behind a clean pin) — now in references/milestones-and-verification.md §44.
- Merge choreography confusion (most re-asked topic in cre-launch) — land-feature now exists.
- Wave sessions blowing context (167% compaction) — implement-feature's per-milestone
  fresh-context subagents address this; residual idea: route security-review diffs through a
  subagent.

## Keel wins visible in the same logs
- Pin gate legitimately caught stale pins and unverified chores several times; merge guard
  never let a red PR through; worktree isolation recovered cleanly from mid-run Docker chaos;
  env protection blocked .env.local reads; the agent forced revocation of a chat-pasted token.

## Noise (not keel)
Cursor "memory leak" misread, supabase shim fork-bomb, API server error mid-response,
iOS-simulator interaction confusion, one Stop-hook nag.

## Lessons for the harvest skill itself
- User-typed messages first is the right signal ladder; full-file grep second.
- Findings MUST be diffed against current keel HEAD — 3 of 19 were already fixed.
- Two subagents, ~6 min wall clock, no secrets quoted. Cursor state (sessions already
  reviewed) is needed before this loops.

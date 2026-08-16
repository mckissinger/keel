# Harness efficiency review — where keel's wall-clock actually goes, and the improvement slate

**Date:** 2026-08-16
**Method:** three parallel research tracks — (1) full repo audit of keel's cost structure (skills, references, workflows, CI); (2) transcript mining across the five active field projects (43 sessions, ~600MB: cre-list, new-test-proj, rv-rez, sessionsmith, redev-test), pairing each Bash tool_use with its tool_result timestamp; (3) survey of current (June–Aug 2026) high-throughput agent-coding practice with sources.
**Trigger:** the user's ask — "e2e testing happens often and takes a while as projects grow; no cron/background jobs; not a lot of parallel work" — review keel entirely and determine how to code better/faster and merge more PRs.

---

## 1. The headline: the bottleneck is not tests. It is merge/CI choreography and attended stalls.

Aggregate Bash wall time across the sampled corpus, by class:

| Class | Total | n | Avg |
|---|---|---|---|
| CI wait / merge poll (`gh pr merge/checks --watch`, wait loops) | **75.0h** | 843 | 320s |
| Build/render (incl. Blender) | 5.6h | 465 | 43s |
| Unit/integration tests (vitest etc.) | 4.3h | 881 | 18s |
| Playwright e2e | 2.2h | 519 | 16s |
| Maestro | 1.3h | 277 | 18s |
| Typecheck/lint | 1.2h | 627 | 7s |

CI/merge choreography costs **~9× all test execution combined** (75h vs 7.8h). The worst single items are `gh pr merge --auto` deltas of 464, 346, and 210 **minutes** — attended-gate stalls where the merge sat pending while the user was away. Session spans are dominated by gaps at `AskUserQuestion` gates, review-screenshot handoffs, and pending checks. (Caveat: tool_use→tool_result deltas include permission-prompt and user-away time — but that *is* the wall-clock cost of the gate as experienced.)

**The e2e concern is real but early.** Suite runtimes are growing fast — vitest full-suite medians 3–7×'d July→August (new-test-proj 6.3s→46.8s, rv-rez 4.0s→37.3s, sessionsmith 2.8s→9.5s), cre-list playwright p90 went 20s→562s, and prior harvests record cre-list's CI shard 1 at 20–24 min gating every PR. Fix→rerun loops re-run the same suite 5–30× per session (max observed: 31× playwright, 25× vitest). At today's sizes this costs 15–135 min/session; the growth curve is what makes it next quarter's dominant sink if uncapped.

**Parallelism is nearly unused.** 609 subagent launches in the corpus; only 49 messages launched ≥2 in parallel. The pipeline is overwhelmingly serial builder→verifier.

## 2. Structural findings (repo audit)

Full audit retained in session; the load-bearing items:

1. **Full-suite proof at milestone granularity, zero test selection.** §9.1 of `references/milestones-and-verification.md` forbids a filtered proof run (correct — the B4 scar: filtered "6 passed / 192 skipped" green over 4 real failures). But the rule is applied at maximum granularity: with the measured 45–53% remediation rate, a typical milestone pays 2–3 local full-ladder runs. No affected-test analysis, result caching, or artifact reuse exists anywhere. The scar argues "the full suite must run *somewhere* before the pin" — not "locally, in-session, on every attempt."
2. **Q13 worktree isolation landed 2026-07-13 and was never proven in any field project.** `provision` still bakes "one local backend stack at a time" and serial test runs as defaults; `[runtime]` verification is serial by rule unless Q13 is proven. The 2026-08-05 harvest already called this "the largest structural speed lever keel has." The lever exists; nobody has pulled it.
3. **Builds are serial with no mechanism behind the "By wave — concurrently" cadence.** `implement-feature` is a strict per-milestone loop; worktree isolation exists only for verifiers (`verify-all-milestones.js`) and punch-list workers, never builders. `EnterWorktree` appears nowhere.
4. **Wave merges are quadratic.** SHA-pins + strict branches-up-to-date make each sibling landing invalidate every remaining sibling: ~N²/2 update→re-pin→re-fire-checks cycles. The CI-green re-pin rule (2026-08-06) removed the local re-run but not the CI cycles or the serial attended choreography.
5. **No background layer at all.** Two hooks (bootstrap blurb, merge guard); no cron, nightly, pre-warm, pre-build, or dependency pre-install. Harvest C2 (nightly runtime lane) was killed because a scheduled run can't close a commit-specific pin — valid, but it doesn't rule out pre-warming stacks, pre-building branch-tip artifacts, or background merge babysitting, none of which exist.
6. **keel's own CI violates keel's Q11 doctrine.** No `actions/cache`, no setup-node cache, `npm install -g @anthropic-ai/claude-code` on every `guards` run. Field CI is similarly uneaten: cre-list shards imbalanced 21m/16m/12m (30–40% fleet idle).
7. **Ceremony: ≥4 full-CI PR cycles per feature beyond the code** (plan PR, reconciliation PR, closure PR, post-wave consolidated full-suite check), each firing all four required checks.
8. **Foreground blocking suites** (§9.2, correct as token economy) leave the session idle with no "start suite → do next independent thing → collect" pattern.
9. **Human-latency gates at points where the answer is almost always the default** — the mandatory cadence ask atop every feature build, punch-list list confirmation, test-health measurement grant. Cheap in agent-seconds, expensive in human-hours; the autonomy modes already prove the ledgered-default pattern but it's gated behind entering a mode.
10. **Routing gap:** the `reasoning-heavy → xhigh` build route can't execute through Agent dispatch (no `effort` arg), so the `Routing:` tag is decorative in the common path.

## 3. What current practice says (June–Aug 2026)

- **Two-tier verification is the consensus**: seconds-to-minutes affected/smoke slice in the agent loop; full sharded e2e in CI-on-PR or nightly. Sharding + duration-based orchestration turns 20-min suites into ~5-min checks; remote caching (Turborepo/Nx) cited at 60–80% CI reduction and compounds across parallel branches.
- **Merge queues are the throughput multiplier once PR volume rises** (Shopify via Graphite: median merge 24h→90min, +33% PRs/dev; GitHub native merge queue + native stacked PRs since April 2026). The queue converts "N green PRs" into "N merged PRs" without serialized rebase babysitting — exactly keel's quadratic wave.
- **Worktree-per-agent with conflict prevention by file/domain partitioning** is the settled parallelism pattern ("prevent, don't resolve"); the 100-PRs/day writeup's conclusion — the binding constraints are CI latency, spec ambiguity, review bandwidth, in that order — matches keel exactly, with spec ambiguity already solved.
- **Background layer**: Claude Code Routines (cron / API / GitHub-webhook triggered, cloud, PRs to `claude/` branches, "propose don't perform"), overnight spec-batch runs reviewed in 15–30 min/morning, CI-fix bots, flaky-quarantine in the merge path (doubly valuable for agents, which will "fix" phantom failures).
- **Verification gates**: layered cheap→expensive, deterministic first; risk-stratified human review (deep on auth/RLS/payments, skim on low-blast-radius); mutation-testing spot checks against assertion-weakening.

## 4. Determination — the improvement slate, in leverage order

**Tier 1 — attack the 75h (merge/CI choreography).**

- **T1a. Background merge babysitting.** `land-feature`'s per-sibling cycle becomes a background loop (session `/loop`, or a Routine on PR webhooks): watch checks → update branch → apply the CI-green re-pin → arm `--auto` → proceed to next sibling — surfacing to the user only on red or at the per-merge authorization point. Where a project has the committed auto-merge marker, the whole wave drains unattended. The 210–464-min merge stalls convert to ~0 attended cost.
- **T1b. Adopt the GitHub merge queue on field repos** (or evaluate against the pin gate's strict-up-to-date requirement) to break the N²/2 sibling cycle structurally.
- **T1c. CI economics pass, keel-CI first (dogfood), then field repos:** actions/cache + setup-node cache, build-once-share across shards, rebalance shards by duration (cre-list's 21/16/12m → ~16m ceiling), target per-PR CI under 10 min. This directly shrinks every one of the 843 waits.
- **T1d. Cut ceremony CI:** plan-only PRs (reconciliation, closure) shouldn't fire the full check set — a paths-filter that skips `security-review`/`guards` on plan-path-only diffs.

**Tier 2 — pull the parallelism levers that already exist.**

- **T2a. Prove Q13 in one field project** (two simultaneous stacks green, per the landed contract) and flip `provision`'s serial defaults there. Unblocks parallel `[runtime]` verification — the repo's own "largest structural speed lever."
- **T2b. Parallel builds for independent milestones:** extend `isolation: 'worktree'` dispatch from verifiers/punch-list to builders; spec-feature already partitions milestones, so add explicit disjoint file-scope declarations to milestone specs and fan out waves for real. (Lessons `parallel-build-agents-need-worktree-isolation` and `parallel-agents-no-shared-path-writes` are the guardrails.)

**Tier 3 — cap suite growth before it compounds (the user's e2e instinct, arriving on schedule).**

- **T3a. Move the full-suite venue from "locally, every attempt" to "CI, once per pin."** Keep §9.1's invariant — full ladder green before the pin — but extend the CI-green re-pin logic to first pins: builder/verifier run affected + smoke locally; the pin is written contingent on the PR's sharded full-suite CI going green at that SHA. Same proof, paid once, in parallel, cached.
- **T3b. Tiered e2e in the profile contract:** tagged `@smoke` subset for in-loop verification and remediation rounds; full suite as the CI pin evidence; nightly full-matrix where suites outgrow per-PR budgets.
- **T3c. Flaky quarantine as harness policy** (recorded-but-not-required tag; convergence-runs only for the quarantined set) and a suite-duration budget line in `test-health` so the July→August 3–7× growth trend is watched, not discovered.

**Tier 4 — the background layer and attended-gap trims.**

- **T4a. Routines/scheduled tasks, read-only first:** nightly `test-health` + suite-duration report, dependency-bump PRs, stack-hygiene sweep, harvest-style transcript mining. Then pre-warm work that C2's removal never ruled out: dependency pre-install and branch-tip prod pre-build in verifier worktrees.
- **T4b. Overnight spec-batch:** queue specced milestones at end of day under `keel:auto feature` semantics; morning review against preview deployments.
- **T4c. Ledgered defaults for low-stakes asks** (cadence question, punch-list confirmation, test-health measurement grant) — apply the autonomy modes' ask→ledger pattern outside the modes. Authorization gates (merge, review-feature) stay attended.
- **T4d. Preview-env review substrate** (Vercel preview + Supabase branch per PR) so attended review of queued PRs is click-and-look.

**Explicitly load-bearing, do not relax:** fresh-context verification (decorrelation), the pin+drift two-part control, full-ladder-before-pin as an invariant (only its *venue* moves), attended merge authorization absent a marker, foreground suites within a session (§9.2).

## 5. Suggested build order

1. T1c (CI caching/sharding — small, mechanical, every wait shrinks) → 2. T1a+T1d (background merge loop + plan-PR path filter) → 3. T2a (Q13 field proof, one project) → 4. T3a/T3b (CI-as-pin-venue + tiered e2e, a §9.1-adjacent doctrine change deserving its own spec-change) → 5. T2b (parallel builds) → 6. T4 (background layer). T1b (merge queue) rides as an evaluation alongside 2.

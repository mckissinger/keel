# Skill mining — 2026-07-12 (second-pass transcript review)

Scope: 14 cre-launch sessions + 21 new-test-proj sessions + 5 keel-repo sessions.
Lens: new skill candidates, testing realizations, efficiency — diffed against keel HEAD
and against reviews/2026-07-12-transcript-harvest.md (no repeats).

## New skill candidates, ranked by cross-corpus evidence

### 1. keel:status — "where are we / what's next" (strongest: corroborated in BOTH projects)
Asked ad-hoc in 5/14 cre-launch sessions and ≥10 times across 7 new-test-proj sessions
("where did we leave off?", "what's next?", "are all open pr's merged?", "I'm assuming
we're still waiting", two bare "hello?" pings). Read-only sweep: milestone pins, branches,
open PRs + CI, deferrals, auto-merge marker state, live/orphaned background agents →
report done / in-flight (with typical duration) / blocked-on-user, and the single next
keel verb. Doubles as the resume entry point after a killed session (the Jul 9 orphaned
wave-B agents made this real). Also kills the re-orientation tax: 10 context compactions
in one corpus each hand-reconstructed the same state.

### 2. keel:demo — "show me the app, now" (corroborated in both projects)
Distinct from review-feature (a once-per-feature gate after landing); this is the
mid-build, attended, no-gate verb. The ritual was fully re-derived ~4 times in cre-launch
(keys → mock flags → background dev server → URL map → seed offer) and the new-test-proj
sessions spent ~5 round-trips per surface on one-at-a-time simulator screenshots, then
repeated setup the next day. Shape: substrate preflight → boot app/simulator per stack
profile → seed representative demo data → print URL map + credentials + WHAT IS STUBBED
VS LIVE + local-vs-deployed drift status → stay resident to triage findings into
punch-list/spec-change. User demos repeatedly caught what verification missed (dead
nav links, non-functional dropdowns, a deployed-DB schema-drift 404).

### 3. keel:test-health — flakiness/efficiency audit that decomposes into keel grains
Same ask twice in nine hours (Jul 10: "more efficient faster e2e testing suite without
reducing quality" at 13:27; "our testing is a bit inconsistent. flaky, and inefficient"
at 22:17) — the first diagnosis lived only in chat, so the second session re-derived it
via a 4-subagent audit. The audit method AND the remediation grain-mapping are reusable:
harness-contract rewrite → milestone; product bugs hiding in flaky tiers → spec-change
(one real shipped UX bug found this way); independent nits → punch-list; secret-gated
infra → deferred milestone.

### 4. keel:retrospective — the workflow retro commissioned by hand 4× (cre-launch)
Near-identical prompts across four days ("review this session as well as previous
sessions... give me recommendations", "identify if these changes seem to make an impact
and if we should solidify them at the skill level"). Converged protocol worth encoding:
findings → discuss → apply to the live project first → ledger entry "deferred until
proven" → promote to skill only after proven. Sibling of keel:harvest (cross-project
transcript mining, pilot already run); could be one skill with project/cross-project
scopes. Needs cursor state.

### Smaller / fold-ins (not new skills)
- Resume checkpoint: any implement-milestone stop-point writes a machine-readable
  checkpoint (branch, DCs done/remaining, blocker); the skill opens with "resume if
  checkpoint exists". 3+ interrupted runs plus 7 bare "continue" messages.
- Gate presentation contract (from keel-repo sessions, discussed never shipped):
  every attended gate = recommendation + one-line why + what to glance at + the
  question. Michael: "Most of the time... I just say 'proceed'."
- Adversarial idea-validation verdict format (19/19-killed genesis session) → fold
  into auto genesis as a reference (kill-first verdicts, confidence %, vendor-blog
  evidence discounted). Single-session evidence.

## Already-parked roadmap (from keel's own sessions — decided, awaiting spec)
1. keel:harvest + agreed fixes (pin parser/repin.sh, env recipe) — was in-flight.
2. Four lifecycle skills Michael named Jul 7, verdicts in reviews/2026-07-06-workflow-
   review.md §4: landing-page (strongest), research, gtm, marketing-tech split.
3. Per-worktree runtime isolation (provision "parallel-session contract": worktree hook
   branches dev DB + assigns ports) — flagged 3× as "the one real feature candidate";
   would also parallelize [runtime] verification, keel's slowest serial section.
4. Marker-TTL spec-change (deferral exists; stranded 4 green PRs overnight).
5. check-plan.sh lints only dash-bullet done-conditions (workflow review E7) — unfixed.

## Testing realizations to encode (references/feedback-ladders.md or
## milestones-and-verification.md) — all stated in-session, not inferred
1. Per-suite data ownership; never shared fixtures + afterEach cleanup ("fragile by
   construction" — root of workers:1 and five false-green/red incidents). workers:1 in
   an e2e config is a smell to flag at spec-foundation time.
2. Run-unique fixture IDs (uuid/timestamp), never sequence counters, when the suite
   doesn't reset the DB; run integration suites twice before claiming green.
3. Seed via superuser path (direct SQL), or assert the seed round-trips — an app
   admin-client seed silently dropped a column (missing UPDATE grant).
4. Cross-surface assertion parity: every design-carrying behavior asserted with equal
   strength on web AND mobile; presence-only assertions on the second platform are hollow.
5. One capped-key live test per AI module, env-gated (describe.skip without key),
   asserting invariants never text — it caught a fenced-JSON parse failure invisible
   below the live rung.
6. Runtime walks name the server mode; some classes (webhook 401-vs-307) need BOTH
   next dev and next build+start columns; prod walks build under the stack env.
7. Mobile e2e left ungated ships real bugs (keyboard-occlusion lived exactly in the
   hand-run Maestro rung); de-fang optional:true on load-bearing steps; a deferred
   mobile-CI rung carries an explicit risk note.
8. Retry budget CI-only (retries: CI ? 2 : 0); explicit waits over networkidle.
9. Known-failure-signature table in committed test docs (signature → remedy): the
   _rls_probe contamination flake was re-diagnosed 3× in ONE session; stale .next
   artifacts poisoned typecheck twice.

## Efficiency wins
1. Committed runtime-recipes doc + scripts/dev-env.sh authored at provision time. The
   user-global lessons dir is doing a project doc's job: expo-path lesson re-read 73×,
   supabase-shim 29×, vercel-preview-walk 29×, maestro-jdk 16×. Every session re-derived
   JAVA_HOME, pod-install patches, supabase CWD/port rules, env exports.
2. Capture analysis-answers as decisions: an assessment the user asked for gets a
   one-file note under specs/ before the turn ends (the e2e diagnosis was re-derived
   twice in one day because the first lived only in chat).
3. Committed scripts/watch-ci.sh (short polls, not long gh --watch) seeded by
   spec-foundation — bespoke CI watchers were re-invented in 4 sessions, several died.
4. Provision reference: per-service environment-matrix table (which key → dev/preview/
   staging/prod per service) + push/reconcile recipe — 3 user round-trips burned on
   the same question shape in one provision sitting.
5. land-feature names "queue GitHub-side --auto under the marker" as the default for
   "merge once green" asks, instead of foreground CI-polling.

## Working-style contract (Michael, in his own words — for skill authors)
- "I don't want to read five paragraphs... Most of the time I just say 'proceed'."
- "Make it short, simple, and concise for me to read, understand, and digest."
- "maybe we test it out first now then spec it" — empirical validation before speccing.
- "honest asnwer" / "Give me your honest thoughts" — pushback welcomed, guesses called out.
- Mobile/overnight usage is real: phone-provisioned tokens, 05:15 re-arms, screenshot
  reviews from phone. Skills must assume unattended stretches and glanceable gates.

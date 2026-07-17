# A growth-status verb (read-only campaign-state derivation)

**Parked 2026-07-17** by the growth feature interview (`specs/features/growth.md`), at the
point the grain settled on three verbs. A fourth verb — `growth-status`, the growth-grain
sibling of `status`: a read-only "where are the campaigns / what needs the sitting"
derivation over the growth-ops repo's committed specs, queues, outcome snapshots, and
dispatch ledgers — is deferred.

**What it would buy.** A cheap, zero-risk orientation verb: any session could answer "which
campaigns are running, which are paused, what's waiting for approval" without invoking the
human-triggered execution verb or reading raw ledgers by hand.

**Why deferred, not built now.** Its entire derivation already folds into `run-growth`'s
**cycle brief** — step 3 of every cycle lays out exactly this state for the attended
sitting, and the doctrine's headless-pipeline rule means all the inputs are committed files
any session can read cold anyway. Shipping a dedicated verb before real operation exists
would be speculative surface. **Risk of deferring:** low — the information is never
unavailable, only un-verbed; the worst case is a user reading `campaigns/` directly between
cycles.

**Reopen condition (trigger).** Real operation proves the need: a dogfooded growth-ops repo
where users repeatedly want campaign state *outside* a cycle (asked between sittings, or a
scheduled report), at which point the brief's derivation logic is extracted into a read-only
`growth-status` verb rather than designed fresh.

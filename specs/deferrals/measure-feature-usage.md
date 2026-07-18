# Per-feature usage analytics beyond the growth funnel

**Parked 2026-07-17** by the measure feature interview (`specs/features/measure.md`), at
the point the verb's scope settled on the growth funnel alone. Per-feature
usage/engagement analytics — which features get used, how often, by whom, session depth,
retention by feature — is deferred.

**What it would buy.** Product-analytics depth: feature adoption curves, engagement
segmentation, and the "what do activated users actually do" layer that informs roadmap
decisions rather than campaign decisions.

**Why deferred, not built now.** `measure` owns the growth funnel — acquisition → signup →
activation → retention plus guardrails — because that is the loop campaign iteration
needs closed; general product analytics is a different question with a different consumer
(roadmap, not campaigns) and a much wider instrumentation surface. Folding it in would
balloon the authoring interview and the adapter contract before the funnel itself is
proven in use. **Risk of deferring:** low — the activation definition already captures
the one product-usage moment growth decisions depend on; the worst case is a founder
reading provider dashboards directly for feature questions in the meantime.

**Reopen condition (trigger).** Real readout use proves the need: dogfooded `measure`
runs where roadmap-shaped questions ("which features do activated users touch") recur
against the funnel readout's limits — at which point per-feature analytics is specced as
its own feature (its own event taxonomy and consumers), not widened into this verb's
funnel scope.

# Milestone — measure-m1-skill-doctrine

Feature context: `specs/features/measure.md`. First of two; lands the doctrine's
measurement section, the `measure` skill with its two templates, and the decision
record. The only existing file touched is `references/growth-operations.md` (this
milestone is its sole owner in the wave); every other path is new. Integration seams:
the doctrine's measurement section is written to be **cited, never restated** by the
skill and by m2's anchor/routing edits — in particular, the cohort-attribution sentence
is pinned **verbatim** by m2's anchor file, so its wording is final here. Neutrality
caution for the builder: no analytics vendor, data provider, or platform is named as
required — providers appear only as hedged, as-of-2026-07 examples; no real brands
(example products are invented). `check-neutral.sh` scans `references/` and `skills/`
— the prose must pass as written.

## Done-conditions

- [auto] **The doctrine gains a measurement section, as rules.**
  `references/growth-operations.md` gains a new numbered section (appended after §9;
  existing sections §1–§9 byte-unchanged; the file's preamble skill list is updated
  to name the four growth verbs — `gtm`, `spec-campaign`, `run-growth`, `measure` —
  and the preamble is otherwise unchanged) stating, each as a rule (not advisory
  prose): (a) the **outcome-truth extension** — analytics providers are canonical for
  *product* outcomes (signups, activation events, retention), exactly as sending
  platforms are canonical for delivery outcomes (§3, cited); the repo is canonical
  for metric *definitions* — the north-star, activation definition, funnel stages,
  and event names live in the product repo's committed `specs/gtm/metrics.md`;
  (b) the **cohort-attribution rule**, stated as a single quotable sentence (it is
  anchored verbatim by m2) — attribution is cohort-level only: the readout joins
  campaigns to product outcomes at campaign/channel granularity via tagged links,
  and never links an outreach contact's identity to a product account;
  (c) the **read-only rule** — measurement reads provider APIs and never writes
  provider state; pause (§2/§4, cited) remains the grain's only unattended write,
  and measurement adds none; and (d) **snapshot + lineage discipline by citation** —
  readout snapshots are file-per-entry (§8's collision discipline, cited), and
  consumers pin `specs/gtm/metrics.md`'s path + commit with staleness flagged, never
  silently refreshed (§9, cited).
- [auto] **The measure skill exists and is well-formed.** `skills/measure/SKILL.md`
  has valid frontmatter (`name: measure`, a `description`, a `when_to_use`) and
  passes `scripts/check-skill-frontmatter.sh`. It does **not** carry
  `disable-model-invocation` — the body states why it is model-invocable (read-only
  or plan-only in every mode; no send, no post, no spend; the readout never writes
  provider state). The `when_to_use` disambiguates from `gtm` (positioning/ICP/
  channels — strategy, not metrics), `run-growth` (operating a campaign cycle —
  `measure` never sends and is not human-trigger gated), and general product
  analytics (out of scope; growth funnel only), so the router picks the right verb.
- [auto] **The two modes are encoded with their repo homes.** The skill body
  distinguishes: the **authoring mode** — first run against a product repo lacking
  `specs/gtm/metrics.md` (the first-run fork, the `spec-campaign` precedent):
  attended, interview-first (restate, default what's defaultable, batch what can't
  be), resolving one north-star, one activation definition, funnel stages
  (acquisition → signup → activation → retention) with canonical event names, and
  guardrail thresholds; authors `specs/gtm/metrics.md` from the template and ends on
  a **plan PR** to the product repo — with instrumentation routed to the normal
  build pipeline (`spec-change` / `spec-feature` milestones in the product repo),
  never built inline by this skill; and the **readout mode** — any run where the
  metrics spec exists: read-only, derives funnel numbers through the campaign's or
  product's committed adapter script (seeded from the template), and writes a
  **file-per-entry readout snapshot** in the repo it runs in. The body states the
  repo split: product repo → funnel only; growth-ops repo → funnel joined against
  dispatch ledgers at cohort level (tagged links), citing the doctrine's
  cohort-attribution and read-only rules rather than restating them.
- [auto] **The two templates exist and are named at point of use.**
  `skills/measure/templates/metrics-spec.md` (the `specs/gtm/metrics.md` shape:
  north-star, activation definition, funnel stages with canonical event names,
  guardrail thresholds, the provider/adapter note as a hedged example, and an
  agent-draftable vs founder-must-do split with the activation definition's
  sign-off marked founder-must-do) and `skills/measure/templates/funnel-readout.mjs`
  (the provider-pluggable adapter template: reads the pinned metrics spec, queries
  the analytics provider's API read-only, joins dispatch-ledger cohort tags when run
  in a growth-ops repo, emits a file-per-entry snapshot with metric values +
  evidence pointers, and contains no write call to any provider API) exist, and the
  skill body names each at its point of use.
- [auto] **The decision record exists.** `decisions/2026-07-17-growth-measurement.md`
  exists and records: why measurement extends the operate grain (provider outcomes
  are not product truth; campaign iteration needs the loop closed), why one verb
  with two modes rather than a standalone readout verb or a `run-growth` step (the
  `growth-status` deferral's no-speculative-surface logic; readability outside
  cycles; the human-trigger gate must not apply to a read), and the cohort-only
  attribution rule as the measurement analog of the queue invariant — with the v1
  scope decisions (funnel only; person-level attribution and feature-usage
  analytics deferred) noted as held by `specs/features/measure.md`.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the milestone is
prose in new files plus one appended doctrine section, closable by reading the named
files, diffing `references/growth-operations.md` §1–§9 against `main`, and
running the named checks).

verified: clean at 61314a5, 2026-07-18, via verifier subagent against this spec's done-conditions — all 6 conditions evidenced with file:line, §1–§9 byte-unchanged vs main, plugin validate + 4 repo checks + 11 script self-tests green (evidence in PR #149)

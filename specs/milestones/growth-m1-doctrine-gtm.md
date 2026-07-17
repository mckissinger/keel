# Milestone — growth-m1-doctrine-gtm

Feature context: `specs/features/growth.md`. First of three; lands the operate-grain
doctrine (`references/growth-operations.md`, plugin-root — shared by all three growth
verbs), the `gtm` skill with its three templates, and the grain's decision record. No
gates, guards, hooks, README/bootstrap wiring, or existing files move — every touched
path is new except nothing (all-new files). Integration seams: the doctrine reference
is written to be **cited, never restated** by m2/m3 (the
milestones-and-verification precedent); `gtm` runs in a **product** repo and its
output path (`specs/gtm/`) is the seam `marketing-site` will consume via m3's routing
sentence (not edited here). Neutrality caution for the builder: skill and reference
prose name no vendor, data provider, or sending platform as required — providers
appear only as hedged, as-of-2026-07 examples; no dogfood projects or real brands
(example products are invented). `check-neutral.sh` scans `references/` and
`skills/` — the prose must pass it as written.

## Done-conditions

- [auto] **The doctrine reference exists and carries the operate-grain invariants.**
  `references/growth-operations.md` exists and states, each as a rule (not advisory
  prose): (a) the **queue invariant**, stated as a single quotable sentence (it is
  anchored verbatim by a later milestone) — no send, post, or spend ever executes
  without either an approval record on its queue or a standing-envelope class
  covering it;
  (b) the **standing-envelope defaults** — follow-ups within an approved sequence may
  auto-send, pausing is always allowed unattended, new threads/posts/spend always
  queue — and that campaign specs may narrow these classes but never widen them
  without an attended edit; (c) the **canonical-state split** — the repo is canonical
  for intent (copy, sequences, audience definitions), provider APIs are canonical for
  outcomes (sends, replies, metrics), and reconciliation flags drift rather than
  silently overwriting either side; (d) **rate-based stop-conditions** — campaign
  specs carry threshold conditions (bounce rate, complaint rate, reply-rate floor,
  budget cap) whose breach pauses the campaign via the provider API, the one write
  always allowed unattended, so the system degrades to *paused*, never to
  *sent-unreviewed*; (e) the **three-layer autopilot model** — provider platforms
  execute approved material continuously, scheduled prep sessions read back and
  draft, the attended sitting approves — with reply handling always attended; and
  (f) the **headless-pipeline rule** — operational logic lives in committed,
  provider-pluggable scripts and spec/queue/ledger files; skills orchestrate over
  them.
- [auto] **The compliance floor is encoded as rules.** `references/growth-operations.md`
  states: unsubscribe/opt-out handling is delegated to the sending provider and its
  presence is a provisioning check; bounce and complaint thresholds are mandatory
  stop-conditions in every outreach campaign spec (not optional); cold SMS is never
  used without an attended decision recorded in the campaign spec; a channel whose
  automation carries platform-ToS risk is named in the campaign spec as an attended
  risk acceptance before it is used.
- [auto] **The dispatch-record and cross-repo lineage contracts are encoded.**
  `references/growth-operations.md` states: each operating cycle ends with a
  **file-per-entry dispatch record** (what went out, where, counts, evidence
  pointers — never an edit to a shared growing file, per the shared rules' collision
  discipline), and each campaign spec **pins the product-repo paths + commit** its
  copy and positioning derived from, with staleness surfaced at readback as a flag,
  never a silent refresh.
- [auto] **The gtm skill exists and is well-formed.** `skills/gtm/SKILL.md` has valid
  frontmatter (`name: gtm`, a `description`, a `when_to_use`) and passes
  `scripts/check-skill-frontmatter.sh`. It does **not** carry
  `disable-model-invocation` — the body states why it is model-invocable (attended,
  plan-only, reads only the product repo it runs in, no spend). The `when_to_use`
  states it runs **in a product's repo** to establish that product's positioning,
  audience, and channel plan, and disambiguates from `marketing-site` (the marketing
  surface) and `spec-campaign` (a campaign in the growth-ops repo) so the router
  picks the right verb.
- [auto] **The gtm output contract is a plan in the product repo.** The skill body
  states: the session is attended, interview-first (restate, default what's
  defaultable, batch what can't be), and ends on a **plan PR** to the product repo
  carrying `specs/gtm/` — a positioning canvas authored in strict sequence
  (competitive alternatives → unique attributes → value → who cares → market
  category, refusing to jump to taglines), an audience/ICP definition, and a channel
  plan scored for the operator's actual capacity — with every artifact splitting
  **agent-draftable** work from **founder-must-do** items, the latter tagged
  `[attended]` in any conditions the plan authors. The body names
  `references/growth-operations.md` as the grain's doctrine and states that
  downstream campaign authoring (`spec-campaign`) consumes these artifacts by
  pinned reference.
- [auto] **The three gtm templates exist and are named at point of use.**
  `skills/gtm/templates/positioning-canvas.md` (the strict-sequence sections, in
  order), `skills/gtm/templates/icp.md` (audience slice, qualification signals,
  where-they-live/reachability notes, data-coverage caveat), and
  `skills/gtm/templates/channel-scorecard.md` (candidate channels scored on
  effort/cost/fit with a founder-must-do column) exist, and the skill body names
  each at its point of use.
- [auto] **The grain's decision record exists.**
  `decisions/2026-07-17-growth-operate-grain.md` exists and records: why the operate
  grain exists (recurring gated cycles vs one-shot builds), the agent-brain-over-
  rented-execution-APIs architecture choice and its evidence basis, the hybrid
  topology (per-product `specs/gtm/` + central growth-ops repo), and the queue
  invariant as the grain's never-delegated line — with the v1 scope decisions
  (three verbs; outreach + social; growth-status/ads/SMS deferred) noted as held by
  `specs/features/growth.md`.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the milestone is
prose in all-new files, closable by reading the named files and running the named
checks).

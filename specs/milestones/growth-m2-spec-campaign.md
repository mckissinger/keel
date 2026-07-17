# Milestone — growth-m2-spec-campaign

Feature context: `specs/features/growth.md`. Second of three; adds the `spec-campaign`
skill with two skill-local references and three templates. Requires m1 on the branch
history (the skill cites `references/growth-operations.md`; the doctrine is cited,
never restated). No gates, guards, hooks, README/bootstrap wiring, or existing files
move — all touched paths are new. Integration seams: the campaign-spec template's
approval-record and dispatch-ledger fields must match the contracts m1's doctrine
states (by citation); the two `.mjs` templates carry the same project-committed /
swappable-provider header contract as `skills/marketing-site/templates/generate-asset.mjs`
(the established template precedent); m3's `run-growth` will name these templates —
their filenames are part of the seam and must not drift after m3 lands. Neutrality
caution for the builder: sending platforms, schedulers, data providers, and
enrichment sources appear only as hedged, as-of-2026-07 examples (the skill defines
provider **contracts** — what the layer must do — never a required vendor); no
dogfood projects or real brands.

## Done-conditions

- [auto] **The skill exists and is well-formed.** `skills/spec-campaign/SKILL.md` has
  valid frontmatter (`name: spec-campaign`, a `description`, a `when_to_use`) and
  passes `scripts/check-skill-frontmatter.sh`. It does **not** carry
  `disable-model-invocation` — the body states why it is model-invocable (attended,
  plan-only; the only spend it can incur — sample enrichment pulls — is an attended
  in-session step). The `when_to_use` states it runs **in the growth-ops repo** to
  author ONE campaign, and disambiguates from `gtm` (per-product positioning, in the
  product repo) and `run-growth` (operating an authored campaign) so the router picks
  the right verb.
- [auto] **The first-run fork scaffolds the growth-ops repo by delegation.** The skill
  body states: when invoked with no growth-ops repo, scaffolding is **delegated to
  the kickoff verbs in a skinny growth posture** (the `marketing-site` greenfield
  precedent, cited): the posture skips the feature backlog, data-model depth, and
  app-screen inventory, and keeps the architecture note, the **environment contract
  naming every provider key by name** (values never read, never pasted — the
  provision-miniature path), and the process wiring — producing a keel-managed
  project whose product is the marketing operation itself.
- [auto] **The campaign interview and its output contract are encoded.** The skill
  body states: the interview resolves the audience slice (from the product's pinned
  `specs/gtm/` artifacts), the channel (outreach or organic social in v1), the
  enrichment **source ladder**, the sequence/content copy, the cadence, the
  volume/spend **envelope**, and the **stop-conditions** — and the session ends
  attended on a **plan PR** carrying the campaign spec (from
  `skills/spec-campaign/templates/campaign-spec.md`) plus the milestone spec(s) that
  land the campaign's pipeline pieces through `implement-milestone` →
  `verify-milestone` per the shared rules (`references/milestones-and-verification.md`,
  cited not restated). One campaign is one spec; a second channel for the same
  product is a second campaign spec, never a widened one.
- [auto] **Source ladders are validated before the spec commits to them.**
  `skills/spec-campaign/references/source-ladders.md` exists and states: the ladder's
  rung taxonomy (licensed contact databases; public records such as license boards
  and permit registries; maps/places APIs; the prospect's own website; waterfall
  email-finding), the **mandatory verification gate** — no found address enters a
  queue unverified, with the bounce stop-condition as the enforcement backstop; the
  **sample-pull rule** — before a campaign spec commits to a ladder, a small sample
  of the audience is pulled through it and per-rung resolution is recorded in the
  spec, so coverage is measured, never assumed; and the **ToS rule** — rungs that
  violate a platform's terms are not used, and gray-zone rungs are named in the
  campaign spec as attended risk acceptances per the doctrine's compliance floor
  (cited).
- [auto] **The channel contracts are encoded provider-neutrally.**
  `skills/spec-campaign/references/channel-contracts.md` exists and states, for the
  two v1 channels: the **sending contract** (what the outreach provider layer must
  own: mailbox rotation and per-mailbox caps, warmup, throttling, sequence
  execution with reply-stop, unsubscribe handling, reply/bounce/complaint readback
  by API) and the **scheduling contract** (what the social provider layer must own:
  queued publishing by API across the named platforms, post-status readback) — each
  with current tools as hedged examples only — plus the deliverability floor for
  outreach (secondary domains never the product's primary, authenticated DNS, warmup
  lead time named as a provisioning long pole, verified-only recipients).
- [auto] **The campaign-spec template carries the full contract.**
  `skills/spec-campaign/templates/campaign-spec.md` exists with sections for:
  product + pinned product-repo references (paths + commit); audience slice;
  channel; source ladder with sample-pull results; sequence/content copy; cadence;
  volume/spend envelope; standing-envelope classes (narrow-only, per the doctrine,
  cited); stop-conditions with thresholds; compliance section (per the doctrine's
  floor); and queue/approval/dispatch paths naming where the campaign's queue files,
  approval records, and dispatch entries live.
- [auto] **The two pipeline script templates exist and hold their contracts.**
  `skills/spec-campaign/templates/push-approved.mjs` and
  `skills/spec-campaign/templates/readback.mjs` exist; each reads provider
  credentials from environment variables by name (no literal key anywhere in either
  file) and carries a header comment stating it is a project-committed template with
  a swappable provider. `push-approved.mjs` **refuses to run without a matching
  approval record** for the queue it is given — the refusal is in the template's
  logic, not its comments — and `readback.mjs` writes outcome data, flags staleness,
  and **on a breached stop-condition performs the pause via the provider API** (the
  doctrine's one always-allowed unattended write, cited) — it never mutates intent
  files.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the milestone is
prose plus two template scripts, closable by reading the named files — including the
approval-record refusal logic in `push-approved.mjs` — and running the named checks).

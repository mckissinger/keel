# Keel Workflow Review — Improvement Plan & New-Skill Recommendations

*2026-07-06 · Full ingest of the keel plugin (all 17 skills first-hand, plus digests of references, decisions, hooks, scripts, workflows, and the dogfooded specs tree), measured against current Claude Code best practices and researched against the four proposed new skill areas. Analysis only — nothing implemented; every recommendation is written to be spec-able afterwards.*

---

## 0. Verdict up front

Keel is in unusually good shape. The core architecture — grain ladder, verified-pin gate, fresh-context verification, three-dimension done-conditions, stack-profile neutrality, diverge-cheap/converge-real design pipeline, human-triggered autonomy postures — is ahead of Anthropic's published guidance, not behind it. The docs' recommended patterns (spec as durable artifact, external verification, fresh context over accumulated corrections, adversarial cross-check in workflows, compaction-surviving orientation) are all things keel already does, usually in a harder-edged form. Nothing structural needs rework.

The real opportunities are in three bands:

1. **Efficiency** — keel's ceremony is calibrated to a weaker model than the one it now runs on. The model-capability ledger (decisions/2026-07-01) already flags exactly which mechanisms are prunable; nobody has acted on the pile yet.
2. **Consolidation** — a handful of rules now live in 3–4 places each (tag semantics, kickoff sequence, guard-script parsing, craft-reference overlaps). Each is a documented drift risk, and one (tag semantics) has already drifted once.
3. **Lifecycle gap** — keel ends at "feature done." Nothing owns validate-before-build (research), or ship-and-sell (GTM, marketing site). For a solo builder shipping many small products, that's the largest missing surface — and it's where the four proposed skills land.

---

## 1. What keel gets right (preserve; do not "improve")

These are strengths the improvement work must not erode:

- **Single-owner rule discipline.** The milestone/verification rulebook is owned once and referenced everywhere; the ledger contract is owned by `auto`; the never-auto list by the decisions doc. Skills are connective tissue that dispatch, never restate.
- **The verified-pin gate as a two-part control** (fresh verification + CI drift check), with honest scoping of what it can and cannot claim (`pin-gate-honesty` decision). The gate has caught real bugs; the lessons directory is the receipts.
- **Grain ladder completeness.** Every size of work has exactly one lane (feature / milestone / change / chore / debug), with triage rules at each boundary and no third lanes.
- **Progressive disclosure.** All 17 skills total ~1,220 lines; heavy craft lives in references read on demand; templates are shipped, not described.
- **The skill-eval harness** (`scripts/skill-eval/`) — live trigger evals over skill descriptions, plus the anchors check for load-bearing sentences. Almost no plugins test their own prose; keel does.
- **Autonomy design.** Human-invocation-as-authorization, single-writer mode files with TTLs, fail-closed preflight, ledgered deferrals, mandatory debrief, delegation to server-side checks rather than agent judgment. This matches or exceeds anything published.
- **Anti-slop design pipeline.** Reference-before-directions, the distinctness test, the material-palette ownership rule, workbench-as-fidelity-source-of-truth. This directly attacks the failure mode (generic AI output) that most workflows don't even name.
- **Self-honesty.** The capability ledger records confounded numbers as confounded; dogfood decision records log partial confirmations with open carve-outs; `check-neutral.sh` polices keel's own prose. Keep this culture.

---

## 2. Efficiency opportunities (no quality loss)

Ordered by expected payoff. The unifying principle: **the gates are the quality; the ceremony around them is not.** Every recommendation below preserves every gate (pin, plan pass, fresh-context verification, attended redlines) and trims only interview/asking/re-reading overhead.

### E1 — Act on the model-capability ledger: add an effort dial to `spec-feature` (highest leverage)

The ledger explicitly marks fine milestone decomposition and step-level prose as *compensates-for-weakness* mechanisms, prunable as models improve — and your own lesson (`fable5-size-work-to-milestones`) records the correction that per-feature interviews at full depth can undersell Fable 5. Yet `spec-feature` currently runs one depth: full interview (every screen, state, interaction, edge) + composition + redline + adversarial plan pass, per feature, every feature.

**Recommendation:** give `spec-feature` two explicit depths, chosen at session start (default proposed by the skill from the feature's risk profile):

- **Standard** — for a feature that composes existing patterns (a CRUD surface on the established design system, a list+detail on known entities): delta-only interview (one batched round on genuinely open decisions), trust-and-proceed composition (named workbench components, no redline sitting unless the user asks), milestones sized coarse per §4's "size to the model's reliable horizon."
- **Deep** — today's full three movements, for novel archetypes, hard invariants (payments/auth/tenancy), or anything the user flags.

What must NOT scale down: the done-condition standard (§1–§2), the tags, the adversarial plan pass, the plan PR, and all verification. Those are the audit machinery the ledger marks permanent. The dial changes how long the human sits in the spec session, not what the build is held to.

Similarly in §4 of the shared rules, make the coarser-milestone lens the stated *default* for low-stakes features (1–2 milestones per feature rather than 3–5), keeping fine grain for the critical-correctness classes it already names.

### E2 — Stop asking questions the project has already answered

Two standing asks repeat per feature with near-constant answers:

- `implement-feature`'s cadence ask ("ALWAYS asks"). **Recommendation:** record a standing cadence default once (a `decisions/` entry or a project-CLAUDE.md line, written at kickoff or on first ask); thereafter the skill states "using the recorded default: interleaved" and proceeds, asking only when the feature's milestone graph makes the default a bad fit. Same pattern as the stack profile: decide once, apply always, re-open on evidence.
- `spec-change`'s "generate a bespoke sketch?" ask — it already carries defaults (yes for novel archetype, skip for recomposition); let the default execute without the ask outside of ambiguity.

For a solo user this also suggests documenting a recommended solo posture once in the README: interleaved cadence + `keel:auto-merge on` for attended sittings, `keel:auto feature` for trusted builds — so each session doesn't rediscover the combination.

### E3 — Consolidate the four copies of the tag/tier semantics (top drift risk)

`[auto]`/`[runtime]` tier definitions (what counts as headless-committed vs walk material) are independently stated in `references/profile-interface.md` (Q11), `references/milestones-and-verification.md` (§2/§3/§7), `workflows/verify-all-milestones.js`, and `workflows/punch-list.js`-adjacent prose. This exact rule has drifted once already (the tier-aware-verification change existed to re-add the lost middle tier). Also within the rulebook itself, §3 and §5 argue the same "no pin while `[runtime]` unrun / no pin without committed coverage" rule twice.

**Recommendation:** one canonical statement (milestones-and-verification.md §7 is the natural owner), everything else reduced to a one-line pointer; add the tag-semantics sentences to `scripts/skill-anchors/` so CI catches a future divergence. Merge the §3/§5 duplication into a single pin-gate subsection.

### E4 — Deduplicate the kickoff-sequence prose

The kickoff sequence (interview → spec-foundation → design gate → provision → charter, "no milestone list") is restated at length in `kickoff`, `interview` (greenfield section), and `spec-foundation` (sequence section). Three narrations of one sequence is exactly the drift shape the corpus polices elsewhere. **Recommendation:** `kickoff` owns the sequence; `interview` and `spec-foundation` keep one-line handoff pointers. Saves ~40–60 lines of always-loaded prose and removes a three-way sync obligation.

### E5 — Reference-ify `verify-milestone`'s scar rules

`verify-milestone` is the densest skill: the flake-convergence rule (N≥5), the git-check-ignore rule, the dangling-record postconditions, environment-classification — all inline. These are load-bearing but *checklist-shaped*. **Recommendation:** move the scar detail to a `verify-milestone/references/hard-rules.md` with a compact in-skill checklist naming each rule in one line. The verifying session reads the reference once; the skill body stops paying the full cost on every load. (Same treatment is *not* recommended for the pin-record section — that is the gate itself and should stay in the skill.)

### E6 — Cheap-model routing for mechanical stages

Verification fan-outs (the `[auto]` sweep, punch-list fixers, screenshot capture/diff, plan lint) are mechanical stages where a smaller model is equally reliable. Workflow `agent()` calls and agent frontmatter accept `model`/`effort` overrides. **Recommendation:** annotate the two workflows and the verifier dispatches with deliberate model/effort choices (e.g. mechanical sweeps at lower effort; adversarial plan pass and security-adjacent verification at full). Record the policy in the capability ledger so it's revisited as models change. Pure cost/latency win; the judgment-bearing stages keep the strong model.

### E7 — Fix the plan-lint bypass (quality bug found during this review, cheap fix)

`check-plan.sh` only tag-lints dash-bullet done-conditions; numbered-style specs (and a stray non-canonical `[completeness]` tag) in keel's own tree bypass the lint entirely. **Recommendation:** extend the lint to numbered bullets and reject non-canonical tags — or normalize the legacy specs. Right now keel doesn't fully dogfood its own plan gate.

### Consolidations to consider, lower priority

- **Guard-script triplication** (~100+ lines of security-sensitive marker/TTL/whitelist parsing kept in sync by hand across `merge-guard.sh`, `guard-branch-rules.sh`, `session-bootstrap.sh`, held together by a parity test). The self-contained-hook idiom is deliberate; an alternative is a single sourced `lib/guard-common.sh` with a build step that inlines it into each shipped hook (generated, not hand-synced). Worth a spec only if these scripts keep changing.
- **Craft-reference overlap** — `interaction-craft.md`, `motion-cookbook.md`, and `product-ui-craft.md` all touch reduce-motion, focus rings, scrollbar chrome, live-surface states. Assign each fact one owner file and cross-reference, same as the design.md/architecture.md "one owner per fact" rule keel already applies to projects.
- **Autonomy decision chain** — the effective autonomy policy now spans four amend-by-reference decision files. Keep the files (history), but add a short "current effective policy" summary in the newest one, maintained on each amendment.
- **Release-chore accumulation** in `specs/chores/` — adopt the `_landed/` archive convention there too.

---

## 3. Best-practice alignment

Measured against the current docs (skills, plugins, subagents, workflows, best-practices, changelog through 2.1.202):

**Aligned or ahead:**
- Skill structure: frontmatter descriptions + `when_to_use`, `disable-model-invocation` on all human-authorization verbs, `allowed-tools` scoping on build/verify skills, skill-scoped hooks in frontmatter, references/templates for progressive disclosure — all current best practice.
- Plugin structure: convention-based discovery, hooks.json with SessionStart `compact` matcher (compaction survival — explicitly recommended), plugin-validate in CI, semver releases.
- Orchestration: fresh-context verifier subagents, worktree isolation, structured phases in the two workflows, read-only verifier agent with disallowedTools — matches the documented verification pattern (work phase → independent adversarial verification) almost exactly.
- Spec-driven long-horizon work: keel's specs/pins/derived-status/orient-before-build protocol is a stronger version of the documented "spec as durable artifact" guidance.

**Gaps worth adopting (all small):**
1. **`context: fork` frontmatter** now exists for skills. `verify-milestone` in particular is a candidate: forked execution gives the fresh-context guarantee at the harness level instead of by procedure ("run in a fresh session"). Evaluate for `verify-milestone` and possibly the adversarial plan pass.
2. **`$ARGUMENTS` / argument-hint consistency** — `verify-milestone` declares arguments; `auto` and `auto-merge` parse args from prose without declaring `argument-hint`. Declare them uniformly.
3. **Dynamic context injection** (the `!`command`` frontmatter pattern) is used only in `implement-milestone`. `verify-milestone` (current branch, dirty-tree, pin lines) and `land-feature` (open PRs + bases) would benefit from the same injected ground truth.
4. **Nested subagents (5 levels) + background-by-default** — no change required, but `implement-feature`'s orchestration ledger could exploit background verifier dispatch more aggressively; note it in the capability ledger.
5. **plugin.json metadata** — add `homepage`/`repository` fields (trivial; helps marketplace listing since the repo is public).
6. **Overlap policy with first-party skills** — keel correctly leans on `/security-review` and `/code-review`. Two adjacencies worth one deliberate paragraph somewhere (README or a decision): `frontend-design` (keel's design track supersedes it inside keel projects — say so, so sessions don't double-invoke) and `/verify` (the built-in app-verify skill vs keel's verify-milestone — keel's is the stronger, gated form; state that the built-in is not a substitute for the pin gate).

**One inconsistency to acknowledge:** keel mandates a stack profile for every project but carries none itself (reasonable — it's a no-UI methodology repo; its CI plays the role). Add the one-line acknowledgment the digest suggests, so a future contributor doesn't "fix" it.

---

## 4. New skills — recommendations

Keel today covers **build** completely and **sell** not at all. Everything ends at "feature done"; even "launch" exists only as a deferrals checkpoint no skill owns. For a solo builder shipping many small products, the validate-before-build and ship-and-sell surfaces are the largest unclaimed value. All four proposed areas were researched against native Claude Code capabilities and community prior art (~50 searches / ~30 source fetches). Verdicts:

| Candidate | Verdict | Shape |
|---|---|---|
| Research | **Build — as a wrapper, not an engine** | Standalone `keel:research` |
| Go-to-market | **Build — thin, interview-driven** | Standalone `keel:gtm` (or `spec-gtm`) |
| Marketing | **Split: build the technical half, adopt the rest** | Reference doc + milestone conventions; adopt a community collection for content strategy |
| Landing page / marketing site | **Build — the strongest candidate** | Standalone `keel:landing-page` |

### 4.1 `keel:research` — yes, and the native deep-research skill is the engine, not the competitor

The native `/deep-research` workflow already does the hard part well — fan-out searches, source fetching, adversarial claim verification, cited synthesis — and it keeps being maintained. Rebuilding that would be waste. But it has structural limits that matter for keel: no mid-run user input, no filesystem access, and its output is a chat report — it reads nothing from `specs/` and writes nothing back. The unclaimed ground (no meaningful prior art found) is the **integration layer**: research that starts from project context and lands as a spec artifact keel's other skills consume.

Shape: three typed modes, each with an output contract —

- **Validation / market research** → feeds `interview` / `spec-foundation` (and genesis): competitive alternatives, demand signals, a should-this-exist decision table. Notably, `auto:genesis` Phase 1 already *contains* an inline research fan-out — this skill should become the single owner of that mechanism, with genesis dispatching it (the same connective-tissue pattern keel uses everywhere else).
- **Technical / library-selection research** → feeds the stack profile and `decisions/`: an options-×-criteria table with evidence, landing as a decision-log entry in keel's existing format. (This also formalizes the "bounded web research" `spec-foundation` and the design gate already prescribe informally.)
- **Domain research** (underwriting, real estate, etc.) → feeds the data model: findings mapped to entities/attributes/invariants ready for `01-architecture.md`.

Each mode derives its scope questions from existing specs, holds one attended checkpoint between scoping and deep dive, may invoke `/deep-research` as its engine, and writes `specs/research/<slug>.md` (sources, confidence, explicit unverified-claims list — keel's honesty discipline applied to research).

### 4.2 `keel:gtm` — yes, thin and attended

No native coverage; the community space is crowded for sales-team GTM and thin for exactly your case (solo dev, small SaaS, no sales motion). The keel-specific value is not the reference knowledge — it's the **interview flow and the repo artifacts**, same as every keel spec skill. Contents worth encoding:

- **Positioning first, in April Dunford's strict sequence** (alternatives → unique attributes → value → who cares → category), refusing to jump to taglines. Output: a positioning canvas at `specs/gtm/positioning.md` — the foundation doc every downstream marketing artifact reads (the pattern the best community collections use).
- **Pricing module** (value-anchoring rules, tier structure, when-not-freemium) producing a priced tier table the user signs off.
- **Channel selection** scored for a solo founder (two-way-conversation-first channels, staged: community → content → launch platforms).
- **Launch module with hard guardrails** (Product Hunt post-2024 realities, Show HN rules) as a staged checklist.
- **The keel-native convention:** every output splits agent-draftable work from **founder-must-do** items (customer conversations, launch-day presence, final pricing sign-off) — mapping directly onto the `[attended]` tag.

Option to keep it even thinner: adopt a community marketing-skills collection as a companion plugin for generic reference material, and let `keel:gtm` own only the interview + artifact schemas.

### 4.3 Marketing — split it; don't build a monolith

Research finding: content-marketing strategy and drafting (calendars, topic clusters, email sequences, social) are well-covered by existing collections, including Anthropic's first-party knowledge-work marketing plugin — **skip building that layer; adopt one**. The genuinely unoccupied space is the **codebase-integrated technical execution** every collection stops short of: generating `sitemap.ts`/`robots.ts`, JSON-LD server components, OG image routes, and programmatic-SEO page ladders with anti-thin-content guardrails as *done-conditions* (per-page differentiation floors, batched rollout, the 2026 AEO/GEO findings like answer capsules and the measured irrelevance of llms.txt).

Recommended shape: **not a full skill** — a `references/marketing-site-tech.md` (like the craft references) plus milestone conventions, consumed by `spec-change`/`spec-feature` when marketing-site work is specced, with `[auto]` conditions (schema validates, sitemap covers all routes, pSEO pages pass the differentiation floor) and `[attended]` publish gates. If it grows, it can graduate to a skill later.

### 4.4 `keel:landing-page` — yes; strongest of the four

The clearest gap and the best keel fit. `app-design-directions` explicitly scopes marketing pages *out* ("product UI lives by different rules than landing pages") while listing marketing/landing as an archetype — so the surface every shipped product needs has no owner. Neither Anthropic (frontend-design is aesthetics-only) nor the community (copy-only, audit-only, or checklist fragments) ships an integrated build skill. And the domain has a settled, citable body of knowledge (Julian Shapiro's conversion formula, Harry Dry's landing-page grammar, Unbounce's quantitative benchmarks — e.g. 5th–7th-grade copy converting ~6× better).

Why it must be its own skill rather than an app-design-directions extension: the priorities invert. **Copy before pixels** (headline copy is the highest-conversion lever; the workflow starts from mined customer language, not visual direction); the scroll order is a persuasion argument, not a task workspace; attention ratio (1:1 links-to-goal), message match, and anti-fabricated-social-proof rules have no product-UI equivalent; acceptance criteria are quantitative (readability grade, word budget, LCP < 2.5s, meta/OG/schema present, analytics events wired).

Keel-native shape: compressed interview (consuming `specs/gtm/positioning.md` when it exists) → copy artifact (20+ headline candidates, section grammar chosen by awareness stage) → page build **through the normal milestone gates**, consuming the app's committed design tokens/workbench so the brand carries over at marketing-scale typography → verify with `[auto]` conditions + one `[attended]` review. PostHog CTA/scroll/form instrumentation wired by default. A waitlist-vs-signup mode switch covers pre-launch pages.

### Dependency order

`research` → `gtm` (positioning consumes validation research) → `landing-page` (consumes positioning + design tokens) → marketing-tech reference (consumes positioning + the live site). Each is independently useful; nothing blocks on the others existing.

---

## 5. Suggested sequencing (all spec-able as normal keel work)

Two independent tracks; nothing here is urgent enough to interrupt product work.

**Track A — consolidation & efficiency (mostly chores and spec-changes):**
1. `check-plan.sh` numbered-bullet + non-canonical-tag fix, plus normalizing the legacy specs (punch-list / spec-change; it's a real gate bypass today). **[E7]**
2. Tag-semantics consolidation to one owner + skill-anchors coverage (spec-change). **[E3]**
3. Kickoff-sequence dedup + verify-milestone reference-ification + the small best-practice items (argument-hints, injected context, plugin.json metadata, overlap paragraphs) — one or two punch-lists / spec-changes. **[E4, E5, §3 gaps]**
4. Cadence-default + effort-dial changes (spec-change each; the effort dial touches `spec-feature` + the shared rules §4, so treat it as the one carefully-reviewed change in this track). **[E1, E2]**
5. Model/effort routing annotations in the workflows + capability-ledger entry (spec-change). **[E6]**

**Track B — the lifecycle skills (each a feature: spec-feature → build → verify → dogfood on a real product):**
1. `keel:landing-page` — highest value, clearest spec, immediately dogfoodable (keel itself and any current product both need one).
2. `keel:research` — refactor genesis Phase 1 to dispatch it as part of the same feature.
3. `keel:gtm` — thin first version (positioning + launch checklist), grown by use.
4. Marketing-tech reference — smallest; can ride as a milestone within the landing-page feature or follow it.

**Deliberately not recommended:** rebuilding a research engine (native deep-research already is one), a content-marketing strategy skill (adopt a community collection), any change to the pin gate / fresh-context verification / merge authority (the capability ledger marks these permanent, and this review found them correct), and merging the guard scripts without a generated-inlining build step (the triplication is ugly but load-bearing).


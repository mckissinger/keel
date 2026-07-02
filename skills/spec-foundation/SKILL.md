---
name: spec-foundation
description: Stand up a project's FOUNDATIONAL specs/ once at kickoff — the product skeleton (a feature backlog, not a milestone list), the architecture + data model + environment contract, the decisions/deferrals conventions, and the project CLAUDE.md with the GitHub/CI/verified-pin process.
when_to_use: At the start of a new project, after the app-skeleton interview and before the design system. NOT for per-feature milestones — those are authored later, one feature at a time, by the spec-feature skill.
---

# Spec — Foundation

Turn a resolved set of **app-level** decisions (from the `interview` skill's app-skeleton round, or clear goal-framing) into the foundational `specs/` artifacts that govern the whole project, plus the project-level CLAUDE.md. This skill runs **once, at kickoff.** It does **not** author feature milestones — that is the per-feature job of `spec-feature`, done one feature at a time as building proceeds.

## What changed, and why (read first)

The previous single `spec` skill authored *the complete milestone list in one pass* at kickoff, design-blind for most features and at "outcome altitude" for late ones. For a small app that's fine; for a large app it structurally caps per-feature depth (one shallow pass over 40 milestones) and is the root cause of "thin features / generic design." The fix is **grain**: plan *globally* what is expensive to change (architecture, data model, design system, invariants, the GitHub/CI process) — that's this skill — and decide *locally, per feature, informed by what's already built*, what you can only judge by seeing (a feature's screens, states, and done-conditions) — that's `spec-feature`. This skill stops at a **feature backlog + a green foundation**, not a milestone list.

## The kickoff sequence this skill sits in

1. **`interview`** (app skeleton) — goal, users, scope, the **feature backlog**, the spine journey, external services, design *direction* inputs.
2. **`spec-foundation`** (this skill) — product skeleton + architecture + environment contract + conventions + project CLAUDE.md. **Stop. Do not author milestones.**
3. **Design *system* gate** (`app-design-directions`, attended) — explore directions → pick → build the **reviewable component gallery** + `specs/design.md`. Committed to main.
4. **`provision`** (attended) — logins, dev resources, allowlist, spend cap, green preflight.
5. **Kickoff ends.** Then the **per-feature loop** runs (see `spec-feature` / `review-feature`): for each feature, `spec-feature` → `implement-feature` → `land-feature` → `review-feature`. Interleaved (recommended) or batched up-front — both work; the cadence is the user's call.

## Structure

```
specs/
  00-product.md          # vision, users, out-of-scope, the FEATURE BACKLOG + build order, the spine journey
  01-architecture.md     # stack, data model, environment contract, hard invariants, deploy model
  design.md              # design system: decision + material palette; written at the design-system gate, committed to main, durable
  features/
    <feature>.md         # one per feature — the DEEP feature spec (interview outcome + screen mockups + its milestone list). Written by spec-feature, NOT here.
  milestones/
    m1-<slug>.md         # one file per milestone (the build/verify unit). Written by spec-feature.
  decisions/             # file-per-entry log of material decisions + reasoning (YYYY-MM-DD-<slug>.md + README)
  deferrals/             # file-per-entry list of what's outstanding before production is real (<slug>.md + _closed.md + README)
```

This skill writes `00-product.md`, `01-architecture.md`, the `decisions/` + `deferrals/` conventions (with their kickoff entries), and the project CLAUDE.md. The `features/` and `milestones/` dirs are *created* here but *populated* by `spec-feature`. Collapse freely for a small project (a single `specs/spec.md`) — never create a file just to satisfy the list.

The milestone-authoring + verification rules live in **`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`** (shared with `spec-feature`). This skill *establishes* them (and wires the CI gate, below); `spec-feature` *applies* them.

## `00-product.md` is a feature backlog, not a milestone list

Write it at skeleton altitude:
- **Vision + users + jobs** — what this is, who it's for, what it enables.
- **The feature backlog** — every feature as a short paragraph (the capability, who uses it, why it matters), plus a **build order** and which features are independent (parallelizable as waves). This is the map `spec-feature` draws from, one feature at a time. Do **not** decompose features into milestones here.
- **The spine journey** — the one end-to-end path through the app, so the first features build a usable walking skeleton rather than horizontal layers.
- **High-level data shapes** — core entities + key fields, enough for the architecture/data-model to anticipate the known features (it will migrate as features deepen).
- **Out-of-scope** — explicitly, so scope creep is detectable rather than arguable.

## Environment contract

1. **`01-architecture.md` carries the environment contract**: every external service, its mode (test/live), the env var names it requires, and how it's provisioned. Var *names* only — values never appear in the spec or any committed file.

   - **Home-assignment rule for front-end libraries (one owner per fact).** The stack splits by *design consequence*, not by "is it a library." Infrastructure with no design consequence — framework, language, styling engine, state, data-fetching, forms, auth, hosting — is decided here and owned by `01-architecture.md`. Design-consequential libraries — **component primitives, icon set, motion library, chart/data-viz library** — are decided at the design-system gate and owned by `specs/design.md`; this file's stack list *references* them ("front-end libraries: see design.md") but never re-decides them. The test: if you can't choose it well until the visual direction is set (shadcn-vs-Mantine, Phosphor-vs-Lucide, Tremor-vs-Recharts all turn on the direction), it's design-owned. Leaving these unowned is how an app defaults to slop.

2. **Test-mode credentials only until launch.** Dev gets its own dev-dedicated resources (e.g. a dev database project, payment test keys, a spend-capped AI-provider key). Record "live keys never enter this environment" in out-of-scope so violations are detectable.

   - **Deploy model: continuous deployment, single gated go-live.** If the project deploys to a host, `main` auto-deploys to production and every PR gets a preview (e.g. Vercel) — both **test-mode env** pre-launch, so "production" before launch is the prod build on real infra with no real users (harmless). **Previews are the verification surface** (the profile's Q10 deployed surface). "Launch" is the one discrete, **attended** event where live keys replace test keys, the real domain is pointed, and prod data migrations are applied — the home of the `deferrals/` real-resource checkpoints. Nothing in an autonomous run crosses it: explicit deploy/resource/live-mode commands are never allowlisted, and a push to `main` (which auto-deploys) is blocked by **branch protection on `main`** (see Repo setup) plus the standing "never commit to main" rule. (Local-only projects have no deployed surface — see below.)

3. **This skill writes the contract; `provision` executes it.** End the kickoff sitting by invoking `provision` — it runs logins, dev-resource creation, allowlist seeding, and the dry-run while the user is present; the sitting ends on its green preflight.

## Stack profile

Derive **`specs/stack-profile.md`** — the project's answers to the verification interface (`${CLAUDE_PLUGIN_ROOT}/references/profile-interface.md`): what a surface is, how to activate one and assert it's healthy, how to drive an action and assert its effect, how to seed no-human test state, the dev vs production build, the schema-versioning scheme, **whether it has a UI**, the deployed surface, and **the test-tier ladder (Q11)** — seeded from `${CLAUDE_PLUGIN_ROOT}/references/feedback-ladders.md` where an entry exists (priors, currency-checked by the research step, never adopted blind). **The scaffold-gap rule: if the scaffold doesn't ship a runner for a declared tier, kickoff adds it** — common web scaffolds ship no test runner at all, and a ladder first stood up mid-feature is the failure this rule exists to prevent (a keel run hit it live). Derive it from **reading the project** (dependency manifest, framework/build/test config) + **web research bounded by those questions** — keel ships no profile and no library; each project answers for its own stack. Propose it in the interview's synthesis and confirm it at the confirm-before-author gate. It is a durable spec artifact: `verify-milestone`/`review-feature` dispatch the runtime-proof through it, `provision` reads its shared-singleton answer, and its **has-UI?** answer gates the design track + the fidelity done-condition (a derived profile starts ~80% and hardens via `lessons/` as gotchas surface).

## Decision log

Make it a **file-per-entry directory** `decisions/` (not a single `decisions.md`): one `YYYY-MM-DD-<slug>.md` per material decision + a `README.md`, so parallel branches each *add a file* and never conflict on a shared append-log. Entry body:

```markdown
# YYYY-MM-DD — One-line summary of the decision
What was decided, why (the constraint or evidence that drove it), and what was rejected and why.
```

- Update an existing entry rather than adding a contradicting one; on reversal, strike the entry with a pointer to the superseder.
- Don't record what the code or spec already makes obvious — only the reasoning a future session can't reconstruct. Most implementation decisions belong next to the code (a migration comment, a `verified:` line, a PR body); reserve `decisions/` for cross-cutting/architectural calls.

## Deferrals ledger

The tracked list of everything outstanding before production is real. Make it a **file-per-entry directory** `deferrals/`: one `<slug>.md` per open item + a `_closed.md` archive + a `README.md`.

- One file per item: what's deferred, which milestone/verdict it came from, and the condition that closes it.
- **It has writers, not just a reader.** Seed the kickoff real-resource checkpoints (live-key swap, prod resource creation, prod migrations, domain) here at spec time. Run-discovered items are appended by whoever produces them: a milestone that passes *with* outstanding punch-list work records that PASS-WITH-DEFERRALS line **in this file** before its PR opens.
- The **run preflight reads it**: any deferral whose closing condition falls inside the run's scope is drained before launch.
- An item is removed only when its condition is actually met — not when the milestone merges.

## Project CLAUDE.md

Generate (or update) the project-level `CLAUDE.md` with:

- Brief project context: what this is, who it's for.
- The governing rule: "All work is governed by `specs/` — resolve implementation choices in favor of the spec, and flag conflicts rather than improvising."
- **The feedback ladder** (from the profile's Q11): the exact commands for each declared rung, cheapest → dearest, plus the two inner-loop rules — **single-test-first** (run the affected tests, not the whole suite) and **the routing rule** (reproduce/check at the cheapest rung that can see the failure class; the runtime walk is the gate, not the debugger). CLAUDE.md is the one artifact every later session reads — this is the ladder's delivery mechanism.
- The verification approach: milestone completion is checked by the verifier subagent (or a dynamic workflow per the milestone's `verification:` line) against the spec's measurable done-conditions; a feature is not done until its `review-feature` gate passes.
- **The run preflight** (authorization-completeness): "Before a milestone run, confirm every milestone in scope can complete autonomously. (1) Services: one cheap read-only command per service where available, bare env-var-name existence otherwise — never read values. (2) Spend/real-resource gates: any done-condition needing live spend must be pre-authorized (spend-capped key + allowlisted command), not gated per-use. (3) Deferrals: read `specs/deferrals/` — drain any open item whose closing condition falls inside this run's scope. Surface anything missing/dead/unauthorized in one batch before starting; if a gate can't be pre-authorized, treat that milestone as a stop point."
- **Derived status, never recorded status:** "Current state is derived — read the `verified:` lines in specs/milestones/ and `gh pr list`." Never add a current-phase paragraph (it lives on main while work advances on branches — stale by construction).
- **The GitHub process:**
  - One branch + one PR per milestone, named after the slug.
  - Checkpoint commits are fine. Independent milestones squash-merge (one commit per milestone on main). **Stacked milestones merge bottom-up with merge commits titled with the slug** — squashing a stacked PR orphans descendants' `verified:` records.
  - **Schema/state changes use a collision-free versioning scheme** (the profile's Q9), never a hand-incremented counter (which forces parallel branches to coordinate a global next-number and collide at merge). Prefer a content/timestamp version (e.g. `supabase migration new <name>` → a UTC-timestamp version). Forward-only: existing counter-named files stay. A timestamp removes the *file-name* collision, not the *shared-object* collision — when several sibling branches each need the SAME new shared change, make that statement **idempotent with an identical object name** (create-if-not-exists) so the earliest-versioned change applies and the rest no-op.
  - **Verify + record in stack order, bottom-up.** Don't fork the next milestone off unverified code. With the default one-file-per-milestone layout the `verified:` lines never conflict (each in its own file); the in-order rule rests on the semantic point plus the SHA-pin self-invalidation.
  - **Keep stacks as shallow as the genuine dependency chain requires.** Prefer parallelizable milestones off main; stacking exists only to decouple autonomous build-order from attended merge-order.
  - **A wave isn't done until it's green on `main` together.** Each milestone is verified on its own branch; nothing on a branch proves the merged result (combined migrations in order, the coverage harness seeing every new table/resource, siblings coexisting). After a wave's PRs merge, run one **consolidated check on `main`**: fresh state → all migrations → full suite (+ the consolidated first-run walk for UI waves). This is the only gate that catches cross-sibling integration bugs.
  - **A conflict-forced rebase re-pins; it doesn't re-verify from scratch.** If a rebase changed only conflict resolutions with no behavioral diff, re-run the suite green and **re-pin to the new `HEAD^`** with a carry-forward note. A rebase that changed behavior is a new state and must be re-verified.
  - Merge execution: before each stacked merge confirm the PR's base is `main` (`gh pr view <n> --json baseRefName`). Never merge with checks pending or red. Merging requires the user's per-merge approval (the `gh pr merge` ask rule). After each merge+delete, verify the next PR retargeted and is still OPEN (GitHub's auto-retarget races branch deletion and can CLOSE the dependent — recover with `gh pr edit <n> --base main` then `gh pr reopen <n>`).
  - Run `/verify-milestone` in a fresh session before opening the PR. The PR body quotes the done-conditions + verification evidence.
  - Spec updates and `decisions/` + `deferrals/` entries ride the same milestone branch as the work that caused them (file-per-entry, so parallel branches never collide).
  - **The user reviews and merges; agents open PRs and merge only on their explicit per-merge instruction.** Be precise about server-enforced vs behavioral: branch protection (once provision's preflight verifies it's *live*) blocks direct pushes/force-pushes/deletion of `main` — but does not by itself stop the shared agent token from *merging*. So "never commit to main" is a server guarantee; "only the user merges" is a behavioral rule. To make it server-true: a separate account without merge rights, or CODEOWNERS.
  - **Adversarial review runs before the pin, type chosen by milestone kind** (see `${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md` §3): implement → review → verify+pin, never pin-then-review (an earlier tenancy milestone was re-pinned ~5× because findings landed after the first pin).
  - **A review of a *stacked* PR is blind to its descendants** — treat every "remove/simplify this" finding as suspect until checked against descendants (an ultrareview called a `unique(org_id,user_id)` constraint redundant; it was the FK target the next stacked milestone depended on). Validate the reviewer's proposed *fix*, not just its finding.

## Repo setup

If the project isn't a git repo yet, step zero is `git init` + GitHub remote, with minimal CI — **the CI job list is the profile's declared ladder (Q11: static / unit / component-render / e2e as declared), not a hardcoded trio** — plus **the `verified-pin` job** and **the `plan-lint` job** — copy keel's shipped `${CLAUDE_PLUGIN_ROOT}/scripts/check-verified-pin.sh` and `${CLAUDE_PLUGIN_ROOT}/scripts/check-plan.sh` into the project's `scripts/` and wire each as a CI job (copy them, don't re-author them; their behavior is specified in `${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md` §5) — **and branch protection on `main`** (require a PR, block direct pushes). Branch protection is what makes "the agent never commits to main / nothing autonomous crosses go-live" *server-enforced* rather than behavioral. The `specs/` folder lands as the first PR — the spec deserves its own review moment before any code. Foundation-window PRs (this first PR, the workbench, the scaffold) pass the gate via its **bootstrap window**: until the first milestone or chore spec exists — judged at both the base branch's tip and HEAD — the gate exempts PRs with an explicit bootstrap-window message, and it arms itself permanently the moment the first one lands.

## Local-only projects

If the project is local-only (no cloud, no external services, no auth/payments), `provision` is a no-op and the deploy/preview/go-live machinery doesn't apply. End the kickoff on a **local green** (build + typecheck + lint + test + a route smoke), and verification swaps the preview-deploy smoke for a dev-mode route smoke throughout. Record the subtraction in `decisions/` so it reads as deliberate.

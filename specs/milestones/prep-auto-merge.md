# Milestone — prep-auto-merge: a human-invoked skill that prepares a repo's auto-merge prerequisites

**Goal:** `keel:prep-auto-merge` — a new human-invoked skill — discovers what a repo is missing for
`keel:arm-auto-merge` to pass and prepares it: it scaffolds the security-review workflow (and, for a
name-mismatch repo, the names-only `.claude/keel-auto-merge-checks.json`) as a **plain code PR the human
merges**, and **prints** the exact branch-protection / `allow_auto_merge` commands for the human to run. It
**never** runs the security-settings mutations, **never** sets the `ANTHROPIC_API_KEY` secret, and **never**
arms — it points at `keel:arm-auto-merge` as the next step. Provisioning stays **separate** from certifying:
the tool that builds the floor is never the tool that certifies it.

**Change:** `specs/changes/prep-auto-merge.md`. **No-UI** (keel plugin repo) → two-dimension done-conditions
(logic/invariants + behavioral completeness), no fidelity. **Depends on:** `keel:arm-auto-merge`
(`skills/arm-auto-merge/SKILL.md`, #199) and its reused assertion `scripts/check-branch-protection.sh`; the
names-only check-contract (`specs/milestones/_landed`/#205); the tier-1 recipe in
`references/template-contract.md`; `decisions/2026-08-01-required-checks-protection.md` (the protection
shape) and `specs/walks/2026-08-02-security-review-cache-mask.md` (the cache caveat). **Parallelizable:**
n/a (single milestone). **Routing:** reasoning-heavy and **trust-adjacent** — the scaffolded workflow, once
merged, *becomes* a repo's arming floor, so a subtly-hollow scaffold (missing `pull_request`, an unpinned
tag, a review job that runs nothing) would let a repo arm on a weak review. A gap here is a security gap.
Dispatch the verifier at `xhigh`; `/security-review` runs pre-pin.

## What the skill produces (shape)

- **A new skill** `skills/prep-auto-merge/SKILL.md` — frontmatter `disable-model-invocation: true`, a
  `when_to_use` naming the human-triggered per-repo setup, an `effort`. Procedure only; it reuses
  `check-branch-protection.sh` and issues no new merge-authority logic.
- **A committed workflow template** `skills/prep-auto-merge/templates/security-review.yml` — the single
  concrete source the skill materializes into a consuming repo. It matches keel's own dogfooded
  `security-review` job (`.github/workflows/ci.yml`): `on: pull_request`, `permissions: { contents: read,
  pull-requests: write }`, the review action pinned to a **full commit SHA**,
  `claude-api-key: ${{ secrets.ANTHROPIC_API_KEY }}`, and the job named so its status context is
  `security-review`. **Materialization is a verbatim file copy** — the skill copies this template file into
  the target repo's `.github/workflows/`, never re-typing or regenerating its content — so "the committed
  template passes (b2)" is exactly "what lands in the repo passes (b2)" (closing the gap the adversarial
  plan pass flagged: a re-typed scaffold could drift from the tested one).
- **The check-contract**, generated (not templated) only when the repo's check *names* differ from keel's.
  Its `required_checks` are derived from the repo's **actually-reporting** check contexts — the check-runs
  that have reported on the default branch's head (`gh api repos/{owner}/{repo}/commits/<default-sha>/check-runs`),
  or the repo's own CI workflow job names — **never** from `gh api …/protection`'s required-status-checks
  list. (Rationale, from the plan pass: prep runs *because* protection is missing/wrong on this repo — that
  is gap (b) — so protection's required list is 404 or incomplete by construction; reading the desired set
  from it would emit an empty or under-complete `required_checks`, which `read_check_contract` rejects as
  malformed, or — worse — silently DROP a check the repo already enforces, since the contract *replaces* the
  asserted set.) The generated set is **presented to the human for confirmation in the PR** before it lands.
  Shape (names-only, no `pattern`/`external` per #205):
  `{ "required_checks": [<reporting contexts>], "security_review": { "check": "security-review" } }`.
- **The printed protection command has a specified literal shape** (not left for a cold build to invent):
  a `gh api -X PUT repos/{owner}/{repo}/branches/<default>/protection` whose payload matches
  `decisions/2026-08-01-required-checks-protection.md` and what `check-branch-protection.sh` actually reads
  (it reads BOTH `.required_status_checks.contexts` and `.required_status_checks.checks[].context`,
  script `:251-252`) — `required_status_checks` with `strict: true` and the contexts, `enforce_admins: true`,
  `required_pull_request_reviews` with `required_approving_review_count: 0`, `restrictions: null`. Plus a
  separate `gh api -X PATCH repos/{owner}/{repo} -f allow_auto_merge=true`. The skill prints these; it never
  runs them.

## Done-conditions

### Logic / invariants

- [auto] **The skill discovers gaps by reusing `check-branch-protection.sh`, never re-authoring it.** The
  SKILL.md procedure runs the existing assertion and routes each GAP class to a targeted remediation —
  (b)/name-mismatch → the check-contract + the protection command; (b2) → scaffold the workflow;
  (d) → the `allow_auto_merge` command; a present-but-broken contract → fix it. No second copy of the
  branch-protection logic is introduced anywhere in the skill or its templates. Verified by skill content +
  a grep that the skill invokes `scripts/check-branch-protection.sh` and inlines none of its assertions.
  All committed tests below live in a **named** test file `scripts/check-prep-auto-merge.test.sh` (repo
  convention: every test is `scripts/<name>.test.sh`, invoked by name — there is no glob sweep).
- [auto] **The scaffolded workflow provably PASSES the very gate the skill prepares for.**
  `scripts/check-prep-auto-merge.test.sh` materializes `templates/security-review.yml` into a fixture repo
  (the existing `make_proj`/`git_proj` fixture shapes in `check-branch-protection.test.sh`) and runs
  `check-branch-protection.sh`; its **(b2) content scan passes** — the template declares the review context,
  invokes the review action on an **uncommented `uses:` line** matching the default pattern
  `claude-code-security-review`, and triggers on `pull_request`. Because materialization is a verbatim copy,
  this proves what actually lands in a consuming repo passes — not merely a look-alike.
- [auto] **The scaffolded workflow pins the action by a full commit SHA, never a tag.** The test asserts the
  template's `uses:` line matches `…@<40-hex>` (not `@vN` / a branch/tag) — a tag move must not silently swap
  the reviewer's code (`references/template-contract.md` tier 1).
- [auto] **The template's action SHA is kept in lockstep with keel's own security-review workflow.** The test
  asserts the SHA in `templates/security-review.yml` equals the `anthropics/claude-code-security-review@<sha>`
  pin in keel's own `.github/workflows/ci.yml` (the **one** such pin in the repo) — single source, so a keel
  SHA bump updates the scaffold and it can never ship a stale/forked pin.
- [auto] **`scripts/check-prep-auto-merge.test.sh` is wired as a named step in CI.** It is added to the test
  job in `.github/workflows/ci.yml` alongside the other `scripts/*.test.sh` steps — **not** left to a glob
  sweep (CI invokes each test by name; a test that isn't named never runs). Without this the SHA-lockstep
  invariant above holds only at the one-time `verify-milestone` pass and rots silently on the next keel SHA
  bump. **(Note for the build: `scripts/check-branch-protection.test.sh` — added by #205 — is itself NOT yet
  wired into `ci.yml`; wiring it too is in-scope hygiene here, since prep depends on that assertion.)**
- [auto] **A generated-shape check-contract is accepted by the reader.**
  `scripts/check-prep-auto-merge.test.sh` materializes a names-only contract of the shape the skill emits and
  asserts `check-branch-protection.sh:read_check_contract` accepts it (parseable JSON, `required_checks` a
  non-empty array of non-empty strings, a non-empty `security_review.check` ∈ `required_checks`, **no**
  `pattern`/`external`) and the assertion certifies those names. (This proves the *shape* the skill targets is
  valid; that the skill *derives* those names from reporting contexts is the `[attended]` condition below —
  a prose skill has no executable entry point to test its live derivation.)
- [auto] **The skill prints the mutations, never runs them; never sets the secret; never arms.** The
  SKILL.md boundary section states, and the skill obeys: for branch protection and `allow_auto_merge` it
  **prints** the exact `gh api` commands and stops; it issues no `gh api -X PUT/PATCH` of its own, no
  `gh secret set`, and no `gh pr merge` / marker write. It opens **only** the scaffolded-files PR (like
  arm-auto-merge opens the marker PR) and hands off to `keel:arm-auto-merge`. Verified by skill content (the
  boundary section is explicit and complete) and a grep that the skill body contains no protection/secret
  mutation call.
- [attended] **The ordered flow gates the protection command on the job actually reporting — not on prose
  alone.** The SKILL.md encodes the sequence ① scaffold PR → merge + let the check report → ② print & apply
  the protection / `allow_auto_merge` commands → ③ arm; and — because the change's own "near-one-command"
  goal invites collapsing ① and ② — it **withholds the protection command that adds the `security-review`
  required context until it has confirmed that job has reported at least once** on the default branch
  (`gh api repos/{owner}/{repo}/commits/<default-sha>/check-runs`). Until then it prints only the next step
  ("merge the workflow PR and let it run once"), never a command that would require a not-yet-reporting
  context (the tier-1 **wedge caveat**: such a context wedges every PR). It also carries the **cache-mask
  caveat** (`specs/walks/2026-08-02-security-review-cache-mask.md`). Verified by reading the skill's gated
  procedure.
- [attended] **The generated check-contract derives from reporting contexts and never drops an enforced
  check.** The skill's discovery step sources `required_checks` from the repo's actually-reporting check
  contexts (check-runs / workflow job names), **never** from `gh api …/protection`'s required list, and — since
  a committed contract *replaces* the asserted required set — it **includes every check the repo already
  enforces** (never silently narrows the floor) and presents the full generated set to the human for
  confirmation in the PR. Verified by reading the skill's derivation procedure. (The reader accepts the shape
  — the `[auto]` condition above; the *derivation* is prose, confirmed here.)

### Behavioral completeness

- [auto] **`skills/prep-auto-merge/SKILL.md` passes `check-skill-frontmatter.sh` + `check-skill-anchors.sh`.**
  Frontmatter carries `disable-model-invocation: true`, a `when_to_use` (human-triggered, per-repo, "before
  arming a repo that isn't set up"), and an `effort`.
- [auto] **A committed integration proof: the artifacts flip a gapping repo toward green.** In
  `scripts/check-prep-auto-merge.test.sh`, a fixture repo gaps on (b2) + name-mismatch; after the template
  file (verbatim) + a generated-shape contract are applied to the fixture, `check-branch-protection.sh`'s
  (b2) and the check-contract legs pass (the live protection / `allow_auto_merge` the printed commands set
  are simulated by the fixture's stubbed `gh`). Proves the template + contract are the *right* artifacts, end
  to end.
- [attended] **`references/template-contract.md`** cross-references `keel:prep-auto-merge` as the tool that
  scaffolds tier-1's security-review wiring (the recipe stays the single source; prep *materializes* it), so
  a project adopting auto-merge is pointed at the skill rather than hand-copying the recipe.
- [attended] **`skills/arm-auto-merge/SKILL.md`** — the "First, once per project" section points a not-yet-set-up
  repo at `keel:prep-auto-merge` (prepare first, then arm), reinforcing assert ≠ provision. **It also
  reconciles the now-partial redundancy**: that section currently hand-walks authoring the check-contract;
  the build makes a deliberate call — trim it to a pointer at `keel:prep-auto-merge` (the tool that now
  generates it) or keep it explicitly as the manual fallback — so there are not two silently-drifting
  "authoritative" procedures for the same artifact.
- [attended] **Collision behavior is stated.** The SKILL.md says what the skill does when the target repo
  already has a `security-review`-shaped workflow (or a differently-named review job): it **warns and leaves
  the existing file untouched** (surfaces the mismatch for the human), never blindly overwrites — a repo may
  already run a real review the human doesn't want clobbered.
- [attended] **A new `decisions/2026-08-03-prep-auto-merge.md`** records the mechanism and the settled forks:
  separate-skill independence (why not a `prep` arg on arm-auto-merge), print-only for the settings
  mutations, the plain-code-PR landing for the scaffold, the check-contract inclusion, the ordered
  wedge-avoidance flow, and secret-is-human. Append-only; amends by reference
  `decisions/2026-08-02-per-project-auto-merge-authorization.md`.
- [attended] **`/security-review` pre-pin** on this branch is mandatory — the scaffold becomes a repo's
  arming floor, so a hollow-scaffold defect is a security defect. A required finding is a **stop-point**.

## Verification

Fresh-context `verify-milestone` (or a `keel:verifier` subagent) at **xhigh**, from these done-conditions +
the checkout — never the builder's claims. Its proof run is the **full** committed suite (every
`scripts/*.test.sh`, unfiltered) + `check-skill-frontmatter.sh` + `check-skill-anchors.sh` + `check-plan.sh`
+ `check-neutral.sh` + `claude plugin validate --strict .`, all green. The **scaffold-validity** conditions
(the materialized `templates/security-review.yml` passes `check-branch-protection.sh` (b2), pins a SHA, and
tracks keel's own SHA) each carry a committed test — these are **new-behavior proofs** (the artifact is
valid), not regressions of prior code. `/security-review` runs **pre-pin**; a finding halts attended. The
`[auto]` conditions are committed shell tests; the `[attended]` ones are the doc/prose cross-references and
the ordered-flow encoding the verifier confirms by reading the skill + docs — **no `[runtime]`**: the skill
issues no live security-settings mutation (print-only), so there is nothing that only a live run proves. On
a clean verdict the verifier writes the `verified:` pin; the build session never pins its own work.

verified: clean at 2a6b853, 2026-08-03, via a fresh-context verify-milestone pass against this file — every
`[auto]` condition checked against the real code, never the builder's claims. Full proof run green: all 13
`scripts/*.test.sh` (unfiltered, run by name), `check-plan.sh`, `check-neutral.sh`,
`check-skill-frontmatter.sh`, `check-skill-anchors.sh`, `claude plugin validate --strict .`. Scaffold-validity
proven by `check-prep-auto-merge.test.sh` (6/6): materialized `templates/security-review.yml` PASSES
`check-branch-protection.sh` (b2) verbatim, pins a full 40-hex SHA
(`anthropics/claude-code-security-review@0c6a49f1fa56a1d472575da86a94dbc1edb78eda`), that SHA equals keel's
own pin in `.github/workflows/ci.yml:115` (single source), a names-only generated contract is accepted, and
the template+contract flip a name-mismatch fixture from (b2) GAP to PASS (with a D2 control proving the
scaffold is load-bearing, not decorative). Both `check-prep-auto-merge.test.sh` and the previously-unwired
`check-branch-protection.test.sh` confirmed wired as named steps in `ci.yml` (L78, L83) — no glob sweep.
`[attended]` conditions confirmed by reading: SKILL.md's ordered wedge-gated flow (scaffold PR → confirm
`security-review` reported via `.../check-runs` → print protection/`allow_auto_merge` → arm), the
reporting-contexts-not-protection derivation, collision = warn+don't-overwrite (SKILL.md:45-47), the
print-never-run/secret-is-human boundary (locked by `scripts/skill-anchors/prep-auto-merge.txt`, no
imperative mutation call found — only fenced print-templates), cross-refs present in
`references/template-contract.md:65-71` and `skills/arm-auto-merge/SKILL.md:56-60`, the decision doc
`decisions/2026-08-03-prep-auto-merge.md`, and both uncertainty records under
`specs/uncertainties/prep-auto-merge/`. Pre-pin `/security-review` (dispatched sub-agent + independent
adversarial diff read) found **no HIGH/MEDIUM findings**: real `on: pull_request` trigger, least-privilege
`permissions:`, byte-identical review job to keel's own dogfooded one, no reintroduction of the #205
`pattern`/`external` names-only violation, and no place in the skill prose where a mutation command is
directed to run rather than print (evidence in PR).

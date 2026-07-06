# Milestone — review-hardening-m3-skills: the pipeline stops contradicting itself; every small fix has one lane

**Goal:** the three files still treating `design/mockups/` as the mandatory fidelity
reference are converged on the workbench-composition model that `spec-feature`/
`spec-change`/§6 already canonize; `provision` seeds the inventory file its own preflight
hard-requires; and a one-line fix has exactly one routing answer across `debug`,
`punch-list`, and `spec-change`.

**Feature:** `specs/features/review-hardening.md`. **No-UI** → two-dimension
done-conditions. **Parallelizable:** no (follows m2 — both edit `skills/adopt/SKILL.md`).

## The contract changes

- **Workbench convergence (finish the refactor).** The fidelity reference is the feature's
  **real workbench composition** (named workbench/gallery components per Q8.3); a static
  mockup under `design/mockups/` is an **optional divergence sketch** — used when present,
  never demanded. `review-feature`, `implement-milestone`'s preconditions, and
  `no-foundation.md`'s output list all currently demand the mockup; after this milestone
  they reference the composition first and treat a mockup as the optional supplement.
- **Routing rule (one lane per fix size).** A fix with no design/spec judgment → a
  `punch-list` item (batched, one chore PR, batch pin). A fix needing a spec'd
  done-condition or any design decision → `spec-change` (one milestone). `debug` owns
  *diagnosis*, not landing: its output hands off to whichever lane fits, and its prose says
  so instead of offering its own third lane. `adopt` vs `no-foundation.md` get a
  one-sentence cut line: **adopt** when the project will take ongoing keel-managed
  development (retrofit the foundation once); **no-foundation** when one feature is being
  built against code that won't otherwise be keel-managed (discover just what the feature
  needs).

## Done-conditions

### Logic / invariants

- [auto] `skills/review-feature/SKILL.md`: the walkthrough diffs each surface against the
  feature's **workbench composition** (the named components from the feature spec's
  Movement-2 record) as the intent reference; `design/mockups/<feature>/<screen>.html` is
  consulted only when it exists, as the divergence sketch; no sentence calls the mockup
  "the intent" or assumes its presence.
- [auto] `skills/implement-milestone/SKILL.md`: the UI-milestone precondition names
  `specs/design.md` + the built workbench/gallery (and the feature spec's composition
  reference); mockups appear only as optional-when-present. A missing `design/mockups/`
  directory no longer blocks a UI milestone whose spec names its workbench components.
- [auto] `skills/spec-feature/references/no-foundation.md`: the output list names the
  workbench composition reference as the standard design artifact, with mockups as the
  optional divergence sketch — consistent with the parent SKILL's Movement 2.
- [auto] `skills/provision/SKILL.md`: step 4 explicitly seeds
  `specs/run-command-inventory.txt` (what it holds, one-line format, alongside the
  allowlist), and the auto-envelope section's "seeded alongside the step-4 allowlist"
  claim now points at a step that exists. The seeding instruction satisfies what
  `scripts/check-auto-preflight.sh` requires of the file.
- [auto] `skills/debug/SKILL.md`: the landing paragraph routes by the rule above
  (punch-list vs spec-change, with the criterion stated) and no longer offers an
  unrouted "trivial fix gets its own branch + PR" third lane; `skills/punch-list/SKILL.md`
  cross-references the same rule in one sentence.
- [auto] `skills/adopt/SKILL.md` carries the adopt-vs-no-foundation cut line (the
  ongoing-keel-management criterion), and `no-foundation.md` states the same line from its
  side — the two describe one boundary, not an overlapping spectrum.
- [auto] `scripts/skill-anchors/review-hardening.txt` exists (file-per-feature, per the
  auto-hardening precedent) anchoring the load-bearing new sentences: the
  workbench-as-reference line in `review-feature`, the provision seeding step, and the
  routing rule in `debug` — and `scripts/check-skill-anchors.sh` passes with it.

### Behavioral completeness

- [auto] `scripts/check-skill-frontmatter.sh` and `scripts/check-skill-anchors.sh` pass on
  all edited skills; no skill's frontmatter (name, description, `disable-model-invocation`)
  changed; `claude plugin validate --strict .` passes; every pre-existing self-test suite
  still passes.
- [auto] `scripts/check-skill-anchors.sh` gains **negative anchors**: a line prefixed `!`
  in an anchor file asserts the fixed string is ABSENT from its target file (the tool is
  presence-only today); `scripts/check-skill-anchors.test.sh` covers both directions
  (present-when-required, absent-when-banned, and the failure messages). The
  `review-hardening.txt` anchor file uses them to assert no converged file still requires
  `design/mockups/` as a precondition or calls a mockup "the intent" — the committed
  negative form of the convergence, scoped to the three converged files.
- [attended] Reading the edited `review-feature` + `implement-milestone` +
  `no-foundation.md` end-to-end against `spec-feature` Movement 2 and §6, the user (or the
  reviewing human at the PR) finds no remaining instruction that contradicts the
  workbench-as-reference model — the judgment half of "the refactor is actually finished."

## verification

verifier subagent against this file — each converged file checked against `spec-feature`
Movement 2 + `references/milestones-and-verification.md` §6 as ground truth (the canonical
model, never this spec's paraphrase); the provision step-4 seeding checked against
`scripts/check-auto-preflight.sh`'s actual requirements of the inventory file; the routing
rule checked for exactly-one-lane coverage of the tiny-fix space (no residual third lane in
`debug`, no gap between the lanes); the anchors file + lints run green.

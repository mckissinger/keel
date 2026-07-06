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

verified: clean at 0bda043, 2026-07-06, via fresh-context verifier subagent — all [auto] conditions PASS, each converged file checked against the canonical model (spec-feature Movement 2 + §6 of milestones-and-verification.md, never this spec's paraphrase): review-feature diffs against the workbench composition with the mockup as optional divergence sketch (body grep clean of mockup-as-intent); implement-milestone's UI precondition names design.md + workbench/gallery + the composition reference, missing design/mockups/ no longer blocks; no-foundation.md's output list names the composition reference as the standard artifact; provision step 4's seeding instruction checked against check-auto-preflight.sh's ACTUAL requirements (missing-file fail-closed, per-line dry-run with comment/blank skip, bundled-merge rejection — all satisfied by the instructed format) and the auto-envelope claim now points at a real step; debug routes by the binary criterion (no design/spec judgment → punch-list; spec'd condition/design decision → spec-change) with the old third lane gone file-wide and punch-list cross-referencing the same rule (lane coverage: binary partition, no gap); adopt + no-foundation state the one boundary from both sides. Anchors: review-hardening.txt (file-per-feature, no other anchor file touched) pins the three load-bearing sentences; negative anchors implemented in check-skill-anchors.sh ('!' asserts absence, missing file still an error) with suite coverage both directions + failure messages, verified empirically fail-on-banned-string and confirmed the banned strings exist on main so a revert trips them. Frontmatter byte-unchanged on every edited skill (hash-compared); check-skill-frontmatter 17 files PASS, check-skill-anchors 20 anchors PASS, all 10 suites + check-neutral + `claude plugin validate --strict` green. **[attended] remains open at the PR** (its stated venue): the end-to-end read of the three converged files. Verifier-flagged for that read: (1) review-feature's frontmatter DESCRIPTION still says "side-by-side with the feature's own mockups" — the spec's frontmatter-freeze condition forces this; needs a routing decision (likely a one-line spec-change or punch-list item if the freeze is lifted); (2) pre-existing old-model residuals outside m3's three-file scope: kickoff:43, adopt:38, spec-foundation:31. (evidence: verifier report in PR)

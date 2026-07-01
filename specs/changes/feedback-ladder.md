# Change — Feedback ladder: the inner-loop half

**Grain:** one change → one milestone (`spec-change`). **No-UI** (methodology/docs change to keel
itself). **Companion to** `tier-aware-verification` (landed): that change made committed tests
the *gate* (coverage gates the pin); this one governs the *inner loop* (build/debug routes to
the cheapest layer that can see the failure) and stands the ladder up at kickoff. The frame:
**the ladder governs the inner loop; the walk governs the gate. Two jobs — keel had only the
second, now it has the gate half; this adds the inner-loop half.**

## Why (the gap)

Researched in a separate session (branch `claude/code-setup-review-8s0v4w`, handoff doc —
delete that branch once this lands); re-based here onto merged `main`:

1. **Nothing stands the ladder up.** `implement-milestone` tells the builder to self-check via
   typecheck/lint/suites, and `tier-aware-verification` made committed tests gate the pin — but
   nothing *creates* the layers. Common web scaffolds ship **no test runner at all** (lived on
   the first tier-aware dogfood: the runner had to be bolted on mid-feature, milestone 2 of 4).
2. **Nothing routes debugging to the cheap layers.** `debug` step 1 reads runtime-first-for-
   everything; observed symptom: an agent hand-driving a browser to debug failures a typecheck
   or unit test shows in a second. Cost evidence: browser-automation-via-MCP debugging measures
   ~4× the tokens of the same task via CLI scripts, and e2e-class checks run ~100× slower and
   ~28× flakier than component-scope ones (research handoff, sourced).
3. **Derivation has no priors.** Q11 asks each project for its tiers, but every kickoff
   re-researches from scratch — and web/testing advice is heavily time-polluted (stale
   recommendations outrank current ones), so unseeded research reliably reproduces the obvious
   80% (which runner) and unreliably reproduces the critical 20% (escalation holes, scaffold
   gaps, flake traps, mid-migration nuance).

**Validated constraint from the same research:** the inverse failure (agents claiming done with
the spec unimplemented, lucky passes, reward-hacked tests) is better-documented than
over-verification — so the runtime walk and pin gate are **not weakened in any way** by this
change. The ladder tunes the inner loop; the gate stays exactly as `tier-aware-verification`
left it.

## The mechanic — five pieces

**1. Extend Q11 (no new question, no renumbering).** `references/profile-interface.md` Q11
gains: (a) **cost-ordering** — the tiers are answered cheapest→dearest with a rough speed per
rung and what each uniquely catches (shape / logic / wiring / environment); (b) **escalation
holes** — the failure classes that structurally cannot be seen below the runtime walk on this
stack (the profile names them so escalating is a routed decision, not a habit); (c) a ⚠
routing scar: *the inner loop reproduces at the cheapest layer that can see the failure class;
the walk is the gate, not the debugger* — plus one line: when browser automation is warranted,
drive it via CLI/scripts rather than MCP snapshotting (~4× token difference, measured).

**2. `skills/spec-foundation/SKILL.md` — stand the ladder up at kickoff.** The step-zero CI
job list = the profile's declared ladder (not a hardcoded trio); when the scaffold ships no
runner for a declared tier, kickoff **adds it** (the scaffold-gap rule). The project CLAUDE.md
section gains: the exact ladder commands from the profile, the single-test-first preference,
and the routing rule — CLAUDE.md is the one artifact every later session reads.

**3. Routing in the build/debug skills.**
- `skills/debug/SKILL.md` step 1: reproduce at the **cheapest layer that can see this failure
  class**, escalating only past a layer that structurally can't (the existing runtime-
  reproduction text stays, scoped to runtime-class bugs per the profile's ⚠ Q3/Q6 and Q11
  escalation holes). Regression-lock step: lock at the **lowest layer that reproduces** (the
  backfill rule — a defect that escaped to a higher layer is missing coverage one layer down).
- `skills/implement-milestone/SKILL.md` step 4 (already rewritten by tier-aware-verification):
  add the ordering — self-check runs the ladder **bottom-up** (static → unit → wiring → e2e),
  single-test-first.
- `references/milestones-and-verification.md` §3: one sentence naming the split — the ladder is
  how you build and debug; the walk is how a pin is earned; neither substitutes for the other.

**4. `skills/provision/SKILL.md` — preflight proves the ladder.** The green preflight runs each
declared rung green once (proves the tiers exist and work before any milestone builds — what
makes the tier-aware hard coverage gate fair). May *mention* lint/typecheck-on-edit hooks as an
optional flake-class mitigation — optional, never mandated (keel is a methodology, not a
harness config).

**5. New `references/feedback-ladders.md` — derivation priors, honestly labeled.** Ten-stack
recipes (web app frameworks ×3, cross-platform mobile ×2, API backends ×4, CLI) as **priors the
Q11 derivation reads, not profiles keel ships** — the "ships no profile" stance holds via three
structural guards, decided attended (2026-07-01):
- **Priors seed research; they never replace it.** Derivation starts from the file's entry and
  verifies currency with the bounded web-research step; a stale entry degrades to today's
  behavior (derive from scratch), never to a silently wrong answer.
- **Per-entry honesty markers:** each entry is date-stamped ("as of …") and marked
  **hardened** (a keel run used it) vs **researched** (unproven prior); marks flip as projects
  actually run them. A header disclaimer says exactly this.
- **Run-discovered staleness updates the file** — same accretion loop as scars/lessons.
Content emphasis: **lead with each stack's escalation holes, scaffold gaps, and flake traps**
(the hard-to-research 20%); the tool names are the boring preamble. Read at derivation time
only (progressive disclosure — not loaded into build sessions).

## Explicitly do NOT
- Do not weaken the runtime walk, the pin gate, or the tier-aware coverage gate in any way.
- Do not hardcode any tool into the methodology spine (Q11 stays question-based; tools live in
  the priors file as dated, hedged entries).
- Do not mandate edit-hooks.
- Do not renumber existing profile questions.

## Maintenance posture (decided attended, 2026-07-01)

Testing ecosystems churn at known rates (static tier ~stable; unit runners ~5-year cycles;
wiring layer mid-migration now; e2e ~4–5-year cycles). Upkeep is a light touch 1–2×/year,
self-funding via the three guards above: derivation catches staleness, runs update entries,
markers keep unproven advice from reading as authority.

## Scope

Docs-only: `references/profile-interface.md` (Q11 extension), `references/feedback-ladders.md`
(new), `references/milestones-and-verification.md` (one sentence, §3), three skills
(`spec-foundation`, `debug`, `provision`) + one small addition to `implement-milestone`. No
script changes. `scripts/check-neutral.sh` must stay green — the priors file names tools as
dated recipes (legitimate, like the profile's hedged examples) but must not use the denylisted
hardcodes; the spine files stay tool-free. One-owner rule: routing doctrine lives in Q11;
skills reference it.

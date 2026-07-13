# Change — testing-doctrine

One milestone, prose-only: a **test-authoring doctrine section** (§8) in
`references/milestones-and-verification.md` — the eight cross-stack testing
realizations the dogfood runs stated in-session — plus one-line pointers in the two
verbs that author tests and ladders. Approved by Michael 2026-07-12 (slate group F,
item 13); the realizations are recorded verbatim-with-evidence in
`specs/reviews/2026-07-12-skill-mining.md` §"Testing realizations to encode" (nine
listed there; the ninth — the failure-signature table — already landed as Q12 in the
substrate-contract milestone, so this change encodes the remaining eight).

## Why

Each of these rules was paid for at runtime: shared fixtures without cleanup were
called "fragile by construction" — the root of a forced serialized e2e suite **and
five false-green/red incidents**; an app-client seed silently dropped a column; a
design behavior asserted only on one surface class shipped hollow on the other; a
fenced-JSON parse failure was invisible below the live rung; a webhook's
dev-vs-prod-build divergence needed both server modes to see; a hand-run mobile rung
shipped a keyboard-occlusion bug; retry budgets in the inner loop masked real flakes.
The diagnoses lived in chat and were re-derived — one twice in nine hours. keel's
shared rules file is where the build verbs already look; putting the doctrine there
is what stops the re-derivation.

## Decisions taken

- **A new §8 "Test-authoring doctrine (cross-stack)" in
  `references/milestones-and-verification.md`**, after today's §7 — eight rules, each
  stating its doctrine plus the scar that earned it, stack-neutral (hedged tool
  examples only):
  1. **Per-suite data ownership** — every suite owns its fixtures and cleans up after
     each test; shared fixtures across suites are fragile by construction (the
     recorded root of five false-green/red incidents). A suite **serialized to paper
     over cross-test contamination** is the *symptom* of violating this — a smell to
     surface and diagnose, distinct from a stack ladder that legitimately serializes
     or isolates a shared-datastore tier by design (the feedback-ladders "serialize
     or isolate" prior stands).
  2. **Run-unique fixture identity** — when the suite doesn't reset its datastore,
     fixture IDs are run-unique (UUID/timestamp), never sequence counters; and an
     integration suite is run **twice** before the builder claims green (first-run
     luck is real; verification-side flake handling stays where it is owned —
     `verify-milestone`'s run-to-convergence hard rule, unchanged).
  3. **Seed via the privileged path, or assert the round-trip** — test seeds go
     through the superuser/direct path, or the suite asserts the seeded state read
     back equals what was written (an app-client seed once silently dropped a column
     it lacked the grant to write).
  4. **Cross-surface assertion parity** — a design-carrying behavior is asserted with
     equal strength on every surface class the profile declares (Q2); a
     presence-only assertion on the second surface is hollow coverage.
  5. **One capped-key live test per AI/external-model module** — env-gated (skipped
     without the key), asserting **invariants, never text** — the rung that catches
     what every mock hides (a fenced-JSON parse failure lived exactly there).
  6. **Tests and walks name their server mode** — some failure classes differ between
     the dev server and the production build (the recorded scar: an auth redirect
     that was a 401 on one and a 307 on the other), so a test class known to straddle
     that line runs in **both** columns, and **the production-build column builds
     under the stack's environment** (the build-time env, not the dev shell); the
     runtime walk already covers both builds (Q6) — this rule extends the *committed*
     tier where the class demands it.
  7. **An undeclared/hand-run rung ships bugs** — a tier the ladder defers (e.g.
     mobile e2e without CI hardware) is recorded as a deferral **with an explicit
     risk note**, and load-bearing steps in its scripts are never marked
     optional/skippable — de-fang "optional: true" on anything that carries an
     assertion.
  8. **Retry budgets are CI-only, waits are explicit** — retries never mask flakes in
     the inner loop (retry count 0 locally, small in CI), and waits target explicit
     conditions (an element, a response), never network-idle heuristics.
- **Two one-line pointers, no restatement**: `skills/implement-milestone/SKILL.md`'s
  test-authoring step (step 5) points at §8 when authoring the conditions' tests;
  `skills/spec-foundation/SKILL.md`'s Stack-profile paragraph points at §8's rule 1
  as a derivation-time smell check (an existing test config serialized to paper over
  cross-test contamination gets surfaced and diagnosed at derivation, not discovered
  mid-feature — a deliberate serialize-or-isolate tier per the stack's ladder prior
  is not the smell).
- **Renumbering owned**: today's file ends at §7; the new section lands as **§8** and
  no existing §-reference moves. (A prior chore fixed the one stale §-xref; grep
  confirms no other file cites a §8 today.)
- **Already-landed realization excluded**: the failure-signature table is Q12's (the
  substrate-contract milestone) — §8 rule 2's convergence clause and rule 7's
  deferral shape cite existing owners rather than duplicating them.

## Milestone

`specs/milestones/testing-doctrine.md` — edits
`references/milestones-and-verification.md` (new §8),
`skills/implement-milestone/SKILL.md` (step-5 pointer),
`skills/spec-foundation/SKILL.md` (derivation smell-check pointer).

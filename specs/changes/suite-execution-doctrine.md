# Change — suite-execution-doctrine

One milestone, prose-only. keel's shared rules already govern how tests are
**written** (`references/milestones-and-verification.md` §8) and how the runtime
proof is **defined** (`references/profile-interface.md` Q3/Q6/Q11/Q12), but nothing
governs how a suite is **run and proven** — and four independent dogfood defects all
live in that gap. This change closes it with four coherent edits across the two shared
references (plus the two dispatch skills that must carry the new rule to make it bite).

Harvest unit 3, from `specs/reviews/2026-07-18-harvest.md` — findings **B3** (~142–157),
**B4** (~159–171), **C3** (~246–257), **C4** (~566–570). All four are "how the suite
runs" failures; grouping them keeps the doctrine in one place instead of four.

## Why — the four defects, each paid for at runtime

- **B3 — a green run against an adopted or stale server proves nothing.** Three
  projects, one hole: Relay's `next start` never rebuilds, so a render milestone's e2e
  passed against a build predating the change — the fidelity screenshot showed the
  **old design**, and behavior-only assertions pass identically on old and new render,
  so nothing flagged it. Jarvis adopted a leftover server on the port and asserted
  against a different build entirely — **twice**. CRE mitigated the same class with a
  remembered `rm -rf .next` before prod walks. Jarvis committed the right fix with the
  reasoning (`reuseExistingServer: false` — fail loudly on a busy port). keel's
  runtime-proof contract should forbid server adoption outright rather than leave each
  project to rediscover it.
- **B4 — the milestone-scoped spec filter is baked into the orchestration dispatch
  prompts, producing false green.** CRE, textbook: a filtered RLS run showed **6
  passed / 192 skipped** — green; the full run showed **4 failed**; clean `main` showed
  **6 failed** — a pre-existing failure no scoped run could see. Relay: `implement-feature`
  dispatched **both** builder and fresh-context verifier with milestone-scoped e2e, and
  a builder was caught reporting *"I did not run e2e (per instruction)."* `test-health`
  audits for this but never touches the dispatch prompts that cause it.
- **C3 — long suites backgrounded burn the supervision budget polling "still
  running."** Subagents backgrounded a ~10-minute suite and paid **336k tokens / 31.8
  min**, **320k / 40.3 min**, and **325k tokens across 5 tool uses** — pure waiting;
  reported results amounted to "still running." The user polled repeatedly; `Monitor`
  timed out on long runs 4+ times across projects. The correction was to run
  **foreground with an explicit timeout**.
- **C4 — CI topology has no doctrine.** CRE paid **four redundant production builds per
  PR** because sharding multiplied the fixed setup (build + install) instead of reducing
  it, and browsers/deps re-installed per job. §8 governs how tests are written; nothing
  records that a CI suite should build the artifact **once and share it**, cache browsers
  + deps, and treat sharding as a multiplier of fixed setup — not a reducer.

Each diagnosis lived in chat and was re-derived across sessions. The shared references
are where the build/verify verbs already look; putting the doctrine there is what stops
the re-derivation.

## Decisions taken

**Home split (already adjudicated, applied here).** The runtime-proof contract (B3) and
the CI-topology doctrine (C4) are **stack-mechanics** → `references/profile-interface.md`.
The verifier-dispatch rule (B4) and the foreground/background suite-execution rule (C3)
are **stack-neutral methodology** → `references/milestones-and-verification.md`. All
phrasing is **stack-neutral**: "the profile's server-run mechanism" and "the production
build", never a framework's server flag or CLI.

- **`references/profile-interface.md` Q6 gains the runtime-proof server/build-freshness
  contract (B3)** — a `⚠` scar stating that the runtime proof runs against a build
  **freshly produced for the commit under test**, served by a server **this run
  started**: never adopt a listening server (fail loud on a busy port — a busy port is a
  stop, not a fallback), and never assert against a build that was not freshly produced
  for the commit under test. This **extends** Q6's existing "runtime-proof runs against
  both builds" — it does not replace it.
- **`references/profile-interface.md` Q11 gains the CI-topology doctrine (C4)** — a `⚠`
  scar stating that in CI the production artifact is **built once and shared** across
  jobs/shards, browser binaries and dependency installs are **cached**, and **sharding
  multiplies the fixed per-job setup (build + install) rather than reducing it** — so a
  suite shards only once its per-shard variable cost dominates that fixed setup.
- **`references/milestones-and-verification.md` gains a new §9, "Suite execution (how a
  suite is run)"** — the deliberate parallel to §8 ("how a test is written"), holding two
  rules:
  1. **The proof run is the full committed suite — the verification dispatch forbids a
     spec/milestone filter (B4).** The fresh-context verifier / `verify-milestone`
     dispatch **must not** carry a milestone-scoped or spec filter for the proof run;
     a green filtered run is not a pass. **Explicit inner-loop exemption:** the builder's
     own single-test-first dev loop **may** filter to the affected test — but the
     **verification/proof run and any "runtime passed" claim (and therefore any pin)**
     are the **full** suite, never a filtered subset.
  2. **A suite that would outlast unattended supervision runs foreground with an explicit
     timeout (C3).** A suite/walk whose expected duration (the Q12 budgets) would outlast a
     single supervision window — one that cannot be watched to completion within the harness's
     own `Monitor`/foreground timeout, so backgrounding it leaves the session **polling** "still
     running" instead of the harness supervising the run — runs **foreground with an explicit
     timeout**. The trigger is that concrete foreground-vs-poll boundary (the harness's
     supervision/`Monitor` timeout), **not** a bare "supervision budget": Q12 records the
     per-suite durations and the 2× kill-bound, and there is no separate named budget quantity to
     look up. The **bound itself** (kill at ~2× the recorded budget, classify as environment)
     stays **owned by Q12** — §9 references it, never restates or relocates it.
- **`references/profile-interface.md` Q12's background clause is reconciled to §9 (C3).**
  Q12 today ends its duration-budget bullet with "long suites run backgrounded with
  periodic progress checks where the harness supports it" — an **unconditional**
  background instruction that now contradicts §9.2. It is amended so backgrounding
  applies **only** when the harness can watch the run to completion within a single
  supervision/`Monitor` window; a suite expected to outlast that runs **foreground with an
  explicit timeout per §9.2**. The old unconditional clause is
  **retired** (negative anchor); Q12 keeps ownership of the budgets and the kill-bound.
- **Two dispatch skills carry the B4 rule so it bites, one line each.**
  `skills/verify-milestone/SKILL.md` (the proof-run owner — its step 4/5 runs the
  committed suites and the walk) and `skills/implement-feature/SKILL.md` (step 2, whose
  verifier dispatch prompts off a **single** milestone's done-conditions — the scoping to that
  milestone is emergent, not a literal filter instruction in the prose today) each gain **one
  sentence** pointing at §9.1: the verifier dispatch forbids a spec/milestone filter; the proof
  run is the full suite. No rule is restated — the pointer rides, the doctrine stays in §9.
- **Anchors.** A new `scripts/skill-anchors/suite-execution-doctrine.txt` (file-per-feature,
  never editing an existing anchor file — §4) carries **positive** anchors on each new
  load-bearing sentence (the Q6 server/build-freshness contract, the Q11 CI-topology
  doctrine, §9.1's no-filter + inner-loop-exemption clause, §9.2's foreground/timeout
  clause, and the two skill pointers) and one **negative** anchor retiring Q12's
  unconditional background clause (confirmed present at the merge-base before removal, per
  the anchor-file rules).

## Deliberately not in scope

- **The cadence contract for `[runtime]` conditions (harvest C2 — no nightly/on-demand
  lane).** A separate `spec-change`; this unit is about how a suite *runs*, not *when* a
  scheduled lane fires. Not touched here.
- **CRE's shard rebalance / `workers: 1` diagnosis (C1).** CRE-repo remediation via
  `test-health`, not a keel-doctrine change.
- **Any framework wiring** (a project's actual `reuseExistingServer: false`, its CI
  build-once config). keel authors the *contract*; each project's `specs/stack-profile.md`
  answers it in its own stack's terms.
- **Renumbering or reworating §1–§8** — the new section appends as §9; nothing above it
  moves.

## Milestone

`specs/milestones/suite-execution-doctrine.md` — one milestone, prose-only. Edits
`references/profile-interface.md` (Q6 scar, Q11 scar, Q12 reconciliation),
`references/milestones-and-verification.md` (new §9), `skills/verify-milestone/SKILL.md`
(one-line pointer), `skills/implement-feature/SKILL.md` (one-line pointer), and adds
`scripts/skill-anchors/suite-execution-doctrine.txt`.

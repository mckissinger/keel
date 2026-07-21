# Milestone — suite-execution-doctrine

Change context: `specs/changes/suite-execution-doctrine.md`. One milestone, prose-only.
Edits `references/profile-interface.md` (Q6 runtime-proof server/build-freshness scar; Q11
CI-topology scar; Q12 background-clause reconciliation), `references/milestones-and-verification.md`
(new §9 "Suite execution"), `skills/verify-milestone/SKILL.md` (one-line §9.1 pointer),
`skills/implement-feature/SKILL.md` (one-line §9.1 pointer), and adds
`scripts/skill-anchors/suite-execution-doctrine.txt`. No scripts, gates, hooks, or
templates change behavior.

**Integration seams.**
- **§ numbering + the pre-existing `§9` citations.** `references/milestones-and-verification.md`
  ends at §8 today; the new section appends as **§9** and must not renumber §1–§8. A repo-wide
  scan shows every existing bare `§9` citation (in `references/growth-operations.md`,
  `skills/run-growth`, `skills/measure`, `skills/spec-campaign`) resolves to **growth-operations.md
  §9**, a *different* file — those citations must stay resolving there, untouched. Any **new**
  citation this milestone adds to the M&V §9 is **file-qualified** (e.g. "milestones-and-verification.md
  §9" or "§9 (suite execution)"), never a bare "§9" that a reader could mis-resolve to the growth
  section.
- **Q6 extends, not replaces.** The B3 scar sits under Q6 and adds to its existing "The
  runtime-proof runs against **both**" / "Prove against both fidelities" text — that text stays.
- **Q12 owns the bound; §9.2 owns the choice.** §9.2 references Q12's kill-at-2×-budget timeout
  rule and the per-suite budgets; it must not restate or relocate them. Q12's amended clause
  references §9.2 for the foreground/background choice. The two reference each other; neither
  duplicates the other.
- **§8 is untouched.** The §8 test-authoring doctrine (how tests are *written*) is not edited;
  §9 is its deliberate counterpart (how a suite is *run*).
- **The two skill pointers ride existing prose.** `verify-milestone`'s step 4/5 already runs the
  committed suites and the walk; `implement-feature`'s step 2 already dispatches the fresh-context
  verifier — each pointer lands as one sentence inside that existing step without disturbing it.
- **Anchor file is new, file-per-feature.** `scripts/skill-anchors/suite-execution-doctrine.txt`
  is a new file (never an edit to an existing anchor file — §4 collision rule).

Evidence base: `specs/reviews/2026-07-18-harvest.md` findings B3 (~142–157), B4 (~159–171),
C3 (~246–257), C4 (~566–570).

## Done-conditions

- [auto] **Q6 carries the runtime-proof server/build-freshness contract (B3).**
  `references/profile-interface.md` Q6 gains a `⚠` scar stating **all three** clauses: (a) the
  runtime proof runs against a build **freshly produced for the commit under test** (never a stale
  build); (b) served by a server **this run started** — the run **never adopts a listening
  server**; (c) a **busy port fails loud** (it is a stop, not a fallback to the found server).
  Phrased stack-neutrally ("the profile's server-run mechanism", "the production build") — no
  framework server flag or CLI named. *Falsifiable:* a version missing any one of the three clauses,
  or that permits adopting a found server, fails.
- [auto] **The B3 scar extends Q6, does not weaken it.** Q6's existing statement that the
  runtime-proof runs against **both** the dev/fast build and the production build remains present
  and unchanged in meaning; the new scar is additive. *Falsifiable:* if Q6's both-builds text is
  removed or narrowed to one build, this fails.
- [auto] **Q11 carries the CI-topology doctrine (C4).** `references/profile-interface.md` Q11
  gains a `⚠` scar stating **all three** clauses: (a) the CI production artifact is **built once and
  shared** across jobs/shards (not rebuilt per shard); (b) browser binaries and dependency installs
  are **cached**; (c) **sharding multiplies the fixed per-job setup (build + install) rather than
  reducing it** — so a suite shards only once its per-shard variable cost dominates that fixed setup.
  Stack-neutral phrasing. *Falsifiable:* a version that omits build-once-and-share, omits the
  caching clause, or states sharding as a pure reducer, fails.
- [auto] **M&V §9 exists with the two suite-execution rules (§9.1 and §9.2).**
  `references/milestones-and-verification.md` gains a section headed **"## 9. Suite execution (how a
  suite is run)"** placed **after §8**, holding the two rules below. A brief framing sentence before
  §9.1, or a short §9.0 pointer to §8's counterpart, is permitted — what's forbidden is the doctrine
  sprawling into a *third* suite-execution rule. The two required rules:
  - **§9.1 — the proof run is the full suite, no filter (B4):** the verification / fresh-context
    verifier / `verify-milestone` dispatch **forbids** a spec/milestone filter for the proof run,
    and a green filtered run is not a pass — **with the explicit inner-loop exemption**: the
    builder's own single-test-first dev loop **may** filter to the affected test, but the
    verification/proof run and any "runtime passed" claim (and therefore any pin) are the **full**
    suite. Both halves (the prohibition **and** the inner-loop exemption) are present.
  - **§9.2 — foreground-with-timeout for suites that outlast supervision (C3):** a suite/walk whose
    expected duration (per Q12's budgets) would **outlast a single unattended supervision window** —
    concretely, one that cannot be watched to completion within the harness's own `Monitor`/foreground
    timeout, so backgrounding it leaves the session **polling** "still running" instead of the harness
    supervising the run — runs **foreground with an explicit timeout**, not backgrounded to poll; and
    it **defers the bound** (kill at ~2× the recorded budget, classify as environment) to **Q12**,
    referencing rather than restating it. The trigger is stated against that concrete
    foreground-vs-poll boundary (the harness's supervision/`Monitor` timeout — the point past which a
    backgrounded run can only be polled, not supervised), **never** against a bare "supervision budget"
    quantity: Q12 records the per-suite expected durations and the 2× kill-bound, and there is **no
    separate named supervision-budget quantity** in the corpus to compare against.
  *Falsifiable:* a §9 missing the inner-loop exemption, missing the no-filter prohibition, missing
  the foreground/timeout rule, that restates (rather than references) Q12's kill-bound, or whose §9.2
  trigger hinges on an undefined "supervision budget" quantity rather than the concrete
  foreground-vs-poll / harness-`Monitor`-timeout boundary, fails.
- [auto] **Q12's unconditional background clause is retired and reconciled (C3).**
  `references/profile-interface.md` Q12 no longer states backgrounding **unconditionally**: the
  clause that read "long suites run backgrounded with periodic progress checks where the harness
  supports it" is amended so backgrounding applies **only** when the harness can watch the run to
  completion within a single supervision/`Monitor` window, and a suite expected to outlast that runs
  **foreground with an explicit timeout per §9.2** (the M&V §9 reference, file-qualified). Q12 **retains** ownership of the per-suite budgets and the
  kill-at-2×-budget rule. *Falsifiable:* if the unconditional background sentence survives verbatim,
  or Q12's budgets/kill-bound are removed, this fails.
- [auto] **The two dispatch skills point at §9.1 (B4 bites).**
  `skills/verify-milestone/SKILL.md` (in its step 4/5 suite/walk prose) and
  `skills/implement-feature/SKILL.md` (in its step 2 verifier-dispatch prose) each carry **one
  sentence** stating the verifier/proof-run dispatch forbids a spec/milestone filter — the proof run
  is the full suite — pointing at M&V §9.1 (file-qualified). No §9 rule is restated in either skill;
  the surrounding step prose is otherwise unchanged. *Falsifiable:* a pointer missing from either
  skill, or one that restates the rule instead of referencing it, fails.
- [auto] **Anchors committed, positive + negative (edit-durability).** A new file
  `scripts/skill-anchors/suite-execution-doctrine.txt` (never an edit to an existing anchor file)
  declares: **positive** anchors — one full operative sentence each — for the Q6 server/build-freshness
  contract, the Q11 CI-topology doctrine, §9.1's no-filter-plus-inner-loop-exemption clause, §9.2's
  foreground/timeout clause, and each of the two skill pointers; and **one negative** anchor for
  Q12's retired unconditional background clause (the removed string, confirmed present at the
  merge-base before removal per the anchor-file rules). `scripts/check-skill-anchors.sh` passes.
  *Falsifiable:* a missing positive anchor, or a negative anchor whose string still appears in Q12,
  fails the lint.
- [auto] **Stack-neutral phrasing.** None of the edits names a framework, runner, server flag, or
  CLI as required (hedged examples at most); `scripts/check-neutral.sh` passes.
- [auto] **No renumbering, no broken or ambiguous references.** §1–§8 of
  `references/milestones-and-verification.md` keep their numbers and content (nothing above the new
  §9 changes); every existing bare `§9` citation across the repo still resolves to
  `references/growth-operations.md` §9 (unchanged); every **new** citation this milestone adds to the
  M&V §9 is file-qualified so it cannot mis-resolve to the growth section; and every other
  §-citation / Q-citation across `skills/`, `references/`, `workflows/`, `agents/` still resolves to
  the section it named.
- [auto] **No weakening — invariants the edit must preserve.** Verify none of the following is
  removed, narrowed, or contradicted: Q6's runtime-proof-runs-against-**both**-builds rule; §3's
  `[runtime]` coverage gate and the pin rules (§5) — §9.1's inner-loop exemption permits filtering
  **only** in the dev loop and **never** for the proof run, the pin, or any "runtime passed" claim;
  Q12's per-suite budgets and kill-at-2×-budget timeout rule (owned by Q12, only *referenced* by
  §9.2); §8's test-authoring doctrine (untouched); `verify-milestone`'s existing hard rules and
  step-5 walk (unchanged beyond the one added pointer sentence); `implement-feature`'s step-2
  fresh-context-verification independence (unchanged beyond the one added pointer sentence).
  *Falsifiable:* any of these being weakened fails the condition.
- [auto] **Repo checks green.** `claude plugin validate --strict .`, `scripts/check-neutral.sh`,
  `scripts/check-plan.sh`, `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`,
  and every `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; prose-only — closable by
reading the named files and running the named checks: `check-neutral.sh`, `check-plan.sh`,
`check-skill-anchors.sh`, `check-skill-frontmatter.sh`, `claude plugin validate --strict .`, the
`*.test.sh` self-tests, and a repo-wide grep for `§9` / `§`-citation resolution). No `[runtime]`
walk exists — keel is no-UI; the standing suites plus a fresh verifier subagent are the verification.

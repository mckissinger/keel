# Milestone — verify-environment-integrity

Change context: `specs/changes/verify-environment-integrity.md`. One milestone,
prose-only across four files plus one new anchor file. It installs the
**poisoned-environment guard**: a `[runtime]`/environment-dependent **negative** finding
may not stand until the working tree is clean for the stack profile's declared
service-config paths **and** an independent positive control proves the environment
reflects committed state. keel is stack-neutral, so the profile declares the specifics
(the paths, the probe/signal) and the spine (verifier contract + shared verification
rules) mandates the requirement; `verify-milestone` runs it.

Files edited: `agents/verifier.md`, `references/profile-interface.md`,
`references/milestones-and-verification.md`, `skills/verify-milestone/SKILL.md`. New file:
`scripts/skill-anchors/verify-environment-integrity.txt`. No scripts, hooks, gates, or
templates move.

**Integration seams** (the four edited sites must stay coherent — see the change spec's
"Integration seams"): the **scope carve-out** (negative runtime findings only — never
`[auto]`/static, never a clean pass) appears at every site; the **authorship split**
(profile supplies paths+probe, the spine mandates the requirement) is consistent (the two
references and the verifier defer specifics to the profile; the profile declares specifics
and does not restate the spine mandate); Q14's **provision-finalized** language matches
Q12/Q13's authorship pattern.

## Done-conditions

### Logic / invariants (the contract is stated correctly and completely)

- [auto] **The profile declares the two specifics.** `references/profile-interface.md`
  gains a verification-integrity profile question (Q14, or an equivalently-discoverable
  placement a build/verify session reads as the profile's answer) declaring both: (a) the
  **service-config paths** — the tracked paths whose uncommitted working-tree state makes
  the running services reflect something other than committed code; and (b) the
  **positive-control probe** — the independent signal *and* the restart/probe recipe that
  prove the environment reflects committed state (probe the gate, not the start banner).
  The question states that a `[runtime]`/environment-dependent **negative** finding is
  gated on both, and carries a scar note recording the B2 case (a failure reproduced
  across dev+prod and new+existing users, all inside one poisoned environment; the tell of
  a genuine reload was an independent signal change, not the repetitions). Falsifiable by
  reading the question: both declarations, the gating sentence, and the scar note are
  present, or the condition fails.
- [auto] **Q14's specifics-vs-commands authorship split matches Q12/Q13.** The new question
  states its answer is **derived at spec time** (which paths, which signal) with the exact
  restart/probe commands **finalized at provision** — the same "finalized at provision"
  authorship pattern Q12/Q13 use — so a derivation session records a placeholder for the
  commands rather than inventing them. Falsifiable: the finalized-at-provision language is
  present and attached to the command specifics.
- [auto] **The spine mandate is stated in `milestones-and-verification.md`.** The shared
  verification rules (§3, the runtime-walk / verification-method rules) gain the
  authoritative statement: before a verifier or the runtime walk records a
  `[runtime]`/environment-dependent **negative** finding, it (a) asserts the working tree
  is clean for the profile's declared service-config paths and (b) establishes the
  profile's positive control that the environment reflects committed state — probe the gate
  (restart, hit the endpoint, expect a real response), requiring an **independent signal to
  change, not a repetition to recur**. The text states that reproducing a failure N times
  inside one un-restarted environment certifies nothing, and defers the specifics to the
  profile (Q14). Falsifiable by reading §3: the mandate, the independent-signal-not-
  repetition clause, and the profile deferral are present.
- [auto] **The verifier contract carries it as a ground rule.** `agents/verifier.md` gains
  a ground rule in the environment-classification family (near "Classify infra-shaped
  failures as environment" / "the profile is runtime ground truth") requiring, before any
  negative finding that depends on the running environment, both (a) the clean-tree
  assertion for the profile's declared service-config paths (a dirty tree there → classified
  environment, not a discrepancy) and (b) the profile's positive control (probe the gate,
  not the start banner; confirm the independent signal changed). The rule states
  explicitly that **reproducing a failure N times inside one un-restarted environment is
  not confidence** — it is the same poisoned read N times. Falsifiable by reading the
  ground rule.
- [auto] **`verify-milestone` runs it.** `skills/verify-milestone/SKILL.md` step 4
  (substrate preflight) asserts the working tree is clean for the profile's declared
  service-config paths before a runtime verdict; and the Verdict section gates a negative
  `[runtime]`/environment-dependent finding on the profile's positive control, classifying
  a control-less negative runtime finding as **environment, not a discrepancy** (beside the
  existing environment-assumption-mismatch classification). Falsifiable by reading step 4
  and the Verdict section.
- [auto] **The B2 tell is stated, not merely implied.** At least one of the four sites
  states in a single sentence that an **independent signal change** certifies a genuine
  reload while a **repetition does not** — the one thing B2 adds atop B1's clean-tree
  assertion. Falsifiable: the sentence exists and names both halves (independent-signal-
  change certifies; repetition does not).

### Behavioral completeness (every consuming site coherent; scope respected; no drift)

- [auto] **The scope carve-out appears at all four sites.** Each of the four edited sites
  (Q14 in `profile-interface.md`, §3 in `milestones-and-verification.md`, the ground rule
  in `verifier.md`, and step-4/Verdict in `verify-milestone/SKILL.md`) states the scope:
  the requirement applies to `[runtime]`/environment-dependent **negative** findings
  **only** — never `[auto]`/static findings, and **never a clean pass**. Falsifiable: a
  site missing the carve-out fails the condition (this is the guard against the real
  regression of making a positive control the price of every verdict).
- [auto] **The authorship split is consistent.** In all four sites the specifics (which
  paths, which probe/signal) are deferred to the stack profile and the *requirement* is the
  spine's; `profile-interface.md` **declares the specifics** and does **not** restate the
  spine mandate as a profile-owned rule, while the two references and the verifier **defer
  specifics to the profile**. Falsifiable by cross-reading the four sites for a site that
  hardcodes a stack-specific path/probe or that relocates the mandate's ownership.
- [auto] **No stale contradiction.** No sentence in any edited file still implies that a
  reproduced-N-times failure is a confident one, or that a `[runtime]`/environment-dependent
  negative finding may stand without the clean-tree assertion and the positive control, or
  that trusting a CLI start banner suffices. Falsifiable by reading the four files for a
  surviving contradiction.
- [auto] **Prose-anchor file present, file-per-feature.**
  `scripts/skill-anchors/verify-environment-integrity.txt` exists and declares a **positive**
  anchor for each of the four new mandate sentences (one per edited file) — each anchor a
  full single-line sentence carrying its rule's operative clause (the term *positive
  control* and the negative-finding scope survive a reword). The anchor for the site that
  carries the **B2 tell** additionally carries the independent-signal-change-certifies-a-
  reload / a-repetition-does-not clause, so that the sharpest finding in the corpus survives
  a reword too (honouring the change spec's guarantee that the tell "is anchored so a reword
  can't drop it") — not just the clean-tree/positive-control language. Each anchor is
  confirmed present verbatim and case-correct on a single line in the file it names. The
  file edits no other feature's
  anchor file (the §4 no-shared-file rule). No negative (retirement) anchors are required —
  the change retires no existing sentence. Falsifiable: `bash scripts/check-skill-anchors.sh`
  passes with these anchors, and each anchor's operative clause is verified by inspection.
- [auto] **No weakening.** The edit preserves, unchanged in force (semantic equivalence, not
  byte-for-byte — a neighbouring sentence may be reworded while integrating the new rule so
  long as its force is preserved): the verifier's
  **read-only** stance and its "classify infra-shaped failures as environment before
  recording any discrepancy" rule; the "**profile is runtime ground truth**" rule and the
  existing environment-assumption-mismatch classification in both `verifier.md` and
  `verify-milestone`; the runtime walk's existing both-builds (dev + production)
  requirement and the no-pin-while-`[runtime]`-unrun gate in
  `milestones-and-verification.md` §3/§5; and the existing Q12 substrate-preflight and
  Q13 isolation contract in `profile-interface.md`. The new guard is **additive** — it adds
  a precondition to *negative* runtime findings and changes none of the above. Falsifiable
  by confirming each named invariant's sentence is unchanged in force.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
  `bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`, and
  every `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; prose-only change —
each condition is closable by reading the four named files + the new anchor file and
running the named standing checks). No `[runtime]` conditions exist (keel is no-UI); the
standing suites plus a fresh-context verifier subagent are the verification. `check-neutral`
guards **only its fixed leak/scar denylist** across the edited prose (stale commands, hardcoded
Next.js paths, retained project names, `@theme`/Lucide/Recharts in the spine); it does **not**
denylist a stack-specific service-config path or term (`supabase/config.toml`, `service-role
key`, `.env.local`, `vitest`) pasted into the neutral spine, so it cannot by itself catch this
change's real leak vector. The guard against a hardcoded stack path in the neutral mandate is
the **authorship-split** done-condition — verifier judgment cross-reading the four sites, not a
mechanized check — which this milestone relies on, not `check-neutral`.

verified: clean at 7d04f2a, 2026-07-21, via fresh-context verifier subagent against this spec's done-conditions — all 12 `[auto]` conditions evidenced with file:line: Q14 declares both specifics (service-config paths + positive-control probe) with the Q12/Q13 "finalized at provision" authorship split and the B2 scar note; the §3 spine mandate carries the independent-signal-not-repetition clause and defers specifics to Q14; the verifier.md ground rule and verify-milestone step-4 + Verdict carry it; the negative-only/never-`[auto]`/never-a-clean-pass carve-out and the authorship split (profile declares specifics, spine owns the mandate — no hardcoded stack path in the neutral spine) are consistent across all four sites; the anchor file pins five positive anchors (one per file + the §3 B2-tell). No `[runtime]` conditions (keel is no-UI) → no runtime walk; prose-only → no `/security-review`. Standing checks green (check-neutral, check-plan, check-skill-frontmatter, check-skill-anchors 52 anchors), all 11 `scripts/*.test.sh` suites green, `claude plugin validate --strict` PASS. First verifier pass returned pass-with-gaps on condition 10 (the verifier.md anchor pinned the N-times aphorism rather than its clean-tree/positive-control core clause, leaving that file's core rule un-reword-protected); strengthened the anchor on the branch (7d04f2a) and re-verified clean. (evidence: verifier report in PR)

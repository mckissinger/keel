# Milestone — provision-hardening

Change context: `specs/changes/provision-hardening.md`. One milestone, prose-only; edits
`references/profile-interface.md` (Q12) and `skills/provision/SKILL.md` (step 6), and adds one
committed anchor file `scripts/skill-anchors/provision-hardening.txt`. No scripts, gates, hooks,
templates, or other skills move. **No UI** (keel is a methodology plugin) — done-conditions cover
two dimensions, logic/invariants and behavioral completeness; fidelity does not apply. Every
condition is `[auto]`: prose-only, closable by reading the named files and running the named checks.

**Integration seams.**
- Q12's existing parts (shared singletons + health checks, unique port block / project identity,
  canonical invocation path, env re-derivation command, env name-check command + direct-read ban,
  known-failure-signature table, per-suite duration budgets + timeout rule) — the additions
  **extend** these (the port rule is the derivation for the *ports/identity* part; the target
  classification rides the *health check*; the test-setup clause sits beside the *direct-read ban*),
  and must not alter or weaken any of them.
- Q12's **authorship split** and the profile's **"What stays in the methodology"** serialization
  rule — the additions touch neither; the port rule and target classification are finalized at
  provision like the ports/identity part they extend, and the serialization rule is not duplicated.
- Provision **step 5** (capped-key / bounded spend) and **step 4** (spend-command allowlist) — the
  D3 capped-key concern is already fully covered there; this milestone does **not** touch step 5.
- Provision **step 6** (bakes flake mitigations into config) and **step 7** (proves the ladder once)
  — step 6 gains the new authoring clauses; the fragile-gate scripts cover the gates surfaced when
  step 7 proves the ladder (the two owners stay distinct: step 6 authors, step 7 surfaces).
- The **entry preflight** at `implement-milestone` (orient) and `verify-milestone` (dispatch) runs
  the Q12 health check already — the target-match assertion added *into* that health check therefore
  fires at both entry points **without editing either skill** (behavioral completeness rides the
  existing invocation, no new call site).

## Done-conditions

- [auto] **The name-derived port rule is promoted VERBATIM into Q12 and pinned.**
  `references/profile-interface.md`'s Q12 *unique port block / project identity* part gains the
  derivation rule as a single physical-line sentence, and
  `scripts/skill-anchors/provision-hardening.txt` carries a **positive** anchor
  (`references/profile-interface.md`<TAB>the sentence) so a later reword can't drop it. The pinned
  sentence is exactly:
  `Derive the port block from the project name (hash the name into a fixed band below 49152): the result is effectively-random so no `` `/etc/services` `` entry claims it, derivable so every project gets its own with no registry and no drift between machines or checkouts, and below 49152 so the OS never transiently takes it as an ephemeral outbound port.`
  **verification:** `scripts/check-skill-anchors.sh` passes with this anchor present; `grep -F` finds
  the sentence in `references/profile-interface.md`.
- [auto] **The dual-update caveat is recorded.** Q12 states that changing the port requires updating
  **both** the local stack config (which needs a stack restart) **and** the hosted dashboard when the
  env points there — both required updates named, so the condition fails if either is omitted.
- [auto] **Environment-target classification joins the Q12 health check.** Q12 records how to
  distinguish a **local-target** env from a **hosted-target** env (the local stack's URL/port
  signature vs the hosted dashboard URL), and states that the substrate health check asserts the
  running config's target **matches the expected substrate** — so hosted keys run against a local
  stack (or the reverse) is a named, checkable failure. A `⚠` scar generalizing the copied-`.env.local`
  hosted-keys-against-a-local-stack incident is present. Fails if the classification is recorded but
  the health-check assertion (the *validate before anything runs* half) is absent.
- [auto] **Test setup derives config from the running substrate, never `.env.local`.** Beside Q12's
  existing direct-read ban, a clause states committed **test setup** obtains its config from the
  running substrate's **status** (mapped to the architecture contract, **swallowing non-zero when no
  stack is up**), **never** from `.env.local`. All three shape elements — status-read, contract
  mapping, swallow-non-zero — are named; the clause is scoped to test-setup code (distinct actor from
  the session's direct-read ban), so it neither duplicates nor weakens that ban.
- [auto] **The fragile-gate → committed-preflight-script declaration exists in Q12.** Q12 gains a
  declaration that every runtime gate with a **remembered precondition** (an env export, a
  reset/clean step, a required key-prefix) names a **committed, executable preflight script** that
  sets up the precondition, **asserts** it, and **fails loud**, and that the profile **lists each
  fragile gate → its script path**. The declaration states it **accretes like the signature table**
  (a newly discovered gate adds its script and row). A `⚠` scar generalizing the fifth-recurrence
  written-down-but-unscripted gotcha is present. Fails if the declaration records only a written list
  with no committed-script + assert + fail-loud requirement (that is the exact defect being fixed).
- [auto] **Provision step 6 authors all three additions.** `skills/provision/SKILL.md` step 6 (a)
  **applies the name-derivation rule** when it assigns the unique ports/identity (it no longer says
  only "assign … collision-free" with no method); (b) **records the environment-target classification
  and the dual-update caveat** in the profile; (c) **authors the committed fragile-gate preflight
  scripts** for the gates surfaced when step 7 proves the ladder, and records them in the profile's
  fragile-gate declaration. All three clauses present; fails if any is missing.
- [auto] **Home held — no unowned widening.** The milestone's diff touches only
  `references/profile-interface.md`, `skills/provision/SKILL.md`,
  `scripts/skill-anchors/provision-hardening.txt`, and `specs/**`. In particular
  `skills/spec-foundation/SKILL.md` and `skills/adopt/SKILL.md` are **unchanged** — the fragile-gate
  scripts are provision-authored artifacts, not derivation placeholders, so the derivation-list
  enumerations need no new entry. **verification:** `git diff --name-only main...HEAD` lists no file
  outside that set.
- [auto] **No weakening.** The edit preserves, verbatim in substance: Q12's env **name-check
  command** and the **direct-read ban** (`sessions never read `` `.env*` `` directly`); the
  **known-failure-signature table**, **duration budgets**, and the **timeout rule**; provision
  **step 5** (capped-key bounded spend) untouched; the **"What stays in the methodology"**
  serialization rule not duplicated or altered; and stack-neutrality — no framework/library/command
  is hardcoded (the OS ephemeral-port band is OS mechanics, like Q12's existing web-reference
  examples). **verification:** `scripts/check-neutral.sh` passes; a `git diff` of Q12 shows the named
  existing parts unchanged except the additive facets.
- [auto] **Repo checks green.** `claude plugin validate --strict .`, `scripts/check-neutral.sh`,
  `scripts/check-plan.sh`, `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`,
  and every `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; prose-only — closable by
reading `references/profile-interface.md` + `skills/provision/SKILL.md`, `grep -F` for the pinned
sentence and the named clauses, `git diff --name-only main...HEAD` for the home-held condition, and
running the five repo checks + `scripts/*.test.sh`).

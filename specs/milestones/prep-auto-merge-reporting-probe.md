# Milestone — prep-auto-merge-reporting-probe: probe the PR head, not the default-branch head

**Goal:** Correct `keel:prep-auto-merge`'s reporting-context probe so a `pull_request`-only `security-review`
(the workflow the skill scaffolds) is actually observable. Both probe sites in
`skills/prep-auto-merge/SKILL.md` move from the default-branch head to the **PR head**: the step-1b
`required_checks` derivation and the step-2 confirm-before-require wedge gate. The wedge gate is reframed to
require the `security-review` context only once it has gone green **on a PR** and the workflow is **merged to
`main`**. Prose-and-anchor correction only — the scaffold template and `check-branch-protection.sh` are
untouched, so `keel:arm-auto-merge`'s independent floor certification is unchanged.

**Change:** `specs/changes/prep-auto-merge-reporting-probe.md`. **No-UI** (keel plugin repo) → two-dimension
done-conditions (logic/invariants + behavioral completeness), no fidelity. **Depends on:** the landed
`prep-auto-merge` (`skills/prep-auto-merge/SKILL.md`, #207) and its anchors. **Parallelizable:** n/a (single
milestone). **Routing:** reasoning-heavy — the reframed wedge gate is a **safety property** (a wrong gate
either wedges every PR by requiring a not-yet-inherited context, or requires a context nothing produces), so
the corrected procedure must be read for soundness, not skimmed. Dispatch the verifier at **xhigh**.

## What changes (all in `skills/prep-auto-merge/SKILL.md`, plus its anchors + a decision doc)

- **Step 1b — derivation, with a concrete source rule.** At generation time the scaffold PR does not yet
  exist (the contract is committed into it), so "a PR head" must be pinned to a specific commit.
  `required_checks` = the union of **(1)** the contexts on the repo's **most-recent** PR (open or merged) —
  `gh pr checks <that-pr>` or `commits/<its-head-sha>/check-runs` (most-recent so the set can't drift to a
  stale PR), or the repo's **CI workflow job/context names** when the repo has **no** PR — **plus (2)** the
  scaffolded `security-review` context name, added **explicitly** (not observed — it has not run anywhere
  yet). **Not** `commits/<default-sha>/check-runs`. The human confirms the full generated set in the PR.
  Unchanged invariants: **never** read `gh api …/protection`'s required-status-checks list; **include every
  check the repo already enforces** (a committed contract replaces the asserted set).
- **Step 2 — confirmation + wedge gate.** Confirm the review job **produced its context by going green on a
  PR** (the scaffold PR's head) via `gh pr checks <pr>` (or `commits/<pr-head-sha>/check-runs`), and that it
  was a **real scan, not a cached-skip hollow green** (the existing cache-mask caveat is retained). The gate:
  require the `security-review` context only once **(a) it has gone green on a PR** AND **(b) the workflow is
  merged to `main`** (so every future PR inherits it). Drop `commits/<default-sha>/check-runs` as the wedge
  signal — a PR-only check never appears there.
- **Anchors.** `scripts/skill-anchors/prep-auto-merge.txt` updated so the corrected load-bearing prose is
  locked (a positive anchor for the PR-head probe / reframed gate), the still-true anchors
  (reuse-the-assertion, print-never-run, secret-is-human, never-the-protection-list) remain present, **and a
  NEGATIVE anchor** — `!skills/prep-auto-merge/SKILL.md<TAB>commits/<default-sha>/check-runs` — makes the
  regression permanently CI-checkable (the committed form of "this probe was removed and must stay removed",
  per `check-skill-anchors.sh`), not merely caught by a one-time merge grep.
- **Decision doc.** `decisions/2026-08-04-prep-reporting-probe.md` records the bug (surfaced dogfooding on
  `crelaunch`), the PR-only-never-on-default-head root cause, and the fix; amends
  `decisions/2026-08-03-prep-auto-merge.md` by reference (edits nothing in place).

## Done-conditions

### Logic / invariants

- [auto] **The default-head probe is gone and stays gone — enforced by a negative anchor.**
  `scripts/skill-anchors/prep-auto-merge.txt` carries `!skills/prep-auto-merge/SKILL.md<TAB>commits/<default-sha>/check-runs`,
  so `check-skill-anchors.sh` **fails** if the string `commits/<default-sha>/check-runs` is present in the
  skill — both a one-time proof the two occurrences were replaced and a permanent CI guard against
  reintroduction. Verified: `check-skill-anchors.sh` green with that negative anchor committed.
- [auto] **Both steps reference the PR head, and the reframed gate names the merged-to-`main` precondition.**
  In `skills/prep-auto-merge/SKILL.md`: `grep -F "gh pr checks"` matches in **both** step 1b and step 2;
  the literal phrase **"merged to `main`"** (the wedge precondition) is present in step 2; and the scaffolded
  **`security-review`** name is named in the step-1b derivation. Verified by grep for those fixed strings.
- [auto] **The reused-assertion + never-the-protection-list invariants are intact.** `grep` confirms the
  skill still runs `scripts/check-branch-protection.sh` (never re-authored) and still says **never** read
  `gh api …/protection`'s required-status-checks list — the fix did not disturb them (their positive anchors
  in `prep-auto-merge.txt` still pass).
- [attended] **The reframed wedge gate is sound on a read.** A verifier reading step 2 confirms the gate
  requires the `security-review` context only when **both** (a) it has gone green on a PR (real scan, not a
  cached skip) **and** (b) the workflow is merged to `main` — neither condition alone — and that no path
  prints a protection command requiring a context before both hold. The cache-mask caveat is retained. This
  is the milestone's **safety gate** (a wrong reframing wedges PRs or requires a phantom context): a genuine
  soundness doubt is a **stop-point**.
- [attended] **The derivation's source rule is concrete, not toothless.** The verifier confirms step 1b
  pins a **specific** commit — the repo's **most-recent** PR head (CI job names when the repo has no PR) —
  rather than an unresolved "a PR head", explicitly includes the scaffolded `security-review` name (the
  not-yet-observable check), routes the generated set through human confirmation, and preserves "include
  every enforced check" + "never the protection list". A build that inserts `gh pr checks` without a concrete
  which-PR rule does **not** satisfy this condition.

### Behavioral completeness

- [auto] **`skills/prep-auto-merge/SKILL.md` still passes `check-skill-frontmatter.sh` + `check-skill-anchors.sh`,**
  and every anchor in `scripts/skill-anchors/prep-auto-merge.txt` (updated for the corrected prose) is
  present. `check-skill-anchors.sh` green on the whole corpus.
- [auto] **The artifact tests are untouched and still green.** `scripts/check-prep-auto-merge.test.sh`
  passes unchanged (this milestone edits no template, no contract shape, no assertion script), and the full
  committed suite is green — proving the fix is confined to procedure prose.
- [attended] **A new `decisions/2026-08-04-prep-reporting-probe.md`** records the bug + `crelaunch` incident,
  the PR-only-never-on-default-head root cause, and the fix; amends `2026-08-03-prep-auto-merge.md` by
  reference. Append-only.
- [attended] **Scope is confined.** `git diff --name-only main...HEAD` lists only
  `skills/prep-auto-merge/SKILL.md`, `scripts/skill-anchors/prep-auto-merge.txt`, the new decision doc, and
  the two spec files (this milestone + its change doc). The **landed** `specs/milestones/prep-auto-merge.md`
  and `decisions/2026-08-03-prep-auto-merge.md` are **not** rewritten; no template/test/assertion is in the
  diff.

## Verification

Fresh-context `verify-milestone` (or a `keel:verifier` subagent) at **xhigh**, from these done-conditions +
the checkout — never the builder's claims. Proof run: the **full** committed suite (every `scripts/*.test.sh`,
unfiltered) + `check-skill-frontmatter.sh` + `check-skill-anchors.sh` + `check-plan.sh` + `check-neutral.sh`
+ `claude plugin validate --strict .`, all green. The `[auto]` conditions are greps over the skill + anchors;
the `[attended]` ones are the soundness read of the reframed wedge gate + derivation and the doc/scope
checks. **No `[runtime]`** — the skill issues no live command; it is procedure prose. **No `/security-review`
required:** this changes no scaffold template, no assertion script, no merge-authority/guard/hook code — only
the skill's procedure prose — so there is no new security surface (the original prep-auto-merge ran
`/security-review` precisely because its *scaffold artifact* becomes a repo's floor; that artifact is
untouched here). The verifier still reads the reframed gate for **safety soundness** (the wedge property) as
an `[attended]` gate, and a genuine soundness doubt is a stop-point. On a clean verdict the verifier writes
the `verified:` pin; the build session never pins its own work.

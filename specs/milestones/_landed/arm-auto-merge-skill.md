# Milestone — arm-auto-merge-skill: the human-invoked writer that verifies protection, then commits the flag

**Goal:** a `disable-model-invocation` skill (`keel:arm-auto-merge`) is the committed marker's **only
writer** — a human invokes it, it **asserts branch protection + the three required checks + the repo's
auto-merge capability are live**, and only then commits `.claude/keel-auto-merge.json` (as a plan-only
PR, per M1's carve-out). The agent never self-arms; the model cannot invoke the skill. The
protection-assertion it runs is the **same code** the auto-preflight already runs — extracted, not
re-authored — so the arming check and the auto-entry check can never drift apart.

**Feature:** `specs/features/per-project-auto-merge.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `committed-auto-merge-marker` (needs the marker committable + its contract).
**Parallelizable:** no (M3/M4 depend on it). **Routing:** reasoning-heavy — it defines the
authorization path for standing per-project merge authority; a gap here arms auto-merge on a repo
whose protection is not actually live. Dispatch the verifier at `xhigh`.

## Done-conditions

### Logic / invariants

- [auto] **The protection assertion is extracted into one reusable path** that both
  `scripts/check-auto-preflight.sh` and the arming skill call — the **merge-relevant subset only**:
  check (b) (the three required checks are *required* in branch protection), (b2) (the
  `security-review` check is backed by workflow **content**, not a name — the uncommented `uses:` line
  + `pull_request` trigger, with `PREFLIGHT_SECREVIEW_PATTERN` / `PREFLIGHT_SECREVIEW_EXTERNAL`
  overrides intact), and (d) (`allow_auto_merge` enabled on the repo). It **excludes** (a)/(a2)
  (command-inventory dry-run) and (c) (env-var names) — those are auto-run concerns that fail on a
  project with no `specs/run-command-inventory.txt` / no `specs/01-architecture.md`, and arming
  auto-merge must not require either. Realize the extraction as `scripts/check-branch-protection.sh`
  (b + b2 + d, fail-closed, same GAP vocabulary and exit convention as the preflight), and have
  `scripts/check-auto-preflight.sh` **call it** for those three checks rather than keeping its own
  copies — the preflight's overall pass/fail semantics and its (a)/(a2)/(c) checks are **unchanged**,
  and its existing test expectations all still hold.
- [auto] **`skills/arm-auto-merge/SKILL.md` exists with `disable-model-invocation: true`** in
  frontmatter (the model cannot invoke it — the same authorization-trail discipline as
  `keel:auto-merge` and `land-feature`), a `when_to_use` naming it human-invoked-only, and an
  `effort` line. Its pass: (1) run `scripts/check-branch-protection.sh` and **halt on any GAP** with
  the remediation surfaced — never write the marker on a red assertion; (2) on green, write
  `.claude/keel-auto-merge.json` with `scope: "project"`, `created` (ISO-8601 UTC), `invoker`; (3)
  open it as a **plan-only PR** (M1's carve-out makes it plan-only → exempt → lands under protection),
  never a direct push to `main`; (4) state that this arms `--auto` for **every** session in the repo
  and that **the required checks are now the review** — and that disarming is removing the file
  (a `disarm`/`off` path in the same skill, symmetric with `keel:auto-merge on`/`off`).
- [auto] **The skill never merges and never self-arms:** its prose states it opens the arming PR and
  stops (the human reviews + merges the plan-only PR, exactly like every other plan PR), and that it
  is the marker's *only* writer. It does not call `gh pr merge`.
- [auto] **The arming skill reuses, never re-authors, the protection assertion** — its prose points at
  `scripts/check-branch-protection.sh` as the single source, matching the deferral's original
  instruction ("reuse `scripts/check-auto-preflight.sh`'s branch-protection assertion, don't
  re-author it").

### Behavioral completeness

- [auto] **`scripts/check-branch-protection.sh` has its own self-test** (`.test.sh`): green when
  protection + three required checks + content + `allow_auto_merge` all hold; a GAP for each of —
  protection absent, a required check missing from the required set, security-review name-without-
  content, `allow_auto_merge` disabled; the `PREFLIGHT_SECREVIEW_PATTERN` override and the
  `PREFLIGHT_SECREVIEW_EXTERNAL=1` attestation both exercised. **Every existing
  `scripts/check-auto-preflight.test.sh` case still passes** after the extraction (the preflight now
  delegates b/b2/d but its observable behavior is identical).
- [auto] **`skills/arm-auto-merge/SKILL.md` passes the skill lints:**
  `scripts/check-skill-frontmatter.sh` (name/description/when_to_use/effort + `disable-model-invocation`)
  and `scripts/check-skill-anchors.sh` (any `${CLAUDE_PLUGIN_ROOT}` / cross-references resolve), and
  `claude plugin validate --strict .` is green with the new skill present.
- [auto] **The whole repo suite is green** and **no unowned surface moved:** `git diff --stat` is
  confined to `skills/arm-auto-merge/SKILL.md` (new), `scripts/check-branch-protection.sh`(+`.test.sh`,
  new), `scripts/check-auto-preflight.sh`(+`.test.sh`, the delegation edit), and this milestone spec.
  The M1 gate files, `session-bootstrap.sh`, `template-contract.md`, the deferral, and
  `implement-feature` are **out of scope** (empty diffs).

## verification

verifier subagent against this file — every `[auto]` condition with `file:line` evidence: the
extracted `check-branch-protection.sh` runs exactly b + b2 + d and **not** a/a2/c (grep its body for
the absence of inventory/env-name logic), the preflight now delegates those three with identical
observable behavior (its full test suite green), the arming skill's `disable-model-invocation` + the
halt-on-GAP-before-write ordering + the plan-only-PR + no-`gh pr merge`, the skill lints, and the
confined diff. Suites run, not re-derived. **Dispatch the verifier at `xhigh`**. **`/security-review`
of the milestone's diff is a pre-pin precondition** — the adversarial question: can the marker be
written while any of protection / required-checks / content / `allow_auto_merge` is **not** live (it
must not — the write is strictly gated on a green `check-branch-protection.sh`), and does the
extraction drop or weaken any assertion the preflight made before (it must be behavior-preserving);
confirmed findings remediated before the pin.

verified: clean at 1edf3c9, 2026-08-02, via a fresh-context verifier subagent against this file — every `[auto]` condition checked against the real code. The extraction is the merge-relevant subset ONLY: `check-branch-protection.sh` runs (b) (L59-105), (b2) (L107-132), (d) (L134-144) and nothing else — a grep for inventory/settings/allowlist/architecture/env-name logic matches only the header comment declaring the exclusion (L21-23), zero code. The preflight delegates: check-auto-preflight.sh L142-147 invokes the shared script for (b)/(b2)/(d), passing `PREFLIGHT_REQUIRED_CHECKS="$REQUIRED_CHECKS"` across the process boundary (L144) so a config-block-hardened required set survives the delegation (test 21, check-auto-preflight.test.sh:335-343, demonstrated to false-PASS pre-fix); `git diff main` shows its (a) (L68-105), (a2) (L107-124), (c) (L149-175) blocks and overall pass/fail semantics untouched (only hunks: the SCRIPT_DIR refactor of ROOT, the b/b2/d removal, the delegation). skills/arm-auto-merge/SKILL.md: `disable-model-invocation: true` (L6), `when_to_use` "Human-triggered only" (L4), `effort: high` (L5); the ordering is load-bearing and stated — "assert first, write only on green" (L51-53), step 1 runs `scripts/check-branch-protection.sh` (L55-66), step 2 halts on any GAP and does NOT write the marker (L68-74), step 3 writes `.claude/keel-auto-merge.json` with `scope: "project"` + `created` (ISO-8601 UTC) + `invoker` only on green (L76-93); step 4 opens it as a plan-only PR, never a direct push to main, never merges it (L95-102, L115); step 5 states it arms `--auto` for EVERY session, "the required checks are now the review", and disarm is the `off` path (L104-107, L109-115). Boundaries: only writer of the marker, issues no merge command, "it never calls `gh pr merge`" (L119-122); the agent never invokes it to self-arm (L123-126); the assertion is reused never re-authored, pointing at check-branch-protection.sh as the single source (L55-66, L127-130). Security remediation held: the default branch is resolved from `gh repo view --json defaultBranchRef` server truth (check-branch-protection.sh:72), `origin/HEAD` surviving only as last-resort fallback (L75-86), regression-locked by tests 14-15 (check-branch-protection.test.sh:192-215, server truth overrides a repointed origin/HEAD); the accepted residual (working-tree trust boundary) is recorded in specs/uncertainties/arm-auto-merge-skill/. Suites run, not re-derived — all 12 scripts/*.test.sh green: check-branch-protection 19 (green case; GAPs for protection-absent/check-not-required/name-without-content/allow_auto_merge-disabled; PATTERN override; EXTERNAL=1 attestation; a/a2/c-excluded proof), check-auto-preflight 30 (every prior case + the delegation-propagation case), merge-guard 140, guard-branch-rules 79, session-bootstrap 61, check-verified-pin 38, check-plan 21, attended-marker-parity 20, check-neutral 17, check-skill-anchors 14, check-skill-frontmatter 12, repin 13. Lints green with the new skill present: check-skill-frontmatter (30 skills), check-skill-anchors (66 anchors), `claude plugin validate --strict .` passed. `git diff --name-only main` is confined to skills/arm-auto-merge/SKILL.md, scripts/check-branch-protection.sh(+.test.sh), scripts/check-auto-preflight.sh(+.test.sh), and the uncertainties record — the M1 gate files, session-bootstrap.sh, template-contract.md, the deferral, and implement-feature all have empty diffs. (evidence: verifier report in PR)

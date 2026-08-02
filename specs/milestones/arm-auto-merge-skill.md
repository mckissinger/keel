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

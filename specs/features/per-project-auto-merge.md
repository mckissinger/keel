# Feature — per-project auto-merge (committed, human-armed) + the attended run-through posture

**One-paragraph definition.** Give a keel-managed repo a **committed, per-project setting** that arms
`gh pr merge --auto` on every gate-passing PR the workflow opens — so a repo whose owner has decided
"the required checks are my review" stops paying the per-merge tap in *every* session, not just the
session where a human ran `keel:auto-merge on`. The setting is **armed only by a human-invoked skill**
that first verifies branch protection + the three required checks are live, then commits the flag; the
agent never self-arms. Paired with it: `/keel:implement-feature` gains an **attended run-through
posture** — under a valid committed marker it runs start-to-finish (build → verify → land the wave →
post-wave consolidated check → **prepare** `review-feature`), asking mid-run **only at true
stop-points** and otherwise recording a run-note and continuing, so the owner is left with exactly the
one judgment the framework reserves for a human: the feature review. It never auto-passes
`review-feature`, never touches the never-auto list, and never lands code that less than the
three-check contract inspected.

**flow research:** skipped — no user-facing flow. This is a no-UI infrastructure feature on keel
itself (a plugin repo: no `specs/stack-profile.md`, no `specs/design.md`, no workbench/gallery). Per
`references/no-foundation.md` the workbench/design movements (Movement 2) are skipped; done-conditions
carry **two** dimensions (logic/invariants + behavioral completeness), never fidelity. No design-
reference MCP pull applies.

## Settled interview decisions (owner, 2026-08-02 — do not re-litigate)

1. **Safety model = required-checks backstop, identical to autonomy mode.** The committed marker
   removes the human merge eyeball in *every* session (including headless/build), so it rides the
   same compensating control the autonomy path already uses: branch protection with the three
   required checks (`verified-pin`, `plan-lint`, `security-review`) — GitHub lands a `--auto` PR when
   and only when those pass. **Attended-vs-headless detection stays deferred** (unconfirmed harness
   signal — `specs/deferrals/mode-file-binding-ttl.md`); the marker does not try to behave
   differently in a watched vs unwatched session, because the required-checks floor makes that
   distinction unnecessary for safety, and inventing a signal keel can't reliably read would be the
   very over-reach `mode-file-binding-ttl.md` parked.
2. **Arming = human-invoked skill only.** A `disable-model-invocation` skill (`keel:auto-merge`'s
   committed sibling) is the marker's **only writer**: it asserts branch protection + the three
   required checks are live *before* it writes, and commits the flag. The agent never self-arms, and
   the model cannot invoke the arming skill.
3. **`review-feature` stays the human gate.** The run **prepares** it (renders the surfaces, stages
   the screenshots/preview) and **ends there** — it never auto-passes the aesthetic/completeness
   judgment. The never-auto list, the feature-spec sign-off, and the taste gate are untouched.

## The design fork this feature resolves (it broke the earlier two-milestone attempt)

**The committed marker's shape/transport.** `.claude/keel-auto-merge.json` is a **code path** under
the pin gate's classification (`is_plan_path()` returns 1 for anything outside
`specs/**|design/**|decisions/**|deferrals/**`), so under the full protection contract the arming
commit is a **code PR that touches no milestone/chore spec** — and `check-verified-pin.sh:130`
hard-fails it. An arming path that cannot land under the protection the flag *requires* is
self-defeating.

**Resolution (recorded in `decisions/2026-08-02-committed-auto-merge-marker.md`, authored by M1):**
keep the marker at **`.claude/keel-auto-merge.json`** (sibling of the untracked
`.claude/keel-attended-merge.json` / `.claude/keel-autonomy.json`, so the guards read it the same
way) and add it as a **plan-path carve-out** in `check-verified-pin.sh`'s `is_plan_path()` — the exact
same surgical, reviewed mechanism as the existing `specs/stack-profile.md` /
`specs/run-command-inventory.txt` carve-outs, which go the other way (code-not-plan). Consequence:
arming is a **plan-only PR** that lands cleanly under protection with no pin. That is **correct**, not
a loophole: a `verified:` pin proves *unwatched* verification (a fresh session confirmed the work at a
SHA no human watched); arming is **human-attended by construction** (a `disable-model-invocation`
skill a person invoked), so a pin is the wrong instrument — the arming skill's own live
protection-assertion is the proof, and the required-checks floor guards every subsequent auto-merge.
Rejected alternatives are recorded in the decision entry: (b) route arming through the chore-lane pin
(ceremonious — a pinned chore PR per arm/disarm, and the "verification" would be a hand-authored pin
of an attended change); (c) relocate the flag to a plan path like `specs/` (guards reading policy from
`specs/` is a worse layering surprise than one carve-out line the pin gate already has a pattern for).

**The carve-out alone is not the safety story — two mechanical controls make "the agent never
self-arms" true (added after the adversarial plan pass, which showed prose alone left two holes):**
(1) **the guards honor the marker only as read from the default-branch ref proper**
(`origin/$DEFAULT_BRANCH` — *not* the PR's base ref `BASE_REF_R`, which under a stack is a sibling
milestone branch), via `git show "origin/$DEFAULT_BRANCH:.claude/keel-auto-merge.json"` — never the
working tree — so a locally `Write`-n or branch-only file is ignored; since the default branch advances
only by a human-merged PR, presence there *is* the authorization trail. (2) **any merge-shaped command
whose PR touches the marker file is never auto-merged** (forced to the human tap, before any allow row,
via a non-truncating `git diff --name-only base...head` that fails closed on an indeterminate list), so
no *temporary* authority — an 8h attended marker or a 24h mode — can auto-land the *permanent* marker's
own PR. M1 owns both; without them the "committed" flag would be forgeable at the working-tree level
and a temporary authorization could escalate itself to a standing one. The residual (forging the local
default-branch ref itself with `git update-ref`/`git branch -f`) is named in M1, is the existing
markers' own threat model, and is backstopped by the required-checks floor.

## Milestone decomposition (4 milestones)

| # | Milestone | Owns | Hard-invariant? |
|---|-----------|------|-----------------|
| M1 | `committed-auto-merge-marker` | the marker contract + `is_plan_path` plan-path carve-out (so it commits) + both guards' committed-project rows + all four affected self-test suites + the shape decision entry | yes — pin gate + merge gate |
| M2 | `arm-auto-merge-skill` | the human-invoked `disable-model-invocation` arming skill + extraction of the protection-assertion (checks b + b2 + **d**) into a reusable path both the skill and the preflight call + preflight refactor + frontmatter/anchor coverage | yes — merge authority |
| M3 | `auto-merge-doctrine` | the reader-family + doctrine surfaces: `session-bootstrap.sh` orientation line, `references/template-contract.md` autonomy-tier trigger (arming becomes a **third** security-review wiring moment), guard vocabulary consistency, the deferral's RESOLVED closure, the standing-authorization doctrine decision entry | prose + one script's orientation text |
| M4 | `implement-feature-run-through` | `skills/implement-feature` attended run-through under a valid marker (arm `--auto` per PR, drive landing, run the consolidated check, **prepare** `review-feature`, end there) + the stop-point-vs-notify-and-continue mechanism + the run-through decision entry + a `land-feature` pointer | amends who drives the merge (merge-authority prose) |

**Dependencies.** M1 is foundational (nothing is honored or committable until it lands). M2 depends on
M1 (needs the marker committable + its contract). M3 depends on M1 + M2 (doctrine describes the
shipped rows + the arming skill). M4 depends on M1 + M2 (consumes the marker + the arming primitive).
**Parallelizable:** M3 and M4 may build concurrently once M1 + M2 land (disjoint file ownership —
M3 owns doctrine/prose surfaces, M4 owns `skills/implement-feature` + its decision entry); M1 → M2 is
strictly serial. **One cross-reference to note:** M4's decision entry cites M3's
`decisions/2026-08-02-per-project-auto-merge-authorization.md` (an "amends by reference" pointer); with
M3 ∥ M4 the pointer is a forward reference until both land in the same wave — no lint checks decision
cross-refs, so this is transient and acceptable, not a build-order constraint. **Every milestone that
touches a hard invariant runs `/security-review` pre-pin** — all four are in the merge-authority blast
radius, so all four carry it.

## Surface → milestone map (every surface owned exactly once)

- `scripts/check-verified-pin.sh` (`is_plan_path` carve-out) + `.test.sh` → **M1**
- `scripts/merge-guard.sh` (committed-project row + marker contract header) + `.test.sh` → **M1**
- `scripts/guard-branch-rules.sh` (committed-project defer row) + `.test.sh` → **M1**
- `decisions/2026-08-02-committed-auto-merge-marker.md` (shape decision) → **M1**
- `skills/arm-auto-merge/SKILL.md` (new, `disable-model-invocation`) → **M2**
- `scripts/check-auto-preflight.sh` (extract checks b+b2+**d** into a reusable protection-assertion the skill calls) + `.test.sh` → **M2**
- `scripts/session-bootstrap.sh` (orientation line ~L200) + `.test.sh` (matching assertions) → **M3**
- `skills/auto-merge/SKILL.md` (`when_to_use` "no marker of either kind" disambiguation) → **M3**
- `references/template-contract.md` (autonomy-tier trigger list — third wiring moment) → **M3**
- `specs/deferrals/per-project-auto-merge.md` (RESOLVED banner) → **M3**
- `decisions/2026-08-02-per-project-auto-merge-authorization.md` (standing-authorization doctrine) → **M3**
- `skills/implement-feature/SKILL.md` (run-through posture + prepare-review + notify-and-continue) → **M4**
- `decisions/2026-08-02-implement-feature-run-through.md` (run-through posture) → **M4**
- `skills/land-feature/SKILL.md` (one-line pointer to the run-through, no behavior change) → **M4**

## Lifecycle (reconciled to merged reality, 2026-08-03)

- **Feature sign-off** — this spec, authored + owner-approved 2026-08-02 (scope confirmed in-session;
  spec-feature chosen over stretching the spec-change after the adversarial pass showed the change is
  feature-sized). Evidence: this file, authored on the plan branch and landed via the plan PR below.
- **Plan PR** — plan-only, carrying this spec + the 4 milestone specs (no `verified:` pins yet).
  Evidence: **PR #197, merged**.
- **Per-milestone build + pin** — M1..M4 each built in a fresh `implement-milestone` session,
  `verify-milestone`-clean by a fresh-context verifier, pin appended in its own code PR (M1/M2 carry
  `/security-review` pre-pin remediation records — M1 fixed four self-arm/tap-evasion holes, M2 fixed
  two ≥8/10 findings). Evidence:
  - M1 `committed-auto-merge-marker` — pin `clean at e44d1f5`; **PR #198, merged (620ce2c)**.
  - M2 `arm-auto-merge-skill` — pin `clean at 1edf3c9`; **PR #199, merged (90eb689)**.
  - M3 `auto-merge-doctrine` — pin `clean at aa0414c`; **PR #200, merged (a229e09)**.
  - M4 `implement-feature-run-through` — pin `clean at f8ae2cc`, **re-pinned `clean at f072b48`**
    after the strict-protection cascade (rebased onto `main` when #200 landed, re-verified disjoint,
    re-pinned via commit 223ab87); **PR #201, merged (c542d37)**.
- **Wave landing** — landed under the required-checks floor, order-independent (M3/M4 disjoint), each
  the owner's tap. M4 hit the strict "branch up to date" cascade after M3 merged: update-onto-`main` →
  re-suite → re-pin, exactly the `land-feature` remedy. Post-wave **consolidated check GREEN on `main`
  together, 2026-08-03**: 12/12 committed suites, `plugin validate --strict`, all four lints
  (frontmatter/anchors/plan/neutral), `verified-pin` clean. Evidence: the four merged PRs + this
  consolidated-check run.
- **Spec reconciliation** — this plan-only commit: this Lifecycle backfill + the 4 completed milestone
  specs archived to `specs/milestones/_landed/`. Evidence: **this reconciliation PR**. (No
  `00-product.md` / `01-architecture.md` edit — the feature changed no data shape or environment fact;
  it added scripts/skills/decisions only.)
- **`review-feature`** — **not applicable** (no-UI feature, Q8.1 verb false): completeness is closed
  by `verify-milestone` per milestone; there is no composition to diff. Its absence is recorded here,
  never silently skipped. **The feature is DONE at the consolidated check above.**

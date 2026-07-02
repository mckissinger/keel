# autonomy-modes — composition walk TRANSCRIPT (executed, scripted)

Executed 2026-07-02 on branch `auto-m5-composition` (scripts identical to `main` @ 9f1e0ba —
the walk drives the shipped mechanism, it does not modify it). Companion milestone:
`specs/milestones/auto-m5-composition.md`; the mode contract under test:
`skills/auto/SKILL.md` + `scripts/merge-guard.sh`'s header. All eight assertions (a–h) pass.

## Fixture

A throwaway keel-managed project in a scratch directory (git repo, default branch `main`,
milestone branch `m-demo` carrying `feature.txt`), containing:

- `specs/milestones/m-demo.md` — the keel marker + demo milestone.
- `scripts/check-verified-pin.sh` — **fixture-controlled gate (disclosed stub #1):** PASS
  unless a `.gate-state/fail` flag file exists, in which case it exits 1 with a realistic
  drift reason on stderr. The real guard invokes *this* file exactly as it would the real
  gate; the flag only makes gate-PASS/gate-FAIL states reproducible.
- `.claude/settings.json` — committed allowlist:
  `Bash(git *)`, `Bash(gh pr view *)`, `Bash(gh pr merge *)`, `Bash(gh api *)`, `Bash(./scripts/*)`.
- `specs/run-command-inventory.txt` — six command shapes (git status/checkout, gh pr
  view/merge, gh api …/protection, ./scripts/check-verified-pin.sh), all covered above.
- `specs/01-architecture.md` — environment contract naming `` `FIXTURE_API_URL` `` and
  `` `FIXTURE_API_KEY` ``; `.env.local` (gitignored) carries both names with dummy values.
- `.github/workflows/ci.yml` — runs `verified-pin`, `plan-lint`, **and `security-review`**
  jobs, so in (f)'s gap state the security-review check is genuinely *present in CI* while
  *not required* in protection.

**Disclosed stub #2 — `gh` on PATH:** GitHub is not reachable from this walk, so a stub `gh`
answers exactly the two read-only calls the shipped scripts make —
`gh pr view 123 --json baseRefName,headRefName` → `{"baseRefName":"main","headRefName":"m-demo"}`
(merge-guard's PR-context resolution; both refs exist locally in the fixture), and
`gh api repos/{owner}/{repo}/branches/main/protection` → a protection JSON file the walk
flips between the (f) states. Any other call fails loudly.

Every guard invocation below feeds the script the **exact PreToolUse stdin the harness
sends** (`{"tool_name":"Bash","tool_input":{"command":"<cmd>"}}`, built with `jq`), with
`CLAUDE_PROJECT_DIR` pointed at the fixture and the stub `gh` first on PATH. The scripts
run are the repo's real `scripts/merge-guard.sh`, `scripts/session-bootstrap.sh`,
`scripts/guard-branch-rules.sh`, `scripts/check-auto-preflight.sh` — not copies.

**Scope note (honest boundary, as in the hooks-m3 walk):** this proves keel's shipped
scripts emit the correct decisions/text/exit codes end-to-end, composed in one fixture.
Whether the harness *renders* an emitted `permissionDecision` as a prompt is the harness's
property, not keel's code. And the landing itself — GitHub merging the PR when the required
checks pass — is GitHub's server-side behavior, **stubbed here (disclosed stub #3)**: the
walk proves the `allow` handoff to `gh pr merge --auto`, and delegation past that point is
exactly the mode's design (the checks decide, never agent judgment).

## (a) mode-file lifecycle — write per the skill's contract, remove at run end, guard flips back

**Human-trigger property (not runnable — asserted by grep, disclosed stub #4):** the mode
file below is written by the walk driver *simulating* the human-invoked `keel:auto` skill;
the human-trigger property itself is enforced by the harness honoring the skill's
`disable-model-invocation` flag, which is asserted statically:

```
$ grep -n 'disable-model-invocation' skills/auto/SKILL.md
5:disable-model-invocation: true
```

Mode file written exactly per the m2 contract in `merge-guard.sh`'s header (all four
fields, untracked — `git status --porcelain --ignored` shows `?? .claude/keel-autonomy.json`):

```json
{
  "level": "feature",
  "scope": "demo-feature",
  "created": "2026-07-02T17:00:00Z",
  "invoker": "michael via /keel:auto feature demo-feature"
}
```

With the file present, `merge-guard.sh` on `gh pr merge 123 --auto --squash` (gate passing)
→ exit 0:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow",
 "permissionDecisionReason":"autonomy mode active (level: feature) — gh pr merge --auto on a gate-passing PR delegates the merge to the server-side required checks (decisions/2026-07-autonomy-modes.md); GitHub merges when and only when the required checks pass"}}
```

`session-bootstrap.sh` under the same mode frames the session (line 13 of its output):

```
- Autonomy mode ACTIVE — level: feature, scope: demo-feature. Merge authority is delegated to the server-side required checks via gh pr merge --auto, per decisions/2026-07-autonomy-modes.md — the checks decide, never agent judgment. Ledger every would-be ask to specs/runs/<run-id>/ (recorded deferral; silent deferral stays banned). Stop-points still halt: go-live, live-key swaps, and spend beyond pre-authorized caps stay attended.
```

Then the file is **removed** (run end — the skill is the one writer and one clearer) and the
identical command re-run → the guard flips back to today's floor:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask",
 "permissionDecisionReason":"verified-pin gate passed — per-merge human approval"}}
```

**PASS.** Deterministic core: `merge-guard.test.sh` mode-file validity/spoof/fail-closed
cases (62/62 green below).

## (b) mode active + pinned gate-PASSING `gh pr merge 123 --auto` → allow

Mode file rewritten; gate passing; command `gh pr merge 123 --auto --squash` → exit 0:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow",
 "permissionDecisionReason":"autonomy mode active (level: feature) — gh pr merge --auto on a gate-passing PR delegates the merge to the server-side required checks (decisions/2026-07-autonomy-modes.md); GitHub merges when and only when the required checks pass"}}
```

The landing itself is delegated to GitHub's required checks — **stubbed here (disclosed
stub #3 above)**; the walk's evidence is the allow handoff on exactly the canonical shape.
**PASS.**

## (c) plain `gh pr merge 123` under the same mode → ask

Same mode file, same passing gate, `--auto` absent → exit 0:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask",
 "permissionDecisionReason":"verified-pin gate passed — per-merge human approval"}}
```

The mode changes exactly one decision-table row; plain merge keeps per-merge human
approval. **PASS.**

## (d) gate-FAILING merge attempt → deny with the gate's stderr reason

`.gate-state/fail` created (the fixture gate now exits 1); same mode file, same
`gh pr merge 123 --auto --squash` → exit 0:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny",
 "permissionDecisionReason":"verified-pin: FAIL — specs/milestones/m-demo.md — code changed after the pin (a1b2c3d); verified code != merged code: feature.txt"}}
```

The deny reason is the gate's own stderr verbatim; the mode does not soften a failing gate.
Flag removed afterward. **PASS.**

## (e) no-mode regression — today's behavior end-to-end

Mode file removed. `session-bootstrap.sh` emits today's orientation; the never-merge
invariant is present verbatim (line 13):

```
- Never merge; the user reviews and merges. Open PRs and stop there.
```

(Full no-mode output also carries "Never commit to main", the verified-pin invariant, and
"Attended gates stop and ask; they are never silently deferred" — no mode framing anywhere.)

Guard with no mode file, gate passing — **both** shapes land on the ask-floor, exit 0:

- `gh pr merge 123 --auto --squash` →
  `"permissionDecision":"ask", "permissionDecisionReason":"verified-pin gate passed — per-merge human approval"`
- `gh pr merge 123` → identical ask.

`--auto` without a mode buys nothing; no mode file → byte-for-byte today's table. **PASS.**

## (f) preflight fails closed on present-but-not-required, passes once required

Gap state: `security-review` runs in the fixture's CI workflow but the stub protection JSON
requires only `verified-pin` + `plan-lint`. `check-auto-preflight.sh <fixture>` → exit 1;
stdout shows (a)+(c) clean, stderr names the exact gap:

```
auto-preflight: GAP — protection: check 'security-review' is not a REQUIRED status check in branch protection on 'main' (a check that exists but is not required does not gate the merge)
auto-preflight: 1 gap(s) — fix attended before launching an auto run; never widen permissions mid-run
```

Protection JSON updated so `security-review` is a required check → re-run → exit 0:

```
auto-preflight: env FIXTURE_API_URL — present (name check only)
auto-preflight: env FIXTURE_API_KEY — present (name check only)
auto-preflight: PASS — inventory covered, required checks required, contract env names resolve
```

Fails closed on the named gap, passes when the check is actually required; env values never
echoed (names only). **PASS.** Deterministic core: `check-auto-preflight.test.sh` (13/13).

## (g) a would-be attended gate writes a ledger entry, committed with the work it explains

On the fixture's `m-demo` branch, a would-be attended design-direction pick is recorded
per `skills/auto/SKILL.md` §5 — file-per-entry under `specs/runs/<run-id>/`, carrying the
three contracted parts (**decision**, **rationale**, **would-have-shown artifact**):

`specs/runs/2026-07-02-auto-feature-demo/001-design-direction.md`

```markdown
# Ledger — deferred gate: design-direction pick (m-demo)

- **Gate:** app-design-directions' attended pick (would have asked the user to
  choose among the composed directions).
- **Decision:** direction B ("quiet ledger") — proceed without asking.
- **Rationale:** matches specs/design.md's committed density + type tokens; the
  other two directions break the token contract; recorded default per the mode.
- **Would-have-shown artifact:** design/mockups/demo-feature/directions/ —
  the three-direction comparison gallery (inline summary: A editorial serif,
  B quiet ledger, C dense console).

Adjudicate at the feature debrief (review-feature); silent deferral stays banned.
```

Committed **with the work it explains** (one commit, ledger + the styled change together):

```
commit fd203aa
m-demo: apply direction B + ledger the deferred design pick

 feature.txt                                                  |  1 +
 .../2026-07-02-auto-feature-demo/001-design-direction.md     | 12 ++++++++++++
 2 files changed, 13 insertions(+)
```

**PASS.**

## (h) build-session merge attempt still hard-blocks with the mode ACTIVE

Mode file present and valid (the same one the merge guard honored in (b)).
`guard-branch-rules.sh` — the build-session hook — fed the identical canonical command
`gh pr merge 123 --auto --squash` → **exit 2** (hard block), stderr:

```
keel: build sessions never merge — merging is the user's decision, driven through land-feature with per-merge approval. Open the PR and stop there.
```

Second shape, on branch `m-demo` under the same active mode: `git merge main` → exit 2,
same block. Cross-check in the same instant: `merge-guard.sh` on the identical
`gh pr merge 123 --auto --squash` returns **allow** (mode + passing gate) — so the mode's
one widened row demonstrably does **not** weaken the build-session guard; the two compose
(the branch guard never reads the mode file; landing runs only from the orchestrating
session). **PASS.** Deterministic core: `guard-branch-rules.test.sh` (16/16).

## Stubs disclosed (complete list)

1. **`gh` on PATH** — GitHub unreachable; answers only `pr view 123 --json
   baseRefName,headRefName` and `api repos/{owner}/{repo}/branches/main/protection`
   (protection JSON flipped by the walk for (f)).
2. **`scripts/check-verified-pin.sh` in the fixture** — walk-controlled PASS/FAIL via a
   flag file; invoked by the real guard exactly as the real gate would be.
3. **The landing itself** — GitHub merging when required checks pass is server-side and not
   observable here; the walk proves the allow handoff, per the mode's delegation design.
4. **The `keel:auto` invocation** — the walk driver writes/removes the mode file simulating
   the human-triggered skill; the human-trigger property is `disable-model-invocation:
   true`, asserted by grep in (a), enforced by the harness.
5. **Harness rendering** — emitted `permissionDecision` JSON is keel's contract; the
   prompt/allow UX is the harness's (same boundary the hooks-m3 walk recorded).

## Suite runs + validate (this branch)

```
scripts/check-auto-preflight.test.sh   13 passed, 0 failed
scripts/check-neutral.test.sh          17 passed, 0 failed
scripts/check-plan.test.sh             18 passed, 0 failed
scripts/check-verified-pin.test.sh     17 passed, 0 failed
scripts/guard-branch-rules.test.sh     16 passed, 0 failed
scripts/merge-guard.test.sh            62 passed, 0 failed
scripts/session-bootstrap.test.sh      29 passed, 0 failed

./scripts/check-neutral.sh   → check-neutral: PASS — no retained stack/command language
./scripts/check-plan.sh      → check-plan: PASS — 28 milestone spec(s), 2 chore spec(s) well-formed
claude plugin validate --strict .  → ✔ Validation passed
```

## Verdict

**No composition failure.** The mode file's lifecycle governs exactly one decision-table
row (a, b), plain merges and failing gates keep today's semantics under the mode (c, d),
a modeless session is byte-for-byte today's behavior (e), the preflight fails closed on the
one named protection gap and passes when it is fixed (f), the ledger contract produces a
committed recorded deferral (g), and the build-session hard block is untouched by an active
mode (h). Presented as the walk evidence gating the pin (the pin itself is
`verify-milestone`'s to write, after `/security-review`).

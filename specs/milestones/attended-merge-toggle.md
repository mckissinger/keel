# Milestone — attended-merge-toggle: a per-session opt-in both guards honor

**Goal:** a human-invoked `/keel:auto-merge on` lets an explicitly-instructed, gate-passing
`gh pr merge --auto` land with no per-merge tap and no build-session refusal — while the
verified-pin gate and the no-agent-initiative rule stay intact.

**Change:** `specs/changes/attended-merge-toggle.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** the shipped enforcement hooks (`specs/features/enforcement-hooks.md`).
**Parallelizable:** no (single change to two hook scripts + a skill + docs).

## The attended-marker contract (the reading owner is `merge-guard.sh`)

- **Path:** `.claude/keel-attended-merge.json` under `CLAUDE_PROJECT_DIR`.
- **Fields (all required, non-empty strings; any defect → treated as NO marker, fail closed):**
  `scope` (must equal `"session"`), `created` (ISO timestamp), `invoker`.
- **Untracked, or it is a spoof.** A git-tracked copy is ignored — parity with the autonomy
  mode-file contract.
- **Written only by `/keel:auto-merge`** (`on` writes it, `off` removes it). The write path is
  the authorization trail; `disable-model-invocation: true` keeps the model from invoking the
  skill. (The residual "an agent could write the file directly / a stale file persists" is the
  same class the autonomy mode file carries — see `specs/deferrals/mode-file-binding-ttl.md`;
  the delegation-to-required-checks backstop holds it, because the marker unlocks only `--auto`.)
- **Autonomy precedence:** when a valid autonomy mode file is active, the attended marker is
  ignored — the mode path governs that decision.

## Done-conditions

### Logic / invariants
- [auto] New skill `skills/auto-merge/SKILL.md`: frontmatter carries `name: auto-merge`, a
  non-empty `description:`, `disable-model-invocation: true`, and a `when_to_use` that names it
  human-triggered-only — conforming to the CI-gated `scripts/check-skill-frontmatter.sh`. Its
  body instructs: `on` → write `.claude/keel-attended-merge.json` with the contract's three
  fields (`created` from a real timestamp), confirm the path is untracked (add to `.gitignore`
  if the project tracks `.claude/`), and never commit it; `off` → remove the file if present.
  It writes/removes **only** that file and issues no merge command itself.
- [auto] `scripts/merge-guard.sh` reads the attended marker with the same rigor as
  `read_mode_file`: untracked-only (a `git ls-files` hit → ignored), all three fields present
  and non-empty else no-marker, parity across the jq and python3 readers, ignored when an
  autonomy mode file is active. The read never eval's the file; values are handled as data.
- [auto] `scripts/merge-guard.sh` decision, **attended marker active AND no autonomy mode**:
  a command matching the existing `detect_strict_auto` shape (bare
  `gh pr merge <pr> --auto [--squash|--merge|--rebase]`) with the verified-pin gate **passing**
  → `allow` (the decision word bound through a variable, reusing the mode row's machinery so the
  self-test's no-bare-`allow`-literal tripwire stays live). Plain `gh pr merge` (no `--auto`) →
  `ask`. Gate **fail** → `deny` with the gate's reason verbatim. Unresolvable context → `ask`.
  **Marker absent → the existing ask/deny/allow matrix is byte-for-byte unchanged.**
- [auto] `scripts/guard-branch-rules.sh` reads the same attended marker (same validation, same
  autonomy precedence, duplicated per the self-contained-hook idiom the script header states).
  Marker active + no autonomy mode + command matches the bare `detect_strict_auto` shape →
  `exit 0` (defer the gate decision to `merge-guard.sh`, which fires on the same Bash call).
  Every other merge-shaped command, and `git commit` on the default branch → `exit 2`
  unchanged. **Marker absent → the exit-2 matrix is unchanged.**
- [auto] Both scripts stay safe under `set -euo pipefail` with quoted expansions; marker text is
  parsed as data, never eval'd or re-executed; decision JSON stays jq/python3-encoded, never
  interpolated. `scripts/check-neutral.sh` passes on both scripts and the new skill, and
  `scripts/check-skill-frontmatter.sh` passes on the new skill.

### Behavioral completeness
- [auto] `scripts/merge-guard.test.sh` extended to cover: marker-active `allow` on
  bare-`--auto` + gate-pass; `ask` on plain `gh pr merge` under the marker; `deny` on gate-fail
  under the marker; **marker-absent regression** (the full existing matrix, unchanged);
  git-tracked marker (spoof) → treated absent; malformed/partial marker → treated absent;
  autonomy-mode-present → attended marker ignored (the mode row governs); a **bundled/chained**
  `--auto` under an active marker (e.g. `gh pr merge 1 --auto && echo`) → `ask` (only the bare
  un-chained shape unlocks).
- [auto] `scripts/guard-branch-rules.test.sh` extended to cover: marker-active + bare-`--auto`
  → exit 0; marker-active + plain `gh pr merge` → exit 2; marker-active + `git commit` on the
  default branch → exit 2; marker-absent + merge-shaped → exit 2 (unchanged); a
  **bundled/chained** `--auto` under an active marker → exit 2 (only the bare shape unlocks);
  marker **and** a valid autonomy mode both active + bare `--auto` in build scope → exit 2
  (autonomy precedence governs — turning autonomy mode on suppresses the attended unlock here).
- [auto] A committed marker-read parity assertion: `scripts/merge-guard.sh` and
  `scripts/guard-branch-rules.sh`, given the same fixture marker (valid, git-tracked spoof, and
  malformed), reach the same conclusion — across the jq and python3 field readers and across
  both scripts.
- [auto] `scripts/session-bootstrap.sh` orientation reconciled: the attended standing invariant
  "Never merge; the user reviews and merges. Open PRs and stop there." gains a clause that a
  user-invoked `/keel:auto-merge on` lets an explicitly-instructed, gate-passing `--auto` merge
  land without the per-merge tap — the agent still never merges on its own initiative, and with
  no marker the line holds as written. `scripts/session-bootstrap.test.sh` updated to match.
- [auto] New append-only `decisions/2026-07-04-attended-auto-merge.md` amends the human-merge-
  gate doctrine **by reference** (it does **not** edit `2026-07-01-model-capability-ledger.md`
  or `2026-07-autonomy-modes.md` in place): the attended toggle delegates the per-merge *tap* —
  not the authority — to an explicit human invocation, unlocks only the `--auto` handoff
  (server-side checks still decide), and preserves both the verified-pin gate and the
  no-agent-initiative rule; it names `specs/deferrals/mode-file-binding-ttl.md` as the shared
  stale/forged-marker concern.
- [auto] `claude plugin validate --strict .` passes; every pre-existing self-test still passes
  (`merge-guard`, `guard-branch-rules`, `session-bootstrap`, `check-neutral`,
  `check-verified-pin`, `check-plan`, `check-skill-frontmatter`).
- [runtime] In a fixture repo (branch protection on), an attended session with the marker set:
  "merge PR #n" issues a bare `gh pr merge <n> --auto` and the guard emits the `allow` decision;
  the identical command with the marker off emits `ask`. Deterministic core — the decision
  matrix — is covered by `scripts/merge-guard.test.sh` (named committed test).
- [attended] The user confirms, during dogfooding, that with the marker on an instructed merge
  lands with no approval prompt (a tool result cannot itself prove a prompt did or did not
  appear — the guard's emitted decision JSON is the machine-checkable ground truth; this bullet
  is only the human's end-to-end no-prompt confirmation).

## verification
verifier subagent against this file — the decision matrices exercised via the committed
self-tests (never re-derived), the marker-contract validation and autonomy-precedence read in
both scripts, the skill frontmatter (`disable-model-invocation`), and a no-eval / quoted-data /
no-bare-`allow`-literal review of both guards — **+ `/security-review` pre-pin** (hard-invariant
surface: a marker flips a merge decision. Adversarial questions: can a git-tracked, malformed,
stale, or crafted marker flip `ask`/`deny` into `allow`; can a bundled / aliased / non-`--auto`
command ride the marker to a merge; does the autonomy-mode precedence hold; is field-reader
parity intact across jq and python3 and across both scripts?).

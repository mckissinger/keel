# Change — Attended auto-merge toggle: end the "I can't merge, do it in gh" refusal

**Grain:** one change → one milestone (`spec-change`). **No-UI** (plugin hooks + a skill +
docs — keel's own enforcement layer). **Stacked on:** `main` (independent).

## Why (the gap)

keel's merge posture has two hard walls that fire even when the human is at the keyboard,
explicitly asking to merge a **verified** PR:

1. **The build-session guard** (`scripts/guard-branch-rules.sh`, skill-scoped to
   `implement-milestone` / `implement-feature`) returns `exit 2` on *any* merge-shaped
   command — unconditionally, with no approval path. In a build session the agent literally
   cannot merge, so it punts the user to GitHub or a copy-paste command in another terminal.
   This is the recurring friction this change targets.
2. **The plugin merge guard** (`scripts/merge-guard.sh`, all sessions) floors a gate-passing
   merge at `ask` — a per-merge approval **tap** the user must click every single time.

Both are correct defaults (they make "a build session never self-merges" and "per-merge human
approval" *mechanism*, not prose). But when the human has *explicitly* instructed a merge of a
gate-passing PR, the tap is redundant and the categorical refusal is pure friction — the
authority is the human's, and it is being exercised. Per the model-capability ledger
(`decisions/2026-07-01-model-capability-ledger.md`), the human merge gate is *"authority, not
capability"*: removing the redundant tap on a **user-instructed, gate-passing** merge does not
weaken that authority; letting the **agent** decide to merge would.

## The mechanic

An **attended, per-session** opt-in the human turns on deliberately, which both guards honor —
reusing keel's autonomy-mode-file authorization-trail pattern so an agent can never mint it.

- **`/keel:auto-merge on|off`** — a new human-invoked-only skill (`disable-model-invocation:
  true`). `on` writes an **untracked** marker `.claude/keel-attended-merge.json`; `off` removes
  it. The write path is the authorization trail: the human invoking the command is the
  authorization, exactly as `keel:auto` is the sole writer of the autonomy mode file.
- **When the marker is active** (and no autonomy mode is active — that path takes precedence):
  - `merge-guard.sh`: a **bare** `gh pr merge <pr> --auto [--squash|--merge|--rebase]` (the
    existing `detect_strict_auto` shape) on a **verified-pin-gate-PASSING** PR → **`allow`**
    (no tap) instead of `ask`. Plain `gh pr merge` (no `--auto`) → still `ask`. Gate **fail** →
    still `deny`. This is the attended sibling of the existing mode-gated allow row — same
    machinery, a different unlock condition.
  - `guard-branch-rules.sh`: the same bare `--auto` shape → **exit 0** (defer the gate decision
    to `merge-guard.sh`, which runs on the same Bash call) instead of the `exit 2` refusal.
    Every other merge-shaped command, and `git commit` on the default branch → `exit 2`
    unchanged.
- **No marker** → both guards behave **byte-for-byte as today** (ask / deny / exit 2).

### What stays load-bearing (not weakened)

- **The verified-pin gate still blocks unverified code.** The marker only ever unlocks
  `--auto`, which GitHub merges *when and only when* required checks pass; and the local gate
  still denies a failing PR. A stale or forged marker cannot merge unsafe code — the same
  delegation-to-required-checks backstop that
  `specs/deferrals/mode-file-binding-ttl.md` records for the autonomy mode file covers this
  marker equally (referenced, not re-argued).
- **The agent still cannot merge on its own initiative.** No human-minted marker → today's
  ask/deny/exit-2. `disable-model-invocation` keeps the model from invoking the toggle skill.
- **Only the `--auto` handoff is unlocked** — plain `gh pr merge` and pushes/`git merge` to the
  default branch stay gated. So this takes effect only where branch protection makes `--auto`
  meaningful, i.e. a provisioned keel project (`provision` step 8 requires branch protection +
  a required CI check to be live). A local-only repo with no protection is out of scope here.
  The attended path deliberately adds **no** branch-protection preflight of its own (unlike the
  deferred per-project path, which requires one) — it relies on the protection a provisioned
  project already guarantees, with the human in the loop as the backstop.

## Explicitly deferred (its own future session)

The **per-project committed** variant of this toggle — always-on for every session in a repo,
including headless ones — is deferred with its compensating **required security-review check**.
Recorded in `specs/deferrals/per-project-auto-merge.md`; the user wants to dogfood it
separately.

## Known-adjacent (not this change)

The observed "auto-run `--auto` still prompts" symptom is most likely a bare-emission /
mode-active / bundling condition in the *existing* autonomy path, not the allow-row logic. It
needs the reproducing run's command log; it is not fixed here, but this change's done-conditions
carry the same emission-discipline requirement so the attended path is robust to it.

---
name: arm-auto-merge
description: Arm keel's committed per-PROJECT auto-merge for a repo — `keel:arm-auto-merge` (or `on`) asserts branch protection + the three required checks + the repo's `allow_auto_merge` are live via `scripts/check-branch-protection.sh`, and ONLY on a green assertion writes the tracked `.claude/keel-auto-merge.json` (`scope: "project"`) and opens it as a plan-only PR, so every session in the repo may land an instructed, gate-passing `gh pr merge <pr> --auto` with no per-merge tap; `keel:arm-auto-merge off` opens the plan-only PR that removes it. The skill only writes or removes that one marker file and opens the PR — it never merges anything itself, and the verified-pin gate and the no-agent-initiative rule stay intact.
when_to_use: Human-triggered only, when the user at the keyboard wants to make auto-merge the standing posture for THIS repo (every session, until disarmed) rather than one session — args `on` (default) / `off`. NOT `keel:auto-merge` (that's the per-SESSION attended marker), NOT autonomy (that's keel:auto), NOT a way for the agent to merge or to arm itself — the human invocation IS the authorization, the skill never merges, and with no committed marker every guard behaves exactly as today.
effort: high
disable-model-invocation: true
---

# Arm auto-merge (committed, per-project)

Make auto-merge the **standing posture of a repo**, not one session's. Where `keel:auto-merge`
drops the per-merge tap for the session you're driving, this skill drops it for **every** session
in the project — by committing a marker to the default branch that both merge guards honor. It is
the deliberate, human-invoked switch that says "on this repo, the server-side required checks are
the review; a gate-passing `--auto` needs no human tap."

`decisions/2026-08-02-committed-auto-merge-marker.md` is the shape this executes, and
`decisions/2026-07-04-attended-auto-merge.md` is the doctrine it extends from the session grain to
the project grain: the tap — **not** the authority — is delegated to an explicit human invocation,
and only the `--auto` handoff is unlocked (GitHub's required checks still decide what actually
lands). The verified-pin gate and the no-agent-initiative rule are untouched.

Because the marker is a **standing** authority — it outlives this session and applies to sessions
no human is watching — the bar to write it is higher than the session marker's: the skill refuses
to arm a repo whose protection is not actually live. That gate is the whole point of the skill.

## What the committed marker unlocks (and what it does not)

The marker is `.claude/keel-auto-merge.json`, honored **only** when present on the repo's **default
branch** (both guards read it from the server default branch, never the working tree). When it is
live — and no autonomy mode file and no attended session marker take precedence (precedence is
mode > attended > committed) — both guards honor it for **one** command shape: a **bare**
`gh pr merge <pr> --auto [--squash|--merge|--rebase]` in its own Bash call (the existing
`detect_strict_auto` whitelist).

- `scripts/merge-guard.sh`: that shape on a verified-pin-gate-**passing** PR → **allow** (no tap)
  instead of the ask floor. Plain `gh pr merge` (no `--auto`) stays **ask**. Gate **fail** stays
  **deny**. **Any PR whose diff touches `.claude/keel-auto-merge.json` is forced to a human tap**
  (`ask`), before and regardless of every allow row — arming, disarming, or editing the marker is
  never itself auto-merged. Every other shape is byte-for-byte today's table.
- `scripts/guard-branch-rules.sh` (the build-session guard): that same bare shape → **defer**
  (exit 0) to `merge-guard.sh` instead of the categorical `exit 2` refusal. Every other
  merge-shaped command, and `git commit` on the default branch, still `exit 2`.

**With no committed marker, every guard behaves exactly as today.** The marker never unlocks a
plain merge, a push, a `git merge` to the default branch, or a bundled/chained `--auto` — only the
bare delegation shape, which is meaningful only where branch protection makes `--auto` real.

## First, once per project: declare this repo's check names (if they aren't keel's)

The assertion certifies that specific **required checks** are live. By default it looks for keel's
own job names — `verified-pin`, `plan-lint`, `security-review`. A consuming repo's real CI almost
never uses those names (it's `verified-pin gate`, `typecheck · lint · test`, and so on), so on such
a repo the assertion would GAP on a pure **name mismatch**, not a real protection hole.

The fix is a **committed per-project check-contract** — `.claude/keel-auto-merge-checks.json` — where
the repo declares *its own* required-check contexts and its security-review check name/pattern. The
assertion reads it fail-closed from the server default branch (the same transport as the marker), so
a working-tree or branch-only copy is ignored. Shape:

```json
{
  "required_checks": ["verified-pin gate", "typecheck · lint · test", "security-review"],
  "security_review": { "check": "security-review", "pattern": "claude-code-security-review" }
}
```

It **declares names only** — it can *rename* the security-review check but never *remove* it (a set
omitting it GAPs), and it cannot switch off the (b2) content scan or the `allow_auto_merge` check. In
particular it carries **no `external` field**: a non-Actions security-review provider is attested only
by the per-invocation `PREFLIGHT_SECREVIEW_EXTERNAL=1` env var, never committed (a committed
`external: true` would silently disable content-scanning forever). A present-but-malformed or empty
contract fails closed (GAP), never a silent fall-back. Precedence is
**operator override (`PREFLIGHT_*` env, or an edited config-block default) > committed contract > keel
default** (`decisions/2026-08-03-arm-auto-merge-check-contract.md`). Commit it as a **plan-only PR**
(it gets the same `is_plan_path` carve-out as the marker) — and note a PR editing it takes a human tap
(it is auto-merge trust base). If the repo's checks already match keel's names, skip this; the default
just works.

## `on` (default) — assert protection is live, then commit the marker

The order is load-bearing: **assert first, write only on green.** Never write the marker on a red
or unproven assertion — a marker on a repo whose protection is not live arms unattended merges with
no server-side backstop, the exact failure this gate exists to prevent.

1. **Assert branch protection.** Run the shared assertion — do **not** re-author it:

   ```bash
   scripts/check-branch-protection.sh
   ```

   This is the **same code** `scripts/check-auto-preflight.sh` runs for its (b)/(b2)/(d) checks
   (the merge-relevant subset: the required checks are actually *required*, the `security-review`
   check is workflow **content** not just a name, and `allow_auto_merge` is enabled on the repo). It
   is the single source of the assertion, so the arming check and the auto-entry check can never
   drift apart. It resolves *which* check names to certify from the committed check-contract above
   (or `PREFLIGHT_*` / keel default). It fails closed: missing `gh`/`jq`, unreadable protection, or
   an API error is a GAP, not a silent pass.

2. **Halt on any GAP.** If the assertion exits non-zero, **stop** — surface each GAP line and its
   named remediation verbatim, and do **not** write the marker. Every gap is fixed **attended**
   (wire the required check, make it required, enable `allow_auto_merge`), never worked around by
   arming anyway. A red assertion is a full stop, not a warning to write past. The overrides the
   assertion documents (`PREFLIGHT_SECREVIEW_PATTERN` for a different in-Actions review
   implementation, `PREFLIGHT_SECREVIEW_EXTERNAL=1` to attest a non-Actions provider) are the only
   legitimate ways to clear (b2) — never by renaming or dropping the check.

3. **On green, write the marker.** Compute a real ISO-8601 UTC timestamp for `created`
   (`date -u +%Y-%m-%dT%H:%M:%SZ`) and an `invoker` string identifying this human invocation. Write
   `.claude/keel-auto-merge.json` under the project directory with **exactly** the three contract
   fields — all non-empty strings:

   ```json
   {
     "scope": "project",
     "created": "<the ISO-8601 UTC timestamp>",
     "invoker": "<who invoked this — e.g. human:keel-arm-auto-merge>"
   }
   ```

   `scope` **must** equal `"project"`; any other value, a missing or empty `created`/`invoker`, or
   malformed JSON makes the marker invalid and both guards fail closed to today's behavior. **There
   is no TTL** — unlike the session marker, a committed project marker is a standing decision that
   stays in force until a human removes it (that is what "per-project" means). Removal is the `off`
   path below.

4. **Open it as a plan-only PR — never a direct push to `main`.** The marker is the **only** changed
   file, and M1's carve-out (`decisions/2026-08-02-committed-auto-merge-marker.md`) makes
   `.claude/keel-auto-merge.json` a plan-path in the verified-pin gate, so a marker-only PR is
   plan-only → exempt from the pin → lands under the full protection contract with no `verified:`
   pin. Commit the marker on a branch and open the PR with `gh pr create`. **Do not push to `main`,
   and do not merge the PR** — the human reviews and merges it, exactly like every other plan PR
   (and the human-tap rule above independently forces that PR to a tap even if arming were somehow
   attempted via `--auto`).

5. **Report what was armed.** State that once the PR merges, this arms an instructed, gate-passing
   `gh pr merge <pr> --auto` for **every** session in this repo with no per-merge tap, that **the
   required checks are now the review**, and that disarming is `keel:arm-auto-merge off` (which
   opens the plan-only PR removing the file).

## `off` — open the plan-only PR that removes the marker

Symmetric with `on`. If `.claude/keel-auto-merge.json` is present on the default branch, remove it
on a branch and open the plan-only PR that deletes it (a marker-only diff is still plan-only →
exempt). The human reviews + merges; once merged, both guards are back to today's ask / deny /
exit-2 matrix for the repo. If the marker is already absent, report that and open nothing. As with
`on`, this skill **opens** the PR and stops — it never merges it, and never pushes to `main`.

## Boundaries

- **This skill writes or removes only `.claude/keel-auto-merge.json` and opens the plan-only PR.**
  It is the committed marker's **only** writer. It issues **no** merge command of its own — it never
  calls `gh pr merge`; the human merges the arming PR, and thereafter humans still type each
  `gh pr merge <pr> --auto`. The marker only changes how the guards score that shape.
- **The agent never invokes this skill to arm its own merges.** `disable-model-invocation: true`
  keeps the model from calling it; the human invocation is the whole authorization trail — the same
  pattern by which `keel:auto` is the sole writer of the autonomy mode file and `keel:auto-merge` is
  the sole writer of the session marker.
- **The assertion is reused, never re-authored.** The protection check is
  `scripts/check-branch-protection.sh` — the single source both this skill and the auto-preflight
  call. Never inline a second copy of the branch-protection logic here; if the assertion needs to
  change, it changes in that one script.
- **Precedence: mode > attended > committed.** When a valid `.claude/keel-autonomy.json` (autonomy
  mode) or `.claude/keel-attended-merge.json` (attended session) is active, that path governs the
  merge decision and the committed marker yields — the committed marker is the lowest-priority,
  always-on floor (`decisions/2026-07-05-autonomy-modes-v2.md`).
- **The load-bearing gates are untouched.** The verified-pin gate still denies unverified code, and
  `--auto` still lands only when the branch's required checks pass. A stale or forged marker cannot
  merge unsafe code — the marker (and the check-contract) are honored only from the server default
  branch behind a mandatory fail-closed fetch, and any PR touching the marker **or the check-contract**
  is forced to a human tap.

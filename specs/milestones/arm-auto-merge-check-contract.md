# Milestone — arm-auto-merge-check-contract: a project declares its own required-check names, committed and fail-closed

**Goal:** `keel:arm-auto-merge`'s protection assertion honors a **committed per-project check-contract**
— a project names its own required-check contexts (and *which* of them is its security-review check) in
`.claude/keel-auto-merge-checks.json`, read fail-closed from the repo's server default branch — instead
of only keel's plugin-repo defaults or an ephemeral env override. The plugin's assertion **logic** stays
canonical; the project supplies only **names**. A project can rename the security-review check, never
remove it; a missing, malformed, or floor-weakening config fails closed. Any PR editing the
check-contract takes a human merge tap.

**Design note (settled 2026-08-03, owner-approved after three verification rounds).** The committed
contract carries **names only** — `required_checks` and the security-review `check` name. It carries
**neither `pattern` nor `external`**: the (b2) content-scan pattern (which `uses:` reference identifies a
real review action) stays keel's default, overridable ONLY by the trusted `PREFLIGHT_SECREVIEW_PATTERN`
env, and external attestation stays the env-only `PREFLIGHT_SECREVIEW_EXTERNAL`. Both were removed from
the committed schema because a committed value the file's author picks can silently weaken the (b2) scan
— a committed `external:true` skips it outright (pre-pin `/security-review` finding), and a committed
`pattern` is a **substring** whose too-broad values (`""`, `.*`, `@`, an org prefix, the repo's own
non-review action) make the scan match every `uses:` line and pass with no real review. Substring-
matching an attacker-declarable pattern is inherently weakenable, so the untrusted committed file never
supplies it; the real motivating incident (crelaunch) needed only project-specific **check names**, which
a project using keel's own review action never needs a custom pattern for.

**Change:** `specs/changes/arm-auto-merge-check-contract.md`. **No-UI** (keel plugin repo) →
two-dimension done-conditions (logic/invariants + behavioral completeness), no fidelity.
**Depends on:** the shipped per-project-auto-merge feature (`specs/features/per-project-auto-merge.md`,
merged #198–#202) — the marker, both guards' committed rows, `scripts/check-branch-protection.sh`, and
the `is_plan_path` carve-out this change extends. **Parallelizable:** n/a (single milestone).
**Routing:** reasoning-heavy — it edits the merge-authority assertion; a gap here lets a human arm
standing auto-merge on a repo whose real floor is weaker than the assertion certified. Dispatch the
verifier at `xhigh`.

## The check-contract file (shape)

`.claude/keel-auto-merge-checks.json` (final key names are the build's to settle; this is the intent):

```json
{
  "required_checks": ["verified-pin gate", "typecheck · lint · test", "security-review"],
  "security_review": {
    "check": "security-review"
  }
}
```

`required_checks` is the exact set of status-check contexts that must be REQUIRED on the default
branch. `security_review.check` is which of those contexts is the security review (the (b2) content
scan keys off that name). The committed contract carries **no `pattern` and no `external` field** — the
uncommented-`uses:` action reference the (b2) scan matches stays keel's default (overridable only by the
trusted `PREFLIGHT_SECREVIEW_PATTERN` env), and a non-Actions provider is attested only by the
per-invocation `PREFLIGHT_SECREVIEW_EXTERNAL=1` env var. Both are deliberately env-only / keel-default:
a committed `external: true` would skip the (b2) scan forever, and a committed `pattern` is a
substring whose too-broad values match every `uses:` line and pass with no real review — see the Design
note above. Any `pattern` / `external` key present in the file is **ignored**.

## Done-conditions

### Logic / invariants

- [auto] **`check-branch-protection.sh` reads the committed check-contract, default-branch-sourced,
  with an absent-vs-malformed fork.** When `.claude/keel-auto-merge-checks.json` is present on the
  repo's SERVER default branch, its `required_checks` (and its declared security-review `check` name) is
  what the assertion certifies, replacing keel's built-in default set (any `pattern` / `external` key in
  the file is ignored — those stay env-only / keel-default per the Design note). The read uses
  the **same fail-closed transport** as `merge-guard.sh:read_committed_marker` — default branch resolved
  from `gh repo view` server-truth; a **MANDATORY** fetch of that branch from origin; the content read
  from the just-fetched `refs/remotes/origin/<db>:.claude/keel-auto-merge-checks.json` and parsed as
  DATA — **never the working tree**. A locally `Write`-n or branch-only config is therefore ignored.
  **One behavioral fork must be ADDED, not copied:** `read_committed_marker` collapses every failure
  (no `gh`, fetch fails, `git show` non-zero, empty, wrong scope) into one undifferentiated "absent"
  return; this reader must instead key on the `git show` **exit code** — a non-zero `git show` (file
  genuinely not on the default branch) is **absent → fall back to default**, whereas a **successful**
  read whose content is then malformed/empty is **present-but-broken → GAP** (next bullet). The two
  outcomes are distinct and must not both route to "absent."
- [auto] **Precedence is operator override > committed config > keel built-in default**, where
  "operator override" = `PREFLIGHT_REQUIRED_CHECKS` / `PREFLIGHT_SECREVIEW_PATTERN` /
  `PREFLIGHT_SECREVIEW_EXTERNAL` set in the environment **or** a project copy that has edited the
  script config-block default away from keel's built-in string. Absent any operator override, the
  committed config wins. Absent **both** the file and any override, the assertion falls back to keel's
  current defaults (`verified-pin plan-lint security-review`, check `security-review`, pattern
  `claude-code-security-review`) — so keel's own repo and any name-matching project behave
  **byte-for-byte as today**.
- [auto] **The config declares names, it never weakens the floor.** (1) A `required_checks` that omits
  the declared security-review context → **GAP**: the config may rename the security-review check (via
  its declared `security_review.check`), never remove the compensating control; the (b2) content scan
  runs against **that declared name** (not the literal string `security-review`), and if the declared
  name is not a member of `required_checks` the assertion GAPs. The effective set must include a
  security-review check, still asserted as workflow **content** (b2) or explicit external attestation.
  (2) A present-but-**malformed** config → **GAP, fail closed** — never a silent pass and never a
  silent fall-back-to-default (absence falls back; a broken *present* config is an error to surface,
  not paper over). "Malformed" is strict at the fail-closed read boundary: unparseable JSON,
  `required_checks` not a non-empty array of **non-empty** strings, **or a present-but-empty
  `security_review.check`** — an empty `check` is a (b2) name-match hole, so it is rejected (jq's `//`
  substitutes the keel default only on a genuinely *absent* field, never on `""`). The committed
  `check` name is matched **literally** (`grep -F`), never as a regex, so a non-empty but
  trivially-matching value (`check:"."`, a bare space) cannot satisfy the (b2) name leg against an
  unrelated file either. (The (b2) `pattern` is **not** validated or matched from the committed file at
  all — it is env-only / keel-default, so no committed value can weaken it; see the Design note.)
  (3) The config cannot switch off the (b2) content scan or the (d) `allow_auto_merge` assertion — both
  run regardless of what the file says, and neither the `pattern` nor the `external` field is read from
  it.
- [auto] **The preflight delegation honors the committed config without breaking the config-block-edit
  path.** `scripts/check-auto-preflight.sh` today unconditionally forwards its resolved
  `PREFLIGHT_REQUIRED_CHECKS="$REQUIRED_CHECKS"` to `check-branch-protection.sh` (`:144`), which masks
  any committed config. The fix: forward the override **only when it is a real override** — i.e. when
  `PREFLIGHT_REQUIRED_CHECKS` is set in the environment **OR** the resolved config-block value
  **differs from keel's built-in default string** (a project copy that hardened the config-block
  default) — and forward **nothing** when it equals the unmodified built-in default, so the child
  resolves committed-config-or-default itself. This **preserves `check-auto-preflight.test.sh` test 21**
  ("config-block `REQUIRED_CHECKS` edit survives the delegation" — an edited default differs, so it is
  still forwarded and the child still GAPs on the added check) **and** lets an unmodified preflight
  honor a committed `.claude/keel-auto-merge-checks.json`. Do the same for the `PREFLIGHT_SECREVIEW_*`
  knobs. The preflight's (a)/(a2)/(c) checks and overall pass/fail semantics are otherwise **unchanged**,
  and every existing preflight test still passes.
- [auto] **`merge-guard.sh` forces a human tap on any PR touching the check-contract.** The existing
  "PR touches `.claude/keel-auto-merge.json` → `ask` (never auto)" rule — the guard that stops a
  temporary authority landing the permanent trust base — is extended to also cover
  `.claude/keel-auto-merge-checks.json`, via the same non-truncating fresh-fetched `base...head` diff,
  fail-closed on an indeterminate list. A PR that edits the declared check-set can **never**
  auto-merge, closing the escalation where an active authority silently weakens the floor a later
  arming would trust. The `d_auto` variable-binding tripwire and the pre-allow ordering are preserved.
- [auto] **The check-contract file is committable under the protection contract.**
  `check-verified-pin.sh`'s `is_plan_path()` carve-out is extended to
  `.claude/keel-auto-merge-checks.json` (sibling to the marker's existing exact-match carve-out at
  `:61`) — so a project commits/edits its check-contract as a **plan-only PR** that lands under branch
  protection with no pin, exactly like the marker. Without this the setup PR would hard-fail the pin
  gate (the M1 problem this mirrors). **Update the now-stale `:59-60` comment** ("Exactly one file,
  never a `.claude/*` wildcard") to reflect two exact-match carve-outs (still exact matches, not a
  wildcard).

### Behavioral completeness

- [auto] **`check-branch-protection.test.sh`** gains, each written to **fail on pre-change code**:
  a committed config present → its named set is certified (green only when the repo's protection
  requires exactly those contexts; GAP when it does not); a **forged working-tree / branch-only**
  config is **ignored** (the default-branch read wins) — the anti-forge regression; a **malformed** or
  **empty** `required_checks` → GAP; an **empty `security_review.check`** → GAP; a config **omitting the
  declared security-review** → GAP; a committed **`pattern` is ignored** (env-only) so it cannot
  self-certify a non-review action → GAP — the substring-weakening regression; the committed **`check`
  name is matched literally** so a regex-special name does not satisfy the (b2) name leg → GAP; an env
  override still **beats** the committed config; **absent** config → keel default (the existing green
  case, unchanged). **Fixture note:** this suite currently has **no** git-remote/fetch/`git show`
  machinery (its fixtures are plain dirs + a stubbed `gh`); the transport fixture must be **built here**
  by copying the shape of `merge-guard.test.sh`'s `arm_committed()` helper (a real `origin` remote + a
  committed ref on the default branch + the mandatory fetch) — it is **not** already established in this
  suite.
- [auto] **`check-auto-preflight.test.sh`**: every existing case still passes after the delegation
  change; a new case proves the preflight **honors a committed config** (no operator override) rather
  than masking it with keel's default.
- [auto] **`merge-guard.test.sh`**: a PR touching `.claude/keel-auto-merge-checks.json` → `ask`
  (never `allow`), matching the marker-touch case; the existing marker-touch, committed-row, and
  precedence cases are unchanged (suite stays green).
- [auto] **`check-verified-pin.test.sh`**: `.claude/keel-auto-merge-checks.json` classified plan-path
  (a code PR touching only it is exempt), mirroring the marker carve-out test.
- [auto] **`skills/arm-auto-merge/SKILL.md`** documents the committed check-contract: the one-time
  per-project **setup** (author `.claude/keel-auto-merge-checks.json` naming this repo's required
  checks + its security-review check name, commit it via a plan-only PR — which takes a human tap), that
  it declares **names only** and never weakens the assertion (security-review stays mandatory; b2 and d
  always run), and the **env > committed config > keel default** precedence. Passes
  `check-skill-frontmatter.sh` + `check-skill-anchors.sh`.
- [auto] **`references/template-contract.md`** records where a consuming project declares its check
  names (the check-contract file) as part of tier-1 adoption, cross-referenced from the security-review
  wiring moment — so a project adopting auto-merge learns to name its own checks, not rename its CI to
  keel's.
- [auto] **A new `decisions/2026-08-03-arm-auto-merge-check-contract.md`** records the mechanism: data
  not script, the fail-closed default-branch transport, the env>config>default precedence, the
  never-weakens constraints (security-review mandatory; malformed/empty → GAP; absence → default), the
  touch-protection, and the plan-path carve-out. Append-only; amends by reference
  `decisions/2026-08-02-committed-auto-merge-marker.md`.
- [attended] **`/security-review` pre-pin** on this branch is mandatory (hard-invariant: edits the
  merge-authority assertion and the guard touch-rule). A required finding is a **stop-point**.

## Verification

Fresh-context `verify-milestone` (or a `keel:verifier` subagent) at **xhigh**, from these
done-conditions + the checkout — never the builder's claims. Its proof run is the **full** committed
suite (every `scripts/*.test.sh`, unfiltered) + `check-skill-frontmatter.sh` + `check-skill-anchors.sh`
+ `check-plan.sh` + `check-neutral.sh` + `claude plugin validate --strict .`, all green. The **anti-forge**
(forged working-tree/branch-only config ignored) and **fail-closed-on-malformed** conditions each carry
a regression test that **fails on pre-change code**. `/security-review` runs **pre-pin**; a finding
halts attended. All conditions are `[auto]` (committed shell tests with fixtures) — **no `[runtime]`**:
the default-branch read, precedence, and guard behavior are all provable without a live merge. On a
clean verdict the verifier writes the `verified:` pin; the build session never pins its own work.

# 2026-08-03 — The committed per-project check-contract: a repo declares its own required-check names

Records the resolved design for milestone `arm-auto-merge-check-contract`
(`specs/milestones/arm-auto-merge-check-contract.md`, `specs/changes/arm-auto-merge-check-contract.md`):
how `keel:arm-auto-merge`'s protection assertion honors a consuming repo's *own* required-check names
without weakening the fail-closed gate. Amends by reference (edits nothing in place)
`decisions/2026-08-02-committed-auto-merge-marker.md`.

## The problem

`scripts/check-branch-protection.sh` certifies that specific **required checks** are live before the
committed marker may arm `gh pr merge --auto`. It ran with keel's own job names as the default set —
`verified-pin plan-lint security-review`. A consuming repo's real CI almost never uses those names
(the motivating incident, `crelaunch`, requires `verified-pin gate` + `typecheck · lint · test`), so
arming there GAPped on a pure **name mismatch**, not a real protection hole. The only lever was the
per-invocation `PREFLIGHT_REQUIRED_CHECKS` env var — which lives nowhere committed, and a fail-closed
safety gate must not depend on a hand-retyped variable each arm.

## The mechanism — data, not script

A consuming repo declares its own check names in a committed **`.claude/keel-auto-merge-checks.json`**
(sibling to the marker):

```json
{
  "required_checks": ["verified-pin gate", "typecheck · lint · test", "security-review"],
  "security_review": { "check": "security-review" }
}
```

The plugin's `check-branch-protection.sh` stays the canonical **logic**; the file supplies only
**names**. `required_checks` are the contexts that must be REQUIRED on the default branch;
`security_review.check` is which of them is the review (the (b2) content scan keys off that name).

**The committed contract carries neither `pattern` nor `external`** — both are env-only / keel-default,
and any such key in the file is ignored. This was settled after three verification rounds (see "Why the
committed file supplies names only" below): a committed value the file's author picks can silently
weaken the (b2) scan. A committed `external: true` skips it outright; a committed `pattern` is a
**substring** whose too-broad values (`""`, `.*`, `@`, an org prefix, or the repo's own non-review
action) make the scan match every `uses:` line and pass with no real review. The (b2) match pattern
stays keel's default, overridable ONLY by the trusted per-invocation `PREFLIGHT_SECREVIEW_PATTERN`; a
non-Actions provider is attested ONLY by the per-invocation `PREFLIGHT_SECREVIEW_EXTERNAL=1`.

## Transport, precedence, and the never-weakens rules

- **Fail-closed, default-branch-sourced.** The config is read with the same transport as
  `merge-guard.sh:read_committed_marker` — default branch from `gh repo view` server-truth, a MANDATORY
  fetch, `git show refs/remotes/origin/<db>:<path>` parsed as DATA, never the working tree. A locally
  written or branch-only config is ignored. One behavioral fork is **added, not copied** from the
  marker read: a non-zero `git show` (file genuinely absent) falls back to the keel default, whereas a
  *successful* read of broken content is a GAP — absence and malformed are distinct.
- **Precedence: operator override > committed contract > keel default.** "Operator override" =
  `PREFLIGHT_REQUIRED_CHECKS` / `PREFLIGHT_SECREVIEW_*` set in the environment, or a project copy that
  edited the script's config-block default away from keel's built-in string. Absent any override, the
  committed contract wins; absent both, the keel default holds — so keel's own repo and any
  name-matching project are byte-for-byte unchanged.
- **Never-weakens.** The committed contract declares names, it cannot lower the floor: a
  `required_checks` omitting the declared security-review check → GAP (rename yes, remove no); a
  present-but-malformed config → GAP, fail closed, never a silent fall-back. "Malformed" is read
  strictly at the fail-closed boundary: unparseable JSON, `required_checks` not a non-empty array of
  **non-empty** strings, **or a present-but-empty `security_review.check`**. An empty `check` is a (b2)
  name-match hole, so it is rejected (jq's `//` substitutes the keel default only on a genuinely *absent*
  field, never on `""`), and the committed `check` name is matched **literally** (`grep -F`), never as a
  regex, so a trivially-matching value (`check:"."`, a bare space) cannot satisfy the (b2) name leg
  against an unrelated file. The `pattern` is **not read from the committed file at all** — so no
  committed value, empty or trivial, can weaken the (b2) content scan (see below). The config can switch
  off neither the (b2) content scan nor the (d)
  `allow_auto_merge` assertion. An **operator** override that deliberately omits
  security-review is still trusted (keel trusts an operator stating the set explicitly) — the
  never-weakens rule binds the committed-config / keel-default path, the ergonomic data file a project
  edits without touching the script.
- **Check names may contain spaces.** `required_checks` is a JSON array read into a NEWLINE-separated
  list, so a context like `typecheck · lint · test` survives — the pre-existing space-separated
  `REQUIRED_CHECKS` string could not represent it (keel's own names have no spaces, so it never
  surfaced until a consuming repo's did).

## Why the committed file supplies names only (the three-round evolution)

The committed contract began carrying `security_review.pattern` (and, in the earliest draft,
`external`). Verification then found the same fail-open class four times — each a committed value that
made the (b2) "a real review workflow runs" scan pass while no review ran:

1. `external: true` — skipped the (b2) content scan outright (pre-pin `/security-review`). → committed
   `external` ignored; env-only.
2. `pattern: ""` — jq's `//` substitutes the keel default only on a genuinely *absent* field, so `""`
   survived and collapsed the `grep -E "...uses:...$pattern"` regex to "any uses: line". → reject empty.
3. `pattern: ".*"` — a non-empty regex wildcard, same collapse. → match the pattern **literally**
   (`grep -F`), not as a regex.
4. `pattern: "@"` / `"uses"` / an org prefix / the repo's own non-review action — a non-empty *literal*
   substring that is present on every real `uses:` line anyway.

Each fix was one variant behind because the underlying operation — "does this author-supplied substring
appear in the workflow?" — is **inherently weakenable**: there is always some too-broad string that
matches everything, so no validation rule closes the class. The resolved decision (owner-approved
2026-08-03) is to remove the weakenable surface entirely: the untrusted committed file declares check
**names** only and never supplies the (b2) match pattern. The pattern stays keel's default, overridable
only by the trusted per-invocation `PREFLIGHT_SECREVIEW_PATTERN` env. The motivating incident
(crelaunch) never needed a committed pattern — it was a pure check-**name** mismatch, and a repo using
keel's own review action uses the default pattern; a repo using a different in-Actions review action
supplies its pattern via the trusted env at arm time (the same override that already existed). The
committed `check` name stays (bounded: it must also be an exact member of `required_checks` and a live
required status check, and it is matched literally), so a project can still *rename* which context is
its review.

## Why the preflight delegation had to change too

`check-auto-preflight.sh` delegated (b)/(b2)/(d) to `check-branch-protection.sh` by **unconditionally**
forwarding its resolved `PREFLIGHT_REQUIRED_CHECKS`, which would mask a committed contract on the
auto-run path. It now forwards the set only when it is a **real** override — the env var is set, OR the
config-block value differs from keel's built-in default — and forwards nothing when it equals the
unmodified default, so the child resolves the committed contract itself. This preserves
`check-auto-preflight.test.sh`'s config-block-edit test (an edited default still forwards) while
honoring a committed contract under an unmodified preflight.

## Trust base: touch-protection and the plan-path carve-out

The check-contract is auto-merge **trust base** — it declares what "protected" means for arming — so it
gets the same two protections as the marker:
- **Human tap on any edit.** `merge-guard.sh:pr_touches_marker` matches the check-contract path as well
  as the marker, so a PR editing it is forced to `ask` before every allow row. This closes the
  escalation where, under an active auto-merge authority, an agent could silently weaken the declared
  floor a later human arming would then rubber-stamp.
- **Committable under protection.** `check-verified-pin.sh:is_plan_path` carves out the check-contract
  (a second exact-match path beside the marker, never a `.claude/*` wildcard), so a project commits its
  declared names as a plan-only PR that lands under branch protection with no pin.

The load-bearing gates are untouched: a valid contract still only makes arming assert *the right
names*; the verified-pin gate, the (b2) content scan, `allow_auto_merge`, and the required-checks floor
all still run, and `--auto` still lands only when those checks pass.

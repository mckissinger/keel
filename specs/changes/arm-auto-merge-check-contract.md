# Change — arm-auto-merge per-project check-contract

**One sentence.** Let a consuming project declare its **own** required-check names (and its
security-review check name / pattern) in a **committed, in-repo data file** that
`keel:arm-auto-merge`'s protection assertion reads — so a project whose real CI diverges from keel's
plugin-repo defaults can arm without renaming its checks or re-typing an ephemeral env override on
every arm.

## Why (motivating incident, 2026-08-03)

Arming `crelaunch` tripped the fail-closed gate with 5 gaps. Two of them are that project's own infra
to wire (no `security-review` workflow; `allow_auto_merge=false`). The other three are a **name
mismatch**: crelaunch's `main` requires `verified-pin gate` + `typecheck · lint · test` (its real app
CI), while `keel:arm-auto-merge` asserts keel's own defaults `verified-pin plan-lint security-review`.
Today arming runs the **plugin copy** of `scripts/check-branch-protection.sh`, so `REQUIRED_CHECKS`
resolves to keel's repo defaults and a consuming project has **no committed place** to state its check
names — only the per-invocation `PREFLIGHT_REQUIRED_CHECKS` env var, which a *fail-closed safety gate*
must not depend on being hand-retyped correctly each arm.

## Settled design (owner-approved 2026-08-03)

- **Data, not script.** A small committed JSON — `.claude/keel-auto-merge-checks.json`, sibling to the
  marker `.claude/keel-auto-merge.json` — names the project's `required_checks` and its security-review
  `check` / `pattern` / `external` attestation. The plugin's `scripts/check-branch-protection.sh` stays
  the canonical **logic**; the project supplies only **names**. It can rename the security-review check,
  never **remove** it.
- **Fail-closed transport, mirrored from the marker read.** The config is read from the repo's SERVER
  default branch via the same `gh repo view` → mandatory fetch → `git show refs/remotes/origin/<db>:…`
  pattern as `merge-guard.sh:read_committed_marker`. A working-tree or branch-only file is ignored.
- **Precedence: env override > committed config > keel default.** Absent both the file and an operator
  override, the assertion falls back to keel's current defaults — so keel's own repo and any
  name-matching project are unchanged.
- **Touch-protection.** Any PR that edits the check-contract file takes a human merge tap (the same
  guard that already protects the marker), closing the escalation where an active auto-merge authority
  could silently weaken the floor a later human arming would trust.

Fans into **one milestone** — `specs/milestones/arm-auto-merge-check-contract.md`. Hard-invariant
(edits the merge-authority assertion) → `/security-review` pre-pin mandatory.

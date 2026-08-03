# Uncertainty — the extracted assertion resolves the default branch from repointable `origin/HEAD`, not `gh repo view` server-truth

**Milestone:** `arm-auto-merge-skill` (M2 of `per-project-auto-merge`).

## The choice made

`scripts/check-branch-protection.sh` resolves which branch to read protection for
(`default_branch`) from **local git state** — `git symbolic-ref --quiet refs/remotes/origin/HEAD`,
falling back to a `main`/`master` show-ref probe — then calls
`gh api repos/{owner}/{repo}/branches/$default_branch/protection`. This is copied **verbatim** from
the (b) block of `scripts/check-auto-preflight.sh` as it stood on `main`: the extraction is
behavior-preserving, which is exactly what the milestone's done-condition requires ("its existing
test expectations all still hold", "identical observable behavior").

## The viable alternative

Resolve `default_branch` from **server truth** —
`gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'` — with the `origin/HEAD` path
only as a fallback. This is what M1 (`committed-auto-merge-marker`) deliberately did for the
**runtime honor path** (`read_committed_marker` in `merge-guard.sh`): its pre-pin `/security-review`
found that `origin/HEAD` is agent-repointable via `git remote set-head`, so an agent could point it
at a protected branch to fool a marker read, and the fix was to resolve the default branch from
`gh repo view`, never `origin/HEAD`, behind a mandatory fail-closed fetch.

## Why it's uncertain

The two paths now use **different** notions of "the default branch": arming's assertion
(`check-branch-protection.sh`, origin/HEAD) and the enforcement it is supposed to certify
(`merge-guard.sh`'s `read_committed_marker`, `gh repo view` server-truth). If a repo's local
`origin/HEAD` is repointed to a *protected* branch while the *server* default branch is unprotected,
the arming assertion could pass against branch A while the marker it writes lands on and is honored
from branch B — arming a repo whose real merge-gating branch is not protected.

**Why I left it as inherited (the case for the choice):**

- The milestone is an **extraction**, and its done-conditions mandate behavior-preservation of the
  preflight; changing the resolution source is a behavior change to a pre-existing, separately-shipped
  check, arguably out of M2's scope.
- The threat is heavily backstopped: the skill is `disable-model-invocation` (an agent cannot invoke
  arming), arming is attended and lands via a **human-reviewed plan-only PR**, and the runtime honor
  path independently uses server-truth — so a fooled assertion does not by itself change what
  `merge-guard.sh` reads at merge time.
- For the assertion to be fooled, an *attended human* would have to be running against a repo whose
  local `origin/HEAD` was repointed away from the server default — the same persistence-then-attended
  class M1 closed for the runtime path, not a fresh agent-only escalation.

**Why a reviewer might decide the other way:** coherence — the check that *certifies* merge-readiness
should read protection for the *same* branch the enforcement honors the marker from. Aligning
`check-branch-protection.sh` to `gh repo view` server-truth (origin/HEAD as fallback) closes the
gap-of-notions and matches M1's hardening, at the cost of touching the preflight's resolution logic
and re-confirming its test suite stays green. **This is explicitly in scope for the milestone's
pre-pin `/security-review`** ("can the marker be written while protection is not live").

## Resolution (pre-pin `/security-review`, 2026-08-02)

The review rated the divergence a **real hole (confidence 8/10)** — a persistence-then-attended
escalation: an agent repoints `origin/HEAD` in an ordinary build session (`git remote set-head`,
an unguarded command), a later attended `keel:arm-auto-merge` certifies the wrong branch, and the
marker lands on and is honored from an unprotected server default. **So it was FIXED here, not
deferred:** `check-branch-protection.sh` now resolves the default branch from
`gh repo view --json defaultBranchRef` (server truth, the same source `read_committed_marker` uses),
with the local `origin/HEAD`/probe logic surviving only as a last-resort fallback for when
`gh repo view` cannot answer — and in that state the protection/`allow_auto_merge` `gh api` calls
fail closed too. The PASS line now also **names the certified branch** so an attended operator sees
which branch was checked. Regression-tested: `check-branch-protection.test.sh` proves server truth
overrides a repointed `origin/HEAD` (demonstrated to GAP on the pre-fix code), and the preflight
suite stays green (behavior-preserving: local resolution still resolves to `main` when
`gh repo view` is unavailable).

## Accepted residual — the working-tree trust boundary (a separate follow-up)

The review surfaced two lower-severity items in the **same trust boundary**, both rated
below the fix-now bar (3/10 and 2/10) and **deliberately left for a dedicated follow-up**, not fixed
in this extraction milestone:

- **(b2) reads workflow content from the local working tree,** not the default branch's committed
  content — an agent could stage an uncommitted `.github/workflows/*.yml` to satisfy the content
  scan while the default branch's `security-review` job is vacuous.
- **The gate script itself is a working-tree file** with no server-side re-run (unlike
  `check-verified-pin.sh`, which CI re-runs as a required check) — an agent with file-write could
  edit `check-branch-protection.sh` to `exit 0`.

Both share one precondition (agent write-access to the local checkout) and one trigger (a later
attended arming), and the cheaper attack (edit the gate) subsumes the other — so fixing (b2) alone
while the script stays tamperable buys nothing. Closing the boundary properly means reading
default-branch **committed** content (via `git show` behind the mandatory fetch M1 already uses) and
finding an answer for trusting a working-tree gate script (e.g. re-asserting protection from the
arming PR's own CI run) — a coherent unit of work larger than this behavior-preserving extraction,
and one that touches the shipped preflight's content-scan semantics. Tracked here for that follow-up;
the standing backstops (arming is attended + `disable-model-invocation`; the marker is honored only
from the server default behind a fail-closed fetch; every merge still faces GitHub's server-side
required checks; any marker-touching PR is force-tapped) hold in the interim.

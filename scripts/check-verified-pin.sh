#!/usr/bin/env bash
#
# check-verified-pin.sh — keel's verified-pin gate.
#
# Enforces "verified code == merged code" on a milestone CODE PR: the milestone's
# spec file must carry a `verified:` line whose pinned <short-sha> is an ancestor of
# HEAD, and between that SHA and HEAD only PLAN files (specs/**, design/**) may have
# changed. A wholly PLAN-ONLY PR (the upfront feature plan PR) is EXEMPT.
#
# BOOTSTRAP WINDOW: until the first milestone or chore spec exists — judged at BOTH the
# base branch's tip and HEAD, so the window is deletion-proof and can never be re-entered
# from an old branch root once a spec is on the base — every PR is exempt. Pre-first-milestone
# foundation work (the specs+CI+this-script PR, the design-gate workbench, the scaffold) is
# attended by design and has nothing a pin could describe; the gate arms itself permanently
# the moment the first milestone/chore spec lands on the base branch.
#
# This is the canonical implementation. spec-foundation / adopt copy it into a project
# and wire it as a CI job; it is never re-authored from prose.
#
# Usage:
#   BASE_REF=origin/main scripts/check-verified-pin.sh [HEAD_REF]
#   BASE_REF=<parent-branch> ...   # for a stacked PR, check against its base
#
# Exit 0 = pass (or exempt). Non-zero = fail, with the reason on stderr.

set -euo pipefail

BASE_REF="${BASE_REF:-origin/main}"
HEAD_REF="${1:-HEAD}"

is_plan_path() {
  case "$1" in
    # Runtime-affecting spec files are code, not plan: a PR touching either needs a
    # pinned milestone/chore spec, and a post-pin edit to either counts as drift.
    specs/stack-profile.md|specs/run-command-inventory.txt) return 1 ;;
    specs/*|design/*|decisions/*|deferrals/*) return 0 ;;
    *) return 1 ;;
  esac
}
fail() { echo "verified-pin: FAIL — $1" >&2; exit 1; }

# 0. Fail closed on unresolvable refs. A misconfigured CI (missing fetch, deleted stack
#    parent) must never read as "no changes — pass": the diff's failure would otherwise
#    hide inside the process substitution below and the gate would exit 0.
git rev-parse --verify --quiet "$BASE_REF^{commit}" >/dev/null \
  || fail "BASE_REF '$BASE_REF' does not resolve to a commit"
git rev-parse --verify --quiet "$HEAD_REF^{commit}" >/dev/null \
  || fail "HEAD_REF '$HEAD_REF' does not resolve to a commit"

# 0.5. Fail closed when no merge base exists. Both refs resolving is not enough: with
#      disconnected histories the three-dot diff below fails INSIDE the process
#      substitution, the failure never propagates past set -euo pipefail, and the empty
#      result reads as "no changes — pass". Likely causes: a shallow CI clone
#      (actions/checkout without fetch-depth: 0) or unrelated histories.
git merge-base "$BASE_REF" "$HEAD_REF" >/dev/null 2>&1 \
  || fail "no merge base between BASE_REF '$BASE_REF' and HEAD_REF '$HEAD_REF' — likely a shallow clone (use fetch-depth: 0 / git fetch --unshallow for a full fetch) or unrelated histories; the diff cannot be computed and must never read as 'no changes'"

# 1. What does this PR change (vs the merge-base with BASE_REF)?
changed=()
while IFS= read -r f; do [ -n "$f" ] && changed+=("$f"); done \
  < <(git diff --name-only "$BASE_REF"..."$HEAD_REF")

if [ ${#changed[@]} -eq 0 ]; then
  echo "verified-pin: no changes vs $BASE_REF — pass"
  exit 0
fi

# 2. Plan-only PR? Exempt (milestone specs may land without pins; pins come later in code PRs).
has_code=0
for f in "${changed[@]}"; do is_plan_path "$f" || has_code=1; done
if [ "$has_code" -eq 0 ]; then
  echo "verified-pin: plan-only PR (specs/** + design/** + decisions/** + deferrals/** only) — exempt, pass"
  exit 0
fi

# 2.5 Bootstrap window: no milestone/chore spec exists at either the base branch's TIP or
#     HEAD → pre-first-milestone foundation work → exempt. The base TIP (never the
#     merge-base: a branch rooted at a pre-first-spec commit would make the merge-base
#     predate the spec and re-enter the window) plus HEAD means neither a deletion nor an
#     old branch root can reopen it. quotePath off so unusual spec filenames still close
#     the window; `.+` (not `[^/]+`) so nested spec paths match step 3's glob semantics.
has_specs() { # <rev>
  git -c core.quotePath=false ls-tree -r --name-only "$1" -- specs/milestones specs/chores 2>/dev/null \
    | grep -Eq '^specs/(milestones|chores)/.+\.md$'
}
if ! has_specs "$BASE_REF" && ! has_specs "$HEAD_REF"; then
  echo "verified-pin: bootstrap window — no milestone or chore spec exists yet (pre-first-milestone foundation work); the gate arms when the first lands — pass"
  exit 0
fi

# 3. Code PR: every milestone OR chore-batch spec it touches must carry a valid, drift-free pin.
#    A chore batch (specs/chores/<slug>.md) carries ONE batch pin covering many tiny changes —
#    the punch-list lane — validated exactly like a milestone pin.
specs=()
for f in "${changed[@]}"; do
  case "$f" in specs/milestones/*.md|specs/chores/*.md) specs+=("$f") ;; esac
done
[ ${#specs[@]} -eq 0 ] && \
  fail "code PR touches no milestone or chore spec (specs/milestones/ or specs/chores/) — nothing carries a verified: pin"

for spec in "${specs[@]}"; do
  line="$(git show "$HEAD_REF:$spec" 2>/dev/null | grep -m1 '^verified:' || true)"
  [ -z "$line" ] && fail "$spec has no 'verified:' line"

  case "$line" in
    *pending*|*unverified*|*"to be verified"*)
      fail "$spec verified: line carries a pending/unverified caveat — a pin is never written while a check is pending: $line" ;;
  esac

  sha="$(printf '%s\n' "$line" | sed -nE 's/.* at ([0-9a-f]{7,40}),.*/\1/p')"
  [ -z "$sha" ] && fail "$spec verified: line has no parseable pinned <short-sha>: $line"

  git merge-base --is-ancestor "$sha" "$HEAD_REF" 2>/dev/null \
    || fail "$spec pinned sha $sha is not an ancestor of $HEAD_REF — the record describes a different commit"

  drift=()
  while IFS= read -r f; do
    [ -n "$f" ] && { is_plan_path "$f" || drift+=("$f"); }
  done < <(git diff --name-only "$sha" "$HEAD_REF")
  [ ${#drift[@]} -ne 0 ] && \
    fail "$spec — code changed after the pin ($sha); verified code != merged code: ${drift[*]}"

  echo "verified-pin: OK — $spec pinned at $sha, no code drift"
done

echo "verified-pin: PASS"

#!/usr/bin/env bash
#
# check-verified-pin.sh — keel's verified-pin gate.
#
# Enforces "verified code == merged code" on a milestone CODE PR: the milestone's
# spec file must carry a `verified:` line whose pinned <short-sha> is an ancestor of
# HEAD, and between that SHA and HEAD only PLAN files (specs/**, design/**) may have
# changed. A wholly PLAN-ONLY PR (the upfront feature plan PR) is EXEMPT.
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

is_plan_path() { case "$1" in specs/*|design/*) return 0 ;; *) return 1 ;; esac; }
fail() { echo "verified-pin: FAIL — $1" >&2; exit 1; }

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
  echo "verified-pin: plan-only PR (specs/** + design/** only) — exempt, pass"
  exit 0
fi

# 3. Code PR: every milestone spec it touches must carry a valid, drift-free pin.
specs=()
for f in "${changed[@]}"; do
  case "$f" in specs/milestones/*.md) specs+=("$f") ;; esac
done
[ ${#specs[@]} -eq 0 ] && \
  fail "code PR touches no milestone spec under specs/milestones/ — nothing carries a verified: pin"

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

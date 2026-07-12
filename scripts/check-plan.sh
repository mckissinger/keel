#!/usr/bin/env bash
#
# check-plan.sh — keel's plan lint: the structural half of the pre-plan-PR gate.
#
# Plan-only PRs are exempt from the verified-pin gate, so a malformed plan (an
# untagged done-condition, a [runtime] condition naming no committed test, a
# fidelity condition with no reference, a missing verification section) would
# otherwise sail through CI and be discovered a full build+verify cycle later.
# This lint mechanizes the STRUCTURAL rules; the judgment half is the pre-PR
# adversarial verifier pass (references/milestones-and-verification.md §5).
#
# Per specs/milestones/*.md it asserts:
#   - a verification section exists (a `## verification` heading, any case, or a
#     line starting `verification:`);
#   - a Done-conditions section exists, and every top-level dash bullet in it
#     (`- [...] ...` — the house done-condition style) carries exactly one of
#     [auto] / [runtime] / [attended];
#   - every [runtime] condition names its committed test — a presence heuristic
#     (a path-like token or "test"/"suite"/"walk" in the bullet), not semantics;
#   - a spec whose conditions mention fidelity names a reference (workbench /
#     mockup / gallery / reference / design-path token somewhere in the spec).
# Per specs/chores/*.md (punch-list batch specs): pin-line SHAPE only — if a
# `verified:` line exists it must carry a parseable ` at <short-sha>,` and no
# pending/unverified caveat. No line is fine (the pin lands in the code PR).
#
# Conservative by design: structure fails, judgment doesn't. The numbered legacy
# condition style (`1. **[auto] ...**`, pre-dash-bullet era) is grandfathered —
# only dash bullets are tag-checked. Empty or missing spec dirs pass
# (bootstrap-compatible: the lint can be wired before the first spec exists).
#
# This is the canonical implementation. spec-foundation copies it into a project
# and wires it as a CI job; it is never re-authored from prose.
#
# Usage: scripts/check-plan.sh [ROOT]     (ROOT defaults to the repo root)
# Exit 0 = clean. Non-zero = a malformed spec, with the reason on stderr.

set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

fails=0
fail() { echo "check-plan: FAIL — $1" >&2; fails=$((fails + 1)); }

shopt -s nullglob
milestones=(specs/milestones/*.md)
chores=(specs/chores/*.md)
shopt -u nullglob
# Loops expand via ${arr[@]+...} — an empty array under `set -u` is an unbound
# variable on bash 3.2 (macOS), and one dir may legitimately be empty.

if [ ${#milestones[@]} -eq 0 ] && [ ${#chores[@]} -eq 0 ]; then
  echo "check-plan: no specs under specs/milestones or specs/chores — pass (bootstrap window)"
  exit 0
fi

# Extract the Done-conditions section: lines after a `#+ Done-condition...`
# heading, up to the next heading of the same or shallower level (deeper `###`
# subsections like "Logic / invariants" stay inside the region).
done_region() { # <file>
  awk '
    /^#/ {
      n = 0; while (substr($0, n + 1, 1) == "#") n++
      if (inr && n <= lvl) inr = 0
      if (tolower($0) ~ /^#+[[:space:]]+done-condition/) { inr = 1; lvl = n; next }
    }
    inr { print }
  ' "$1"
}

for spec in ${milestones[@]+"${milestones[@]}"}; do
  # 1. A verification section exists.
  if ! grep -qE '^#{1,6}[[:space:]]+[Vv]erification([[:space:]]|$)|^verification:' "$spec"; then
    fail "$spec — no verification section (\`## verification\` heading or \`verification:\` line)"
  fi

  region="$(done_region "$spec")"
  if [ -z "$region" ]; then
    fail "$spec — no Done-conditions section found"
    continue
  fi

  # 2. Every top-level dash bullet carries exactly one tag.
  untagged="$(printf '%s\n' "$region" | grep -E '^- ' | grep -vE '^- \[(auto|runtime|attended)\] ' || true)"
  if [ -n "$untagged" ]; then
    fail "$spec — done-condition bullet(s) without exactly one [auto]/[runtime]/[attended] tag:"
    printf '%s\n' "$untagged" | sed 's/^/  /' >&2
  fi
  doubled="$(printf '%s\n' "$region" | grep -E '^- \[(auto|runtime|attended)\][[:space:]]*\[(auto|runtime|attended)\]' || true)"
  if [ -n "$doubled" ]; then
    fail "$spec — done-condition bullet(s) carrying more than one tag:"
    printf '%s\n' "$doubled" | sed 's/^/  /' >&2
  fi

  # 3. Every [runtime] bullet names a committed test (presence heuristic:
  #    a path-like token, or test/suite/walk naming where the deterministic
  #    core lives). Continuation lines (indented) belong to the bullet.
  while IFS= read -r bullet; do
    [ -z "$bullet" ] && continue
    if ! printf '%s\n' "$bullet" | grep -qiE '[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+|test|suite|walk'; then
      fail "$spec — [runtime] condition names no committed test (no path-like token or test/suite/walk): ${bullet:0:120}"
    fi
  done < <(printf '%s\n' "$region" | awk '
    function flush() { if (buf != "") print buf; buf = "" }
    /^- /            { flush(); if ($0 ~ /^- \[runtime\]/) buf = $0; next }
    /^[[:space:]]/   { if (buf != "") { sub(/^[[:space:]]+/, ""); buf = buf " " $0 }; next }
                     { flush() }
    END              { flush() }
  ')

  # 4. Fidelity-mentioning conditions → the spec names a reference.
  if printf '%s\n' "$region" | grep -qi 'fidelity'; then
    if ! grep -qiE 'workbench|mockup|gallery|reference|design/' "$spec"; then
      fail "$spec — conditions mention fidelity but the spec names no reference (workbench / mockup / gallery / reference / design path)"
    fi
  fi
done

# Chore batch specs: pin-line shape only.
for spec in ${chores[@]+"${chores[@]}"}; do
  line="$(grep -m1 '^verified:' "$spec" || true)"
  [ -z "$line" ] && continue
  # Caveat scan + SHA extraction are IDENTICAL to check-verified-pin.sh's — the two
  # shipped scripts must never disagree about one line. Whole line minus backticked
  # spans; first ' at <hex>,' occurrence, never the last.
  scrubbed="$(printf '%s\n' "$line" | sed 's/`[^`]*`//g')"
  case "$scrubbed" in
    *pending*|*unverified*|*"to be verified"*)
      fail "$spec — verified: line carries a pending/unverified caveat (a domain term that merely contains a caveat word must be backticked, e.g. \`pending-leads\`): $line"
      continue ;;
  esac
  sha="$(printf '%s\n' "$line" | grep -oE ' at [0-9a-f]{7,40},' | head -n1 | sed -E 's/ at ([0-9a-f]+),/\1/' || true)"
  if [ -z "$sha" ]; then
    fail "$spec — verified: line has no parseable ' at <short-sha>,': $line"
  fi
done

if [ "$fails" -eq 0 ]; then
  echo "check-plan: PASS — ${#milestones[@]} milestone spec(s), ${#chores[@]} chore spec(s) well-formed"
  exit 0
fi
echo "check-plan: $fails malformed spec finding(s)" >&2
exit 1

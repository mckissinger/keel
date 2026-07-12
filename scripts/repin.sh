#!/usr/bin/env bash
#
# repin.sh — keel's canonical re-pin mechanizer: rewrite a milestone spec's
# `verified:` pin to the current code tip with a carry-forward clause, commit it
# as its own plan-only commit, and assert the result parses back.
#
# When a conflict-only rebase (the land-feature cascade, the diamond finish, the
# spec-foundation rebase rule) moves a verified branch's code tip, the pin is
# self-invalidating: it names a SHA that is no longer the tip. The process rule
# is: re-run the suite green, then re-pin with a carry-forward note. This script
# mechanizes the SECOND half only — the edit + plan-only commit + postcondition
# assertions. RE-RUNNING THE SUITES GREEN FIRST IS THE CALLER'S JOB: this script
# invokes no test command, and running it never substitutes for the green re-run.
# (Hand-editing the line and amending has repeatedly raced itself — a stale amend
# that never landed the edit; hence a script with postconditions.)
#
# What it does:
#   1. Refuses a dirty working tree (the pin commit must be plan-only, and the
#      current HEAD must be the exact code tip being pinned).
#   2. Refuses a spec with no `verified:` line (a first pin is written by
#      verify-milestone on a passing verdict — never by this script).
#   3. Rewrites the pin line to
#        verified: <verdict> at <new-sha>, <today>, via <method> (<evidence>) — carried forward from <old-sha>[: <note>]
#      where <new-sha> is the pre-commit short HEAD, REPLACING any prior
#      "— carried forward from ..." clause (the chain lives in git history,
#      never accumulated on the line).
#   4. Commits the spec edit as its own plan-only commit.
#   5. Asserts before exiting 0: `git rev-parse --short HEAD^` equals the new
#      pinned SHA; the pin gate's own first-match extraction parses the
#      committed line to that SHA; and the working tree is clean. Any failed
#      postcondition exits non-zero naming the failure.
#
# This is the canonical implementation. spec-foundation / adopt copy it into a
# project alongside the pin-gate scripts; it is never re-authored from prose.
#
# Usage: scripts/repin.sh <milestone-spec> [note]
# Exit 0 = re-pinned. Non-zero = refused, or a postcondition failed, with the
# reason on stderr.

set -euo pipefail

fail() { echo "repin: FAIL — $1" >&2; exit 1; }

SPEC="${1:-}"
NOTE="${2:-}"
[ -n "$SPEC" ] || fail "usage: repin.sh <milestone-spec> [note]"
[ -f "$SPEC" ] || fail "spec '$SPEC' does not exist"

# 1. Refuse a dirty tree — the pin commit must contain the pin edit and nothing
#    else, and HEAD must be exactly the code state the new pin describes.
[ -z "$(git status --porcelain)" ] \
  || fail "working tree is dirty — the re-pin must be its own plan-only commit on the exact tip it pins; commit or stash first"

# 2. Refuse a spec with no pin — re-pin carries a verdict forward, never invents one.
line="$(grep -m1 '^verified:' "$SPEC" || true)"
[ -n "$line" ] || fail "$SPEC has no 'verified:' line to carry forward — a first pin is written by verify-milestone, not repin"

# 3. Parse the existing line. Strip any prior carry-forward clause first (a repeated
#    re-pin REPLACES it), then take the FIRST ' at <hex>,' occurrence — the identical
#    extraction the pin gate (check-verified-pin.sh) uses.
stripped="${line%% — carried forward from *}"
old_sha="$(printf '%s\n' "$stripped" | grep -oE ' at [0-9a-f]{7,40},' | head -n1 | sed -E 's/ at ([0-9a-f]+),/\1/' || true)"
[ -n "$old_sha" ] || fail "$SPEC verified: line has no parseable ' at <short-sha>,': $line"

prefix="${stripped%% at $old_sha,*}"   # 'verified: <verdict>'
verdict="${prefix#verified: }"
rest="${stripped#* at $old_sha, }"     # '<date>, via <method> (<evidence>)'
tail_part="${rest#*, }"                # 'via <method> (<evidence>)'

new_sha="$(git rev-parse --short HEAD)"
today="$(date +%Y-%m-%d)"
newline="verified: $verdict at $new_sha, $today, $tail_part — carried forward from $old_sha"
if [ -n "$NOTE" ]; then
  newline="$newline: $NOTE"
fi

# Repo-relative path (for the committed-state read below), resolved while tracked.
rel="$(git ls-files --full-name -- "$SPEC")"
[ -n "$rel" ] || fail "$SPEC is not tracked by git"

# Rewrite the first verified: line in place (ENVIRON, not -v: no escape mangling).
tmp="$(mktemp)"
NEWLINE="$newline" awk '
  !done && /^verified:/ { print ENVIRON["NEWLINE"]; done = 1; next }
  { print }
' "$SPEC" > "$tmp"
mv "$tmp" "$SPEC"

# 4. Commit the spec edit as its own plan-only commit.
slug="$(basename "$SPEC" .md)"
git add -- "$SPEC"
git commit -q -m "re-pin($slug): carry forward to $new_sha"

# 5. Postconditions — any failure exits non-zero naming it.
head_parent="$(git rev-parse --short HEAD^)"
[ "$head_parent" = "$new_sha" ] \
  || fail "postcondition failed: HEAD^ ($head_parent) is not the new pinned sha ($new_sha)"

committed_line="$(git show "HEAD:$rel" | grep -m1 '^verified:' || true)"
committed_sha="$(printf '%s\n' "$committed_line" | grep -oE ' at [0-9a-f]{7,40},' | head -n1 | sed -E 's/ at ([0-9a-f]+),/\1/' || true)"
[ "$committed_sha" = "$new_sha" ] \
  || fail "postcondition failed: the gate's extraction parses the committed line to '${committed_sha:-<nothing>}', not $new_sha: $committed_line"

[ -z "$(git status --porcelain)" ] \
  || fail "postcondition failed: working tree is not clean after the pin commit"

echo "repin: OK — $SPEC re-pinned at $new_sha (carried forward from $old_sha)"

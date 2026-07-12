#!/usr/bin/env bash
#
# Self-test for repin.sh. Builds throwaway git repos in a temp dir, exercises each
# refusal, the rewrite, and the postconditions, and asserts exit codes + line shape.
# No network, no fixtures.
#
# Run: bash scripts/repin.test.sh

set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/repin.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0 failc=0
ok()  { echo "ok   - $1"; pass=$((pass+1)); }
bad() { echo "FAIL - $1"; failc=$((failc+1)); }

mkrepo() { # <name> — fresh repo, m1 spec pinned at its code commit; sets OLD
  local d="$TMP/$1"
  mkdir -p "$d"; cd "$d"
  git init -q -b main
  git config user.email t@example.com
  git config user.name tester
  mkdir -p specs/milestones src
  echo "code" > src/a.ts
  echo "# m1" > specs/milestones/m1.md
  git add -A && git commit -qm "m1 code"
  OLD="$(git rev-parse --short HEAD)"
  printf 'verified: clean at %s, 2026-07-01, via verifier (evidence in PR #1)\n' "$OLD" >> specs/milestones/m1.md
  git add -A && git commit -qm "verify(m1): record"
}

# 1. Happy path: the tip moved past the pin; repin rewrites the line, commits it
#    plan-only, and the postconditions hold.
mkrepo r1
echo "rebased" >> src/a.ts && git add -A && git commit -qm "rebase moved the tip"
TIP="$(git rev-parse --short HEAD)"
if bash "$SCRIPT" specs/milestones/m1.md "conflict-only rebase" >/dev/null 2>&1; then
  ok "happy path exits 0"
else
  bad "happy path exits 0"
fi
line="$(grep -m1 '^verified:' specs/milestones/m1.md)"
case "$line" in
  "verified: clean at $TIP, "*", via verifier (evidence in PR #1) — carried forward from $OLD: conflict-only rebase")
    ok "pin line rewritten to the new sha with the carry-forward clause + note" ;;
  *)
    bad "pin line rewritten to the new sha with the carry-forward clause + note (got: $line)" ;;
esac
if [ "$(git rev-parse --short HEAD^)" = "$TIP" ]; then
  ok "HEAD^ is the new pinned sha (pin commit sits on the exact tip)"
else
  bad "HEAD^ is the new pinned sha (pin commit sits on the exact tip)"
fi
if [ "$(git diff --name-only HEAD^ HEAD)" = "specs/milestones/m1.md" ]; then
  ok "pin commit is plan-only (touches only the spec)"
else
  bad "pin commit is plan-only (touches only the spec)"
fi

# 2. Repeated re-pin REPLACES the carry-forward clause — never accumulates.
echo "again" >> src/a.ts && git add -A && git commit -qm "tip moved again"
TIP2="$(git rev-parse --short HEAD)"
if bash "$SCRIPT" specs/milestones/m1.md >/dev/null 2>&1; then
  ok "repeated re-pin exits 0"
else
  bad "repeated re-pin exits 0"
fi
line="$(grep -m1 '^verified:' specs/milestones/m1.md)"
n="$(printf '%s\n' "$line" | grep -o 'carried forward from' | wc -l | tr -d ' ')"
if [ "$n" = "1" ]; then
  ok "repeated re-pin leaves exactly one carry-forward clause"
else
  bad "repeated re-pin leaves exactly one carry-forward clause (got $n: $line)"
fi
case "$line" in
  "verified: clean at $TIP2, "*"— carried forward from $TIP")
    ok "repeated re-pin carries forward from the PREVIOUS pin, note dropped with the old clause" ;;
  *)
    bad "repeated re-pin carries forward from the PREVIOUS pin (got: $line)" ;;
esac

# 3. Dirty working tree → refused, nothing committed.
mkrepo r3
before="$(git rev-parse HEAD)"
echo "uncommitted" >> src/a.ts
if bash "$SCRIPT" specs/milestones/m1.md >/dev/null 2>&1; then
  bad "dirty tree is refused"
else
  ok "dirty tree is refused"
fi
if [ "$(git rev-parse HEAD)" = "$before" ]; then
  ok "dirty-tree refusal commits nothing"
else
  bad "dirty-tree refusal commits nothing"
fi

# 4. Spec with no verified: line → refused.
mkrepo r4
echo "# m2 unpinned" > specs/milestones/m2.md
git add -A && git commit -qm "m2 spec, no pin"
out="$(bash "$SCRIPT" specs/milestones/m2.md 2>&1)" && got=0 || got=$?
if [ "$got" -ne 0 ]; then ok "spec without a verified: line is refused"; else bad "spec without a verified: line is refused"; fi
if printf '%s' "$out" | grep -q "no 'verified:' line"; then
  ok "missing-line refusal names the failure"
else
  bad "missing-line refusal names the failure (got: $out)"
fi

# 5. A failed postcondition exits non-zero naming the failure. A post-commit hook
#    drops an untracked file, so the tree-clean postcondition cannot hold.
mkrepo r5
echo "moved" >> src/a.ts && git add -A && git commit -qm "tip moved"
printf '#!/bin/sh\ntouch stray-postcommit-file\n' > .git/hooks/post-commit
chmod +x .git/hooks/post-commit
out="$(bash "$SCRIPT" specs/milestones/m1.md 2>&1)" && got=0 || got=$?
if [ "$got" -ne 0 ]; then ok "failed postcondition exits non-zero"; else bad "failed postcondition exits non-zero"; fi
if printf '%s' "$out" | grep -q "postcondition failed"; then
  ok "postcondition failure names itself"
else
  bad "postcondition failure names itself (got: $out)"
fi

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]

#!/usr/bin/env bash
#
# Self-test for check-verified-pin.sh. Builds throwaway git repos in a temp dir,
# simulates each PR shape, and asserts the gate's exit code. No network, no fixtures.
#
# Run: bash scripts/check-verified-pin.test.sh

set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-verified-pin.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

git init -q -b main
git config user.email t@example.com
git config user.name tester
mkdir -p specs/milestones src
echo "# product" > specs/00-product.md
git add -A && git commit -qm base
BASE="$(git rev-parse HEAD)"

pass=0 failc=0
check() { # desc  expected_exit
  local desc="$1" exp="$2" got
  BASE_REF="$BASE" bash "$SCRIPT" HEAD >/dev/null 2>&1 && got=0 || got=$?
  if [ "$got" -eq "$exp" ]; then
    echo "ok   - $desc"; pass=$((pass+1))
  else
    echo "FAIL - $desc (got exit $got, want $exp)"; failc=$((failc+1))
  fi
}
fresh() { git checkout -q -b "$1" "$BASE"; mkdir -p src specs/milestones; }

# 1. Plan-only PR → exempt.
fresh c1-plan-only
echo "more" >> specs/00-product.md
git add -A && git commit -qm "plan only"
check "plan-only PR is exempt" 0

# 2. Code PR with a valid, drift-free pin → pass.
fresh c2-valid
echo "code" > src/feature.ts
echo "# m1" > specs/milestones/m1.md
git add -A && git commit -qm "m1 code"
sha="$(git rev-parse --short HEAD)"
printf 'verified: clean at %s, 2026-06-29, via verifier (evidence in PR #2)\n' "$sha" >> specs/milestones/m1.md
git add -A && git commit -qm "verify(m1): record"
check "valid pin passes" 0

# 3. Code PR whose milestone spec has no verified: line → fail.
fresh c3-no-pin
echo "code" > src/x.ts
echo "# m2 unpinned" > specs/milestones/m2.md
git add -A && git commit -qm "m2 code, no pin"
check "code PR without a verified: line fails" 1

# 4. Code PR with code but no milestone spec at all → fail.
fresh c4-no-spec
echo "code" > src/orphan.ts
git add -A && git commit -qm "code with no milestone spec"
check "code PR touching no milestone spec fails" 1

# 5. Pinned sha not an ancestor → fail.
fresh c5-bad-sha
echo "code" > src/y.ts
echo "# m3" > specs/milestones/m3.md
printf 'verified: clean at deadbee, 2026-06-29, via verifier (evidence in PR #5)\n' >> specs/milestones/m3.md
git add -A && git commit -qm "m3 bogus pin"
check "non-ancestor pinned sha fails" 1

# 6. Code drift after the pin → fail.
fresh c6-drift
echo "code" > src/z.ts
echo "# m4" > specs/milestones/m4.md
git add -A && git commit -qm "m4 code"
sha="$(git rev-parse --short HEAD)"
printf 'verified: clean at %s, 2026-06-29, via verifier (evidence in PR #6)\n' "$sha" >> specs/milestones/m4.md
git add -A && git commit -qm "verify(m4): record"
echo "sneaky" >> src/z.ts
git add -A && git commit -qm "extra code after pin"
check "code drift after pin fails" 1

# 7. Pending caveat in the verified: line → fail.
fresh c7-pending
echo "code" > src/p.ts
echo "# m5" > specs/milestones/m5.md
sha="$(git rev-parse --short HEAD)"
printf 'verified: clean at %s, 2026-06-29, via verifier — pending the runtime walk\n' "$sha" >> specs/milestones/m5.md
git add -A && git commit -qm "m5 pending pin"
check "pending caveat fails" 1

# 8. Chore batch: code PR with a specs/chores/<slug>.md batch pin → pass.
fresh c8-chore
mkdir -p specs/chores
echo "fix1" > src/a.ts
echo "fix2" > src/b.ts
echo "# chore batch 2026-06-29" > specs/chores/2026-06-29.md
git add -A && git commit -qm "chore: two small fixes"
sha="$(git rev-parse --short HEAD)"
printf 'verified: clean at %s, 2026-06-29, via punch-list (evidence in PR #8)\n' "$sha" >> specs/chores/2026-06-29.md
git add -A && git commit -qm "verify(chore): batch record"
check "chore batch with a valid batch pin passes" 0

# 9. Chore batch with no verified: line → fail.
fresh c9-chore-nopin
mkdir -p specs/chores
echo "fix" > src/c.ts
echo "# chore batch, unpinned" > specs/chores/unpinned.md
git add -A && git commit -qm "chore: unpinned"
check "chore batch without a pin fails" 1

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]

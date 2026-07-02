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
# BASE has no milestone/chore spec → PRs off it sit in the BOOTSTRAP WINDOW unless they
# add one themselves. BASE2 has a landed milestone spec → the window is closed.
git checkout -qb base2
echo "# m0" > specs/milestones/m0.md
printf 'verified: clean at %s, 2026-06-29, via verifier (evidence in PR #0)\n' "$(git rev-parse --short HEAD)" >> specs/milestones/m0.md
git add -A && git commit -qm "first milestone landed (window closed)"
BASE2="$(git rev-parse HEAD)"

pass=0 failc=0
check() { # desc  expected_exit  [base_ref]
  local desc="$1" exp="$2" base="${3:-$BASE}" got
  BASE_REF="$base" bash "$SCRIPT" HEAD >/dev/null 2>&1 && got=0 || got=$?
  if [ "$got" -eq "$exp" ]; then
    echo "ok   - $desc"; pass=$((pass+1))
  else
    echo "FAIL - $desc (got exit $got, want $exp)"; failc=$((failc+1))
  fi
}
check_msg() { # desc  expected_substring  [base_ref]
  local desc="$1" want="$2" base="${3:-$BASE}" out
  out="$(BASE_REF="$base" bash "$SCRIPT" HEAD 2>&1)" || true
  if printf '%s' "$out" | grep -q "$want"; then
    echo "ok   - $desc"; pass=$((pass+1))
  else
    echo "FAIL - $desc (output lacked \"$want\")"; failc=$((failc+1))
  fi
}
fresh() { git checkout -q -b "$1" "${2:-$BASE}"; mkdir -p src specs/milestones; }

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
#    (Off BASE2: post-bootstrap. Off BASE this shape is the scaffold PR and legitimately
#    passes via the bootstrap window — see case 11.)
fresh c4-no-spec "$BASE2"
echo "code" > src/orphan.ts
git add -A && git commit -qm "code with no milestone spec"
check "code PR touching no milestone spec fails (window closed)" 1 "$BASE2"

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

# 10. Bootstrap window: foundation-shaped PR (specs + CI + gate script + CLAUDE.md), no
#     milestone/chore spec at either end → exempt, with the explicit window message.
fresh c10-foundation
mkdir -p .github/workflows scripts
echo "more" >> specs/00-product.md
echo "jobs: {}" > .github/workflows/ci.yml
echo "#!/bin/sh" > scripts/check-verified-pin.sh
echo "# project instructions" > CLAUDE.md
git add -A && git commit -qm "foundation: specs + CI + gate + CLAUDE.md"
check "foundation PR passes via the bootstrap window" 0
check_msg "bootstrap window pass names itself" "bootstrap window"

# 11. Bootstrap window: pure-code PR (the scaffold shape) before any milestone → exempt.
fresh c11-scaffold
echo "code" > src/scaffold.ts
git add -A && git commit -qm "scaffold, pre-first-milestone"
check "pre-first-milestone code PR passes via the bootstrap window" 0

# 12. Deletion-proof: base has a milestone spec; head deletes it and adds code → still fails
#     (the window never reopens).
fresh c12-delete "$BASE2"
git rm -q specs/milestones/m0.md
echo "code" > src/sneak.ts
git add -A && git commit -qm "delete the only milestone spec + add code"
check "deleting milestone specs does not reopen the window" 1 "$BASE2"

# 13. Root-proof (the security-review attack): repo is PAST bootstrap (base tip = BASE2,
#     which has m0.md), but the attacker roots their branch at the pre-spec BASE commit so
#     the merge-base predates the first spec. The window must NOT reopen — judged at the
#     base TIP, not the merge-base.
fresh c13-prespec-root "$BASE"
echo "evil" > src/evil.ts
git add -A && git commit -qm "unverified code on a pre-first-spec root"
check "pre-spec branch root does not re-enter the window post-bootstrap" 1 "$BASE2"

# 14. Unusual spec filenames still close the window (git path-quoting must not hide them).
fresh c14-quoted-spec
echo "code" > src/q.ts
echo "# spec with non-ascii name" > "specs/milestones/café.md"
git add -A && git commit -qm "code + non-ascii-named milestone spec, no pin"
check "non-ascii-named spec closes the window (fails without a pin)" 1

# 15/16. Fail closed on unresolvable refs: a misconfigured CI must never read as
#        "no changes — pass".
fresh c15-bad-base
echo "code" > src/r.ts
git add -A && git commit -qm "any change"
check "unresolvable BASE_REF fails closed" 1 "no-such-ref"
got=0; BASE_REF="$BASE" bash "$SCRIPT" no-such-head >/dev/null 2>&1 || got=$?
if [ "$got" -ne 0 ]; then echo "ok   - unresolvable HEAD_REF fails closed"; pass=$((pass+1));
else echo "FAIL - unresolvable HEAD_REF fails closed (got exit 0)"; failc=$((failc+1)); fi

# HEAD-side closure of the window (a PR that itself adds the first milestone spec is
# validated normally, never exempted) is covered by cases 2 (with pin → pass) and
# 3 (without pin → fail); chore specs closing the window by case 9.

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]

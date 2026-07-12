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

# 17. decisions/**-only PR is plan-only exempt (off BASE2, window closed — off BASE it would
#      pass via the bootstrap window, making the test vacuous).
fresh cX-decisions-only "$BASE2"
mkdir -p decisions
echo x >> decisions/2026-01-note.md
git add -A && git commit -qm 'decisions only'
check "decisions-only PR is plan-only exempt" 0 "$BASE2"

# 18. deferrals/**-only PR is plan-only exempt. Repo-root deferrals/ exercises the new
#      deferrals/* arm (keel's real deferrals live at specs/deferrals/, already covered by specs/*).
fresh cX-deferrals-only "$BASE2"
mkdir -p deferrals
echo x >> deferrals/foo.md
git add -A && git commit -qm 'deferrals only'
check "deferrals-only PR is plan-only exempt" 0 "$BASE2"

# 19. Merge-base precondition (the 2026-07-05 review's live repro): both refs resolvable
#     but sharing NO merge base — an orphan-history branch carrying code + an UNPINNED
#     milestone spec. Was: the three-dot diff failed inside the process substitution,
#     read as empty, and the gate passed open ("no changes — pass"). Now: fail closed,
#     naming both refs and the shallow-clone/unrelated-histories cause.
git checkout -q --orphan c19-orphan
git rm -rfq . >/dev/null 2>&1 || true
mkdir -p src specs/milestones
echo "code" > src/orphan.ts
echo "# m-orphan, unpinned" > specs/milestones/m-orphan.md
git add -A && git commit -qm "orphan history: code + unpinned milestone spec"
check "orphan-history PR (no merge base) fails closed (was: passed open)" 1 "$BASE2"
check_msg "no-merge-base failure names both refs" "no merge base between BASE_REF '$BASE2' and HEAD_REF 'HEAD'" "$BASE2"
check_msg "no-merge-base failure names the shallow-clone/unrelated-histories cause" "shallow clone" "$BASE2"
check_msg "no-merge-base failure names the fix (full fetch)" "fetch-depth: 0" "$BASE2"

# 20/21. Runtime-affecting spec files are code, not plan: a PR touching only
#        specs/stack-profile.md or specs/run-command-inventory.txt is NOT plan-exempt —
#        the gate proceeds to the pin requirement (and fails here, no spec pinned).
fresh c20-stack-profile "$BASE2"
echo "run: npm test" > specs/stack-profile.md
git add -A && git commit -qm "stack profile only"
check "stack-profile-only PR is not plan-exempt (proceeds to the pin requirement)" 1 "$BASE2"
fresh c21-inventory "$BASE2"
echo "npm test" > specs/run-command-inventory.txt
git add -A && git commit -qm "run-command inventory only"
check "run-command-inventory-only PR is not plan-exempt (proceeds to the pin requirement)" 1 "$BASE2"

# 22. A post-pin edit to a runtime-affecting spec file lands in the DRIFT set → fail.
fresh c22-profile-drift "$BASE2"
echo "code" > src/w.ts
echo "# m22" > specs/milestones/m22.md
git add -A && git commit -qm "m22 code"
sha="$(git rev-parse --short HEAD)"
printf 'verified: clean at %s, 2026-07-05, via verifier (evidence in PR #22)\n' "$sha" >> specs/milestones/m22.md
git add -A && git commit -qm "verify(m22): record"
echo "post-pin profile edit" > specs/stack-profile.md
git add -A && git commit -qm "edit stack profile after the pin"
check "post-pin edit to stack-profile.md is drift → fail" 1 "$BASE2"

# 23. Positive control: a stack-profile change riding a properly pinned milestone passes —
#     the carve-out makes the file code, not unmergeable.
fresh c23-profile-pinned "$BASE2"
echo "profile" > specs/stack-profile.md
echo "# m23" > specs/milestones/m23.md
git add -A && git commit -qm "m23: profile change"
sha="$(git rev-parse --short HEAD)"
printf 'verified: clean at %s, 2026-07-05, via verifier (evidence in PR #23)\n' "$sha" >> specs/milestones/m23.md
git add -A && git commit -qm "verify(m23): record"
check "stack-profile change with a valid pin passes (treated exactly as code)" 0 "$BASE2"

# 24. Backtick escape: a caveat word inside a backticked domain term must NOT trip the
#     caveat scan (the scan is whole-line minus backticked spans).
fresh c24-backtick-pending
echo "code" > src/bt.ts
echo "# m24" > specs/milestones/m24.md
git add -A && git commit -qm "m24 code"
sha="$(git rev-parse --short HEAD)"
printf 'verified: clean at %s, 2026-07-12, via e2e over the `pending-leads` suite (evidence in PR #24)\n' "$sha" >> specs/milestones/m24.md
git add -A && git commit -qm "verify(m24): record"
check "backticked domain term containing a caveat word passes" 0

# 25. A bare trailing caveat still fails (case 7 keeps the original anti-pattern line
#     byte-identical; this one asserts the failure message teaches the backtick escape).
fresh c25-bare-caveat
echo "code" > src/bc.ts
echo "# m25" > specs/milestones/m25.md
sha="$(git rev-parse --short HEAD)"
printf 'verified: clean at %s, 2026-07-12, via verifier — pending the runtime walk\n' "$sha" >> specs/milestones/m25.md
git add -A && git commit -qm "m25 bare caveat pin"
check "bare trailing caveat still fails" 1
check_msg "caveat failure teaches the backtick escape" "must be backticked"

# 26. First-match SHA parse: a carry-forward clause mentioning a second SHA in the
#     ' at <hex>,' shape later on the line must NOT outrank the real pin (the old
#     greedy sed took the LAST match → 'deadbee' → non-ancestor → false fail).
fresh c26-carry-forward
echo "code" > src/cf.ts
echo "# m26" > specs/milestones/m26.md
git add -A && git commit -qm "m26 code"
sha="$(git rev-parse --short HEAD)"
printf 'verified: clean at %s, 2026-07-12, via verifier (evidence in PR #26) — carried forward from deadbee: previously at deadbee, 2026-07-01\n' "$sha" >> specs/milestones/m26.md
git add -A && git commit -qm "verify(m26): record"
check "carry-forward second SHA parses to the first (pin stays valid)" 0

# 27. No ' at <sha>,' shape at all still fails with the no-parseable-sha message.
fresh c27-no-sha
echo "code" > src/ns.ts
echo "# m27" > specs/milestones/m27.md
printf 'verified: clean, trust me\n' >> specs/milestones/m27.md
git add -A && git commit -qm "m27 shapeless pin"
check "no-parseable-sha line still fails" 1
check_msg "no-parseable-sha failure keeps its message" "no parseable pinned"

# 28. Best-effort base-ref freshness: BASE_REF=origin/<branch> is fetched from origin
#     before the diff. Stale local origin/main (rewound to A below) used to make the
#     three-dot diff span the already-merged sibling mb and report FALSE drift on it;
#     the refreshed ref diffs only the PR's own milestone → pass.
R="$TMP/remote28"; L="$TMP/local28"
git init -q --bare "$R"
git clone -q "file://$R" "$L" 2>/dev/null
cd "$L"
git config user.email t@example.com
git config user.name tester
git checkout -qb main
mkdir -p specs/milestones src
echo "# product" > specs/00-product.md
echo "# m0" > specs/milestones/m0.md
git add -A && git commit -qm base
printf 'verified: clean at %s, 2026-07-12, via verifier (evidence in PR #0)\n' "$(git rev-parse --short HEAD)" >> specs/milestones/m0.md
git add -A && git commit -qm "m0 pin (window closed)"
A28="$(git rev-parse HEAD)"
echo "b" > src/b.ts
echo "# mb" > specs/milestones/mb.md
git add -A && git commit -qm "mb code (sibling, merged on main)"
shb="$(git rev-parse --short HEAD)"
printf 'verified: clean at %s, 2026-07-12, via verifier (evidence in PR #1)\n' "$shb" >> specs/milestones/mb.md
git add -A && git commit -qm "mb pin"
git push -q origin main
git checkout -qb mc
echo "c" > src/c.ts
echo "# mc" > specs/milestones/mc.md
git add -A && git commit -qm "mc code"
shc="$(git rev-parse --short HEAD)"
printf 'verified: clean at %s, 2026-07-12, via verifier (evidence in PR #2)\n' "$shc" >> specs/milestones/mc.md
git add -A && git commit -qm "mc pin"
git update-ref refs/remotes/origin/main "$A28"   # simulate the stale remote-tracking ref
check "stale origin/main is refreshed via fetch — no false drift on the merged sibling" 0 origin/main

# 29. Remote deleted: the fetch fails → WARN on stderr, proceed with the local ref.
#     The retained ref is re-staled to A, so proceeding means the stale diff runs (and
#     fails on the sibling's false drift) — proving the gate went past the fetch rather
#     than hard-failing on it, and that case 28's pass came from the refresh.
rm -rf "$R"
git update-ref refs/remotes/origin/main "$A28"
check "deleted remote proceeds with the local (stale) ref — the fetch is never a hard failure" 1 origin/main
check_msg "deleted remote warns on stderr and names the fallback" "proceeding with the local ref" origin/main
cd "$TMP"

# HEAD-side closure of the window (a PR that itself adds the first milestone spec is
# validated normally, never exempted) is covered by cases 2 (with pin → pass) and
# 3 (without pin → fail); chore specs closing the window by case 9.

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]

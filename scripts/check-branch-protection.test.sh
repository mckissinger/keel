#!/usr/bin/env bash
#
# Self-test for check-branch-protection.sh — the extracted, shared (b)+(b2)+(d)
# assertion. Builds throwaway fixtures, stubs `gh` on PATH (no network), and
# asserts the gate's exit code and named gaps. Also proves the extraction is the
# MERGE-relevant subset only: it passes with NO run-command-inventory.txt and NO
# 01-architecture.md present (checks a/a2/c are deliberately excluded — a repo
# arming auto-merge need not carry those auto-run-only inputs).
#
# Run: bash scripts/check-branch-protection.test.sh

set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-branch-protection.sh"
REAL_BASH="$(command -v bash)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0 failc=0
ok()  { echo "ok   - $1"; pass=$((pass + 1)); }
bad() { echo "FAIL - $1"; failc=$((failc + 1)); }

# gh stub, modelling the three calls the gate makes:
#   `gh repo view --json defaultBranchRef --jq …` → the SERVER default branch name
#      (${GH_DEFAULT_BRANCH:-main}); this is the source-of-truth resolution the fix
#      uses instead of the agent-repointable local origin/HEAD.
#   `gh api …/branches/<db>/protection` → $GH_PROT_FILE, but ONLY when <db> is the
#      server default branch — a protection query for any OTHER branch 404s, so a
#      test can prove the query targets the server-resolved branch, not a decoy.
#   any other `gh api` (the repos/{owner}/{repo} lookup, check d) → $GH_REPO_FILE.
mkdir -p "$TMP/bin"
cat > "$TMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
db="${GH_DEFAULT_BRANCH:-main}"
case "$*" in
  *"repo view"*)
    printf '%s\n' "$db" ;;
  *"branches/$db/protection"*)
    if [ -n "${GH_PROT_FILE:-}" ] && [ -f "$GH_PROT_FILE" ]; then cat "$GH_PROT_FILE"; exit 0; fi
    echo "gh: Branch not protected (HTTP 404)" >&2; exit 1 ;;
  *protection*)
    echo "gh: Branch not protected (HTTP 404)" >&2; exit 1 ;;
  *)
    if [ -n "${GH_REPO_FILE:-}" ] && [ -f "$GH_REPO_FILE" ]; then cat "$GH_REPO_FILE"; exit 0; fi
    echo "gh: Not Found (HTTP 404)" >&2; exit 1 ;;
esac
EOF
chmod +x "$TMP/bin/gh"

printf '{"allow_auto_merge":true}\n'  > "$TMP/repo-aam-true.json"
printf '{"allow_auto_merge":false}\n' > "$TMP/repo-aam-false.json"
cat > "$TMP/protection-full.json" <<'EOF'
{"required_status_checks":{"contexts":["verified-pin","plan-lint","security-review"]}}
EOF
# security-review present as a CI job but NOT in the required set.
cat > "$TMP/protection-partial.json" <<'EOF'
{"required_status_checks":{"contexts":["verified-pin","plan-lint"],"checks":[{"context":"verified-pin"},{"context":"plan-lint"}]}}
EOF

make_proj() { # <name> → PROJ with a b2-satisfying workflow and NOTHING ELSE
  # (no settings.json / inventory / architecture — proving a/a2/c are excluded).
  PROJ="$TMP/$1"
  mkdir -p "$PROJ/.github/workflows"
  cat > "$PROJ/.github/workflows/ci.yml" <<'EOF'
on:
  pull_request:
jobs:
  security-review:
    steps:
      - uses: anthropics/claude-code-security-review@0000000000000000000000000000000000000000
EOF
}

run_gate() { # <proj> [prot-file] [repo-file] → OUT, RC
  local proj="$1" prot="${2:-}" repo="${3:-$TMP/repo-aam-true.json}"
  OUT="$(PATH="$TMP/bin:$PATH" GH_PROT_FILE="$prot" GH_REPO_FILE="$repo" \
    bash "$SCRIPT" "$proj" 2>&1)" && RC=0 || RC=$?
}
expect() { # <desc> <exit> [output substring]
  local desc="$1" exp="$2" sub="${3:-}"
  if [ "$RC" -ne "$exp" ]; then bad "$desc (got exit $RC, want $exp)"; return; fi
  if [ -n "$sub" ] && ! printf '%s' "$OUT" | grep -qF "$sub"; then
    bad "$desc (output lacked \"$sub\": ${OUT:0:200})"; return
  fi
  ok "$desc"
}

# 1. Full pass: all three required, security-review is content, allow_auto_merge on.
make_proj p1
run_gate "$PROJ" "$TMP/protection-full.json" "$TMP/repo-aam-true.json"
expect "full pass exits 0" 0 "branch-protection: PASS"

# 2. The MERGE-subset proof: p1 carries NO inventory / settings / architecture, yet
#    still passes — checks a/a2/c are excluded (arming must not require auto-run inputs).
if [ ! -e "$TMP/p1/.claude" ] && [ ! -e "$TMP/p1/specs" ]; then
  ok "passes with no run-command-inventory / settings / architecture present (a/a2/c excluded)"
else bad "fixture unexpectedly carries auto-run inputs"; fi

# 3. Branch protection missing (gh api fails) → fail closed, named.
make_proj p3
run_gate "$PROJ" ""
expect "missing branch protection fails" 1 "no readable branch protection"

# 4. A required check present-but-not-required → fail, the check named + remediation.
make_proj p4
run_gate "$PROJ" "$TMP/protection-partial.json"
expect "present-but-not-required check fails, named" 1 "'security-review' is not a REQUIRED status check"
if printf '%s' "$OUT" | grep -qF "make it a required status check" \
  && printf '%s' "$OUT" | grep -qF "references/template-contract.md"; then
  ok "check (b) failure names the remediation path (wire, require, re-run + the contract)"
else bad "check (b) failure names the remediation path"; fi

# 5. security-review name-WITHOUT-content (context declared, pattern absent) → fail (b2).
make_proj p5
cat > "$PROJ/.github/workflows/ci.yml" <<'EOF'
on:
  pull_request:
jobs:
  security-review:
    steps:
      - run: echo "green by construction"
EOF
run_gate "$PROJ" "$TMP/protection-full.json"
expect "name-without-content fails check (b2), named" 1 "no workflow content performs a review"
if printf '%s' "$OUT" | grep -qF "PREFLIGHT_SECREVIEW_PATTERN" \
  && printf '%s' "$OUT" | grep -qF "PREFLIGHT_SECREVIEW_EXTERNAL=1"; then
  ok "check (b2) failure names both legitimate overrides"
else bad "check (b2) failure names both legitimate overrides"; fi

# 6. allow_auto_merge disabled → fail (d), naming the setting + attended remedy.
make_proj p6
run_gate "$PROJ" "$TMP/protection-full.json" "$TMP/repo-aam-false.json"
expect "allow_auto_merge=false fails check (d), named" 1 "allow_auto_merge is not enabled"
if printf '%s' "$OUT" | grep -qF "gh api -X PATCH"; then
  ok "check (d) failure names the attended fix (gh api -X PATCH)"
else bad "check (d) failure names the attended fix"; fi

# 7. allow_auto_merge api error (no repo fixture) → fail closed (d).
make_proj p7
run_gate "$PROJ" "$TMP/protection-full.json" "$TMP/repo-absent.json"
expect "repo api error fails check (d) closed" 1 "cannot confirm allow_auto_merge"

# 8. PREFLIGHT_SECREVIEW_PATTERN override: a different in-Actions implementation → pass.
make_proj p8
cat > "$PROJ/.github/workflows/ci.yml" <<'EOF'
on:
  pull_request:
jobs:
  security-review:
    steps:
      - uses: acme/acme-review-bot@0000000000000000000000000000000000000000
EOF
PREFLIGHT_SECREVIEW_PATTERN="acme-review-bot" run_gate "$PROJ" "$TMP/protection-full.json"
expect "pattern override passes check (b2)" 0 "branch-protection: PASS"

# 9. PREFLIGHT_SECREVIEW_EXTERNAL=1: a non-Actions provider attested → pass, echoed loudly.
make_proj p9
rm -rf "$PROJ/.github"
PREFLIGHT_SECREVIEW_EXTERNAL=1 run_gate "$PROJ" "$TMP/protection-full.json"
expect "external attestation passes check (b2)" 0 "branch-protection: PASS"
if printf '%s' "$OUT" | grep -qF "OPERATOR ATTESTATION"; then
  ok "external attestation is echoed loudly in the output"
else bad "external attestation is echoed loudly in the output"; fi

# 10. (b2) scopes to the security-review name: a required set without it skips (b2).
make_proj p10
rm -rf "$PROJ/.github"
cat > "$TMP/protection-two.json" <<'EOF'
{"required_status_checks":{"contexts":["verified-pin","plan-lint"]}}
EOF
PREFLIGHT_REQUIRED_CHECKS="verified-pin plan-lint" run_gate "$PROJ" "$TMP/protection-two.json"
expect "(b2) skipped when security-review absent from the required set" 0 "branch-protection: PASS"

# 11. Degraded: no gh on PATH → fail closed, naming gh. (jq-only PATH; real bash.)
mkdir -p "$TMP/nogh"; ln -s "$(command -v jq)" "$TMP/nogh/jq"
make_proj p11
OUT="$(PATH="$TMP/nogh" "$REAL_BASH" "$SCRIPT" "$PROJ" 2>&1)" && RC=0 || RC=$?
expect "no gh in context fails closed, naming gh" 1 "gh is unavailable"

# 12. Degraded: no jq on PATH → fail closed, naming jq.
mkdir -p "$TMP/nojq"; ln -s "$TMP/bin/gh" "$TMP/nojq/gh"
make_proj p12
OUT="$(PATH="$TMP/nojq" GH_PROT_FILE="$TMP/protection-full.json" "$REAL_BASH" "$SCRIPT" "$PROJ" 2>&1)" && RC=0 || RC=$?
expect "no jq in context fails closed, naming jq" 1 "jq is unavailable"

# 13. The PASS line NAMES the branch it certified (attended arming evidence).
make_proj p13
run_gate "$PROJ" "$TMP/protection-full.json"
expect "PASS names the certified default branch" 0 "default branch 'main'"

# 14. The protection query targets the SERVER-resolved default branch: with the
#     server default = 'release' and protection defined only there, the gate passes
#     and reports 'release' (the resolution came from `gh repo view`, not a guess).
make_proj p14
GH_DEFAULT_BRANCH=release run_gate "$PROJ" "$TMP/protection-full.json"
expect "server-truth branch drives the protection query" 0 "default branch 'release'"

# 15. Regression for the origin/HEAD self-arm vector: a real repo whose LOCAL
#     origin/HEAD is repointed to an unprotected decoy, while server truth says the
#     default is 'main' (protected). Server-truth resolution must win — the gate
#     certifies 'main' and PASSES. On the pre-fix code (which read origin/HEAD) this
#     resolved 'decoy', whose protection 404s → GAP. So a PASS here proves the fix.
PG="$TMP/pg"; mkdir -p "$PG/.github/workflows"
cat > "$PG/.github/workflows/ci.yml" <<'EOF'
on:
  pull_request:
jobs:
  security-review:
    steps:
      - uses: anthropics/claude-code-security-review@0000000000000000000000000000000000000000
EOF
git -C "$PG" init -q >/dev/null 2>&1
git -C "$PG" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/decoy >/dev/null 2>&1
OUT="$(PATH="$TMP/bin:$PATH" GH_DEFAULT_BRANCH=main GH_PROT_FILE="$TMP/protection-full.json" \
  GH_REPO_FILE="$TMP/repo-aam-true.json" bash "$SCRIPT" "$PG" 2>&1)" && RC=0 || RC=$?
expect "server truth overrides a repointed origin/HEAD" 0 "default branch 'main'"

# =============================================================================
# Committed per-project check-contract (.claude/keel-auto-merge-checks.json).
# These need a REAL git repo with a self-origin so the gate's fail-closed
# transport (gh-repo-view default branch → mandatory `git fetch origin` →
# `git show refs/remotes/origin/<db>:<path>`) resolves — the plain-dir fixtures
# above have no git and so exercise only the "absent → keel default" path. This
# transport machinery is NOT present in the fixtures above; it is built here,
# mirroring merge-guard.test.sh:arm_committed().
# =============================================================================
git_proj() { # <name> <check-contract-json|""> → PROJ: git repo, self-origin, workflow (+ optional config) committed on main
  PROJ="$TMP/$1"
  mkdir -p "$PROJ/.github/workflows"
  cat > "$PROJ/.github/workflows/ci.yml" <<'EOF'
on:
  pull_request:
jobs:
  security-review:
    steps:
      - uses: anthropics/claude-code-security-review@0000000000000000000000000000000000000000
EOF
  git -C "$PROJ" init -q >/dev/null 2>&1
  git -C "$PROJ" symbolic-ref HEAD refs/heads/main   # force the default branch to 'main' regardless of git config
  if [ -n "${2:-}" ]; then
    mkdir -p "$PROJ/.claude"; printf '%s' "$2" > "$PROJ/.claude/keel-auto-merge-checks.json"
    git -C "$PROJ" add -f .claude/keel-auto-merge-checks.json
  fi
  git -C "$PROJ" add -f .github/workflows/ci.yml
  git -C "$PROJ" -c user.email=t@keel.test -c user.name=t commit -qm init
  git -C "$PROJ" remote add origin "$PROJ"   # self-origin: `git fetch origin` resolves offline
}

# crelaunch-shaped names: the real incident — a repo whose CI is NOT keel's.
PROT_CRE="$TMP/protection-crelaunch.json"
cat > "$PROT_CRE" <<'EOF'
{"required_status_checks":{"contexts":["verified-pin gate","typecheck · lint · test","security-review"]}}
EOF
CFG_CRE='{"required_checks":["verified-pin gate","typecheck · lint · test","security-review"],"security_review":{"check":"security-review","pattern":"claude-code-security-review"}}'

# 16. Committed config present → its DECLARED names drive the assertion. Protection
#     requires crelaunch's names; the committed config names them; PASS. On pre-change
#     code the hardcoded keel default set (verified-pin/plan-lint/security-review) is
#     checked against protection that lacks two of them → GAP, so a PASS proves the fix.
git_proj gp16 "$CFG_CRE"
run_gate "$PROJ" "$PROT_CRE"
expect "committed config: its declared names are certified → PASS" 0 "branch-protection: PASS"

# 17. Anti-forge: a config committed on main (crelaunch names, matching protection) with
#     a DIFFERENT, weaker config planted in the WORKING TREE. The gate must read the
#     default-branch ref, not the working tree — so it still certifies the committed
#     names → PASS. If it read the working tree it would check 'only-weak' (absent from
#     protection) → GAP; PASS proves the default-branch read wins.
git_proj gp17 "$CFG_CRE"
printf '%s' '{"required_checks":["only-weak"],"security_review":{"check":"only-weak"}}' > "$PROJ/.claude/keel-auto-merge-checks.json"
run_gate "$PROJ" "$PROT_CRE"
expect "committed config: a forged WORKING-TREE config is ignored (default-branch read wins) → PASS" 0 "branch-protection: PASS"

# 18. Present-but-malformed (unparseable JSON) → GAP, fail closed (never a silent
#     fall-back-to-default). The config is on main; it is broken.
git_proj gp18 '{"required_checks":'
run_gate "$PROJ" "$PROT_CRE"
expect "committed config: malformed JSON fails closed (GAP), does not fall back" 1 "is present on 'main' but is not valid"

# 19. Present but required_checks is empty / not a non-empty array → GAP.
git_proj gp19 '{"required_checks":[]}'
run_gate "$PROJ" "$PROT_CRE"
expect "committed config: empty required_checks fails closed (GAP)" 1 "non-empty \"required_checks\" array"

# 20. Committed config that OMITS the security-review check → GAP (never-weakens):
#     the config may rename the review check, never remove it.
git_proj gp20 '{"required_checks":["verified-pin gate","typecheck · lint · test"]}'
run_gate "$PROJ" "$PROT_CRE"
expect "committed config: omitting security-review fails closed (never-weakens GAP)" 1 "never remove it"

# 21. Env override BEATS the committed config. The config names something protection
#     lacks ('nonexistent'); the env override names keel's set, which protection-full
#     requires. PASS proves the env override won (had the config won, 'nonexistent' →
#     GAP). Uses a repo whose protection is the keel-default set.
git_proj gp21 '{"required_checks":["nonexistent"],"security_review":{"check":"nonexistent"}}'
OUT="$(PATH="$TMP/bin:$PATH" GH_PROT_FILE="$TMP/protection-full.json" GH_REPO_FILE="$TMP/repo-aam-true.json" \
  PREFLIGHT_REQUIRED_CHECKS="verified-pin plan-lint security-review" bash "$SCRIPT" "$PROJ" 2>&1)" && RC=0 || RC=$?
expect "env override beats the committed config → PASS on the override's set" 0 "branch-protection: PASS"

# 22. Absent config on a real git repo (git show non-zero) → falls back to keel default,
#     checked against the keel-default protection → PASS. Confirms absent (not malformed)
#     routes to the default, distinct from the GAP cases above.
git_proj gp22 ""
run_gate "$PROJ" "$TMP/protection-full.json"
expect "no committed config on a git repo → keel default → PASS (absent ≠ malformed)" 0 "branch-protection: PASS"

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]

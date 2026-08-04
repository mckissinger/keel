#!/usr/bin/env bash
#
# Self-test for keel:prep-auto-merge's committed, security-relevant artifacts.
# The skill is prose (no executable entry point), so this proves the ARTIFACTS it
# ships and the invariants a cold edit could erode:
#   A. the scaffolded workflow template, materialized VERBATIM, PASSES the very
#      gate arming runs (check-branch-protection.sh (b2)) — a real review job, not
#      a plausible-looking hollow one;
#   B. its action is pinned to a full commit SHA, never a tag;
#   C. that SHA is kept in lockstep with keel's OWN security-review workflow
#      (single source — a keel SHA bump must update the scaffold, never fork it);
#   D. a names-only, generated-shape check-contract is ACCEPTED and certified, and
#      the template + contract FLIP a name-mismatch repo from (b2) GAP to PASS;
#   E. this test is wired as a named step in ci.yml (keel runs tests by name, not a
#      glob — an unwired test never runs, so the lockstep invariant would rot).
# The prose invariants (print-never-run, secret-is-human, reuse-the-assertion, the
# wedge gate, reporting-contexts-not-protection) are locked by scripts/skill-anchors/
# prep-auto-merge.txt via check-skill-anchors.sh, not here.
#
# Run: bash scripts/check-prep-auto-merge.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BP="$ROOT/scripts/check-branch-protection.sh"
TEMPLATE="$ROOT/skills/prep-auto-merge/templates/security-review.yml"
KEEL_WF="$ROOT/.github/workflows/ci.yml"
CI="$ROOT/.github/workflows/ci.yml"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
pass=0 failc=0
ok()  { echo "ok   - $1"; pass=$((pass + 1)); }
bad() { echo "FAIL - $1"; failc=$((failc + 1)); }

# gh stub — same shape as check-branch-protection.test.sh: repo view → default
# branch; protection query for the default branch → $GH_PROT_FILE; else → $GH_REPO_FILE.
mkdir -p "$TMP/bin"
cat > "$TMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
db="${GH_DEFAULT_BRANCH:-main}"
case "$*" in
  *"repo view"*) printf '%s\n' "$db" ;;
  *"branches/$db/protection"*)
    if [ -n "${GH_PROT_FILE:-}" ] && [ -f "$GH_PROT_FILE" ]; then cat "$GH_PROT_FILE"; exit 0; fi
    echo "gh: Branch not protected (HTTP 404)" >&2; exit 1 ;;
  *protection*) echo "gh: Branch not protected (HTTP 404)" >&2; exit 1 ;;
  *)
    if [ -n "${GH_REPO_FILE:-}" ] && [ -f "$GH_REPO_FILE" ]; then cat "$GH_REPO_FILE"; exit 0; fi
    echo "gh: Not Found (HTTP 404)" >&2; exit 1 ;;
esac
EOF
chmod +x "$TMP/bin/gh"
printf '{"allow_auto_merge":true}\n' > "$TMP/repo-aam-true.json"

# ---------------------------------------------------------------------------
# A. The scaffolded template, materialized VERBATIM, passes (b2).
#    Isolate (b2) by requiring exactly the review check (PREFLIGHT_REQUIRED_CHECKS),
#    so a PASS proves the TEMPLATE's content — not other checks — clears the scan.
# ---------------------------------------------------------------------------
printf '%s' '{"required_status_checks":{"contexts":["security-review"]}}' > "$TMP/prot-secrev.json"
PROJ="$TMP/projA"; mkdir -p "$PROJ/.github/workflows"
cp "$TEMPLATE" "$PROJ/.github/workflows/security-review.yml"   # verbatim copy — exactly what the skill does
OUT="$(PATH="$TMP/bin:$PATH" GH_PROT_FILE="$TMP/prot-secrev.json" GH_REPO_FILE="$TMP/repo-aam-true.json" \
  PREFLIGHT_REQUIRED_CHECKS="security-review" bash "$BP" "$PROJ" 2>&1)" && RC=0 || RC=$?
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -qF "branch-protection: PASS"; then
  ok "scaffolded template PASSES check-branch-protection (b2) when copied verbatim"
else bad "template should PASS (b2) verbatim (rc=$RC: ${OUT:0:200})"; fi

# ---------------------------------------------------------------------------
# B. The template pins a full 40-hex commit SHA, never a tag.
# ---------------------------------------------------------------------------
if grep -Eq 'anthropics/claude-code-security-review@[0-9a-f]{40}([^0-9a-f]|$)' "$TEMPLATE"; then
  ok "template pins the review action to a full 40-hex commit SHA"
else bad "template must pin a full 40-hex SHA (not a tag/branch)"; fi

# ---------------------------------------------------------------------------
# C. The template SHA equals keel's OWN security-review action pin (single source).
# ---------------------------------------------------------------------------
sha_of() { grep -oE 'anthropics/claude-code-security-review@[0-9a-f]{40}' "$1" | head -1 | sed 's/.*@//'; }
T_SHA="$(sha_of "$TEMPLATE")"; K_SHA="$(sha_of "$KEEL_WF")"
if [ -n "$T_SHA" ] && [ "$T_SHA" = "$K_SHA" ]; then
  ok "template action SHA is in lockstep with keel's own workflow ($T_SHA)"
else bad "template SHA ($T_SHA) must equal keel's own workflow SHA ($K_SHA) — single source"; fi

# ---------------------------------------------------------------------------
# D. A generated-shape names-only contract is accepted + certified, and the
#    template + contract FLIP a name-mismatch repo from (b2) GAP to PASS.
#    Git fixture (self-origin, committed on the default branch) so the committed
#    contract is read via the fail-closed default-branch transport.
# ---------------------------------------------------------------------------
CFG='{"required_checks":["verified-pin gate","typecheck · lint · test","security-review"],"security_review":{"check":"security-review"}}'
printf '%s' '{"required_status_checks":{"contexts":["verified-pin gate","typecheck · lint · test","security-review"]}}' > "$TMP/prot-cre.json"

git_fixture() { # <name> <workflow-src|"none"> → GP: git repo, self-origin, contract + workflow committed on main
  GP="$TMP/$1"; mkdir -p "$GP/.github/workflows" "$GP/.claude"
  printf '%s' "$CFG" > "$GP/.claude/keel-auto-merge-checks.json"
  if [ "$2" != "none" ]; then cp "$2" "$GP/.github/workflows/security-review.yml"; fi
  git -C "$GP" init -q >/dev/null 2>&1
  git -C "$GP" symbolic-ref HEAD refs/heads/main
  git -C "$GP" add -f . >/dev/null 2>&1
  git -C "$GP" -c user.email=t@keel.test -c user.name=t commit -qm init
  git -C "$GP" remote add origin "$GP"
}

# D1 (after): generated contract + the scaffolded template → the contract's names are
#     certified and (b2) passes on the template → PASS.
git_fixture gpD1 "$TEMPLATE"
OUT="$(PATH="$TMP/bin:$PATH" GH_PROT_FILE="$TMP/prot-cre.json" GH_REPO_FILE="$TMP/repo-aam-true.json" \
  bash "$BP" "$GP" 2>&1)" && RC=0 || RC=$?
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -qF "branch-protection: PASS"; then
  ok "generated-shape contract accepted + template flips a name-mismatch repo to PASS"
else bad "contract + template should PASS (rc=$RC: ${OUT:0:200})"; fi

# D2 (before): same contract but a NON-review workflow → (b2) GAP. Proves the review
#     workflow is load-bearing (the scaffold is not decorative).
cat > "$TMP/non-review.yml" <<'EOF'
on:
  pull_request:
jobs:
  security-review:
    steps:
      - uses: actions/checkout@0000000000000000000000000000000000000000
EOF
git_fixture gpD2 "$TMP/non-review.yml"
OUT="$(PATH="$TMP/bin:$PATH" GH_PROT_FILE="$TMP/prot-cre.json" GH_REPO_FILE="$TMP/repo-aam-true.json" \
  bash "$BP" "$GP" 2>&1)" && RC=0 || RC=$?
if [ "$RC" -ne 0 ] && printf '%s' "$OUT" | grep -qF "no workflow content performs a review"; then
  ok "without the scaffolded workflow the same repo GAPs on (b2) — the scaffold is load-bearing"
else bad "non-review workflow should GAP (b2) (rc=$RC: ${OUT:0:200})"; fi

# ---------------------------------------------------------------------------
# E. This test is wired as a named step in ci.yml (no glob sweep exists).
# ---------------------------------------------------------------------------
if grep -qF "scripts/check-prep-auto-merge.test.sh" "$CI"; then
  ok "check-prep-auto-merge.test.sh is wired as a named step in ci.yml"
else bad "check-prep-auto-merge.test.sh must be a named step in ci.yml (keel runs tests by name)"; fi

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]

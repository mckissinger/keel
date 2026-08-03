#!/usr/bin/env bash
#
# check-branch-protection.sh — the merge-relevant branch-protection assertion.
#
# The subset of check-auto-preflight.sh that both the auto-run preflight AND the
# keel:arm-auto-merge skill need before trusting `gh pr merge --auto` on a repo:
#
#   (b)  branch protection exists on the default branch and its REQUIRED status
#        checks include every job in REQUIRED_CHECKS (job names are config, not a
#        CI-vendor hardcode);
#   (b2) the security-review check is CONTENT, not just a name: some file under
#        .github/workflows/ declares the check context, invokes the review
#        implementation on an UNCOMMENTED `uses:` line matching the pattern
#        (default `claude-code-security-review`; PREFLIGHT_SECREVIEW_PATTERN for a
#        different in-Actions implementation), AND triggers on pull_request. A
#        non-Actions provider has no workflow to scan — PREFLIGHT_SECREVIEW_EXTERNAL=1
#        attests it explicitly, echoed loudly, never silently;
#   (d)  the repo has `allow_auto_merge` enabled — the setting that lets
#        `gh pr merge --auto` queue a merge instead of dropping to a prompt.
#
# It DELIBERATELY EXCLUDES the auto-run-only checks (a)/(a2) (command-inventory
# dry-run) and (c) (architecture env-var names): those require a
# specs/run-command-inventory.txt / specs/01-architecture.md that a repo arming
# auto-merge need not have. Arming auto-merge asserts merge readiness, not
# unattended-run readiness.
#
# Exit 0 = branch protection is merge-ready. Non-zero = one or more gaps, each
# named on stderr (same GAP vocabulary as the preflight). Fails closed: missing
# gh/jq, unreadable protection, or an API error is a gap, never a silent pass.
# A gap is fixed ATTENDED — never worked around.
#
# This is the single source of the assertion: check-auto-preflight.sh calls it
# for (b)/(b2)/(d) rather than keeping its own copies, so the auto-entry check
# and the arming check can never drift apart. Provision copies it like the pin
# gate; it is never re-authored from prose.
#
# Usage: scripts/check-branch-protection.sh [ROOT]   (ROOT defaults to the repo root)

set -uo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# --- config block (same knobs + defaults as check-auto-preflight.sh) ----------
REQUIRED_CHECKS="${PREFLIGHT_REQUIRED_CHECKS:-verified-pin plan-lint security-review}"
SECREVIEW_CHECK_NAME="security-review"
SECREVIEW_PATTERN="${PREFLIGHT_SECREVIEW_PATTERN:-claude-code-security-review}"
SECREVIEW_WF_DIR="${PREFLIGHT_WF_DIR:-.github/workflows}"
# ------------------------------------------------------------------------------

fails=0
gap() { echo "branch-protection: GAP — $1" >&2; fails=$((fails + 1)); }

HAVE_JQ=0; command -v jq >/dev/null 2>&1 && HAVE_JQ=1
HAVE_GH=0; command -v gh >/dev/null 2>&1 && HAVE_GH=1
[ "$HAVE_JQ" -eq 1 ] || gap "dependency: jq is unavailable — cannot parse the protection JSON (fail closed)"
[ "$HAVE_GH" -eq 1 ] || gap "dependency: gh is unavailable — cannot verify branch protection (fail closed)"

# --- (b) branch protection: the required checks are actually REQUIRED ---------
# Resolve the default branch from SERVER TRUTH — `gh repo view` — the same source
# merge-guard.sh:read_committed_marker uses, and for the same reason: the marker
# is committed to, and honored from, the repo's server default branch, so the
# branch whose protection we certify MUST be that same branch. Local `origin/HEAD`
# is agent-repointable (`git remote set-head`), so certifying the branch it points
# at could pass against a protected decoy while the real default is unprotected
# (M1's pre-pin review, decisions/2026-08-02-committed-auto-merge-marker.md). The
# local resolution survives only as a last-resort fallback for when `gh repo view`
# cannot answer — and in that state the protection/allow_auto_merge `gh api` calls
# below almost certainly fail too, gapping arming closed regardless.
default_branch=""
if [ "$HAVE_GH" -eq 1 ] && [ "$HAVE_JQ" -eq 1 ]; then
  default_branch="$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || true)"
  if [ -z "$default_branch" ]; then
    default_branch="main"
    if command -v git >/dev/null 2>&1; then
      if ref="$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null)"; then
        default_branch="${ref#refs/remotes/origin/}"
      else
        for b in main master; do
          if git show-ref --verify --quiet "refs/heads/$b" 2>/dev/null \
            || git show-ref --verify --quiet "refs/remotes/origin/$b" 2>/dev/null; then
            default_branch="$b"; break
          fi
        done
      fi
    fi
  fi
  if prot="$(gh api "repos/{owner}/{repo}/branches/$default_branch/protection" 2>/dev/null)"; then
    contexts="$(printf '%s' "$prot" | jq -r \
      '[(.required_status_checks.contexts // []), ((.required_status_checks.checks // []) | map(.context))] | add | .[]?' \
      2>/dev/null || true)"
    for want in $REQUIRED_CHECKS; do
      found=0
      while IFS= read -r have; do
        [ "$have" = "$want" ] && found=1
      done <<EOF
$contexts
EOF
      [ "$found" -eq 1 ] \
        || gap "protection: check '$want' is not a REQUIRED status check in branch protection on '$default_branch' (a check that exists but is not required does not gate the merge) — remediate attended: wire '$want' as a CI check job, make it a required status check on '$default_branch', then re-run this preflight. Which jobs the autonomy tier requires, and the recorded default implementation of each, live in keel's references/template-contract.md tier 1. Never drop a job from the required set to get past this gate."
    done
  else
    gap "protection: no readable branch protection on '$default_branch' (gh api .../protection failed — configure it attended before an auto run)"
  fi
fi

# --- (b2) the security-review check is CONTENT, not just a name ---------------
case " $REQUIRED_CHECKS " in
  *" $SECREVIEW_CHECK_NAME "*)
    if [ "${PREFLIGHT_SECREVIEW_EXTERNAL:-0}" = "1" ]; then
      echo "branch-protection: security-review content asserted by OPERATOR ATTESTATION (PREFLIGHT_SECREVIEW_EXTERNAL=1), not by workflow scan — a non-Actions provider is trusted here on the operator's word" >&2
    else
      # Three per-file requirements, so a comment naming the action, a
      # workflow_dispatch-only workflow, or cross-file string scatter cannot
      # satisfy the gate: the file must (1) declare the check context, (2)
      # invoke the review implementation on an UNCOMMENTED `uses:` line, and
      # (3) trigger on pull_request.
      b2_ok=0
      if [ -d "$SECREVIEW_WF_DIR" ]; then
        for wf in "$SECREVIEW_WF_DIR"/*.yml "$SECREVIEW_WF_DIR"/*.yaml; do
          [ -f "$wf" ] || continue
          grep -q "$SECREVIEW_CHECK_NAME" "$wf" 2>/dev/null || continue
          grep -Eq "^[[:space:]]*-?[[:space:]]*uses:[[:space:]]*[^#]*$SECREVIEW_PATTERN" "$wf" 2>/dev/null || continue
          grep -q "pull_request" "$wf" 2>/dev/null || continue
          b2_ok=1; break
        done
      fi
      [ "$b2_ok" -eq 1 ] \
        || gap "security-review content: the required check exists in name; no workflow content performs a review — no file under $SECREVIEW_WF_DIR declares '$SECREVIEW_CHECK_NAME', invokes the review implementation on an uncommented 'uses:' line matching '$SECREVIEW_PATTERN', AND triggers on pull_request. Remediate attended: wire the review job (the recorded default implementation lives in keel's references/template-contract.md tier 1), or set PREFLIGHT_SECREVIEW_PATTERN for a different in-Actions implementation, or attest a non-Actions provider explicitly with PREFLIGHT_SECREVIEW_EXTERNAL=1. Never clear this gate by renaming or dropping the check."
    fi
    ;;
esac

# --- (d) the repo can auto-merge: allow_auto_merge is enabled -----------------
if [ "$HAVE_GH" -eq 1 ] && [ "$HAVE_JQ" -eq 1 ]; then
  if repo_json="$(gh api "repos/{owner}/{repo}" 2>/dev/null)"; then
    aam="$(printf '%s' "$repo_json" | jq -r '.allow_auto_merge // false' 2>/dev/null || true)"
    if [ "$aam" != "true" ]; then
      gap "auto-merge: allow_auto_merge is not enabled on the repo (gh api repos/{owner}/{repo} .allow_auto_merge = ${aam:-missing}) — \`gh pr merge --auto\` would fall back to an interactive prompt and stall a headless run. Enable it attended: repo Settings → General → 'Allow auto-merge', or gh api -X PATCH repos/{owner}/{repo} -f allow_auto_merge=true"
    fi
  else
    gap "auto-merge: gh api repos/{owner}/{repo} failed — cannot confirm allow_auto_merge is enabled (fail closed; enable it attended before an auto run)"
  fi
fi

if [ "$fails" -eq 0 ]; then
  # Name the branch the assertion certified — server-truth-resolved above — so an
  # attended arming operator sees WHICH branch was checked, not just that a check
  # passed (the failure lines already name it; the PASS line must too).
  echo "branch-protection: PASS — required checks required, security-review is content, repo allows auto-merge (default branch '${default_branch:-unknown}')"
  exit 0
fi
echo "branch-protection: $fails gap(s) — fix attended before arming auto-merge or launching an auto run" >&2
exit 1

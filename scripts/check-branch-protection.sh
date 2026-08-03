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
# WHICH checks are asserted (their NAMES) is per-project config — a consuming
# repo's real CI rarely uses keel's own job names (`verified-pin plan-lint
# security-review`). The name set is resolved with a fixed precedence
# (decisions/2026-08-03-arm-auto-merge-check-contract.md):
#   1. an OPERATOR OVERRIDE — PREFLIGHT_REQUIRED_CHECKS / PREFLIGHT_SECREVIEW_*
#      set in the environment, OR a project copy that edited the config-block
#      default away from keel's built-in string;
#   2. else a COMMITTED per-project check-contract — .claude/keel-auto-merge-checks.json
#      on the repo's SERVER default branch, read fail-closed (the same transport
#      merge-guard.sh:read_committed_marker uses: gh-repo-view default branch, a
#      MANDATORY fetch, `git show refs/remotes/origin/<db>:<path>` parsed as DATA,
#      never the working tree — a locally-written or branch-only config is ignored);
#   3. else keel's BUILT-IN defaults.
# The committed config declares NAMES ONLY — it can rename the security-review
# check, never remove it, and cannot switch off (b2) content-scanning or (d). A
# config that is present-but-malformed (unparseable, or required_checks not a
# non-empty array) or that omits the declared security-review check is a GAP, fail
# closed — never a silent pass and never a silent fall-back-to-default (absence
# falls back; a broken PRESENT config is an error to surface). This distinction
# from read_committed_marker — which collapses every failure into "absent" — is
# deliberate: here a genuinely-absent file (git show non-zero) falls back, a
# successful read of broken content GAPs.
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
# The editable config-block values (a project copy may edit these; env overrides
# for one-offs; a committed .claude/keel-auto-merge-checks.json is the preferred
# per-project home). Each carries the literal default so a project copy edits it
# in place; the KEEL_DEFAULT_* sentinels below repeat those values immutably, used
# only to tell an unmodified config block from an edited one — do not edit them.
REQUIRED_CHECKS="${PREFLIGHT_REQUIRED_CHECKS:-verified-pin plan-lint security-review}"
SECREVIEW_CHECK_NAME="${PREFLIGHT_SECREVIEW_CHECK:-security-review}"
SECREVIEW_PATTERN="${PREFLIGHT_SECREVIEW_PATTERN:-claude-code-security-review}"
SECREVIEW_WF_DIR="${PREFLIGHT_WF_DIR:-.github/workflows}"
CHECK_CONTRACT_FILE="${PREFLIGHT_CHECK_CONTRACT:-.claude/keel-auto-merge-checks.json}"
KEEL_DEFAULT_CHECKS="verified-pin plan-lint security-review"
KEEL_DEFAULT_SECREVIEW_CHECK="security-review"
KEEL_DEFAULT_SECREVIEW_PATTERN="claude-code-security-review"
# ------------------------------------------------------------------------------

fails=0
gap() { echo "branch-protection: GAP — $1" >&2; fails=$((fails + 1)); }

HAVE_JQ=0; command -v jq >/dev/null 2>&1 && HAVE_JQ=1
HAVE_GH=0; command -v gh >/dev/null 2>&1 && HAVE_GH=1
[ "$HAVE_JQ" -eq 1 ] || gap "dependency: jq is unavailable — cannot parse the protection JSON (fail closed)"
[ "$HAVE_GH" -eq 1 ] || gap "dependency: gh is unavailable — cannot verify branch protection (fail closed)"

# --- resolve the default branch from SERVER TRUTH — `gh repo view` ------------
# The same source merge-guard.sh:read_committed_marker uses, and for the same
# reason: the marker and the committed check-contract are committed to, and
# honored from, the repo's server default branch, so the branch whose protection
# we certify MUST be that same branch. Local `origin/HEAD` is agent-repointable
# (`git remote set-head`), so certifying the branch it points at could pass
# against a protected decoy while the real default is unprotected (M1's pre-pin
# review, decisions/2026-08-02-committed-auto-merge-marker.md). The local
# resolution survives only as a last-resort fallback for when `gh repo view`
# cannot answer — and in that state the protection/allow_auto_merge `gh api`
# calls below almost certainly fail too, gapping arming closed regardless.
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
fi

# --- resolve the required-check set: operator override > committed config > default
# An OPERATOR OVERRIDE (env var set, OR the config-block default edited away from
# keel's built-in string) wins and the committed config is not consulted for that
# knob. Otherwise, read the committed per-project check-contract from the default
# branch; a valid one supplies the names, a present-but-broken one GAPs, an absent
# one falls back to the keel default already in the variables above.
override_checks=0
[ -n "${PREFLIGHT_REQUIRED_CHECKS+set}" ] && override_checks=1
[ "$REQUIRED_CHECKS" != "$KEEL_DEFAULT_CHECKS" ] && override_checks=1
override_secreview_check=0
[ -n "${PREFLIGHT_SECREVIEW_CHECK+set}" ] && override_secreview_check=1
[ "$SECREVIEW_CHECK_NAME" != "$KEEL_DEFAULT_SECREVIEW_CHECK" ] && override_secreview_check=1
override_secreview_pattern=0
[ -n "${PREFLIGHT_SECREVIEW_PATTERN+set}" ] && override_secreview_pattern=1
[ "$SECREVIEW_PATTERN" != "$KEEL_DEFAULT_SECREVIEW_PATTERN" ] && override_secreview_pattern=1
override_secreview_external=0
[ -n "${PREFLIGHT_SECREVIEW_EXTERNAL+set}" ] && override_secreview_external=1

# read_check_contract → CONTRACT_STATE = absent|malformed|valid; on valid, sets
# CONTRACT_CHECKS / CONTRACT_SECREVIEW_CHECK / CONTRACT_SECREVIEW_PATTERN /
# CONTRACT_SECREVIEW_EXTERNAL from the committed file on the server default branch.
CONTRACT_STATE="absent"
CONTRACT_CHECKS=""
CONTRACT_SECREVIEW_CHECK=""
CONTRACT_SECREVIEW_PATTERN=""
CONTRACT_SECREVIEW_EXTERNAL=""
read_check_contract() {
  [ "$HAVE_GH" -eq 1 ] && [ "$HAVE_JQ" -eq 1 ] || return 0   # deps already gapped; stay absent
  command -v git >/dev/null 2>&1 || return 0
  local db="$default_branch" content
  [ -n "$db" ] || return 0
  # MANDATORY fetch of the default branch; a failed fetch → treat as absent
  # (fall back to keel defaults — the live gh-api protection check below then
  # re-verifies whatever set ends up in force, so this never fails open).
  git fetch origin "+refs/heads/$db:refs/remotes/origin/$db" >/dev/null 2>&1 || return 0
  # git show NON-ZERO = file genuinely absent on the default branch → fall back.
  content="$(git show "refs/remotes/origin/$db:$CHECK_CONTRACT_FILE" 2>/dev/null)" || return 0
  # Content was read: from here a broken file is malformed (GAP), not absent.
  printf '%s' "$content" | jq -e . >/dev/null 2>&1 || { CONTRACT_STATE="malformed"; return 0; }
  # required_checks must be a non-empty array whose every element is a string.
  printf '%s' "$content" | jq -e \
    '(.required_checks|type=="array") and (.required_checks|length>0) and (.required_checks|all(type=="string"))' \
    >/dev/null 2>&1 || { CONTRACT_STATE="malformed"; return 0; }
  # NEWLINE-separated so a check CONTEXT MAY CONTAIN SPACES — a consuming repo's
  # real CI names routinely do (e.g. "typecheck · lint · test"); a space-joined
  # string would be word-split back into bogus one-word contexts by the (b) loop.
  CONTRACT_CHECKS="$(printf '%s' "$content" | jq -r '.required_checks[]')"
  [ -n "$CONTRACT_CHECKS" ] || { CONTRACT_STATE="malformed"; return 0; }
  CONTRACT_SECREVIEW_CHECK="$(printf '%s' "$content" | jq -r '.security_review.check // "'"$KEEL_DEFAULT_SECREVIEW_CHECK"'"' 2>/dev/null || printf '%s' "$KEEL_DEFAULT_SECREVIEW_CHECK")"
  CONTRACT_SECREVIEW_PATTERN="$(printf '%s' "$content" | jq -r '.security_review.pattern // "'"$KEEL_DEFAULT_SECREVIEW_PATTERN"'"' 2>/dev/null || printf '%s' "$KEEL_DEFAULT_SECREVIEW_PATTERN")"
  CONTRACT_SECREVIEW_EXTERNAL="$(printf '%s' "$content" | jq -r 'if (.security_review.external // false) then "1" else "0" end' 2>/dev/null || printf '0')"
  CONTRACT_STATE="valid"
}

# Only consult the committed contract when there is no full operator override of
# the check set. (An operator who set PREFLIGHT_REQUIRED_CHECKS is stating the set
# explicitly; honoring the file underneath them would surprise.)
if [ "$override_checks" -eq 0 ]; then
  read_check_contract
  case "$CONTRACT_STATE" in
    malformed)
      gap "check-contract: $CHECK_CONTRACT_FILE is present on '$default_branch' but is not valid — it must be JSON with a non-empty \"required_checks\" array of check-context names. Fix it attended (a broken check-contract fails closed; it never silently falls back to keel's defaults)."
      ;;
    valid)
      REQUIRED_CHECKS="$CONTRACT_CHECKS"
      # env still wins per-knob for the security-review knobs (precedence env > config).
      [ "$override_secreview_check" -eq 1 ]   || SECREVIEW_CHECK_NAME="$CONTRACT_SECREVIEW_CHECK"
      [ "$override_secreview_pattern" -eq 1 ] || SECREVIEW_PATTERN="$CONTRACT_SECREVIEW_PATTERN"
      [ "$override_secreview_external" -eq 1 ] || export PREFLIGHT_SECREVIEW_EXTERNAL="$CONTRACT_SECREVIEW_EXTERNAL"
      ;;
    absent) : ;;   # keel defaults already in place
  esac
fi

# Canonical iteration list: NEWLINE-separated so a context may contain spaces.
# The env / config-block / default path is a space-separated string (keel's own
# job names have no spaces); the committed-config path already produced newlines.
if [ "$override_checks" -eq 0 ] && [ "$CONTRACT_STATE" = "valid" ]; then
  REQUIRED_CHECKS_NL="$CONTRACT_CHECKS"
else
  # shellcheck disable=SC2086 # intentional word-split of the space-separated set
  REQUIRED_CHECKS_NL="$(printf '%s\n' $REQUIRED_CHECKS)"
fi
REQUIRED_CHECKS_DISPLAY="$(printf '%s' "$REQUIRED_CHECKS_NL" | tr '\n' ' ')"

# --- never-weakens: a committed contract MUST include a security-review check --
# The committed check-contract declares NAMES, it cannot remove the compensating
# control: if its resolved security-review check is not a member of its resolved
# required set, (b2) below would silently skip and no review would be asserted —
# so GAP. This never-weakens rule applies to the committed-config / keel-default
# path ONLY. An OPERATOR override (PREFLIGHT_REQUIRED_CHECKS, or an edited config
# block) that deliberately omits security-review is trusted, exactly as before —
# keel's model trusts an operator stating the set explicitly; the ergonomic data
# file, which a consuming project edits without touching the script, is the one
# held to never-weakens.
if [ "$override_checks" -eq 0 ]; then
  if printf '%s\n' "$REQUIRED_CHECKS_NL" | grep -qxF "$SECREVIEW_CHECK_NAME"; then :; else
    gap "check-contract: the security-review check '$SECREVIEW_CHECK_NAME' is not in the required set ($REQUIRED_CHECKS_DISPLAY) — the check-contract may RENAME the security-review check but never remove it; add it to required_checks (and wire its content), or correct security_review.check. Never clear this by dropping the review."
  fi
fi

# --- (b) branch protection: the required checks are actually REQUIRED ---------
if [ "$HAVE_GH" -eq 1 ] && [ "$HAVE_JQ" -eq 1 ]; then
  if prot="$(gh api "repos/{owner}/{repo}/branches/$default_branch/protection" 2>/dev/null)"; then
    contexts="$(printf '%s' "$prot" | jq -r \
      '[(.required_status_checks.contexts // []), ((.required_status_checks.checks // []) | map(.context))] | add | .[]?' \
      2>/dev/null || true)"
    while IFS= read -r want; do
      [ -n "$want" ] || continue
      found=0
      while IFS= read -r have; do
        [ "$have" = "$want" ] && found=1
      done <<EOF_CTX
$contexts
EOF_CTX
      [ "$found" -eq 1 ] \
        || gap "protection: check '$want' is not a REQUIRED status check in branch protection on '$default_branch' (a check that exists but is not required does not gate the merge) — remediate attended: wire '$want' as a CI check job, make it a required status check on '$default_branch', then re-run this preflight. Which jobs the autonomy tier requires, and the recorded default implementation of each, live in keel's references/template-contract.md tier 1. Never drop a job from the required set to get past this gate."
    done <<EOF_WANT
$REQUIRED_CHECKS_NL
EOF_WANT
  else
    gap "protection: no readable branch protection on '$default_branch' (gh api .../protection failed — configure it attended before an auto run)"
  fi
fi

# --- (b2) the security-review check is CONTENT, not just a name ---------------
if printf '%s\n' "$REQUIRED_CHECKS_NL" | grep -qxF "$SECREVIEW_CHECK_NAME"; then
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
fi

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

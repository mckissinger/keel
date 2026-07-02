#!/usr/bin/env bash
#
# session-bootstrap.sh — keel's SessionStart hook (startup/resume/clear/compact).
#
# Probes the session's project directory for keel markers and, only when the
# project is keel-managed, emits a short orientation (the grain ladder + the
# standing invariants) so every session — including a freshly compacted one —
# knows keel's verbs exist. In any other project it exits 0 with no output,
# costing nothing.
#
# Output contract: for SessionStart, plain stdout on exit 0 is added to
# Claude's context (per https://code.claude.com/docs/en/hooks — no JSON
# envelope required for context-only hooks). The `compact` matcher is the
# documented re-injection path after compaction; PostCompact cannot inject.
#
# Self-contained on purpose: it references no sibling files, so it survives
# plugin-cache path churn with no dirname gymnastics beyond this comment.

set -euo pipefail

# The harness sets CLAUDE_PROJECT_DIR for hook processes; fall back to cwd.
ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

is_keel_managed() {
  [ -d "$ROOT/specs/milestones" ] && return 0
  [ -f "$ROOT/specs/stack-profile.md" ] && return 0
  if [ -f "$ROOT/CLAUDE.md" ] && grep -qiE 'verified[- ]pin' "$ROOT/CLAUDE.md"; then
    return 0
  fi
  return 1
}

# Not a keel-managed project → stay silent.
is_keel_managed || exit 0

cat <<'EOF'
keel is active: this project is keel-managed (spec markers found). Orientation:

Grain ladder — pick the verb that matches the size of the work:
- App:       kickoff (greenfield) / adopt (brownfield) → interview → spec-foundation → app-design-directions (only when there's a UI) → provision
- Feature:   spec-feature → implement-feature → land-feature → review-feature
- Milestone: implement-milestone → verify-milestone
- Change:    spec-change (a sub-feature tweak → one milestone, then the milestone verbs)
- Chore:     punch-list (a batch of tiny changes → one verified chore PR)
- Cross-cut: debug

Standing invariants — these hold no matter what else the session is doing:
- Never merge; the user reviews and merges. Open PRs and stop there.
- Never commit to main; builds run on branches.
- A milestone's code merges only with a fresh-session verified pin (verified code == merged code).
- Attended gates stop and ask; they are never silently deferred.

Specs live under specs/. When work matches a keel verb, invoke that skill rather than improvising the process.
EOF

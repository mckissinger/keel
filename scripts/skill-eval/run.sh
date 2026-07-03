#!/usr/bin/env bash
#
# run.sh — the skill-trigger eval RUNNER. Orchestrates the fresh-session evals:
# for a boundary fixture it spawns a headless `claude -p` session with the keel
# plugin ENABLED and one with it DISABLED, captures each session's activation
# trace, and passes both to the deterministic detector (detect.sh/detect.js) and
# judge (judge.js). It also runs the description-variant A/B mode.
#
# ── TWO LIVE ASSUMPTIONS (each validated at the BASELINE run, each a 1-fn fix) ─
# A live `claude -p` session is a PAID action, so this milestone builds the live
# path real+invocable but never executes it; two mechanisms are assumed and
# quarantined into ONE function each so a wrong guess is a one-function fix:
#
#   (i)  KEEL TOGGLE — `keel_project_dir <on|off>` writes a throwaway project
#        whose .claude/settings.json INCLUDES (on) or OMITS (off) keel's
#        `extraKnownMarketplaces` + `enabledPlugins: {"keel@keel": true}` (the
#        exact shape provision/adopt seed). `claude -p` run with that dir as cwd
#        loads that project's settings, so the same prompt sees keel or doesn't.
#
#   (ii) TRACE CAPTURE + FORMAT — `run_claude_p <dir> <prompt>` invokes
#        `claude -p "<prompt>" --output-format stream-json --verbose` and returns
#        the raw newline-delimited-JSON trace. Its SHAPE (a Skill tool_use whose
#        input.skill is "keel:<verb>") is parsed solely by detect.js. If the live
#        baseline shows a different flag or event shape, edit run_claude_p (flags)
#        or detect.js:skillFromEvent (shape) — nothing else.
#
# The `baseline` subcommand is the milestone's [runtime] spend stop-point: it
# spawns REAL sessions and writes BASELINE.md. It is guarded behind --confirm-spend
# and is authorized/run by /verify-milestone, never during the build.
#
# Node built-ins only; no package.json, no third-party dependency.
#
# Usage:
#   run.sh --help
#   run.sh boundary [--dry-run] [--fixture <path>]   # keel-on vs keel-off sweep
#   run.sh ab <ab-fixture.json> [--dry-run]          # description-variant A/B
#   run.sh baseline --group <boundary> --confirm-spend [--out <file>]  # [runtime]
#
# --dry-run never touches the network: it prints the exact per-fixture plan and
# runs an offline detect→judge pipeline smoke over the committed transcripts.

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
DETECT="$HERE/detect.sh"
JUDGE="$HERE/judge.js"
INDEX="$HERE/index.sh"
TX="$HERE/fixtures/transcripts"

usage() {
  sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
}

require_claude() {
  if ! command -v claude >/dev/null 2>&1; then
    echo "run.sh: 'claude' not found on PATH — the live path needs the Claude Code CLI." >&2
    exit 127
  fi
}

# ── Assumption (i): the keel on/off TOGGLE. EDIT HERE if the live toggle differs.
keel_project_dir() { # <on|off>  → prints a fresh temp project dir
  local state="$1" dir
  dir="$(mktemp -d)"
  mkdir -p "$dir/.claude"
  if [ "$state" = "on" ]; then
    cat > "$dir/.claude/settings.json" <<'JSON'
{
  "extraKnownMarketplaces": {
    "keel": { "source": { "source": "github", "repo": "mckissinger/keel" } }
  },
  "enabledPlugins": { "keel@keel": true }
}
JSON
  else
    printf '{}\n' > "$dir/.claude/settings.json"
  fi
  echo "$dir"
}

# ── Assumption (ii): the live trace CAPTURE + FLAGS. EDIT HERE if they differ.
run_claude_p() { # <project-dir> <prompt>  → prints the raw stream-json trace
  local dir="$1" prompt="$2"
  ( cd "$dir" && claude -p "$prompt" --output-format stream-json --verbose )
}

# The deterministic pipeline: a captured trace + a fixture's expected → verdict.
# Prints "<detected> <PASS|FAIL>"; returns 0 on pass, 1 on fail.
judge_trace() { # <trace-file> <expected>
  local trace="$1" expected="$2" detected rc
  detected="$(bash "$DETECT" "$trace")"
  node "$JUDGE" score --expected "$expected" --detected "$detected" >/dev/null 2>&1 && rc=0 || rc=$?
  [ "$rc" -eq 0 ] && echo "$detected PASS" || echo "$detected FAIL"
  return "$rc"
}

# One live boundary case: same prompt, keel on vs off. keel-off is the CONTROL —
# with the plugin absent no keel verb can fire, so its expected is always `none`.
run_boundary_case_live() { # <boundary> <prompt> <expected>
  local boundary="$1" prompt="$2" expected="$3" on_dir off_dir on_tr off_tr on off
  on_dir="$(keel_project_dir on)";  off_dir="$(keel_project_dir off)"
  on_tr="$(mktemp)"; off_tr="$(mktemp)"
  run_claude_p "$on_dir"  "$prompt" > "$on_tr"
  run_claude_p "$off_dir" "$prompt" > "$off_tr"
  on="$(judge_trace  "$on_tr"  "$expected" || true)"   # keel-on judged vs fixture
  off="$(judge_trace "$off_tr" "none"      || true)"   # keel-off control vs none
  printf '  [%s] %s\n    keel-on : %s (expected %s)\n    keel-off: %s (control expects none)\n' \
    "$boundary" "$prompt" "$on" "$expected" "$off"
  rm -rf "$on_dir" "$off_dir" "$on_tr" "$off_tr"
}

cmd_boundary() {
  local dry=0 one_fixture=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run) dry=1 ;;
      --fixture) one_fixture="$2"; shift ;;
      *) echo "run.sh boundary: unknown arg '$1'" >&2; exit 2 ;;
    esac
    shift
  done

  # The fixture set comes from the barrel (glob), never a hand-maintained list.
  local fixtures=()
  if [ -n "$one_fixture" ]; then
    fixtures=("$one_fixture")
  else
    while IFS= read -r f; do fixtures+=("$f"); done < <(bash "$INDEX" list)
  fi

  if [ "$dry" -eq 1 ]; then
    echo "run.sh boundary --dry-run — no network. Planned per-fixture invocations:"
    local f
    for f in "${fixtures[@]}"; do
      local prompt expected boundary
      prompt="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).prompt)' "$f")"
      expected="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).expected)' "$f")"
      boundary="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).boundary)' "$f")"
      printf '  · [%s] expected=%s\n      keel-on : (cd $ON;  claude -p "%s" --output-format stream-json --verbose) | detect | judge --expected %s\n      keel-off: (cd $OFF; claude -p "%s" --output-format stream-json --verbose) | detect | judge --expected none\n' \
        "$boundary" "$expected" "$prompt" "$expected" "$prompt"
    done
    echo ""
    echo "Offline detect→judge pipeline smoke over the committed transcripts:"
    printf '  implement-feature-fired.jsonl (expect implement-feature): %s\n' \
      "$(judge_trace "$TX/implement-feature-fired.jsonl" implement-feature || true)"
    printf '  nothing-fired.jsonl           (expect none):              %s\n' \
      "$(judge_trace "$TX/nothing-fired.jsonl" none || true)"
    printf '  wrong-verb transcript         (expect implement-feature): %s\n' \
      "$(judge_trace "$TX/wrong-verb-implement-milestone.jsonl" implement-feature || true)"
    echo "(the third is a deliberate FAIL — the wrong verb fired; that is the eval catching a mis-route)"
    return 0
  fi

  # Live path (paid).
  require_claude
  local f
  for f in "${fixtures[@]}"; do
    local prompt expected boundary
    prompt="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).prompt)' "$f")"
    expected="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).expected)' "$f")"
    boundary="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).boundary)' "$f")"
    run_boundary_case_live "$boundary" "$prompt" "$expected"
  done
}

cmd_ab() {
  local fixture="" dry=0
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run) dry=1 ;;
      *) fixture="$1" ;;
    esac
    shift
  done
  [ -n "$fixture" ] || { echo "run.sh ab: need an A/B fixture path" >&2; exit 2; }

  if [ "$dry" -eq 1 ]; then
    # The committed A/B fixture already carries canned per-variant detected
    # results; the judge scores the comparison directly (no network).
    node "$JUDGE" ab "$fixture"
    return 0
  fi

  # Live path (paid): run each variant's prompts under a description overlay,
  # fill in `detected`, then judge. The description-variant overlay rides on
  # assumption (i)/(ii) — it is validated at the baseline run. Left as the live
  # path; the offline comparison is proven by judge.test.sh + `ab --dry-run`.
  require_claude
  echo "run.sh ab (live): spawns per-variant sessions — the paid A/B path." >&2
  echo "  Build a live ab-input by running each variant.description over its cases," >&2
  echo "  detecting each, then: node judge.js ab <live-ab-input.json>." >&2
  exit 3
}

# [runtime] LIVE BASELINE — the spend stop-point. Spawns real sessions and writes
# BASELINE.md. Guarded behind --confirm-spend; run by /verify-milestone, not the
# build. Reads as a normal boundary sweep whose results are captured to a report.
cmd_baseline() {
  local group="" out="$HERE/BASELINE.md" confirmed=0
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --group) group="$2"; shift ;;
      --out) out="$2"; shift ;;
      --confirm-spend) confirmed=1 ;;
      *) echo "run.sh baseline: unknown arg '$1'" >&2; exit 2 ;;
    esac
    shift
  done
  if [ "$confirmed" -ne 1 ]; then
    echo "run.sh baseline: refusing to spend tokens without --confirm-spend." >&2
    echo "  This is the milestone's [runtime] stop-point; /verify-milestone authorizes it." >&2
    exit 4
  fi
  [ -n "$group" ] || { echo "run.sh baseline: need --group <boundary>" >&2; exit 2; }
  require_claude

  {
    echo "# Skill-trigger eval — live baseline"
    echo ""
    echo "Boundary group: \`$group\`. Keel-enabled vs disabled fresh \`claude -p\` sessions."
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
    local f
    while IFS= read -r f; do
      local boundary prompt expected
      boundary="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).boundary)' "$f")"
      [ "$boundary" = "$group" ] || continue
      prompt="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).prompt)' "$f")"
      expected="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).expected)' "$f")"
      echo "## $prompt"
      echo ""
      echo "Expected: \`$expected\`"
      echo ""
      run_boundary_case_live "$boundary" "$prompt" "$expected"
      echo ""
    done < <(bash "$INDEX" list)
  } > "$out"
  echo "run.sh baseline: wrote $out"
}

main() {
  local sub="${1:-}"; shift || true
  case "$sub" in
    boundary) cmd_boundary "$@" ;;
    ab)       cmd_ab "$@" ;;
    baseline) cmd_baseline "$@" ;;
    -h|--help|help|"") usage ;;
    *) echo "run.sh: unknown subcommand '$sub'" >&2; usage; exit 2 ;;
  esac
}
main "$@"

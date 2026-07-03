#!/usr/bin/env bash
#
# Self-test for detect.sh / detect.js — the activation detector's deterministic
# core. Runs the detector over the committed canned stream-json transcripts under
# fixtures/transcripts/ and asserts the detected grain verb equals each
# transcript's ground truth. No network, no live `claude -p`.
#
# Run: bash scripts/skill-eval/detect.test.sh

set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
DETECT="$HERE/detect.sh"
TX="$HERE/fixtures/transcripts"

pass=0 failc=0
# detected <transcript> <expected-verb>
detected() { # transcript-file  expected  desc
  local file="$1" exp="$2" desc="$3" got
  got="$(bash "$DETECT" "$TX/$file" 2>/dev/null)" || got="<error:$?>"
  if [ "$got" = "$exp" ]; then
    echo "ok   - $desc (detected '$got')"; pass=$((pass + 1))
  else
    echo "FAIL - $desc (detected '$got', want '$exp')"; failc=$((failc + 1))
  fi
}

# 1. A transcript where implement-feature fired → detect implement-feature.
detected implement-feature-fired.jsonl implement-feature \
  "implement-feature fired → detect implement-feature"

# 2. A transcript where nothing fired → detect none.
detected nothing-fired.jsonl none \
  "no skill fired → detect none"

# 3. A transcript where the WRONG verb (implement-milestone) fired → detect it.
#    (Ground truth is what actually fired, not what should have — the judge, not
#    the detector, decides right/wrong.)
detected wrong-verb-implement-milestone.jsonl implement-milestone \
  "wrong verb implement-milestone fired → detect implement-milestone"

# 4. stdin path parses identically (locks the `-` entry the runner may use).
got="$(bash "$DETECT" - < "$TX/implement-feature-fired.jsonl" 2>/dev/null)" || got="<error>"
if [ "$got" = "implement-feature" ]; then
  echo "ok   - stdin path detects implement-feature"; pass=$((pass + 1))
else
  echo "FAIL - stdin path (detected '$got', want 'implement-feature')"; failc=$((failc + 1))
fi

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]

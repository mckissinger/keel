#!/usr/bin/env bash
#
# detect.sh — the activation detector's bash entry point. Thin wrapper over
# detect.js (which isolates the stream-json trace-format assumption). Given a
# captured `claude -p` transcript, prints which keel grain verb fired, or `none`.
#
# The trace parsing lives in detect.js (Node built-ins only, keel's no-dependency
# bar) because robust newline-delimited-JSON walking is cleaner in node than bash;
# this wrapper keeps the harness's shell surface uniform (run.sh + the *.test.sh
# suites all shell out through here).
#
# Usage: scripts/skill-eval/detect.sh <transcript-file>   (or - for stdin)
# Exit 0 = clean parse (verb or `none` on stdout). Non-zero = unreadable input.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

if [ "$#" -lt 1 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "usage: scripts/skill-eval/detect.sh <transcript-file|->" >&2
  [ "$#" -ge 1 ] && exit 0 || exit 2
fi

exec node "$HERE/detect.js" "$1"

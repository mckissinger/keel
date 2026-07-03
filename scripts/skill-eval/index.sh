#!/usr/bin/env bash
#
# index.sh — the fixture BARREL. Assembles the boundary fixtures purely by GLOB
# over fixtures/*.json, so registering a fixture is dropping in a NEW FILE — never
# an edit to a shared registry. The glob is non-recursive, so the canned-data
# subdirs (fixtures/transcripts/, fixtures/ab/) are excluded by construction.
#
# Modes:
#   index.sh            # or `list` — print each fixture's path, one per line
#   index.sh --count    # print the number of registered fixtures
#   index.sh --json     # emit a JSON array of {file,prompt,expected,boundary}
#                       #   (what run.sh consumes to drive the boundary sweep)
#
# Usage: scripts/skill-eval/index.sh [list|--count|--json]

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

shopt -s nullglob
fixtures=("$HERE"/fixtures/*.json)
shopt -u nullglob

mode="${1:-list}"
case "$mode" in
  list|"")
    for f in "${fixtures[@]}"; do echo "$f"; done
    ;;
  --count)
    echo "${#fixtures[@]}"
    ;;
  --json)
    # Assemble via node (already a harness dependency), passing each globbed path
    # as an argv so each fixture is JSON-validated as it folds into the barrel.
    node -e '
      const fs = require("fs");
      const out = process.argv.slice(1).map((file) => {
        const fx = JSON.parse(fs.readFileSync(file, "utf8"));
        return { file, prompt: fx.prompt, expected: fx.expected, boundary: fx.boundary };
      });
      process.stdout.write(JSON.stringify(out, null, 2) + "\n");
    ' "${fixtures[@]}"
    ;;
  -h|--help)
    echo "usage: scripts/skill-eval/index.sh [list|--count|--json]" >&2
    ;;
  *)
    echo "index.sh: unknown mode '$mode' (want list|--count|--json)" >&2
    exit 2
    ;;
esac

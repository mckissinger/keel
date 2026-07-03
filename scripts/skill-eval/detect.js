#!/usr/bin/env node
'use strict';
//
// detect.js — the isolated trace-format parser for the skill-trigger evals.
//
// Given the raw stdout of a headless `claude -p ... --output-format stream-json`
// session, decide which keel skill (grain verb) fired, or `none`. This is the
// deterministic core the whole harness pins on: run.sh captures a live trace,
// hands it here, and passes the answer to judge.js.
//
// ── THE ONE TRACE-FORMAT ASSUMPTION (validated at the live BASELINE run) ──────
// `claude -p --output-format stream-json` emits newline-delimited JSON events.
// A keel skill firing shows up as the model invoking the `Skill` tool: an
// `assistant` event whose message content carries a `tool_use` block with
//   name == "Skill" and input.skill == "<plugin>:<verb>" (e.g. "keel:implement-feature").
// We return the FIRST such verb (plugin prefix stripped), or `none` if no Skill
// tool_use appears anywhere in the transcript.
//
// This assumption — the exact event shape — is deliberately confined to the ONE
// function `detectSkill()` below (and specifically its `skillFromEvent` helper),
// so if the live baseline reveals a different shape, the fix is one function, not
// a harness rewrite. A second recognized shape (a top-level event carrying a
// `skill`/`skill_name` field) is included as a cheap hedge on the same seam.
//
// Node built-ins only (keel's no-dependency bar): no require of any third-party
// module, no package.json.
//
// Usage:
//   node detect.js <transcript-file>   # reads the file
//   node detect.js -                   # reads stdin
// Prints the detected verb (or `none`) on stdout. Exit 0 on a clean parse.

const fs = require('fs');

// Strip a leading `<plugin>:` namespace from a Skill id → the bare grain verb.
// keel skills are namespaced `keel:<verb>`; a bare `<verb>` is returned as-is.
function bareVerb(skillId) {
  if (typeof skillId !== 'string') return null;
  const trimmed = skillId.trim();
  if (!trimmed) return null;
  const colon = trimmed.indexOf(':');
  return colon === -1 ? trimmed : trimmed.slice(colon + 1);
}

// The trace-shape seam. Given one parsed stream-json event, return the fired
// grain verb if this event represents a keel Skill activation, else null.
// EDIT HERE (only here) if the live baseline shows a different event shape.
function skillFromEvent(event) {
  if (!event || typeof event !== 'object') return null;

  // Shape 1 (primary): an assistant turn whose content carries a Skill tool_use.
  const msg = event.message;
  const content = (msg && Array.isArray(msg.content)) ? msg.content
                : (Array.isArray(event.content) ? event.content : null);
  if (content) {
    for (const block of content) {
      if (block && block.type === 'tool_use' && block.name === 'Skill') {
        const input = block.input || {};
        const verb = bareVerb(input.skill || input.name);
        if (verb) return verb;
      }
    }
  }

  // Shape 2 (hedge): a top-level event that names the skill directly, e.g.
  // {"type":"system","subtype":"skill_activated","skill":"keel:implement-feature"}.
  if (typeof event.subtype === 'string' && /skill/i.test(event.subtype)) {
    const verb = bareVerb(event.skill || event.skill_name);
    if (verb) return verb;
  }

  return null;
}

// Parse a whole transcript (raw stream-json stdout) → the first fired verb, or
// `none`. Malformed lines are skipped (a partial/interleaved line is not a
// detection signal), which keeps the parser robust to trailing noise.
function detectSkill(transcript) {
  const lines = String(transcript).split('\n');
  for (const line of lines) {
    const s = line.trim();
    if (!s) continue;
    let event;
    try {
      event = JSON.parse(s);
    } catch (_) {
      continue; // not a JSON event line — ignore
    }
    const verb = skillFromEvent(event);
    if (verb) return verb;
  }
  return 'none';
}

module.exports = { detectSkill, skillFromEvent, bareVerb };

// CLI entry: `node detect.js <file|->`.
if (require.main === module) {
  const arg = process.argv[2];
  if (!arg || arg === '--help' || arg === '-h') {
    process.stderr.write('usage: node detect.js <transcript-file|->\n');
    process.exit(arg ? 0 : 2);
  }
  let raw;
  try {
    raw = fs.readFileSync(arg === '-' ? 0 : arg, 'utf8');
  } catch (err) {
    process.stderr.write('detect: cannot read transcript: ' + err.message + '\n');
    process.exit(1);
  }
  process.stdout.write(detectSkill(raw) + '\n');
}

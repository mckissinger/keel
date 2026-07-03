#!/usr/bin/env node
'use strict';
//
// judge.js — the skill-trigger eval's scorer. Node built-ins only (keel's
// no-dependency bar: no package.json, no third-party require).
//
// Two modes:
//
//   score  — one detection against one fixture's `expected`.
//     node judge.js score --expected <verb|none> --detected <verb|none>
//     Prints a JSON verdict; exit 0 = pass, 1 = fail.
//
//   ab     — a description-variant A/B comparison. Given two variants each run
//     over the SAME fixtures (canned detection results, or live results captured
//     by run.sh), emit a COMPARATIVE trigger-accuracy result.
//     node judge.js ab <ab-input.json>
//     Prints a JSON report; exit 0 on a clean computation.
//
// ── SCORING RULE (documented, single source of truth) ────────────────────────
// A fixture declares `expected` = the single keel grain verb that SHOULD fire for
// the prompt, or `none` if NO keel verb should fire. A case PASSES iff
//   detected === expected.
//   • should-trigger fixture  → expected = the intended verb; pass when it fired.
//   • should-not-trigger      → expected = `none` (nothing should fire) OR the
//     correct SIBLING verb when the point is that a confusable verb must stay
//     silent while its sibling fires. Either way, the confusable/wrong verb
//     firing gives detected !== expected → fail (a mismatch).
// This is the whole rule; the comparative A/B accuracy is just this rule tallied
// per variant.

const fs = require('fs');

function scoreCase(expected, detected) {
  return detected === expected;
}

function accuracy(cases) {
  const total = cases.length;
  let passed = 0;
  const scored = cases.map((c) => {
    const pass = scoreCase(c.expected, c.detected);
    if (pass) passed += 1;
    return { expected: c.expected, detected: c.detected, pass };
  });
  return {
    passed,
    total,
    accuracy: total === 0 ? 0 : passed / total,
    cases: scored,
  };
}

function parseFlags(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i += 1) {
    const a = argv[i];
    if (a.startsWith('--')) {
      out[a.slice(2)] = argv[i + 1];
      i += 1;
    }
  }
  return out;
}

function usage(code) {
  process.stderr.write(
    'usage:\n' +
    '  node judge.js score --expected <verb|none> --detected <verb|none>\n' +
    '  node judge.js ab <ab-input.json>\n'
  );
  process.exit(code);
}

function runScore(argv) {
  const f = parseFlags(argv);
  if (f.expected === undefined || f.detected === undefined) usage(2);
  const pass = scoreCase(f.expected, f.detected);
  const verdict = {
    mode: 'score',
    expected: f.expected,
    detected: f.detected,
    pass,
  };
  process.stdout.write(JSON.stringify(verdict) + '\n');
  process.exit(pass ? 0 : 1);
}

function runAb(argv) {
  const inputPath = argv[0];
  if (!inputPath) usage(2);
  let spec;
  try {
    spec = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
  } catch (err) {
    process.stderr.write('judge: cannot read A/B input: ' + err.message + '\n');
    process.exit(1);
  }
  const a = spec.variantA || {};
  const b = spec.variantB || {};
  const ra = accuracy(a.cases || []);
  const rb = accuracy(b.cases || []);
  const delta = rb.accuracy - ra.accuracy; // >0 ⇒ variant B is more accurate
  let better = 'tie';
  if (delta > 0) better = 'variantB';
  else if (delta < 0) better = 'variantA';
  const report = {
    mode: 'ab',
    skill: spec.skill,
    pair: spec.pair,
    measures: spec.measures,
    variantA: { label: a.label, ...ra },
    variantB: { label: b.label, ...rb },
    delta,
    better,
  };
  process.stdout.write(JSON.stringify(report, null, 2) + '\n');
  process.exit(0);
}

module.exports = { scoreCase, accuracy };

if (require.main === module) {
  const [, , mode, ...rest] = process.argv;
  if (mode === 'score') runScore(rest);
  else if (mode === 'ab') runAb(rest);
  else if (mode === '--help' || mode === '-h' || mode === undefined) usage(mode ? 0 : 2);
  else usage(2);
}

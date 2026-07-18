#!/usr/bin/env node
// funnel-readout.mjs — project-committed funnel readout adapter (TEMPLATE).
//
// This is a template a product repo or growth-ops repo commits and owns, with a
// SWAPPABLE PROVIDER — keel records the contract, never mandates the
// implementation. READ-ONLY BY CONSTRUCTION: this script contains no write call
// to any provider API — every provider request is a GET, and pause belongs to
// the campaign readback script, never here. Measurement reads provider state
// and never writes it (references/growth-operations.md §10, cited not
// restated); a fork of this file that adds a provider write is malformed.
//
// The contract (per references/growth-operations.md, cited not restated):
//   - reads:  the PINNED metrics spec — specs/gtm/metrics.md at the path +
//             commit recorded in metrics-pins.json. The repo is canonical for
//             metric DEFINITIONS; the analytics provider is canonical for
//             product OUTCOMES (§10, extending §3). This script never mutates
//             either.
//   - reads:  funnel-stage event counts from the analytics provider's query
//             API, by the spec's canonical event names.
//   - joins:  when run in a growth-ops repo (--dispatch-ledger given), dispatch
//             ledger entries against provider outcomes at COHORT level only —
//             campaign/channel granularity via tagged links (UTM/ref). It
//             never queries, stores, or emits any linkage between an outreach
//             contact's identity and a product account (§10).
//   - writes: one readout snapshot file per run under the readouts/ dir of the
//             repo it runs in (file-per-entry — §8's collision discipline).
//             That local file is its ONLY write.
//   - flags:  staleness — the product repo moved past the pinned metrics-spec
//             commit (§9). A flag for the attended sitting, never a refresh.
//   - key:    read from an environment variable — NEVER a literal in this
//             file. The key's NAME lives in the repo's environment contract.
//
// Default provider shape: a generic product-analytics query API (as of
// 2026-07, mainstream analytics platforms ship read-only event-count endpoints
// with this shape). To swap providers, replace fetchEventCounts() and the
// env-var names; the calling convention, the snapshot format, and the
// read-only guarantee stay.
//
// Usage:
//   node scripts/funnel-readout.mjs --metrics-pins specs/gtm/metrics-pins.json \
//     [--product-repo <path>] [--dispatch-ledger <dir>]
//
// Expects metrics-pins.json (committed, read-only to this script):
//   { "path": "specs/gtm/metrics.md", "commit": "<sha>",
//     "events": { "acquisition": "<name>", "signup": "<name>",
//                 "activation": "<name>", "retention": "<name>" },
//     "cohort_tags": ["<campaign-slug>", ...] }
// The events block mirrors the spec's canonical event names so the adapter
// needs no markdown parsing; the spec file remains the human-readable truth.

import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { parseArgs } from "node:util";

const ENV_KEY_NAME = "ANALYTICS_PROVIDER_API_KEY"; // the contract records this NAME
const ENV_BASE_URL_NAME = "ANALYTICS_PROVIDER_API_BASE_URL"; // provider endpoint, also by name

const execFileAsync = promisify(execFile);

const { values } = parseArgs({
  options: {
    "metrics-pins": { type: "string" },
    "product-repo": { type: "string" },
    "dispatch-ledger": { type: "string" },
  },
});

if (!values["metrics-pins"]) {
  console.error(
    "usage: funnel-readout.mjs --metrics-pins <path> [--product-repo <path>] [--dispatch-ledger <dir>]",
  );
  process.exit(1);
}

const apiKey = process.env[ENV_KEY_NAME];
const baseUrl = process.env[ENV_BASE_URL_NAME];
if (!apiKey || !baseUrl) {
  console.error(
    `missing ${!apiKey ? ENV_KEY_NAME : ENV_BASE_URL_NAME} in the environment — run the repo's name-check command; provision the key if absent`,
  );
  process.exit(1);
}

async function readJson(path) {
  try {
    return JSON.parse(await readFile(path, "utf8"));
  } catch {
    return null;
  }
}

const pins = await readJson(values["metrics-pins"]);
if (!pins?.path || !pins?.commit || !pins?.events) {
  console.error(
    `no readable pins (path + commit + events) in ${values["metrics-pins"]} — a readout without a pinned metrics spec is a number nobody agreed to; refusing to run`,
  );
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Provider adapter — swap this function (and the env-var names above) to
// change providers. GET only: this script performs no provider write, ever.
// ---------------------------------------------------------------------------

async function fetchEventCounts(eventName, cohortTag) {
  const url = new URL(
    `${baseUrl.replace(/\/$/, "")}/events/${encodeURIComponent(eventName)}/count`,
  );
  if (cohortTag) url.searchParams.set("utm_campaign", cohortTag);
  const res = await fetch(url, { headers: { Authorization: `Bearer ${apiKey}` } });
  if (!res.ok) throw new Error(`provider error ${res.status}: ${await res.text()}`);
  // Expected shape: { count }
  const body = await res.json();
  return body.count ?? 0;
}

// ---------------------------------------------------------------------------
// Funnel numbers — the spec's canonical event names, straight through.
// ---------------------------------------------------------------------------

const stages = ["acquisition", "signup", "activation", "retention"];
const funnel = {};
for (const stage of stages) {
  const eventName = pins.events[stage];
  funnel[stage] = eventName
    ? { event: eventName, count: await fetchEventCounts(eventName) }
    : { event: null, count: null, note: "no canonical event pinned for this stage" };
}

// ---------------------------------------------------------------------------
// Cohort join — growth-ops repos only. Campaign/channel granularity via tagged
// links; NEVER an identity join between an outreach contact and an account.
// ---------------------------------------------------------------------------

const cohorts = [];
if (values["dispatch-ledger"]) {
  const ledgerDir = values["dispatch-ledger"];
  let entries = [];
  try {
    entries = (await readdir(ledgerDir)).filter((f) => f.endsWith(".json")).sort();
  } catch {
    console.error(`could not read dispatch ledger dir ${ledgerDir} — skipping cohort join`);
  }
  const tags = pins.cohort_tags ?? [];
  for (const tag of tags) {
    const dispatched = [];
    for (const f of entries) {
      const entry = await readJson(join(ledgerDir, f));
      if (entry?.campaign === tag) dispatched.push({ file: join(ledgerDir, f), counts: entry.counts ?? null });
    }
    cohorts.push({
      campaign: tag,
      dispatch_evidence: dispatched, // ledger files — the cohort's send-side evidence
      outcomes: {
        signups: await fetchEventCounts(pins.events.signup, tag),
        activated: await fetchEventCounts(pins.events.activation, tag),
      },
    });
  }
}

// Staleness: the product repo moved past the pinned metrics-spec commit. A
// FLAG for the attended sitting — never a silent refresh of the pin.
let staleness = null;
if (values["product-repo"]) {
  try {
    const { stdout } = await execFileAsync("git", ["-C", values["product-repo"], "rev-parse", "HEAD"]);
    const head = stdout.trim();
    if (!head.startsWith(pins.commit) && !pins.commit.startsWith(head)) {
      staleness = `product repo HEAD ${head.slice(0, 12)} has moved past pinned metrics-spec commit ${pins.commit} — attended sitting must judge whether the definitions still stand`;
    }
  } catch (err) {
    staleness = `could not resolve product repo HEAD (${err.message}) — staleness unknown`;
  }
}

// One NEW readout snapshot per run — never an edit to a shared growing file,
// never a write to spec/pin/ledger files, never a write to the provider.
const snapshot = {
  read_at: new Date().toISOString(),
  metrics_spec: { path: pins.path, commit: pins.commit }, // evidence pointer: the definitions this readout used
  funnel,
  cohorts,
  staleness_flag: staleness,
};

const outDir = "readouts";
await mkdir(outDir, { recursive: true });
const outPath = join(outDir, `${snapshot.read_at.replace(/[:.]/g, "-")}.json`);
await writeFile(outPath, JSON.stringify(snapshot, null, 2) + "\n");

console.log(`wrote ${outPath}`);
if (staleness) console.log(`STALENESS FLAG: ${staleness}`);

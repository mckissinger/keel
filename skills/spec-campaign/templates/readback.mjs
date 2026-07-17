#!/usr/bin/env node
// readback.mjs — project-committed campaign readback script (TEMPLATE).
//
// This is a template a growth-ops repo commits and owns, with a SWAPPABLE
// PROVIDER — keel records the contract, never mandates the implementation.
// The contract (per references/growth-operations.md, cited not restated):
//   - reads:  provider outcome metrics by API (the provider is canonical for
//             outcomes — §3) and the campaign's committed intent files
//             (thresholds, pinned lineage) — which it NEVER mutates. The repo
//             is canonical for intent; this script only ever writes NEW
//             outcome files.
//   - writes: one outcome snapshot file per run under the campaign's
//             outcomes/ dir (file-per-entry — §8's collision discipline).
//   - flags:  staleness — the product repo moved past the campaign's pinned
//             commit (§9). A flag for the attended sitting, never a refresh.
//   - acts:   on a breached stop-condition it PAUSES the campaign via the
//             provider API — the one always-allowed unattended write (§2, §4).
//             Everything else it merely reports.
//   - key:    read from an environment variable — NEVER a literal in this
//             file. The key's NAME lives in the growth-ops environment
//             contract and is asserted via the recorded name-check command
//             (values never printed).
//
// Default provider shape: a generic sending/scheduling API adapter (as of
// 2026-07, sending platforms ship metrics + pause endpoints with this shape).
// To swap providers, replace fetchMetrics() / pauseCampaign() and the env-var
// names; the calling convention, the snapshot format, and the pause-on-breach
// behavior stay.
//
// Usage:
//   node scripts/readback.mjs --campaign campaigns/<slug> [--product-repo <path>]
//
// Expects in the campaign dir (committed intent, read-only to this script):
//   stop-conditions.json  { "bounce_rate_max": 0.03, "complaint_rate_max": 0.001,
//                           "reply_rate_min": 0.01, "budget_cap": 500 }
//   pins.json             { "product_repo": "<name>", "commit": "<sha>", "paths": [...] }

import { mkdir, readFile, writeFile } from "node:fs/promises";
import { basename, join } from "node:path";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { parseArgs } from "node:util";

const ENV_KEY_NAME = "GROWTH_PROVIDER_API_KEY"; // the contract records this NAME
const ENV_BASE_URL_NAME = "GROWTH_PROVIDER_API_BASE_URL"; // provider endpoint, also by name

const execFileAsync = promisify(execFile);

const { values } = parseArgs({
  options: {
    campaign: { type: "string" },
    "product-repo": { type: "string" },
  },
});

if (!values.campaign) {
  console.error("usage: readback.mjs --campaign campaigns/<slug> [--product-repo <path>]");
  process.exit(1);
}

const apiKey = process.env[ENV_KEY_NAME];
const baseUrl = process.env[ENV_BASE_URL_NAME];
if (!apiKey || !baseUrl) {
  console.error(`missing ${!apiKey ? ENV_KEY_NAME : ENV_BASE_URL_NAME} in the environment — run the repo's name-check command; provision the key if absent`);
  process.exit(1);
}

const campaignDir = values.campaign;
const campaignSlug = basename(campaignDir);

async function readJson(path) {
  try {
    return JSON.parse(await readFile(path, "utf8"));
  } catch {
    return null;
  }
}

const stopConditions = await readJson(join(campaignDir, "stop-conditions.json"));
if (!stopConditions) {
  console.error(`no readable stop-conditions.json in ${campaignDir} — a campaign without committed stop-conditions is malformed; refusing to read back`);
  process.exit(1);
}
const pins = await readJson(join(campaignDir, "pins.json"));

// ---------------------------------------------------------------------------
// Provider adapters — swap these two functions (and the env-var names above)
// to change providers.
// ---------------------------------------------------------------------------

async function fetchMetrics() {
  const res = await fetch(
    `${baseUrl.replace(/\/$/, "")}/campaigns/${encodeURIComponent(campaignSlug)}/metrics`,
    { headers: { Authorization: `Bearer ${apiKey}` } },
  );
  if (!res.ok) throw new Error(`provider error ${res.status}: ${await res.text()}`);
  // Expected shape: { sent, bounces, complaints, replies, spend }
  return res.json();
}

async function pauseCampaign(reason) {
  const res = await fetch(
    `${baseUrl.replace(/\/$/, "")}/campaigns/${encodeURIComponent(campaignSlug)}/pause`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({ reason }),
    },
  );
  if (!res.ok) throw new Error(`provider pause failed ${res.status}: ${await res.text()}`);
}

// ---------------------------------------------------------------------------
// Read back outcomes and evaluate the committed tripwires.
// ---------------------------------------------------------------------------

const metrics = await fetchMetrics();
const sent = metrics.sent ?? 0;
const rate = (n) => (sent > 0 ? n / sent : 0);

const breaches = [];
if (stopConditions.bounce_rate_max != null && rate(metrics.bounces ?? 0) > stopConditions.bounce_rate_max) {
  breaches.push(`bounce rate ${rate(metrics.bounces ?? 0).toFixed(4)} > ceiling ${stopConditions.bounce_rate_max}`);
}
if (stopConditions.complaint_rate_max != null && rate(metrics.complaints ?? 0) > stopConditions.complaint_rate_max) {
  breaches.push(`complaint rate ${rate(metrics.complaints ?? 0).toFixed(4)} > ceiling ${stopConditions.complaint_rate_max}`);
}
if (stopConditions.reply_rate_min != null && stopConditions.reply_rate_min_after != null
    && sent >= stopConditions.reply_rate_min_after
    && rate(metrics.replies ?? 0) < stopConditions.reply_rate_min) {
  breaches.push(`reply rate ${rate(metrics.replies ?? 0).toFixed(4)} < floor ${stopConditions.reply_rate_min} after ${sent} sends`);
}
if (stopConditions.budget_cap != null && (metrics.spend ?? 0) > stopConditions.budget_cap) {
  breaches.push(`spend ${metrics.spend} > budget cap ${stopConditions.budget_cap}`);
}

// Staleness: the product repo moved past the pinned commit. A FLAG for the
// attended sitting — never a silent refresh of any intent file.
let staleness = null;
if (pins?.commit && values["product-repo"]) {
  try {
    const { stdout } = await execFileAsync("git", ["-C", values["product-repo"], "rev-parse", "HEAD"]);
    const head = stdout.trim();
    if (!head.startsWith(pins.commit) && !pins.commit.startsWith(head)) {
      staleness = `product repo HEAD ${head.slice(0, 12)} has moved past pinned commit ${pins.commit} — attended sitting must judge whether in-flight copy still stands`;
    }
  } catch (err) {
    staleness = `could not resolve product repo HEAD (${err.message}) — staleness unknown`;
  }
}

// Breached tripwire → pause via the provider API. Pause is the one write this
// script may perform unattended; it changes provider state only, never a
// committed intent file.
let paused = false;
if (breaches.length > 0) {
  await pauseCampaign(`stop-condition breach: ${breaches.join("; ")}`);
  paused = true;
  console.error(`PAUSED ${campaignSlug} via provider API — ${breaches.join("; ")}`);
}

// One NEW outcome snapshot per run — never an edit to a shared growing file,
// never a write to queue/approvals/spec files.
const snapshot = {
  campaign: campaignSlug,
  read_at: new Date().toISOString(),
  metrics,
  rates: {
    bounce: rate(metrics.bounces ?? 0),
    complaint: rate(metrics.complaints ?? 0),
    reply: rate(metrics.replies ?? 0),
  },
  stop_condition_breaches: breaches,
  paused_via_provider: paused,
  staleness_flag: staleness,
};

const outDir = join(campaignDir, "outcomes");
await mkdir(outDir, { recursive: true });
const outPath = join(outDir, `${snapshot.read_at.replace(/[:.]/g, "-")}.json`);
await writeFile(outPath, JSON.stringify(snapshot, null, 2) + "\n");

console.log(`wrote ${outPath}`);
if (staleness) console.log(`STALENESS FLAG: ${staleness}`);
if (!paused) console.log(`no stop-condition breach — campaign running within its envelope`);

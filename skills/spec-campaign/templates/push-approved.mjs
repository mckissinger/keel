#!/usr/bin/env node
// push-approved.mjs — project-committed campaign push script (TEMPLATE).
//
// This is a template a growth-ops repo commits and owns, with a SWAPPABLE
// PROVIDER — keel records the contract, never mandates the implementation.
// The contract:
//   - input:  a queue file (one approved batch of outbound items)
//   - gate:   the queue invariant (references/growth-operations.md §1) —
//             nothing pushes without a matching approval record for THIS
//             queue file's exact content. The gate is enforced below in
//             logic, not by convention: no record, no push; stale record
//             (queue edited after approval), no push.
//   - output: approved items handed to the provider API for execution
//   - key:    read from an environment variable — NEVER a literal in this
//             file. The key's NAME lives in the growth-ops environment
//             contract and is asserted via the recorded name-check command
//             (values never printed).
//
// Default provider shape: a generic sending/scheduling API adapter (as of
// 2026-07, sending platforms ship agent-facing APIs with this shape). To
// swap providers, replace pushItem() and the env-var names; the calling
// convention and the approval gate stay.
//
// Usage:
//   node scripts/push-approved.mjs --queue campaigns/<slug>/queue/<batch>.json
//   node scripts/push-approved.mjs --queue <batch>.json --dry-run

import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { basename, dirname, join } from "node:path";
import { parseArgs } from "node:util";

const ENV_KEY_NAME = "GROWTH_PROVIDER_API_KEY"; // the contract records this NAME
const ENV_BASE_URL_NAME = "GROWTH_PROVIDER_API_BASE_URL"; // provider endpoint, also by name

const { values } = parseArgs({
  options: {
    queue: { type: "string" },
    "dry-run": { type: "boolean", default: false },
  },
});

if (!values.queue) {
  console.error("usage: push-approved.mjs --queue <queue-file.json> [--dry-run]");
  process.exit(1);
}

const apiKey = process.env[ENV_KEY_NAME];
if (!apiKey && !values["dry-run"]) {
  console.error(`missing ${ENV_KEY_NAME} in the environment — run the repo's name-check command; provision the key if absent`);
  process.exit(1);
}

// ---------------------------------------------------------------------------
// THE APPROVAL GATE — the queue invariant, mechanically enforced.
// A queue file `campaigns/<slug>/queue/<batch>.json` requires the approval
// record `campaigns/<slug>/approvals/<batch>.approval.json`, written by an
// attended sitting, whose recorded hash matches the queue file's CURRENT
// content. This script refuses to run without it — that refusal is the
// contract, and removing it breaks the grain.
// ---------------------------------------------------------------------------

const queuePath = values.queue;
const queueRaw = await readFile(queuePath, "utf8").catch(() => null);
if (queueRaw === null) {
  console.error(`REFUSING to push: queue file not found: ${queuePath}`);
  process.exit(1);
}

const batchName = basename(queuePath).replace(/\.json$/, "");
const approvalPath = join(dirname(queuePath), "..", "approvals", `${batchName}.approval.json`);

const approvalRaw = await readFile(approvalPath, "utf8").catch(() => null);
if (approvalRaw === null) {
  console.error(`REFUSING to push: no approval record for this queue (expected ${approvalPath}).`);
  console.error("Nothing outbound executes without an approval record written by an attended sitting.");
  process.exit(1);
}

let approval;
try {
  approval = JSON.parse(approvalRaw);
} catch {
  console.error(`REFUSING to push: approval record is not valid JSON: ${approvalPath}`);
  process.exit(1);
}

if (approval.approved !== true) {
  console.error(`REFUSING to push: approval record does not carry approved: true (${approvalPath})`);
  process.exit(1);
}

const queueHash = createHash("sha256").update(queueRaw).digest("hex");
if (approval.queue_sha256 !== queueHash) {
  console.error(`REFUSING to push: approval record does not match this queue's content.`);
  console.error(`  approved queue_sha256: ${approval.queue_sha256 ?? "(absent)"}`);
  console.error(`  current  queue_sha256: ${queueHash}`);
  console.error("The queue changed after approval — re-approve it in an attended sitting.");
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Gate passed: hand the approved items to the provider.
// ---------------------------------------------------------------------------

const queue = JSON.parse(queueRaw);
const items = Array.isArray(queue.items) ? queue.items : [];
if (items.length === 0) {
  console.log(`queue ${batchName} is approved but empty — nothing to push`);
  process.exit(0);
}

async function pushItem(item) {
  // Provider adapter: swap this function (and the env-var names above) to
  // change providers. The default shape POSTs one outbound item to the
  // configured provider endpoint.
  const baseUrl = process.env[ENV_BASE_URL_NAME];
  if (!baseUrl) {
    throw new Error(`missing ${ENV_BASE_URL_NAME} in the environment`);
  }
  const res = await fetch(`${baseUrl.replace(/\/$/, "")}/outbound`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify(item),
  });
  if (!res.ok) throw new Error(`provider error ${res.status}: ${await res.text()}`);
  return res.json();
}

if (values["dry-run"]) {
  console.log(`dry-run: queue ${batchName} passes the approval gate (${items.length} item(s); approved by ${approval.approved_by ?? "unknown"} at ${approval.approved_at ?? "unknown"})`);
  process.exit(0);
}

let pushed = 0;
for (const item of items) {
  const result = await pushItem(item);
  pushed += 1;
  console.log(`pushed item ${pushed}/${items.length}: provider id ${result?.id ?? "(none)"}`);
}
console.log(`queue ${batchName}: ${pushed} item(s) handed to the provider — record the dispatch entry for this cycle`);

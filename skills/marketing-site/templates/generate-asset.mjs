#!/usr/bin/env node
// generate-asset.mjs — project-committed marketing-asset generator (TEMPLATE).
//
// This is a template a project commits and owns, with a SWAPPABLE PROVIDER —
// keel records the contract, never mandates the implementation. The contract:
//   - input:  a prompt and an output path (plus optional size/count flags)
//   - output: image file(s) written to the output path
//   - key:    read from an environment variable — NEVER a literal in this file.
//             The key's NAME lives in the project's environment contract and is
//             asserted via the recorded name-check command (values never printed).
//
// Default provider: Gemini image API. To swap providers, replace generateImage()
// and the env-var name; the calling convention stays.
//
// Usage:
//   node scripts/generate-asset.mjs --prompt "…" --out design/marketing/hero-01.png
//   node scripts/generate-asset.mjs --prompt "…" --out hero.png --count 3

import { writeFile } from "node:fs/promises";
import { parseArgs } from "node:util";

const ENV_KEY_NAME = "GEMINI_API_KEY"; // the contract records this NAME
const MODEL = "gemini-3-pro-image-preview"; // swap per provider/model choice

const { values } = parseArgs({
  options: {
    prompt: { type: "string" },
    out: { type: "string" },
    count: { type: "string", default: "1" },
  },
});

if (!values.prompt || !values.out) {
  console.error("usage: generate-asset.mjs --prompt <text> --out <path> [--count n]");
  process.exit(1);
}

const apiKey = process.env[ENV_KEY_NAME];
if (!apiKey) {
  console.error(`missing ${ENV_KEY_NAME} in the environment — run the project's name-check command; provision the key if absent`);
  process.exit(1);
}

async function generateImage(prompt) {
  // Provider default: Gemini image API. Swap this function to change providers.
  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { responseModalities: ["IMAGE"] },
      }),
    },
  );
  if (!res.ok) throw new Error(`provider error ${res.status}: ${await res.text()}`);
  const data = await res.json();
  const part = data.candidates?.[0]?.content?.parts?.find((p) => p.inlineData);
  if (!part) throw new Error("no image in response");
  return Buffer.from(part.inlineData.data, "base64");
}

const count = Number(values.count);
for (let i = 0; i < count; i++) {
  const out =
    count === 1 ? values.out : values.out.replace(/(\.\w+)$/, `-${i + 1}$1`);
  const image = await generateImage(values.prompt);
  await writeFile(out, image);
  console.log(`wrote ${out}`);
}

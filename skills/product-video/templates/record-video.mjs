#!/usr/bin/env node
// record-video.mjs — project-committed pipeline orchestrator for product-video (TEMPLATE).
//
// This is a template a project commits and owns, with SWAPPABLE PROVIDERS — keel
// records the contract, never mandates the implementation. The contract:
//   - input:  a scenes module (the scenes manifest realized as executable steps)
//             and the app's base URL
//   - output: an assembled MP4 + subtitles in the out dir — which is GITIGNORED
//             (sources are committed; renders are not)
//   - key:    the narration provider's key is read from an environment variable —
//             NEVER a literal in this file. The key's NAME lives in the project's
//             environment contract and is asserted via the recorded name-check
//             command (values never printed).
//
// Stage defaults (swap any function to change providers; the contract stays):
//   capture   — Playwright-class browser driver, video-recording context
//   narration — ElevenLabs TTS; zero-key fallback: a local TTS command named in
//               PRODUCT_VIDEO_TTS_CMD ("{text}"/"{out}" placeholders)
//   brand     — optional Remotion-class composition; the seed skips it (the
//               pipeline completes without it — post-process the MP4 to add it)
//   assembly  — ffmpeg mux: scene-aligned narration + subtitles
//
// Scenes module shape (derive it from the committed scenes manifest):
//   export default [
//     { title: "Open the report", narration: "…", timing: 6,
//       step: async (page) => { await page.click("text=Reports"); } },
//   ];
//
// Usage:
//   node scripts/record-video.mjs --scenes design/videos/<slug>/scenes.mjs \
//     --app http://localhost:3000 --out design/videos/out/<slug>

import { mkdir, writeFile, readdir } from "node:fs/promises";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { parseArgs } from "node:util";
import { resolve } from "node:path";

const run = promisify(execFile);

const ENV_KEY_NAME = "ELEVENLABS_API_KEY"; // the contract records this NAME
const VOICE_ID = process.env.ELEVENLABS_VOICE_ID ?? "21m00Tcm4TlvDq8ikWAM";

const { values } = parseArgs({
  options: {
    scenes: { type: "string" },
    app: { type: "string" },
    out: { type: "string" },
  },
});
if (!values.scenes || !values.app || !values.out) {
  console.error("usage: record-video.mjs --scenes <scenes.mjs> --app <url> --out <dir>");
  process.exit(1);
}
const outDir = resolve(values.out);
await mkdir(outDir, { recursive: true });
const scenes = (await import(resolve(values.scenes))).default;

// ---- 1. capture — drive the scenes against the seeded app, recording ---------
async function capture() {
  const { chromium } = await import("playwright"); // the profile's browser driver
  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    recordVideo: { dir: outDir, size: { width: 1280, height: 720 } },
  });
  const page = await context.newPage();
  await page.goto(values.app);
  const marks = [];
  const t0 = Date.now();
  for (const scene of scenes) {
    const start = (Date.now() - t0) / 1000;
    await scene.step(page);
    await page.waitForTimeout(Math.max(0, scene.timing * 1000 - ((Date.now() - t0) / 1000 - start) * 1000));
    marks.push({ ...scene, start, end: (Date.now() - t0) / 1000 });
  }
  await context.close();
  await browser.close();
  const file = (await readdir(outDir)).find((f) => f.endsWith(".webm"));
  return { video: resolve(outDir, file), marks };
}

// ---- 2. narration — TTS per scene (ElevenLabs default; local zero-key fallback)
async function narrate(scene, i) {
  const out = resolve(outDir, `scene-${i + 1}.mp3`);
  const apiKey = process.env[ENV_KEY_NAME];
  if (apiKey) {
    const res = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "xi-api-key": apiKey },
      body: JSON.stringify({ text: scene.narration, model_id: "eleven_multilingual_v2" }),
    });
    if (!res.ok) throw new Error(`provider error ${res.status}: ${await res.text()}`);
    await writeFile(out, Buffer.from(await res.arrayBuffer()));
  } else if (process.env.PRODUCT_VIDEO_TTS_CMD) {
    const [cmd, ...args] = process.env.PRODUCT_VIDEO_TTS_CMD.split(" ").map((a) =>
      a.replace("{text}", scene.narration).replace("{out}", out),
    );
    await run(cmd, args); // local engine — the zero-key fallback
  } else {
    throw new Error(
      `no ${ENV_KEY_NAME} in the environment and no PRODUCT_VIDEO_TTS_CMD fallback — ` +
        "run the project's name-check command; provision the key if absent",
    );
  }
  return out;
}

// ---- 3+4. assembly — subtitles + scene-aligned audio, muxed by ffmpeg ---------
function srtTime(s) {
  const d = new Date(s * 1000).toISOString();
  return `${d.slice(11, 19)},${d.slice(20, 23)}`;
}
async function assemble(video, marks, clips) {
  const srt = marks
    .map((m, i) => `${i + 1}\n${srtTime(m.start)} --> ${srtTime(m.end)}\n${m.narration}\n`)
    .join("\n");
  await writeFile(resolve(outDir, "video.srt"), srt);
  const inputs = clips.flatMap((c) => ["-i", c]);
  const delays = clips
    .map((_, i) => `[${i + 1}:a]adelay=${Math.round(marks[i].start * 1000)}|${Math.round(marks[i].start * 1000)}[a${i}]`)
    .join(";");
  const amix = clips.map((_, i) => `[a${i}]`).join("") + `amix=inputs=${clips.length}:normalize=0[aout]`;
  const out = resolve(outDir, "video.mp4");
  await run("ffmpeg", [
    "-y", "-i", video, ...inputs,
    "-filter_complex", `${delays};${amix}`,
    "-map", "0:v", "-map", "[aout]", "-c:v", "libx264", "-c:a", "aac", out,
  ]);
  return out;
}

const { video, marks } = await capture();
const clips = [];
for (const [i, scene] of scenes.entries()) clips.push(await narrate(scene, i));
const out = await assemble(video, marks, clips);
console.log(`wrote ${out} (+ video.srt) — brand layer, if any, post-processes this file`);

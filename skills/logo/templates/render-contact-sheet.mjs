#!/usr/bin/env node
// render-contact-sheet.mjs — project-committed logo contact-sheet renderer (TEMPLATE).
//
// This is a template a product repo commits and owns, with a SWAPPABLE
// RASTERIZER — keel records the contract, never mandates the implementation.
// LOCAL BY CONSTRUCTION: this script performs no network call of any kind —
// it reads SVG masters from the local filesystem, rasterizes them through a
// locally installed module, and writes PNGs plus an HTML contact sheet. A fork
// of this file that adds a network call is malformed.
//
// The contract (per the logo skill's references/logo-craft.md, cited not
// restated):
//   - reads:  SVG masters under the masters dir, named per the kit convention
//             <product>-logo-<lockup>-<colorway>.svg
//             (lockups: horizontal|stacked|icon; colorways: color|mono|reversed).
//   - writes: the raster matrix into the out dir — the 16/32/64px favicon
//             strip (icon lockup), a forced-monochrome check variant of each
//             color master, the reversed masters on a dark ground, the
//             favicon/PWA set sizes (32, 180, 192, 512, 512-maskable frame),
//             and the OG size (1200×630) — plus contact-sheet.html, a local
//             page laying the matrix out on light and dark grounds for the
//             render-and-verify loop and the integration milestone's [auto]
//             quality gates (16px legibility, monochrome survival, dark/light
//             reversal).
//   - rasterizer: PLUGGABLE, resolved by loadRasterizer() below — never a
//             hardcoded dependency on one vendor. The env var RASTERIZER_MODULE
//             (a NAME recorded in the repo's environment contract; its value is
//             a local module path or package name) points at a wrapper module
//             exporting:
//                 rasterize(svgString, { width, height, background }) -> PNG bytes
//             As of 2026-07, several locally installed SVG rasterizer packages
//             (e.g. a resvg-family binding, or a general image library with SVG
//             input) back this contract with a wrapper of a few lines. The
//             wrapper letterboxes ("contain") when the target aspect differs.
//
// Usage:
//   node scripts/render-contact-sheet.mjs --masters design/brand \
//     [--out design/brand/contact-sheet]
//
// Exit is non-zero when no masters are found or the rasterizer is missing, so
// the [auto] gates fail loudly instead of passing on an empty sheet.

import { mkdir, readdir, readFile, writeFile } from "node:fs/promises";
import { basename, join } from "node:path";
import { parseArgs } from "node:util";

const RASTERIZER_ENV_NAME = "RASTERIZER_MODULE"; // the contract records this NAME

const { values } = parseArgs({
  options: {
    masters: { type: "string" },
    out: { type: "string" },
  },
});

if (!values.masters) {
  console.error("usage: render-contact-sheet.mjs --masters <dir> [--out <dir>]");
  process.exit(1);
}
const mastersDir = values.masters;
const outDir = values.out ?? join(mastersDir, "contact-sheet");

// ---------------------------------------------------------------------------
// Rasterizer adapter — swap the module the env var names to change rasterizers.
// Local module resolution only; this function performs no network access.
// ---------------------------------------------------------------------------

async function loadRasterizer() {
  const moduleId = process.env[RASTERIZER_ENV_NAME];
  if (!moduleId) {
    console.error(
      `missing ${RASTERIZER_ENV_NAME} in the environment — point it at a local wrapper module exporting rasterize(svgString, { width, height, background }) -> PNG bytes. As of 2026-07 several locally installed SVG rasterizer packages back this contract in a few wrapper lines; none is required by keel.`,
    );
    process.exit(1);
  }
  const mod = await import(moduleId);
  const rasterize = mod.rasterize ?? mod.default?.rasterize;
  if (typeof rasterize !== "function") {
    console.error(`${moduleId} does not export rasterize(svgString, opts)`);
    process.exit(1);
  }
  return rasterize;
}

// ---------------------------------------------------------------------------
// Master discovery — the kit naming convention, straight through.
// ---------------------------------------------------------------------------

const MASTER_RE = /^(.+)-logo-(horizontal|stacked|icon)-(color|mono|reversed)\.svg$/;

async function discoverMasters(dir) {
  let files = [];
  try {
    files = (await readdir(dir)).sort();
  } catch {
    console.error(`could not read masters dir ${dir}`);
    process.exit(1);
  }
  const masters = [];
  for (const f of files) {
    const m = MASTER_RE.exec(basename(f));
    if (m) masters.push({ file: join(dir, f), product: m[1], lockup: m[2], colorway: m[3] });
  }
  return masters;
}

// Forced-monochrome CHECK variant (quality gate 2): flatten every fill/stroke
// to a single black. A verification transform for the sheet only — the
// committed mono masters remain the deliverable, this never replaces them.
function forceMonochrome(svg) {
  return svg
    .replace(/(fill|stroke)="(?!none)[^"]*"/gi, '$1="#000000"')
    .replace(/(fill|stroke):\s*(?!none)[^;"'}]+/gi, "$1:#000000");
}

// ---------------------------------------------------------------------------
// The raster matrix.
// ---------------------------------------------------------------------------

const rasterize = await loadRasterizer();
const masters = await discoverMasters(mastersDir);
if (masters.length === 0) {
  console.error(
    `no masters matching <product>-logo-<lockup>-<colorway>.svg under ${mastersDir} — refusing to emit an empty contact sheet`,
  );
  process.exit(1);
}

await mkdir(outDir, { recursive: true });

const cells = []; // { file, label, ground } rows for the HTML sheet
async function emit(name, svg, { width, height, background }, label, ground) {
  const png = await rasterize(svg, { width, height, background });
  const file = `${name}.png`;
  await writeFile(join(outDir, file), png);
  cells.push({ file, label, ground });
}

const LIGHT = "#ffffff";
const DARK = "#111111";

for (const m of masters) {
  const svg = await readFile(m.file, "utf8");
  const base = basename(m.file, ".svg");
  const ground = m.colorway === "reversed" ? DARK : LIGHT; // gate 3: both polarities on the sheet
  const bg = ground;

  if (m.lockup === "icon") {
    // Gate 1 — the 16/32/64 favicon strip.
    for (const px of [16, 32, 64]) {
      await emit(`${base}-${px}`, svg, { width: px, height: px, background: bg }, `${base} @ ${px}px`, ground);
    }
    // Favicon/PWA set sizes (the ICO's 32px source; apple-touch 180 is opaque
    // by construction here — every cell renders on a solid ground).
    for (const px of [180, 192, 512]) {
      await emit(`${base}-${px}`, svg, { width: px, height: px, background: bg }, `${base} @ ${px}px`, ground);
    }
    // Maskable frame check: the 512 render is judged against the central-safe-
    // zone rule (mark inside the central 80% circle) on the sheet.
    await emit(`${base}-512-maskable-frame`, svg, { width: 512, height: 512, background: bg }, `${base} maskable frame`, ground);
  } else {
    // Wordmark lockups: a working preview plus the OG plate size.
    await emit(`${base}-480`, svg, { width: 480, height: 240, background: bg }, `${base} preview`, ground);
    if (m.colorway === "color") {
      await emit(`${base}-og`, svg, { width: 1200, height: 630, background: bg }, `${base} @ 1200×630 (OG)`, ground);
    }
  }

  // Gate 2 — forced-monochrome check variant of every color master.
  if (m.colorway === "color") {
    await emit(`${base}-forced-mono`, forceMonochrome(svg), { width: 240, height: 240, background: LIGHT }, `${base} forced mono`, LIGHT);
  }
}

// ---------------------------------------------------------------------------
// The contact sheet — one local HTML page, light and dark grounds side by
// side, for the render-and-verify loop's vision pass and the attended eye.
// ---------------------------------------------------------------------------

const cell = (c) =>
  `<figure style="background:${c.ground};border:1px solid #ccc;padding:12px;margin:0;text-align:center">` +
  `<img src="${c.file}" alt="${c.label}" style="image-rendering:pixelated;max-width:100%">` +
  `<figcaption style="font:12px monospace;color:${c.ground === DARK ? "#eee" : "#111"}">${c.label}</figcaption></figure>`;

const html = `<!doctype html>
<meta charset="utf-8">
<title>logo contact sheet</title>
<body style="font-family:monospace;background:#f4f4f4;padding:24px">
<h1>Logo contact sheet — ${new Date().toISOString()}</h1>
<p>Gates: 16px legibility (favicon strip) · monochrome survival (forced-mono cells) · dark/light reversal (dark-ground cells).</p>
<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:12px">
${cells.map(cell).join("\n")}
</div>
</body>
`;

await writeFile(join(outDir, "contact-sheet.html"), html);
console.log(`wrote ${cells.length} cells + contact-sheet.html to ${outDir}`);

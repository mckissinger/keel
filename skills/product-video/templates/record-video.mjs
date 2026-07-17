// record-video.mjs — pipeline-orchestrator seed for product-video.
//
// This is a PROJECT-COMMITTED TEMPLATE with swappable providers: keel records the
// contract (scenes manifest in → captured walkthrough + narration + assembled
// export out; narration API key read from the environment BY NAME, never a
// literal), and the project owns the implementation. Every provider below is a
// template default — swap the capture driver, the TTS provider, the brand layer,
// or the assembler without changing the contract.
//
// Contract:
//   node record-video.mjs <scenes-manifest> <out-dir>
//     1. CAPTURE   — drive each scene's step against the seeded dev app with the
//                    profile's browser driver (Playwright-class screencast is the
//                    default), recording frames per scene.
//     2. NARRATION — render each scene's narration text to audio via the TTS
//                    provider (ElevenLabs is the default; a local engine is the
//                    zero-key fallback). The provider's API key comes from the
//                    environment variable named below — no literal key, ever.
//     3. BRAND     — (optional, pluggable) composite intro/outro, chapter titles,
//                    and callouts from the app workbench's tokens
//                    (Remotion-class default). The pipeline completes without it.
//     4. ASSEMBLY  — mux video + aligned audio into an MP4 with subtitles and
//                    chapter markers derived from the manifest (ffmpeg default).
//   Renders land in <out-dir>, which is GITIGNORED — sources are committed,
//   renders are not.

const NARRATION_API_KEY_ENV = 'ELEVENLABS_API_KEY'; // asserted by NAME via the
// project's recorded name-check command; the value is read only here, at run time.

const apiKey = process.env[NARRATION_API_KEY_ENV] ?? null; // null → zero-key
// fallback: use the local TTS engine instead of the hosted provider.

const [manifestPath, outDir] = process.argv.slice(2);
if (!manifestPath || !outDir) {
  console.error('usage: node record-video.mjs <scenes-manifest> <out-dir>');
  process.exit(1);
}

// --- implementation stages (project-owned; providers swappable) ---------------
// async function capture(scenes, outDir) { … drive + screencast per scene … }
// async function narrate(scenes, apiKey, outDir) { … TTS per scene, or local … }
// async function brandLayer(assets, tokens, outDir) { … optional composition … }
// async function assemble(assets, outDir) { … mux + subtitles + chapters … }

console.error(
  'record-video.mjs is a template seed — implement the four stages for this ' +
    'project (see skills/product-video/references/video-pipeline.md).',
);
process.exit(1);

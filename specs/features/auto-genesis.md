# Feature — auto-genesis: idea → one approval → unattended product

**Goal:** a third autonomy posture, `keel:auto genesis "<idea>"`, takes a raw product idea
through an attended Phase 1 — a research fan-out producing a rejectable validation assessment
plus a proposed product skeleton and 2–3 throwaway design-direction boards — to a **single
human approval gate**; on approval, Phase 2 runs unattended: a scripted bootstrap generates a
new repo against a committed **template contract**, the auto-preflight goes green, the mode
file is written, and the existing kickoff-verbs + per-feature loop drive to a preview-deployed
product and the mandatory debrief. The never-auto list (go-live, live-key swaps, spend beyond
caps) binds unchanged; genesis ends at preview, never live.

**Strategic grounding (2026-07-05 research sitting, both reports in the session record):**
the industry's reliable failure for idea-to-app systems is thin features + unusable design +
security gaps shipped past a green pipeline (the "70% problem"; saas-factory D63's own lesson:
the prose-only approval gate missed the design bottleneck — hence the boards in the approval
artifact). keel's per-feature depth + independent verification + review-feature gate is the
countermeasure; genesis must reach it from an idea without diluting it. The provisioning
chicken-and-egg (the preflight demands artifacts only attended provisioning produced) is
dissolved by making the bootstrap produce them: environment-level capped keys already exist
(`~/.config/keel/sandbox.env`, sourced by the shell), so per-project setup reduces to
scriptable, no-judgment actions once a doctrine envelope authorizes them.

**Interview record (decided 2026-07-05):** genesis is a posture of `skills/auto`, not a new
skill; bootstrap **generates from scratch** against the template contract (a fork-based
template repo is deferred until genesis is dogfooded); research depth is a **full validation
pass** (prior art, demand/feasibility, product shaping — the assessment is rejectable);
approval artifact is **skeleton + direction boards** (visual, not prose-only); the mode file
carries `level: "genesis"` under the 24h TTL the auto-hardening feature establishes; the agent
never reads key values — env wiring is by **name** against `sandbox.env`.

**No-UI feature** (keel's own surface is skills/scripts/prose) → two-dimension done-conditions.

## The genesis flow (normative summary the milestones implement)

1. **Phase 1 (attended):** research fan-out → one artifact: validation assessment
   ("should this exist", rejectable), product skeleton (feature backlog, spine journey,
   high-level data shapes, service inventory drawn from the sandbox key set), and 2–3
   throwaway direction boards. **The approval gate:** the user approves (naming a direction),
   revises, or rejects. Rejection ends the flow with nothing created.
2. **Approval = the authorization trail** for the Phase 2 envelope (the doctrine amendment in
   m1): repo creation, branch protection + required checks, CI seeding, allowlist commit, and
   enveloped dev-resource creation become scriptable inside the run — bounded by the caps that
   already authorize spend.
3. **Phase 2 (unattended):** bootstrap generates the repo per the template contract → preflight
   green → mode file (`level: "genesis"`) → the existing verbs: spec-foundation
   (default-taking, seeded by the approved skeleton), app-design-directions (ledgered pick,
   seeded by the approved board), provision's residue, then the `auto:run` feature loop →
   preview deploy → **debrief** (review-feature sittings + ledger adjudication + the Phase 1
   assessment revisited against the built reality).

## Milestones (file→milestone ownership map; no routes — no UI)

| Unit | Milestone | Owns |
|---|---|---|
| Doctrine + contract | `auto-genesis-m1-doctrine` | new `decisions/` entry (genesis envelope), new `references/template-contract.md`, new `specs/deferrals/genesis-template-repo.md` |
| The posture | `auto-genesis-m2-posture` | `skills/auto/SKILL.md` (genesis posture: Phase 1 contract, approval gate, Phase 2 orchestration, ledger + debrief deltas), its frontmatter |
| Guard recognition | `auto-genesis-m3-guards` | `scripts/merge-guard.sh`, `scripts/guard-branch-rules.sh`, their `.test.sh` suites (accept `level: "genesis"`) |

**Build order + integration seams:** m1 → m2 → m3 (m2 cites m1's decision entry + contract by
name; m3 changes the level whitelist m2's prose references). **This feature builds only after
`auto-hardening` lands** — m3 edits the same guard scripts as `auto-hardening-m1-guards`, and
the genesis mode file depends on the TTL contract that milestone establishes.
**Parallelizable:** no.

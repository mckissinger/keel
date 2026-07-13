# Structural review — 2026-07-12 (high-level, full-corpus)

Basis: full read of keel HEAD (rulebook, profile interface, all 17 skills' core content,
gates/scripts, capability ledger, autonomy decisions, 2026-07-06 workflow review) held
against the complete transcript evidence (14 cre-launch + 21 new-test-proj + 5 keel
sessions; see the two 2026-07-12 harvest/mining digests). This is not another findings
list — it is the architecture-level reading of what the findings collectively mean.

## The one-paragraph verdict

Keel's control plane — the gates — is mature, script-canonical, and validated by its own
transcripts (the pin gate, merge guard, plan lint, and preflight all caught real failures
and never let a bad state through). The recurring pain lives in four places keel has no
owner for: **project state** (re-derived ad-hoc everywhere), **the human's console**
(attended gates exist but their presentation is undesigned), **the runtime substrate**
(assumed healthy, owned by nobody after provision day), and **the self-improvement loop**
(keel's origin story — "distilled from dogfooding" — still runs as hand-commissioned
retros). None of these weaken a gate; all four are missing layers around gates that work.

## 1. Mature control plane, missing state plane

Every gate has a single canonical owner (a script, never prose) — keel's best design
property. Project *state* has the opposite shape: every skill re-derives it ("orient
first" in implement-milestone, the entry-state audit in auto, land-feature's sweep), every
compaction summary hand-reconstructs it, and the user asked "where are we / what's next"
15+ times across two projects. State derivation has many re-implementations and no owner —
a violation of keel's own single-owner rule, just in a place no one named.

**Implication:** `keel:status` is not a convenience skill. It is the canonical state
derivation — one read-only verb (pins, branches, PRs+CI, deferrals, marker state, live
background agents → done / in-flight / blocked-on-user / next verb) that skills reference
for orientation, auto consumes as its entry audit, and the user invokes instead of asking.
Doctrine-aligned: derived from spec+git truth, never cached.

## 2. The human's console is undesigned

Keel is precise about *where* human judgment sits (the two permanent attended gates,
review-feature, the debrief) and silent about *how it is presented*. The transcripts show
attention is the actual scarce resource: "too much to read," glance-and-proceed approvals,
mobile sessions, a 05:15 marker re-arm, the user acting as the lifecycle checklist
("did we do feature review?" ×5). The gate-presentation contract (recommendation +
one-line why + glanceable artifact + the question) was discussed in-session and never
shipped.

**Implication:** generalize provision's principle from credentials to attention — *drain
every would-be stall while the user is present*. Concretely: (a) the gate-presentation
contract as a shared reference all attended gates follow; (b) near-expiry/overnight
handling that queues server-side --auto or prompts re-arm while the user is still at the
keyboard; (c) the per-feature lifecycle checklist artifact so no gate depends on the
user's memory.

## 3. The substrate is keel's unowned dependency

The runtime-proof — keel's whole verification spine above unit tier — rests on a local
substrate (Docker, ports, env files, CLIs, simulators) that no verb owns after the
provision sitting. It was the single biggest wall-clock destroyer in the corpus: the
3-day Supabase port-collision saga (sessions silently talking to another project's DB),
a Docker sign-in stall that killed a 14-milestone run at milestone 1, the 2-hour hung
suite, PATH breakage, and a lessons file re-read 73× doing a committed doc's job.

**Implication:** a *substrate contract* as a named concept. Provision authors it (unique
project ports, committed env-rederivation recipe + dev-env script, known-failure-signature
table, long-suite timeout policy); a cheap preflight asserts it at implement/verify verb
entry (daemon responsive, ports owned, toolchain resolves — seconds); debug consults its
signature table before diagnosing. The agreed env-recipe fix and the harvest's substrate
findings all land inside this one concept instead of as scattered patches.

## 4. The spec layer is parallel; the runtime layer is single-threaded

Milestones are marked parallelizable, collectors are file-per-entry, workflows use
worktrees — but there is one local DB and one port set, so [runtime] verification is
serial by rule and parallel sessions collide by accident. Keel's slowest serial section
is a direct consequence. The parked worktree-isolation deferral (per-worktree DB branch +
port block, flagged three times as "the one real feature candidate") is the structural
unlock, and it compounds: it parallelizes runtime verification AND makes concurrent
feature work safe.

## 5. The self-improvement loop has no verb

README line one: keel is "distilled from real autonomous build runs and revised as it's
dogfooded." That distillation currently runs as: the user hand-commissions a retro
(4 near-identical prompts in cre-launch), or this session's manual harvests. Meanwhile
two review docs sit in reviews/ with Track A/B largely unexecuted — the bottleneck is not
findings, it's the findings→spec→build pipeline. `keel:harvest` / `retrospective` closes
the loop in keel's own shape: mine transcripts (cursor state, diff against HEAD, no
secrets) → digest to reviews/ → user triage → spec-change/punch-list. The pilot already
ran and worked.

## What NOT to touch (re-affirmed by this review)

The capability ledger's permanent pile held up perfectly against the evidence: the pin
gate caught real drift and stale pins; fresh-context verification caught what builders
missed; the never-auto list and human merge gate contained the one real authority breach
(the global-settings edit — which argues for *strengthening* scoping doctrine, not the
gate). The transcripts are the receipts. Treat proposals to weaken any of these as defects.

## Priority (my recommendation)

1. **keel:status** — cheapest build, highest frequency, immediately felt daily.
2. **Substrate contract** — biggest wall-clock recovery; absorbs the already-agreed env
   fix + the harvest's port/preflight/timeout findings as one coherent spec.
3. **keel:harvest** — compounds everything else; pilot proven; fold retrospective in.
4. **Gate-presentation contract + lifecycle checklist** — cheap prose, directly serves
   the glance-and-proceed working style.
5. **Worktree runtime isolation** — the big feature; largest throughput unlock; schedule
   deliberately.
6. **Lifecycle skills** (landing-page first) — real gap, already road-mapped in the
   2026-07-06 review §4; sits after the structural items because those compound daily.

Items already agreed earlier (pin-parser anchor + repin.sh; caveat-scan and stale-ref
fixes) are control-plane polish — small spec-changes that can ride alongside any of the
above.

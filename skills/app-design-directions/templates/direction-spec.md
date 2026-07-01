# Direction: [Name]

**Thesis:** [one sentence — what this direction believes about the product]

**Derived from brief:** [which discovery findings this serves]

## Tokens
| Token | Value | Note |
|---|---|---|
| bg | #... | |
| surface | #... | |
| border | #... | |
| text | #... | |
| text-muted | #... | (AA against surface ✓) |
| accent | #... | used for: [selection/primary actions only, etc.] |
| success / warning / danger | #... / #... / #... | semantic only |

- **Type:** display: [face] · UI: [face] · data: [face, tabular figs ✓] — rationale: [...]
- **Spacing base:** [4/8px] · **Radius:** [scale] · **Depth grammar:** [the one shadow/border recipe]
- **Density:** [row height, body size]
- **Motion stance:** [none / functional 150ms / one moment: ...]
- **Interaction-state tokens:** [hover / pressed / focus / disabled deltas — named once at the token layer, inherited by every component]

## Material palette (front-end libraries — owned by design.md once chosen)
| Material | Choice | Chosen against its default |
|---|---|---|
| Icons | [set + style/weight, e.g. Phosphor thin] | (not Lucide-everywhere) |
| Motion + interaction-state tokens | [library + stance, e.g. Framer Motion, functional only; easing/duration + hover/pressed/focus/disabled deltas as tokens] | (not default/absent motion) |
| Charts / data-viz | [library + treatment, e.g. Tremor restyled to palette] | (not stock Recharts) |
| Component primitives | [shadcn/Radix unstyled / opinionated kit] | (not default shadcn styling) |

## Layout architecture
[Nav pattern, screen composition, how density is handled — 2–3 sentences or a small ASCII wireframe]

## Signature element
[The ONE ownable device]

## Optimizes for / trades away
- **Optimizes:** [...]
- **Trades:** [...]

## Anti-slop check
[List any fingerprint patterns present + one-line justification each, or "clean"]

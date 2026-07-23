# Direction Recipes: Generating 3–5 Genuinely Distinct Directions

## The core problem this file solves

Asked for "five design options," models produce one design five times: same layout, same type, five accent colors. That wastes the user's decision. A direction is a *system* — and directions are only worth comparing if they make different bets.

## The axes of variation

Every direction is a combination of positions on these axes. Two directions must differ on **at least three** axes to count as distinct:

| Axis | The spectrum | Notes |
|---|---|---|
| **Density** | Compact data grid ←→ spacious focused flow | The most consequential axis for apps. Tie to the brief's user: daily power user vs. occasional visitor. |
| **Layout architecture** | Sidebar nav / top nav / rail + panels / master-detail / command-palette-first / canvas | Changes the grayscale silhouette of the app — the strongest differentiator. |
| **Type system** | Neutral grotesque / humanist sans / serif-led / mono-data-forward / mixed editorial | In apps, pick a *data face* too: tables and numbers carry the product. Tabular figures matter more than display flair. |
| **Color strategy** | Near-monochrome + one semantic accent / warm material palette / cool professional / domain-derived palette / functional-color-only (color means status, never decoration) | Decide what color *means* before what color *is*. |
| **Shape & depth** | Flat + borders / soft elevation / sharp zero-radius / inset panels | Pick one depth grammar and apply it everywhere; mixed shadow recipes are a slop tell. |
| **Motion stance** | None (instant) / functional only (state transitions) / expressive moments | Apps usually want functional-only. An expressive direction must say where and why. |
| **Voice** | Terse operator language / warm guide / institutional | Microcopy is part of the direction. |

## Portfolio composition

Directions are derived fresh from the brief and the axes above — there is no menu of named looks to pick from (a named list anchors every app toward the same portfolio; the axes describe the space, the tests below reject sameness). For 5 directions, a good portfolio spans the density axis (at least one compact, one spacious), spans warm/cool, includes **at least one direction derived primarily from the domain's own materials** (the section below), and includes one honest risk. Include one "closest to what they have now, but disciplined" direction when redesigning an existing app — incumbents deserve a fair hearing and it calibrates the user's appetite for change.

## Deriving from the domain (the secret weapon)

The brief's subject matter — its instruments, paperwork, geography, materials — is the richest source of choices nobody else would make. Ask: what does this domain *physically look like*? What artifacts do its professionals trust? Examples of the move:

- Acquisitions/real-estate CRM → county plat maps, title documents, rent-roll ledgers, surveyor line-work → ruled tables, stamp-like status chips, a restrained map-derived palette (vegetation/soil/survey-orange), serif document headers.
- DevOps monitor → terminal heritage, status lights → mono data face, semantic green/amber/red as the *only* colors.
- Health scheduling → wayfinding signage, calm clinical palettes, high-legibility humanist sans.

One derived direction per portfolio, minimum. It's usually the one the user remembers.

## The signature element

Each direction names exactly **one** ownable device: a distinctive table header treatment, a status-chip language, a left-rail timeline, a particular way numbers are set, a load-in animation, a panel articulation. One. Everything else stays disciplined so the signature reads. Spend the boldness in one place; before shipping, look at the design and remove one accessory.

## Writing the tradeoff line

Force each direction to declare what it sacrifices ("Terminal: fastest for the user daily, least friendly for an investor he screenshares with"). If a direction has no tradeoff you can articulate, it has no point of view — sharpen or cut it. The tradeoff lines are also what makes Phase 3 a real decision instead of a beauty contest: the user is choosing *priorities*, not just colors.

## Sanity checks before building mockups

- Grayscale test: would thumbnails of the five mockups be tellable apart with color removed? (Layout/density/type must carry difference, not hue.)
- Anti-slop pass: every direction through `references/anti-slop.md`.
- Stack-feasibility: every direction implementable in the app's actual stack found in Phase 0 (no direction that requires a rewrite).
- Brief-fit: every direction names which brief findings it serves.

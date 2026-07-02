# Change — Live-stream / conversational surfaces (archetype + state grammar + scroll intent)

**Grain:** one change → one milestone (`spec-change`). **No-UI** (methodology/docs change to keel
itself). **Stacked on:** `motion-vocab-and-details` (edits the same craft-layer regions).

## Why (the gap)

Sourced from the July 2026 design-engineering research pass. Product surfaces where **content
arrives while the user is reading** — chat (human or AI), activity feeds, live logs, agent
progress panes, streaming dashboards — have become a default shape of new apps, and the craft
of building them well was recently codified publicly (shadcn's streaming-chat rules, June
2026: "never move the reader against their intent"). Keel has nothing for this class:

1. **The state grammar stops at request/response data views.** `product-ui-craft.md` requires
   loading/empty/error/partial per data view — but a live surface's load-bearing states
   (streaming in-flight, content-arrived-out-of-view, held reading position, reopen position)
   aren't named anywhere, so specs can't require them and builders default them.
2. **The scroll-intent discipline is absent from the interaction floor.** The signature defects
   of generated chat/feed UI are behavioral: auto-scroll that steals the reading position,
   history prepends that jump the view, no way back to the live edge, reopening at the absolute
   bottom instead of the last meaningful turn. These are checkable interaction principles —
   exactly what `interaction-craft.md` exists to hold — and they are platform-neutral (a native
   chat app has the same physics).
3. **The spread phase can't see the archetype.** Phase 3.5's archetype list (table, detail,
   form, empty/dashboard, calendar/timeline, data-viz, marketing) predates this surface class,
   so an app whose core surface is a conversation or live feed gets its most failure-prone
   screen left out of the direction spread.

## The mechanic

Three files, additive:

1. **`references/interaction-craft.md`** — new principle **"6. Live surfaces: never move the
   reader against their intent"** (platform-neutral, credited to shadcn's streaming-chat
   rules): follow the live edge only while the reader is at it; every interaction is intent
   (scrolling away, selecting text, keyboard use, opening a link all stop the following); new
   content arrives without moving the reading position (a new turn starts near the top of the
   viewport; offscreen arrivals stay offscreen); what's-happening-out-of-view is shown, with a
   jump-to-latest affordance that resumes following; reopen at the last meaningful position
   (usually the last user action), not the absolute bottom; layout changes (media loading,
   content expanding, history prepending above) and interruptions (stop/retry/error) never
   steal the reading position.
2. **`skills/app-design-directions/references/product-ui-craft.md`** — the state grammar
   section gains the **live-surface state set** for any surface where content arrives while
   the user reads: streaming/in-flight (distinct from initial loading), arrived-out-of-view
   (jump-to-latest + unread boundary), held reading position across prepend/media-load/expand,
   and reopen position — plus the **model-in-the-loop variant states** (token-streaming
   in-progress rendering, stop/regenerate/branch controls that don't move the transcript,
   expandable tool/working blocks) required only when the surface fronts an AI.
3. **`skills/app-design-directions/SKILL.md`** — Phase 3.5's archetype enumeration gains
   **conversational/live-stream (chat, feed, live log)**, mandatory when the app has such a
   surface (mirroring the data-viz rule — it's where generated UI defaults hardest), with the
   note that its *behavior* (the scroll-intent rules) is proven only in the real
   workbench/build, not the throwaway mockup — the mockup shows the states.

**Not weakened:** the existing state grammar, the throwaway/look-only nature of Phases 2–3.5,
the ~5 archetype cap (the new archetype joins the enumeration, it doesn't raise the cap), and
the data-viz mandatory rule are unchanged.

## Scope

Three markdown files, pure prose. All new interaction principles platform-neutral with hedged
web examples; no library named un-hedged; `check-neutral.sh` stays green. No scripts, no
spine-file changes.

# Current task

**Task:** Close the distance between O Empire Reborn and the reference game (O EMPIRE! WARD OFF THY ROT, Steam app 4331110), design and interaction first, at 390px and desktop.
**Spec:** Reference frames: Steam store screenshots for app 4331110 (https://store.steampowered.com/app/4331110). Owner's original reference image from 2026-09-16 is not retrievable.
**Started:** 2026-09-23

## Acceptance criteria

- [x] Field reads as a light grey halftone ground with scattered scarlet blossoms, not dark crimson walls on a dark ground (cycle 2)
- [x] No aspect distortion on phone: square pixels at 390px (cycle 2)
- [x] Message text legible on the lighter ground (cycle 2)
- [x] Ruins and caches read as drawn objects: pixel houses with roof ridge and chimney, conifer stands, broken walls, marker-stone caches, round tower with merlons and cast shadow (M14)
- [x] Corridor bloom banks closer to the field's dotted blossom scale (smaller banks and bloom heads) (M15)
- [x] Bearer drawn at 74% scale, closer to the reference's small figure; stillness moths re-anchored (M16). Camera angle unchanged.
- [x] Title screen on phone shows the scene: dark band only behind the type, field visible above and below (M15)
- [x] Hand screen: pausing opens WHAT YOU CARRY with bread / tincture / reliquary cards (tap to use), a rot-dependent line, WALK ON (M16). M17: compared with reference frame 4 (Inventory | Hand tabs, large dithered hand, item title/subtitle/description); added INVENTORY/HAND tabs and a drawn dithered left hand with a ring and red thread, where rot blossoms climb from the wrist with G.rot.

- [x] Synthesized sound, no assets, soft highs: wind bed by field density, low drone that detunes with rot, footsteps, search bell, milestone toll, bread/tincture cues, ending chords, mute toggle (♪ / M) (M14)
- [x] Pause and sound buttons legible over the light field (M14)

- [x] Conifers read at 390px: larger, lit edges, placed on the road side of ruins so the narrow phone canvas shows them (M15)
- [x] Sound: kneel breath every ~3.6s while kneeling, soft two-note cue when an unsearched cache comes into range (M15)

- [x] Rounded, soft-cornered frame closer to the reference's old-screen look (M18)
- [x] Winter chunks (chunk mood > .8): pale snow drifts, sparse blossoms, dead stems (M18)

- [x] Dark cliff masses in winter chunks (drawCliffs, drawn over the field so blossoms do not cover them) and a smaller bearer (.6) for a higher-camera read (M19)

- [x] World pull-back: conifers, houses and walls scaled down with the bearer (M20)
- [x] Pixel blackletter screen titles: hand-built 9px bitmap glyphs drawn to canvas, aria-label keeps the text (M20)
- [x] Cliff faces get a lit west edge and dithered base shade (M20)

- [x] Ending screen clean: HUD, touch controls and flavor line hidden while the ending shows ('ended' class, restored on WALK AGAIN) (M21)
- [x] Title screen in the File no longer shows the HUD behind the title ('attitle' class; body:has does not reach into the File's shadow root) (M21)
- [x] Blackletter glyph set complete for A-Z plus . , ' ? - (M21)

- [x] Blackletter pen flicks: one hairline entry stroke top-left and one exit tail bottom-right per glyph, drawn after the pixels (M22)

- [x] Wind-hatched snow: short dark diagonal streaks anchored to the world, after the Steam reference's snow texture (drawWindHatch) (M23)
- [x] Long raking shadows off conifers and houses toward the upper right (M23)

**Owner:** web build owned by the O Empire web agent since 2026-09-23 (design-sweep agent is audit-only here; Godot track works only under godot/).

## Non-goals

- Gameplay rebalance (pacing already tuned in M4)
- Copying reference assets. Everything stays drawn from scratch.

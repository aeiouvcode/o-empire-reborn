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

- [x] Naksh playtest 9/24: bearer walked in place while the world slid and boiled. Now the world holds still and the bearer walks the road up the screen; the camera glides to re-frame only when the bearer nears the top (M24)
- [x] Camera scroll snapped to whole pixels and dither patterns anchored to the world, so the ground no longer shimmers while moving (M24)
- [x] Leg poses keyed to distance walked, so feet plant instead of sliding (M24)
- [x] Drifting ash/snow flecks for ambient motion (M24)
- [x] Fixed shots like the original: the frame holds while the bearer crosses it (~9s), then slides one screen in 0.75s (M25)
- [x] Visual world 10x longer (Z=10) so the bearer moves ~16px/s on screen; run length and pacing unchanged (M25)
- [x] Smaller bearer with a long cast shadow to the upper right; denser red field; the far tower looms at the top edge over the last stretch (M25)
- [x] Naksh 9/24 8:12 PM: "varying Blur is missing, it gives it the depth". Tilt-shift depth blur: sharp band through the middle of each shot, soft half-res blur then heavy fifth-res blur toward top and bottom; band is fixed per shot so it never shimmers (M26)
- [x] Left and right edges blur too, like the original's frame; road drawn paler and stronger so it reads at the new scale (M27)
- [x] File only: stage sized to the phone width (clamp 480-740px) and the first tap scrolls the whole game into view; controls copy names the WALK rail (M28, File generation 19)
- [x] House and tree shadows darker and crisper; touch controls need a coarse pointer or a real touch, so desktop windows with a mouse stay clean (M29)
- [x] M32 9/25 3:40 AM: the flower banks beside houses (the dark stalky red clumps) are now loose flower beds in the same fine bloom style, drawn back to front with a soft ground shadow.
- [x] M31 9/25 2 AM: roadside flower patches redrawn as small clumps in the same bloom style as the field (stems, tiny shadows); lone stray flowers in open ground are fewer and never large, so no more big red blobs outside the drifts.
- [x] Night push 9/25: rendering at 2x internal resolution, so the halftone and dither are fine-grained like the original, with an automatic drop to 1x if a device can't hold ~30fps; flowers redrawn as blooms with stems and small cast shadows, gathered in diagonal drifts with open ground between; black cliff boxes replaced by low pale rocks with long shadows; slow drifting cloud light over the field (M30)
- [x] Mobile controls: vertical WALK/BACK rail replaces the round stick (the walk is 1D), buttons 58-72px with 10px labels, pause and sound 44x36 and no longer overlapping, HUD text 8px (M24)

**Owner:** web build owned by the O Empire web agent since 2026-09-23 (design-sweep agent is audit-only here; Godot track works only under godot/).

## Non-goals

- Gameplay rebalance (pacing already tuned in M4)
- Copying reference assets. Everything stays drawn from scratch.

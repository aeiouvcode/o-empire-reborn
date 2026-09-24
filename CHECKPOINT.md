# Checkpoint

Completed atomic steps, newest last. Do not redo anything listed here.

| Date | Step | Evidence (commit, URL, screenshot) |
| --- | --- | --- |
| 2026-09-23 | Distance-to-reference audit vs Steam screenshots, desktop + 390px | Design agent cycle 2 report |
| 2026-09-23 | Field repaint: light ground ramp, scattered clumped scarlet blossom layer (drawField), half the corridor patches, brighter plate reds | index.html commit, see git log "Reference pass" |
| 2026-09-23 | Plate grain: chain-link and cross-hatch families replaced with fine noise / offset bayer | same commit |
| 2026-09-23 | Removed the dashed ellipse overlay; darker soft corner vignette | same commit |
| 2026-09-23 | Canvas width follows viewport aspect (H fixed 270, W 120-640), narrow frame margin on phone | same commit |
| 2026-09-23 | CSP script/style hashes recomputed | same commit, live boot verified |
| 2026-09-23 | M14: ruins/caches/tower redrawn as top-down pixel objects (drawHouse, drawConifer, drawWall, drawCache, drawTower) | commit "M14 drawn ruins and synthesized sound" |
| 2026-09-23 | M14: Web Audio sound pass (wind, drone, steps, bells, cues, mute ♪/M, suspends when hidden) | same commit; headless 390x844: audio running, mute toggles, 0 errors |
| 2026-09-23 | M14: pause/sound buttons given dark pill backing for legibility | same commit |
| 2026-09-23 | M14: CSP hashes recomputed; directives unchanged; secret and sink scan clean | same commit |
| 2026-09-23 | M15: phone title overlay reshaped (scene visible, type still legible) | commit "M15 title contrast, readable pines, bloom scale, kneel breath" |
| 2026-09-23 | M15: conifers enlarged and moved roadward; bloom banks and heads scaled down | same commit |
| 2026-09-23 | M15: kneel breath and cache-in-range cue added to the sound engine | same commit; headless 390x844: 0 errors, audio running |
| 2026-09-23 | M15 shipped; Instinct File embed fixed (game now runs in the File via shadow root) | commit 452a155; File generation 6 |
| 2026-09-23 | M16: bearer scale .74, hand screen on pause (cards use items, WALK ON resumes), quick reveal timing | commit "M16 hand screen and smaller bearer"; File generation 7 |
| 2026-09-23 | M17: reference audit of 9 Steam screenshots; hand screen gets INVENTORY/HAND tabs and a procedural dithered hand whose rot blossoms track G.rot | commit "M17 hand tab"; File generation 8 |
| 2026-09-23 | M18: rounded frame mask with 4-step soft edge; drawSnow for winter chunks (3, 11, 16 of the road) with thinned blossoms | commit "M18 rounded frame and winter chunks"; File generation 9 |
| 2026-09-24 | M19: drawCliffs (two dark crags with snowy top plane and cast shadow per winter chunk), bearer scale .74 -> .6 | commit "M19 winter cliffs and smaller bearer"; File generation 10 |
| 2026-09-24 | M20: props scaled with bearer; pixLine/pixTitle bitmap blackletter for title and end screens; cliff face texture | commit "M20 world scale, pixel blackletter titles, cliff texture"; File generation 11 |
| 2026-09-24 | M21: ended/attitle classes hide HUD and touch controls on end and title screens (Pages and File); glyphs C G J K Q X Z . , ' ? - added | commit "M21 clean ending and title screens, full blackletter glyph set"; File generation 12 |
| 2026-09-24 | M22: pixLine draws hairline pen flicks (entry top-left, exit tail bottom-right, one each per glyph wider than 2) | commit "M22 blackletter pen flicks"; File generation 13 |
| 2026-09-24 | M23: drawWindHatch (world-anchored diagonal streaks, alpha .8, before ruins); long wedge shadows on conifers and parallelogram shadows on houses | commit "M23 wind-hatched snow and long shadows"; File generation 14 |
| 2026-09-24 | M24: PX=.07 world scale; camT/camX dead-zone camera; bearer at proj(G.x,road); pixel-snapped camera + world-anchored dither; distance-keyed gait; drawDrift; 1D walk rail and bigger touch controls | commit "M24 walk the world: still world, moving bearer, mobile controls"; File generation 15 |
| 2026-09-24 | M25: Z=10 visual world scale (content drawn in u=wx*Z, gameplay unchanged); shot camera (advance .64 of view when bearer passes top 20%, smoothstep tween .75s); bearer scale .5 + cast shadow; field density up; tower pinned near top after x>9000 | commit "M25 fixed shots"; File generation 16 |

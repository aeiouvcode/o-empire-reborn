# Handoff (Godot track, branch godot)

## Resume here
Cycle 8: smoke puffs read as dark balls - soften (more, smaller, drifting/animated, fade toward paper); satchel hand drawing with more anatomy/tone (reference frame 6: detailed halftone hand, ring on finger); verify run-stir note in a capture. Live /godot/ is frozen at the cycle 6 build until the owner confirms per-cycle redeploys.

## Cycle log
- Cycle 7: chimney smoke now visible (opaque dark unshaded puffs, 5 per chimney, lightening as they rise; alpha puffs never showed in the web export). Tile lines thinner and mid-grey. Source only; no redeploy. Grade PARTIAL.
- Cycle 6: balance - sprinting through blossoms feeds rot x2.2 (sim, no tinctures: walk WIN 12.5 min peak 70; smart kneel WIN 11.0 min peak 71; all-run LOSE at 1154/1170 - one tincture saves it; before: all-run was the safest line, peak 45). One-time note "The blossoms stir as you run." Roofs: three per-house tones with emission 0.62-0.78 so tiles read pale through the halftone. Reliquary gets a soft emission so the bearer carries a pale mark. Smoke darker/larger. Grade PARTIAL.
- Cycle 5: roof tile courses (4 dark lines per slope) and emission lift on roof material; chimney smoke puffs (unshaded, alpha); road vs field footsteps (step_road: 80 ms scuff, 700 Hz low-pass, same -22 dB). Grade PARTIAL.
- Cycle 4: blackletter display type (UnifrakturMaguntia, OFL, fonts/OFL.txt) for title, end title, story line and satchel item names; body/HUD stays sans. Roofs steeper (3.0-4.0 high, wider eaves) with ridge and eave beams; chimney raised to match. Grade PARTIAL.
- C3 2026-09-23: Satchel screen (Inventory / Hand tabs, dotted frames, halftone-dotted reliquary / bread / tincture / hand with rot buds, pauses play; I / Tab / pad Back / SATCHEL button). Highlight contrast 1.3 on web. Audio measured from a movie capture (-34.7 LUFS, -18 dBFS peak, >4 kHz content 19 dB under mean) and lifted +5 dB. Balance: sim showed rot never threatened (peak 47, tinctures unused); rot rate in blossoms 0.092 -> 0.16 gives walk ~11:00, peak rot 76 without tinctures.
- C2 2026-09-23: web tone calibrated (exposure 0.72 / tone 1.45 on web, measured ground mean 0.58 vs Steam frames 0.47-0.63); synthesized audio (wind bed, footsteps, cairn search, find bell, milestone bell, tower drone, rot heartbeat); half-timbered gables; title camera closer on the tower. Deployed web export to Pages /godot/.
- C1 2026-09-23: full loop ported, halftone plate pass, touch controls, web export boots at 390x844. Grade PARTIAL. Frames in qa/frames/.

## Discoveries
- Reference frames: Steam app 4331110 screenshots (9 x 1920x1080), viewfinder crop ~1000 px wide, ~125 dot cells across -> CELLS_W 132.
- Native Linux (xvfb, opengl3) and web tone differ; judge on the web export.

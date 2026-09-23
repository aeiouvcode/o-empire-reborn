# Handoff (Godot track, branch godot)

## Resume here
Cycle 3: hand/inventory screen (reference frame 6), paper highlights a touch brighter on web (cream dots in lit ground), blackletter-style title type, cairn discoverability at night-dark stretches, bearer silhouette readability, full-walk timing sim.

## Cycle log
- C2 2026-09-23: web tone calibrated (exposure 0.72 / tone 1.45 on web, measured ground mean 0.58 vs Steam frames 0.47-0.63); synthesized audio (wind bed, footsteps, cairn search, find bell, milestone bell, tower drone, rot heartbeat); half-timbered gables; title camera closer on the tower. Deployed web export to Pages /godot/.
- C1 2026-09-23: full loop ported, halftone plate pass, touch controls, web export boots at 390x844. Grade PARTIAL. Frames in qa/frames/.

## Discoveries
- Reference frames: Steam app 4331110 screenshots (9 x 1920x1080), viewfinder crop ~1000 px wide, ~125 dot cells across -> CELLS_W 132.
- Native Linux (xvfb, opengl3) and web tone differ; judge on the web export.

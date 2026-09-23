# Handoff (Godot track, branch godot)

## Resume here
Cycle 2: web export renders brighter than native (ground washes toward paper on WebGL) - calibrate tone in halftone.gdshader against the web frame, not native. Then: tower close-up on title (reference frame 9), village houses with gable detail (frame 4), hand/inventory screen (frame 6), blackletter-style title type.

## Cycle log
- C1 2026-09-23: full loop ported, halftone plate pass, touch controls, web export boots at 390x844. Grade PARTIAL. Frames in qa/frames/.

## Discoveries
- Reference frames: Steam app 4331110 screenshots (9 x 1920x1080), viewfinder crop ~1000 px wide, ~125 dot cells across -> CELLS_W 132.
- Native Linux (xvfb, opengl3) and web tone differ; judge on the web export.

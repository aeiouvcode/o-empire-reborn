# O Empire: Ward the Flowering Rot - Godot version

Godot 4.5.2 (Compatibility / WebGL2) build of the same pilgrimage as the web build on `main`.
Lives only on branch `godot`; the web build's files are untouched. Not deployed.

- Loop: walk, run (stamina), kneel to recover, search the 8 cairns (bread or tincture), flowering rot, milestone story lines, title screen, two endings. Numbers ported from the web build (1 m = 10 web units, road 1170 m).
- Look: real 3D scene rendered into a 132-cell-wide SubViewport, then a print-plate halftone pass (`shaders/halftone.gdshader`): six paper/lavender-grey tones as dot cells, ordered dither, a separate misregistered scarlet plate for blossoms, rounded viewfinder vignette.
- Controls: WASD/arrows, Shift run, R kneel, E search, 1 bread, 2 tincture, Enter start; gamepad; touch stick + SEARCH/KNEEL/BREAD/TINCT/RUN (multi-touch).

Build: `GODOT=/path/to/godot ./build.sh` -> `../export/web/`. QA frames: `python3 qa/shot.py '<url>?shot=play&z=225&touch' out.png` (headless Chrome, 390x844 @2x).
Debug params: `shot=title|play|end_ok|end_fail`, `z=<metres>`, `rot=`, `stam=`, `touch`, `walk`, `run`.

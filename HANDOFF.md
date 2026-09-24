# Handoff

## Resume here

M23 candidates: 1) look and motion toward the reference (bearer gait, fog drift, flower shimmer) - fetch the Steam screenshots via appdetails to compare; 2) digits in the glyph set; 3) Naksh's sound feedback when it arrives.

## Blocked

- Nothing.

## Failed approaches

| Approach | Why it failed | Date |
| --- | --- | --- |
| Hairlines on every stem top and foot, stepped in square dots | Read as scratches and debris, not pen strokes; replaced with one continuous flick in and out per glyph | 2026-09-24 |
| Previewing an edited build via document.write or a blob: URL on the live Pages origin | The page's meta CSP pins script/style by sha256. The edited script is blocked, and blob: inherits the creator's CSP. Preview on about:blank instead, and recompute both hashes before every push. | 2026-09-23 |
| Embedding the game in the Instinct File as an iframe srcdoc | The File host runs in an opaque sandbox with its own script CSP; srcdoc inherits it, so the game script never ran (title showed, BEGIN dead). Scripting the frame from the bundle fails too (cross-origin null). The File now mounts the game into a shadow root from the bundle (mkfile.js pattern). Always tap BEGIN on the File preview before publishing. | 2026-09-23 |
| Frame edge as a 5px dark stroke inside the rounded rect | After dithering it read as a second inner border band; replaced with 4 stepped low-alpha evenodd masks | 2026-09-23 |
| Using the o-empire-reborn page itself as the push bridge | connect-src 'none' blocks fetch to api.github.com. Use a bridge page without a CSP. | 2026-09-23 |

## Discoveries

- In the File the game lives in a shadow root and document.body maps to #wrap, so body:has(...) rules never match there. Toggle classes on document.body (ended, attitle) instead; that works in both builds.
- Toolchain lives only in the sandbox (csp.py, cdp.mjs, qa.mjs, fileqa.mjs, endqa.mjs, mkfile.js); if the sandbox resets, rebuild from the O Empire chat history.

- Screen titles are canvases built by pixTitle(el) from PG/PW glyph tables; any code that rewrites a .title must call pixTitle again (endGame does).

- Scenery drawn inside drawSnow gets covered by the blossom field; solid landforms need their own pass after the field (drawCliffs sits before the window/structure pass).
- File preview tap target moves with page layout; locate BEGIN in the screenshot before tapping.

- The Steam appdetails API (store.steampowered.com/api/appdetails?appids=4331110) lists the 9 reference screenshots directly; the reference hand screen is frame 4 (Inventory | Hand tabs).

- On phone the internal canvas is only ~125px wide (H=270 times the viewport aspect), so anything with |z| above ~14 in proj() lands offscreen. Place scenery the player must see on the road side.
- The godot/ folder is deployed by the Godot track agent in its own commits; the web build only touches root files. Base each push on the current main head, not a remembered SHA.

- Local headless Chrome in the sandbox (google-chrome + CDP from node) renders the game at 390x844 with touch emulation, so pixel and runtime checks don't need the shared cloud browser. Only the push does.
- Web Audio needs no CSP change: oscillators and buffers aren't governed by media-src, so `media-src 'none'` stays.

- Any edit to the inline script or style must update the matching sha256 in the CSP meta, or the live page boots to a blank canvas with no error shown.
- Internal canvas was a fixed 480x270 stretched to the viewport, so on phones every sprite was squashed vertically ~3x. It now keeps square pixels.

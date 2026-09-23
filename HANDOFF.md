# Handoff

## Resume here

M17: compare the hand screen and bearer against the Steam reference frames (app 4331110) and close the gaps; consider a slightly steeper camera (proj dy/z factors) only if it keeps the 15-chunk layout readable at 390px. Apply any sound-level feedback from Naksh.

## Blocked

- Nothing.

## Failed approaches

| Approach | Why it failed | Date |
| --- | --- | --- |
| Previewing an edited build via document.write or a blob: URL on the live Pages origin | The page's meta CSP pins script/style by sha256. The edited script is blocked, and blob: inherits the creator's CSP. Preview on about:blank instead, and recompute both hashes before every push. | 2026-09-23 |
| Embedding the game in the Instinct File as an iframe srcdoc | The File host runs in an opaque sandbox with its own script CSP; srcdoc inherits it, so the game script never ran (title showed, BEGIN dead). Scripting the frame from the bundle fails too (cross-origin null). The File now mounts the game into a shadow root from the bundle (mkfile.js pattern). Always tap BEGIN on the File preview before publishing. | 2026-09-23 |
| Using the o-empire-reborn page itself as the push bridge | connect-src 'none' blocks fetch to api.github.com. Use a bridge page without a CSP. | 2026-09-23 |

## Discoveries

- On phone the internal canvas is only ~125px wide (H=270 times the viewport aspect), so anything with |z| above ~14 in proj() lands offscreen. Place scenery the player must see on the road side.
- The godot/ folder is deployed by the Godot track agent in its own commits; the web build only touches root files. Base each push on the current main head, not a remembered SHA.

- Local headless Chrome in the sandbox (google-chrome + CDP from node) renders the game at 390x844 with touch emulation, so pixel and runtime checks don't need the shared cloud browser. Only the push does.
- Web Audio needs no CSP change: oscillators and buffers aren't governed by media-src, so `media-src 'none'` stays.

- Any edit to the inline script or style must update the matching sha256 in the CSP meta, or the live page boots to a blank canvas with no error shown.
- Internal canvas was a fixed 480x270 stretched to the viewport, so on phones every sprite was squashed vertically ~3x. It now keeps square pixels.

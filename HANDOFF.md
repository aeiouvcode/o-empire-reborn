# Handoff

## Resume here

M18 gaps from the reference audit (Steam app 4331110 screenshots): 1) the frame: reference uses a rounded CRT-like vignette with soft black corners, ours is a flat rectangle; 2) world scale: reference bearer is a few pixels in a vast field, ours still reads large, so consider a higher camera only if 390px stays readable; 3) winter/snow chunk variety (reference has pale snow fields and dark cliffs); 4) hand screen title in a blackletter-like face drawn in pixels rather than Georgia. Apply Naksh's sound feedback when it arrives.

## Blocked

- Nothing.

## Failed approaches

| Approach | Why it failed | Date |
| --- | --- | --- |
| Previewing an edited build via document.write or a blob: URL on the live Pages origin | The page's meta CSP pins script/style by sha256. The edited script is blocked, and blob: inherits the creator's CSP. Preview on about:blank instead, and recompute both hashes before every push. | 2026-09-23 |
| Embedding the game in the Instinct File as an iframe srcdoc | The File host runs in an opaque sandbox with its own script CSP; srcdoc inherits it, so the game script never ran (title showed, BEGIN dead). Scripting the frame from the bundle fails too (cross-origin null). The File now mounts the game into a shadow root from the bundle (mkfile.js pattern). Always tap BEGIN on the File preview before publishing. | 2026-09-23 |
| Using the o-empire-reborn page itself as the push bridge | connect-src 'none' blocks fetch to api.github.com. Use a bridge page without a CSP. | 2026-09-23 |

## Discoveries

- The Steam appdetails API (store.steampowered.com/api/appdetails?appids=4331110) lists the 9 reference screenshots directly; the reference hand screen is frame 4 (Inventory | Hand tabs).

- On phone the internal canvas is only ~125px wide (H=270 times the viewport aspect), so anything with |z| above ~14 in proj() lands offscreen. Place scenery the player must see on the road side.
- The godot/ folder is deployed by the Godot track agent in its own commits; the web build only touches root files. Base each push on the current main head, not a remembered SHA.

- Local headless Chrome in the sandbox (google-chrome + CDP from node) renders the game at 390x844 with touch emulation, so pixel and runtime checks don't need the shared cloud browser. Only the push does.
- Web Audio needs no CSP change: oscillators and buffers aren't governed by media-src, so `media-src 'none'` stays.

- Any edit to the inline script or style must update the matching sha256 in the CSP meta, or the live page boots to a blank canvas with no error shown.
- Internal canvas was a fixed 480x270 stretched to the viewport, so on phones every sprite was squashed vertically ~3x. It now keeps square pixels.

# Handoff

## Resume here

M15: title screen contrast on phone (scene behind the title is too dark to read), then corridor bloom banks to match the field's blossom scale, then bearer scale/camera closer to the reference. Sound follow-up: a soft kneel breath and a quiet cue when a cache comes into range.

## Blocked

- Nothing.

## Failed approaches

| Approach | Why it failed | Date |
| --- | --- | --- |
| Previewing an edited build via document.write or a blob: URL on the live Pages origin | The page's meta CSP pins script/style by sha256. The edited script is blocked, and blob: inherits the creator's CSP. Preview on about:blank instead, and recompute both hashes before every push. | 2026-09-23 |
| Using the o-empire-reborn page itself as the push bridge | connect-src 'none' blocks fetch to api.github.com. Use a bridge page without a CSP. | 2026-09-23 |

## Discoveries

- Local headless Chrome in the sandbox (google-chrome + CDP from node) renders the game at 390x844 with touch emulation, so pixel and runtime checks don't need the shared cloud browser. Only the push does.
- Web Audio needs no CSP change: oscillators and buffers aren't governed by media-src, so `media-src 'none'` stays.

- Any edit to the inline script or style must update the matching sha256 in the CSP meta, or the live page boots to a blank canvas with no error shown.
- Internal canvas was a fixed 480x270 stretched to the viewport, so on phones every sprite was squashed vertically ~3x. It now keeps square pixels.

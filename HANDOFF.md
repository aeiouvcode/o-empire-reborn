# Handoff

## Resume here

Redraw ruins and caches (drawRuins, drawCache, drawTower) as small top-down pixel objects in the reference's manner: a house with a roof ridge, a few dark conifers, the tower as a round mass with a cast shadow. Replace the flat light-grey rectangles first.

## Blocked

- Nothing.

## Failed approaches

| Approach | Why it failed | Date |
| --- | --- | --- |
| Previewing an edited build via document.write or a blob: URL on the live Pages origin | The page's meta CSP pins script/style by sha256. The edited script is blocked, and blob: inherits the creator's CSP. Preview on about:blank instead, and recompute both hashes before every push. | 2026-09-23 |
| Using the o-empire-reborn page itself as the push bridge | connect-src 'none' blocks fetch to api.github.com. Use a bridge page without a CSP. | 2026-09-23 |

## Discoveries

- Any edit to the inline script or style must update the matching sha256 in the CSP meta, or the live page boots to a blank canvas with no error shown.
- Internal canvas was a fixed 480x270 stretched to the viewport, so on phones every sprite was squashed vertically ~3x. It now keeps square pixels.

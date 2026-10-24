# Regression provenance

`fixtures/legacy.json` contains frozen outputs evaluated from the final pre-Fracture HTML source, **Gatefold (6)(1).html**, not from the new GDScript implementation. The fixture file records that source's SHA-256.

- 265 states cover all board starts, valid and invalid moves, each Relic, order-sensitive chains, enhanced/marked tiles, guardians, huge scores, and seeded shops.
- 480 slides cover all directions across 120 generated boards, including inherited enhancements and single-merge ordering.
- Five autoplay inputs include the original two-swipe and six-swipe decisions.

`regression.gd` also checks native/legacy save import, invalid-save protection, card targeting, sales, retries, board downsides, the requested automation price, RNG isolation, and asynchronous search parity.

`ui_smoke.gd` instantiates the composed main scene and every board/reward/shop/pack view, plus help, settings, collection, and save overlays. It verifies title/font/card bounds, the shop position below the owned rack, input buffering, persistent UI nodes, tile settling, animation cancellation, touch and controller input routing, Relic ordering, autoplay cancellation, and reduced motion.

It also verifies pixel-art coverage for every catalog item, board-preview RNG isolation and starting-upgrade statistics, retained selector/seed state, immediate purchase charging, repeat-purchase protection, rapid consecutive transactions, persistent shop/wallet instances, settled counters, acquisition arrival, pending pack choices, and feedback cancellation when returning home.

Tests are excluded from the exported game.

`polish.gd` adds checks for one upgrade per floor, unbought-offer persistence, redemption and save/load, refresh on a new floor, live decimal/scientific multiplier tooltips, selected-item selling, preserved shop nodes, and direct Options access. `polish_capture.tscn` is a reproducible browser review fixture; tests are excluded from production exports.

`gate_flow.gd` checks the persisted gate waiting state, preview RNG isolation, blocked moves before entry, authoritative target/move previews, completed gate status, retries and floor rollover, Options return, item-relative hover/selection anchors, tracking item movement, stable placement when re-inspecting one item, repeat-click dismissal, contextual purchasing, and full-height sidebar/shop bounds.

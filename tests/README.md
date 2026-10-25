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

The gate/UI flow suite also checks the compact tooltip footprint, the separate Board area, a deep-copied read-only tile preview, return to unchanged shop/pack state, all 25 boards across three numbered pages, and seed/selection retention while paging.


`scoring.gd` verifies model/presentation separation, actual Relic order, seal passes, explicit retriggers, exact totals, queue-free maximum speed, menu/run cancellation, and reduced motion.

`fracture.gd` covers all new board starts in both modes, expansion save round trips, pack families/sizes and pending choices, Fractures and invalid-use atomicity, copied/inherited/reverse scoring, financial contracts, reserve/fusion/phantoms, edition power, old-save migration, Legendary/Sovereign generation, blocked-cell autoplay isolation, and malformed-save rejection. It compares each original Relic in production Fracture mode against the original mode, in addition to the frozen source fixtures.

`fracture_ui.gd` exercises actual scene callbacks for companion and difficulty selection, three-page boards, offer paging/locking, floor-upgrade choices, Mega packs, item/Relic targeting, reserves, and Workshop operations. It checks font glyphs across all new catalog text. Browser review fixtures cover desktop and laptop layouts, dense inventories, blocked cells, and scoring speed. The QA bridge is never included in a production export.


Optional browser acceptance: install Playwright locally, set `GODOT_BIN` if Godot is not on PATH, run `python3 tools/export_review.py`, then `node tests/browser_fracture.cjs`. Set `GATEFOLD_CHROMIUM` for a specific browser executable. Screenshots go to `build/review`. Rebuild the ordinary Web preset before publishing; the workflow always exports the production main scene.

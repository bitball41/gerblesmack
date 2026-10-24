# Regression provenance

`fixtures/legacy.json` contains frozen outputs evaluated from the final pre-Fracture HTML source, **Gatefold (6)(1).html**, not from the new GDScript implementation. The fixture file records that source's SHA-256.

- 265 states cover all board starts, valid and invalid moves, each Relic, order-sensitive chains, enhanced/marked tiles, guardians, huge scores, and seeded shops.
- 480 slides cover all directions across 120 generated boards, including inherited enhancements and single-merge ordering.
- Five autoplay inputs include the original two-swipe and six-swipe decisions.

`regression.gd` also checks native/legacy save import, invalid-save protection, card targeting, sales, retries, board downsides, the requested automation price, RNG isolation, and asynchronous search parity.

`ui_smoke.gd` builds every board/reward/shop/pack view and the help, settings, collection, and save dialogs. It verifies automatic input actually advances the run.

Tests are excluded from the exported game.

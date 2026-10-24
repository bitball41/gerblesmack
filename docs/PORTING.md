# Gatefold Godot Web

A native Godot 4.5 project using the supplied HTML game as the rules and visual reference. The HTML game is not embedded in the runtime.

## Presentation and scene structure

The runtime uses original 32px sprite drawings, fifteen illustrated board portraits, a 5x7 bitmap alphabet, unfiltered textures, square beveled frames, and a quantized animated background. Original card palettes and rules are retained; the reference vectors and Nimbus fonts are excluded from the Web export.

New-run selection uses a large board portrait, benefits and drawbacks, and compact browsing portraits. Its statistics and starting kit are generated with an isolated, non-persisting Game instance, so previews include starting upgrades and cannot mutate the active run or its RNG. The five additional boards retain a separate page. The shop sits below the owned rack, and its scene and wallet persist through purchases.

Reusable scenes:

- `scenes/ui/home.tscn`: title, miniature board, fanned cards, continue/new-run navigation, records, and utilities.
- `scenes/ui/run.tscn`: HUD, engine rack, pocket, receipt, and upgrade display.
- `scenes/ui/board.tscn` and `tile.tscn`: grid, directional movement, merge pops, spawning, and tile enhancement marks.
- `scenes/ui/card.tscn`: illustrated cards, hover tilt, descriptions, scoring pulses, drag/drop, and keyboard reorder.
- `scenes/ui/run_select.tscn`: board portraits, traits, actual starting statistics/kit, page browsing, random selection, and seed entry.
- `scenes/ui/shop.tscn`: persistent shop, individual offer replacement, purchase actions, upgrade ticket, packs, and healing.
- `scenes/ui/wallet.tscn`: interrupted/restarted balance counting, signed transaction popups, and short count ticks.
- `scenes/ui/pack.tscn`: staggered card reveal, choice, and skip.
- `scenes/ui/overlay.tscn`: modal host, inspection, help, collection, settings, and save transfer.
- `scenes/ui/feedback.tscn`: chip sounds, card acquisitions, coin flights, gate banners, score popups, and pixel particles.

Board animation completes through a signal. Inputs buffer through short slides. Transactions commit to Game and save immediately; visual flights never delay the charge or grant. Repeated requests cannot buy the same offer twice. Acquired cards are revealed at their destinations when the flight exits, including safe cleanup on cancellation. Money interpolation handles interrupted changes without changing scientific arithmetic. Navigating away clears transient effects and invalidates pending work. No global time-scale change affects the simulation. Reduced motion disables background drift, slides, pops, tilt, coin/card flights, and balance interpolation.

## Gameplay and saves

All 15 boards, 24 Relics, 12 Spells, 5 Runes, 12 Upgrades, and five Guardian rules are retained, including shop and retry behavior, ordered scoring, enhancements, seals, and endless progression.

Scores, money, tile values, targets, and Relic growth use scientific arithmetic beyond floating-point value limits. The original FNV-1a seed hash and Mulberry32 sequence are retained. Both autoplay tiers use the original lookahead rules and a separate simulation sampler, with work divided between frames.

Auto-player upgrades are excluded from non-Robot shops before floor 3. Outside Robot they cost 1.5x their base price, as originally requested; that price increase was missing from the HTML reference.

The existing native save path is unchanged. Import accepts native JSON and the original HTML save format. Original browser storage is detected automatically only on the same origin; other origins require exported JSON because browser storage is isolated by site.

## Controls and verification

WASD/arrows, mouse or touch swipe, and controller D-pad/left-stick input slide the board. Space toggles purchased automation. Escape cancels targeting or opens the menu. Relics can be dragged, moved with inspector buttons, or reordered using Alt+Left/Right while focused.

CI runs the 2,057 source-derived regression assertions and composed-scene integration checks before exporting. UI coverage includes every board/reward/shop/pack, all catalog sprite references, isolated selection previews, interrupted transactions, double-purchase protection, retained shop/wallet nodes, acquisition cleanup, controls, saves, and reduced motion. Browser QA covers title, both selector pages, keyboard/seed start, autoplay, rewards, shop, pack reveal/choice, animated purchases, save/reload, collection/settings, and Chromebook-sized rendering. Controller mapping is exercised with synthetic engine input; no physical controller test is claimed.

Web export uses GL Compatibility with threading disabled, serving all assets from GitHub Pages. Each exported game pack gets a content-addressed filename so a new release does not reuse an older cached pack. Subsequent pushes to main automatically build, test, export, and publish. Visual refinements preserve the pre-Fracture rules; the content expansion remains separate.

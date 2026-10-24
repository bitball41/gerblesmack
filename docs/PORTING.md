# Gatefold Godot Web

A native Godot 4.5 project using the supplied HTML game as the rules and visual reference. The HTML game is not embedded in the runtime.

## Presentation and scene structure

The illustrated title screen, original embedded fonts, line artwork, card palettes, tile colors, and raised controls are restored. The title screen and board selector are separate views; the five additional boards have their own selector page. In a run, the HUD, owned cards, board, and receipt remain persistent nodes. The shop sits beneath the owned rack so purchases and Relic ordering remain accessible.

Reusable scenes:

- `scenes/ui/home.tscn`: title, miniature board, fanned cards, continue/new-run navigation, records, and utilities.
- `scenes/ui/run.tscn`: HUD, engine rack, pocket, receipt, and upgrade display.
- `scenes/ui/board.tscn` and `tile.tscn`: grid, directional movement, merge pops, spawning, and tile enhancement marks.
- `scenes/ui/card.tscn`: illustrated cards, hover tilt, descriptions, scoring pulses, drag/drop, and keyboard reorder.
- `scenes/ui/overlay.tscn`: board selection, shops, packs, inspection, help, collection, settings, and save transfer.
- `scenes/ui/feedback.tscn`: layered synthesized sound, score popups, and particles.

Board animation completes through a signal. Inputs buffer through short slides. Navigating away invalidates pending work, and stopping autoplay or opening a menu cancels its queued search. No global time-scale change affects the simulation. Reduced motion disables drift, slide interpolation, pops, card tilt, particles, and score popups.

## Gameplay and saves

All 15 boards, 24 Relics, 12 Spells, 5 Runes, 12 Upgrades, and five Guardian rules are retained, including shop and retry behavior, ordered scoring, enhancements, seals, and endless progression.

Scores, money, tile values, targets, and Relic growth use scientific arithmetic beyond floating-point value limits. The original FNV-1a seed hash and Mulberry32 sequence are retained. Both autoplay tiers use the original lookahead rules and a separate simulation sampler, with work divided between frames.

Auto-player upgrades are excluded from non-Robot shops before floor 3. Outside Robot they cost 1.5x their base price, as originally requested; that price increase was missing from the HTML reference.

The existing native save path is unchanged. Import accepts native JSON and the original HTML save format. Original browser storage is detected automatically only on the same origin; other origins require exported JSON because browser storage is isolated by site.

## Controls and verification

WASD/arrows, mouse or touch swipe, and controller D-pad/left-stick input slide the board. Space toggles purchased automation. Escape cancels targeting or opens the menu. Relics can be dragged, moved with inspector buttons, or reordered using Alt+Left/Right while focused.

CI runs the 2,057 source-derived regression assertions and composed-scene integration checks before exporting. Browser QA covers the title, selector, keyboard start, autoplay, rewards, shop, pack choice, purchases, save/reload, Relic drag ordering followed by movement, and Chromebook-sized rendering. Controller mapping is exercised with synthetic engine input; no physical controller test is claimed.

Web export uses GL Compatibility with threading disabled, serving all assets from GitHub Pages. Each exported game pack gets a content-addressed filename so a new release does not reuse an older cached pack. Subsequent pushes to main automatically build, test, export, and publish. Visual refinements preserve the pre-Fracture rules; the content expansion remains separate.

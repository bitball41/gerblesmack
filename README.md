# GATEFOLD — Fracture

A Godot Web 2048 roguelike. Choose from 25 boards across three numbered pages, build an ordered Relic engine, clear eight floors, then push into escalating endless play.

The Fracture update adds 10 boards, 30 Relics, six three-tier upgrade families, 15 Fracture consumables, Legendary rarity, and Normal/Cursed difficulty. The original 15 boards, Relic strengths, upgrades, and combos are preserved. Compound Growth is now Legendary with its original effect.

Every shop has two independent pack slots. Five equally likely families—Standard mixed, Reliquary, Grimoire, Sigil, and Fracture—come in Standard (3 choices / 1 pick), Jumbo (5 / 1), and Mega (5 / 2). Unbound Relics use no slot; Oversaturated doubles numerical benefits; Cursed is independent. The Workshop handles loans, investments, wagers, sacrifices, permanent Echoes, rewind, fusion, reserve cards, and board-specific exchanges.

Rounded cards and panels share a quiet tabletop layout. Relics keep distinct colors and stay together in one visible row; pocket overflow uses pages. Rules and current scaling values appear beside the item, with selling available after selection. The illustrated Board button previews current tiles and effects. Next round opens a separate gate selector with progress, authoritative targets, and Guardian rules.

Scoring follows actual Relic order, seal passes, and retriggers, then banks the exact total. The presentation accelerates with large chains. At 8x or with reduced motion, playback and its queue are skipped. Paper, wood, metal, and pack sounds distinguish actions. All new artwork uses editable, manually specified pixel shapes; no image-generation models are used.

## Controls

- WASD, arrows, mouse/touch swipe, or controller D-pad/left stick to slide.
- Space toggles purchased autoplay. Manual input stops it.
- Escape cancels a Spell target or opens Options.
- Drag Relics to reorder; selected-card arrows and Alt+Left/Right also work for ordering the row.
- Click a card for actions; click it again to close. Hover shows rules and current values.
- Workshop opens available Relic abilities and upgrade utilities.
- Options controls sound, motion, speed, fullscreen, and save import/export.

Runs save automatically. Native saves and exported JSON from the original HTML game are supported, including unfinished pack choices. Difficulty, editions, contracts, reserve/phantom cards, and pending Mega choices persist.

## Development and publishing

Use Godot 4.5.2, standard GDScript build with GL Compatibility.

```sh
godot --headless --path . --import
godot --headless --path . --script tests/regression.gd
godot --headless --path . --script tests/ui_smoke.gd
godot --headless --path . --script tests/polish.gd
godot --headless --path . --script tests/gate_flow.gd
godot --headless --path . --script tests/scoring.gd
godot --headless --path . --script tests/fracture.gd
godot --headless --path . --script tests/fracture_ui.gd
godot --headless --path . --export-release Web build/web/index.html
python3 tools/prepare_web.py build/web
```

GitHub Actions runs all seven suites before publishing to GitHub Pages. Test scenes and their browser-only inspection bridge are excluded from production.

Assets are committed. Optional rebuilds use `tools/build_pixel_assets.py` (small pictograms), `tools/build_relic_plates.py` (original Relics/boards), `tools/build_fracture_art.py` (Fracture artwork), `tools/build_shop_art.py` (shop sign/vouchers), and `tools/build_sound_assets.py` (material audio). Pillow and NumPy are only needed to rebuild assets.

See [Fracture rules and tuning](docs/FRACTURE.md), [release notes](docs/RELEASE_NOTES.md), [polish direction](docs/POLISH.md), [scene notes](docs/PORTING.md), [asset provenance](assets/README.md), and [test provenance](tests/README.md).

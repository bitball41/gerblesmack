# GATEFOLD

A native Godot Web 2048 roguelike: choose from 15 boards, build a Relic engine, clear eight floors, then continue in endless.

A compact tabletop presentation with open felt around the board and owned cards, editable 64px Relic illustrations, board portraits, and larger Pixel Operator text. Shop actions use distinct colors; prices stay visible and purchasing appears when an offer is selected.

Hover a card for its rules and current scaling values. Click an owned card for use, reorder, or sell actions in a fixed details dock; click it again to close. Each floor has one persistent upgrade offer. Next round opens a separate gate selector with progress, targets, and guardian rules; Enter starts the gate. The shop and balance remain alive while coins move and purchases arrive in their slots. Paper, wood, metal, and pack-opening cues distinguish actions; reduced motion and sound controls are in Options.

## Controls

- WASD, arrow keys, mouse/touch swipe, or controller D-pad/left stick to slide.
- Space toggles purchased autoplay. Manual input stops it.
- Escape cancels a Spell target or opens the menu.
- Drag Relics to change scoring order; inspector arrow buttons and Alt+Left/Right are also supported.
- Click a pocket card to inspect/use/sell it. Duplicate asks for a source, then an empty destination.
- Settings controls sound, motion, automation speed, fullscreen, and save import/export.

Runs save automatically. Native saves and exported JSON from the original HTML game are supported.

## Development and publishing

Use Godot 4.5.2, standard GDScript build with GL Compatibility.

```sh
godot --headless --path . --import
godot --headless --path . --script tests/regression.gd
godot --headless --path . --script tests/ui_smoke.gd
godot --headless --path . --script tests/polish.gd
godot --headless --path . --script tests/gate_flow.gd
godot --headless --path . --export-release Web build/web/index.html
python3 tools/prepare_web.py build/web
```

GitHub Actions runs all four suites and publishes passing builds to GitHub Pages. No editor installation is required to play or deploy.

Pixel and audio assets are committed. Optional rebuilds: `tools/build_pixel_assets.py` for small pictograms/font, `tools/build_relic_plates.py` for illustrated Relics/boards (Pillow), and `tools/build_sound_assets.py` for material SFX (NumPy). No asset rebuild is needed to play or publish.

See [polish direction](docs/POLISH.md), [migration and scene notes](docs/PORTING.md), [asset provenance](assets/README.md), and [test provenance](tests/README.md). The Fracture content update is a separate next phase.

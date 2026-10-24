# GATEFOLD

A native Godot Web 2048 roguelike: choose from 15 boards, build a Relic engine, clear eight floors, then continue in endless.

An original pixel-art presentation built from reusable Godot scenes: illustrated board portraits, a bitmap font, pixel cards and icons, and a stepped-color animated table. New runs use a portrait browser with a large preview, traits, drawbacks, and the actual starting kit.

The shop stays on screen while balances count, coins move, and purchases fly into their slots. Packs fan out three cards to choose from. Tiles slide and pop, Relics pulse in scoring order, score gains float, and short chip sounds respond to actions. Keyboard input buffers through animation. Reduced motion is available in Settings.

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
godot --headless --path . --export-release Web build/web/index.html
python3 tools/prepare_web.py build/web
```

GitHub Actions runs both suites and publishes passing builds to GitHub Pages. No editor installation is required to play or deploy.

Pixel assets are committed. To regenerate them from the original grid drawings, run `python3 tools/build_pixel_assets.py` with Pillow installed; this is optional for normal development and publishing.

See [migration and scene notes](docs/PORTING.md), [asset provenance](assets/README.md), and [test provenance](tests/README.md). The Fracture content update is a separate next phase.

# GATEFOLD

A native Godot 4.5 Web port of the 2048 roguelike. Choose from 15 boards, build a Relic engine, clear eight floors, and continue in endless.

Development order: gameplay conversion → visual polish → Fracture content update.

GitHub Actions runs regression tests and exports the game for GitHub Pages. No local Godot installation is required to play or deploy.

Enable hosting once in **Settings → Pages → Source → GitHub Actions**, then rerun the deployment. After that, pushing to main publishes the new build automatically.

## Controls

- WASD, arrow keys, or swipe to slide.
- Space toggles purchased autoplay; manual movement stops it.
- Escape cancels a Spell target or returns to the menu.
- Relic arrows change scoring order. Hover to inspect effects.
- Settings includes sound, fullscreen, autoplay speed, and save export. Import native or legacy HTML save JSON from the main menu.

## Development

Use Godot 4.5.2 (standard GDScript build, GL Compatibility).

```sh
godot --headless --path . --import
godot --headless --path . --script tests/regression.gd
godot --headless --path . --script tests/ui_smoke.gd
godot --headless --path . --export-release Web build/web/index.html
```

See [migration notes](docs/PORTING.md) and [test provenance](tests/README.md).

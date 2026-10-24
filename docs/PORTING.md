# Godot migration status

This is a real Godot 4 project, not an HTML wrapper. It is intentionally a pre-Fracture migration of the existing game.

- [x] Godot project and native scene
- [x] GitHub Pages export workflow
- [ ] Verify Godot runtime and browser deployment
- [ ] Match JS game's exact RNG and late-run arbitrary exponent handling
- [ ] Match all legacy relic interactions, spells, upgrades and autoplay heuristics
- [ ] Existing browser-save conversion
- [ ] Visual polish (next phase)
- [ ] Fracture expansion (after visual polish)

Gameplay progress is saved as Godot user:// JSON. The old HTML localStorage save is not automatically imported.

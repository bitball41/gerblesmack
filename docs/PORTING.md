# Godot migration

The pre-Fracture game runs in native Godot 4.5 GDScript. No HTML game is embedded in the runtime.

Implemented and checked against the final HTML reference:

- All 15 boards, 24 Relics, 12 Spells, 5 Runes, 12 Upgrades, and five Guardian rules.
- Single-merge 2048 slides, enhancements, seals, left-to-right scoring chains, payouts, retries, shops, packs, and endless progression.
- Scientific scores, money, tile values, targets, and Relic growth beyond floating-point value limits.
- The original FNV-1a seed hash and Mulberry32 random sequence.
- Both original autoplay searches: two-swipe visible-next-tile planning and six-swipe sampled rollouts. Search uses a separate RNG, leaves the live run untouched, and yields between batches in the UI.
- Autosave, native JSON export/import, and import of the original HTML save format. A legacy save is automatically detected only when it exists on the same browser origin. Other origins require pasting exported save JSON; browsers isolate each site's storage.
- Board pages, tooltips, Relic ordering, consumable sales, collection, help, sound, fullscreen, and automation speed controls.

Auto-player Upgrades are excluded from non-Robot shops before floor 3. Outside Robot they cost 1.5x their base price, as originally requested; that price increase was missing from the HTML reference. Board downsides match the latest HTML balance.

Verification: 265 source-derived state cases, 480 slide cases, and five autoplay scenarios; 2,057 regression assertions including synchronous/asynchronous autoplay parity. UI smoke checks cover every board, reward screen, shop, pack, menu, and automatic input. CI runs both suites before exporting.

The visual redesign/polish and the Fracture content expansion remain the next two phases, in that order.

## GitHub Pages

Web export uses GL Compatibility with thread support explicitly disabled. Assets are loaded from the Pages origin without jsDelivr, Cloudflare, cross-origin-isolation headers, or a local editor installation.

The repository owner must enable Pages once at Settings → Pages → Build and deployment → Source → GitHub Actions. The workflow cannot create that repository setting with its default token. Rerun the failed deploy job after enabling it. Subsequent pushes to main build, test, export, and publish automatically.

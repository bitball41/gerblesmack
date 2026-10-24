# Tabletop polish pass

## Intent
Gatefold is a short-session puzzle roguelike about assembling an increasingly unreasonable scoring engine. The presentation should make the next puzzle decision, each Relic's role, and a purchase's consequence easy to understand. Keep the existing run rules and combo potential. Fracture remains a separate content update.

Art direction: ivory printed objects on restrained teal felt, warm metal accents, clear silhouettes, and brief tactile movement. Large numbers carry immediate information; quiet table space separates decisions. Reference screenshots informed hierarchy, spacing, contextual actions, and semantic button colors. They are not a source of game assets.

## Three problems addressed

1. Heavy slot frames, large cards, and permanent descriptions gave nearly every element equal emphasis. Owned cards now occupy compact groups without empty placeholder boxes; the board is smaller; secondary statistics are unboxed. The shop has a single tray, restrained background, and open margins.
2. Basic tooltips did not expose evolving Relic state, and item interaction replaced the table with an inspector. Hover panels now have a distinct title, emphasized numeric rules, rarity, and live state. Selected owned cards show local actions; only selection exposes selling. Shop offers reveal a Buy action on selection. Options opens directly from the sidebar.
3. Enlarged 32px icons and chip oscillators made unrelated objects and actions feel interchangeable. New editable 64px Relic plates use deliberate silhouettes and consistent paper/ink palettes. Board portraits share the print treatment. Audio separates paper friction, wooden impacts, metal clinks, pack tearing, and resonant milestone cues.

## Production rules

- Logical canvas: 1440 × 900 with an expanding aspect ratio, canvas-item stretching, and an identity root transform. Text sizes use 18px steps with a 36px body default; nearest sampling preserves the art treatment. See the readability revision below.
- Main Relic illustrations are 64 x 64 source images, displayed within larger readable card frames. Keep editable source in `tools/build_relic_plates.py`. Board portraits are 80 x 100. Small interface pictograms remain in the existing pixel set.
- No image-model artwork is used. The source uses explicit pixel shapes and palette assignments. No Balatro imagery or audio is included.
- One upgrade is offered per floor. An unpurchased offer persists between that floor's shops. Buying it leaves the ticket redeemed for the rest of the floor; a new floor offers a new ticket. Rerolls affect the normal offers. Cadence and purchase state survive saving, loading, and retries; old saves remain importable.
- Show current multipliers for Monolith, Compound Growth, Deep Pockets, Runekeeper, and Steelworks; stored points for Dry Cell; trigger progress for Feedback Loop. Resonance explicitly describes its temporary, per-swipe state. Scientific values do not pass through integer-only formatting.
- Commit transactions immediately. Animation explains the transaction and does not delay ownership or payment. Preserve the shop and wallet nodes while buying or inspecting an owned item.
- Material sounds are original synthesized PCM assets with noise excitation and damped resonators. Source is in `tools/build_sound_assets.py`; runtime only plays committed WAVs. Sound and motion settings remain available.

## Review and acceptance

Automated checks cover legacy behavior, scene composition, immediate and repeated transactions, floor-ticket persistence across save/load and floor transitions, fractional and scientific tooltip values, and contextual selling. Browser review uses a reproducible test scene excluded from production exports, followed by normal entry-point checks.

Review at 1366 x 768 as well as larger views. Inspect normal play, shop, hover and selected tooltips, offer selection, Options, both board pages, packs, purchase arrival, and reload. Check that text and art remain readable, the shop never overlaps owned cards, the selected panel can be dismissed, and critical buttons remain visible. A visual walkthrough establishes layout and interaction behavior; it does not establish player enjoyment.

## Gate pacing and readability revision

The largest observed issue was text rasterized from a tiny homemade font through a 2/3 root transform and another browser fit. The new interface uses a 1440 × 900 logical canvas with an expanding aspect ratio and an identity root transform. Canvas-item stretching rasterizes the UI at the output resolution instead of enlarging a small viewport texture. The initial Pixel Operator revision remained too thin. The current m6x11plus face uses fuller strokes, stronger lowercase shapes, 36 logical pixels for the main interface, 27px supporting text in tooltips and the board catalog, and larger values and headings. Import disables antialiasing, hinting, subpixel placement, and font oversampling. Browser fitting can still be fractional; this is a responsive pixel-style UI, not a claim of integer-perfect pixels at every resolution.

Mixed-case rule text sits on quiet, contrasting surfaces. Cards have enough width for names such as Crystallize and Singularity without breaking the word. Hover changes the border, without scaling or rotating text. The sidebar fills the left edge and full height; the shop reaches the bottom and stops before a separate Board area on the right. Wider windows gain table space instead of side gutters.

The shop, gate selector, and board are separate stages. Next round commits the next gate and enters a persisted `gates` waiting phase. All three gates show route status, score target, move count, base reward, and the guardian's rule. Only the current gate has an enabled Enter action. Failure returns to the same gate, and clearing the third gate starts a fresh floor route. Previewing cannot consume RNG or change game state. Existing saves in active play continue as active play.

Item details anchor to the inspected item, shared by hover and selection. The preferred anchor is beside the item; right-edge items use their left side, and vertical placement is clamped to the window. Moving the cursor within the same item does not alter placement. The live multiplier is visible on hover. Clicking pins actions; clicking the same card, upgrade, or pack choice again closes it. Offer Buy and owned Sell actions appear only after selection. Packs require an explicit Take action. Options returns to the current shop or gate selector without starting a gate.

Research used for the typography decisions:

- [Godot 4.5: Using fonts](https://docs.godotengine.org/en/4.5/tutorials/ui/gui_using_fonts.html): design-size multiples, nearest filtering, dynamic font rasterization, and disabling subpixel positioning for pixel fonts.
- [Game Accessibility Guidelines: clear text formatting](https://gameaccessibilityguidelines.com/use-simple-clear-text-formatting/): distinct glyphs, mixed case, left alignment, spacing, and unfussy backgrounds.
- [m6x11plus by Daniel Linssen](https://managore.itch.io/m6x11): the active typeface, free to use with attribution. Attribution appears in Options and `assets/type/m6x11plus-NOTICE.txt`.

Validation adds `tests/gate_flow.gd` for waiting-state save import, blocked gameplay before entry, accurate previews, retries, floor transitions, Options return, item-anchored details, and repeated-click dismissal. Browser review covers 1440 × 900 and 1366 × 768, with pointer-driven purchase, upgrade redemption, pack choice, gate entry, and settings checks.

The appearance review compares actual card names, long descriptions, targets, prices, and UI headings on full screens. Font settings are supporting implementation choices; visual clarity and a coherent appearance are the acceptance criteria. Readability fixes include balanced two-line upgrade names, enough vertical room for the Robot drawback and Chronicle/Archivist descriptions, and ASCII punctuation where the chosen face lacks a glyph. Hover-only tooltip descendants ignore pointer input so the popup cannot intercept another card beneath it.

## Catalog and shop composition revision

New Run uses two plain numbered pages: the first ten boards, then the remaining five. Portraits form a gallery on the left; the selection has one ivory rules card on the right. A colored print stripe and the portrait identify the board. The card includes a concise ability, description, drawback when present, actual starting stats, and a compact starting kit. Navigation preserves the selected board and seed. Back, Random, Seed and Start run have a stable footer; there are no invented board categories or dashboard stat boxes.

The shop is 848 logical pixels wide and still reaches the bottom. Its layout is deliberate: Next round and Reroll at top left, four normal offers at top right, the floor upgrade at bottom left, and the Supply Pack at bottom right. Healing appears below the top-left controls when available. Coin feedback targets the relocated button. The separate Board button opens current tiles, the active board's name, ability, description and drawback. Viewing it neither advances the run nor changes RNG, prices, choices or money. Returning restores the shop or the pending pack choice.

Tooltip width falls from 346 to 300 pixels. Header size is 36px and rule/live-state text is 27px, with reduced padding and gaps. Hover remains attached to each item; click actions and repeated-click dismissal remain. The approved m6x11plus face is retained. Compact shop card titles fit long words without splitting or cropping them.

Custom views fill their assigned host with zero offsets. The old shop scene minimum size is removed so its pointer-input area stays within the visible shop frame and cannot cover the Board button.

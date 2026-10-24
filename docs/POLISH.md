# Tabletop polish pass

## Intent
Gatefold is a short-session puzzle roguelike about assembling an increasingly unreasonable scoring engine. The presentation should make the next puzzle decision, each Relic's role, and a purchase's consequence easy to understand. Keep the existing run rules and combo potential. Fracture remains a separate content update.

Art direction: ivory printed objects on restrained teal felt, warm metal accents, clear silhouettes, and brief tactile movement. Large numbers carry immediate information; quiet table space separates decisions. Reference screenshots informed hierarchy, spacing, contextual actions, and semantic button colors. They are not a source of game assets.

## Three problems addressed

1. Heavy slot frames, large cards, and permanent descriptions gave nearly every element equal emphasis. Owned cards now occupy compact groups without empty placeholder boxes; the board is smaller; secondary statistics are unboxed. The shop has a single tray, restrained background, and open margins.
2. Basic tooltips did not expose evolving Relic state, and item interaction replaced the table with an inspector. Hover panels now have a distinct title, emphasized numeric rules, rarity, and live state. Selected owned cards show local actions; only selection exposes selling. Shop offers reveal a Buy action on selection. Options opens directly from the sidebar.
3. Enlarged 32px icons and chip oscillators made unrelated objects and actions feel interchangeable. New editable 64px Relic plates use deliberate silhouettes and consistent paper/ink palettes. Board portraits share the print treatment. Audio separates paper friction, wooden impacts, metal clinks, pack tearing, and resonant milestone cues.

## Production rules

- Native canvas: 960 x 600, rendered with nearest sampling. Logical interface coordinates remain 1440 x 900 at 2/3 scale. Text sizes snap to 15 logical units, producing 10px bitmap steps at native resolution. Browser fitting can enlarge fractionally; it does not apply smoothing or force a small integer-scale window.
- Main Relic illustrations are 64 x 64 and display at native size in the owned rack. Keep editable source in `tools/build_relic_plates.py`. Board portraits are 80 x 100. Small interface pictograms remain in the existing pixel set.
- No image-model artwork is used. The source uses explicit pixel shapes and palette assignments. No Balatro imagery or audio is included.
- One upgrade is offered per floor. An unpurchased offer persists between that floor's shops. Buying it leaves the ticket redeemed for the rest of the floor; a new floor offers a new ticket. Rerolls affect the normal offers. Cadence and purchase state survive saving, loading, and retries; old saves remain importable.
- Show current multipliers for Monolith, Compound Growth, Deep Pockets, Runekeeper, and Steelworks; stored points for Dry Cell; trigger progress for Feedback Loop. Resonance explicitly describes its temporary, per-swipe state. Scientific values do not pass through integer-only formatting.
- Commit transactions immediately. Animation explains the transaction and does not delay ownership or payment. Preserve the shop and wallet nodes while buying or inspecting an owned item.
- Material sounds are original synthesized PCM assets with noise excitation and damped resonators. Source is in `tools/build_sound_assets.py`; runtime only plays committed WAVs. Sound and motion settings remain available.

## Review and acceptance

Automated checks cover legacy behavior, scene composition, immediate and repeated transactions, floor-ticket persistence across save/load and floor transitions, fractional and scientific tooltip values, and contextual selling. Browser review uses a reproducible test scene excluded from production exports, followed by normal entry-point checks.

Review at 1366 x 768 as well as larger views. Inspect normal play, shop, hover and selected tooltips, offer selection, Options, both board pages, packs, purchase arrival, and reload. Check that text and art remain readable, the shop never overlaps owned cards, the selected panel can be dismissed, and critical buttons remain visible. A visual walkthrough establishes layout and interaction behavior; it does not establish player enjoyment.

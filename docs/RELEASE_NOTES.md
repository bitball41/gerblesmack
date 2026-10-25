# Huge numbers and Hollow — 1.1.2

- Selling Singularity now permanently raises Ghostwriter's stored multiplier to Singularity's current power. Both relics' numerical edition benefits apply. Other scoring-relic sales retain their existing multiplier behavior; Ghostwriter remains Rare.
- Huge values display six significant digits and nested scientific exponents, such as `1.23e4.56e7`. Layered magnitudes show the coefficient of their enormous exponent. Numeric sidebars fit their available space and expose ten significant digits on hover; display rounding never alters the saved value.
- Layered score arithmetic, overflow protection, exact retrigger counters, adaptive animation, 8x skip, reduced motion, and Devourer's current Echoed behavior are retained and regression checked.
- New Hollow runs start with ordinary-strength Perishable Avalanche. It expires after three successful gate clears, freeing its slot; failed gates do not consume a clear. Its remaining lifetime appears on the card and tooltip, survives saves and transformations, and follows the ability if absorbed by Devourer. Existing Hollow saves do not receive a new relic.

# Retrigger fixes — 1.1.1

- Retriggers now apply the scoring effects they reach. Additions scale by activation count, multipliers use repeated powers, Singularity composes its powers, and Resonance multiplies every growing bonus. Batching preserves left-to-right order, seal passes, Guardian rules, and Mobius reverse scoring.
- Devourer retains each absorbed ability's Echoed passes. Host and inherited Echoes combine independently; growth and payouts occur once per actual merge.
- Exact trigger counters avoid native integer overflow. Scores promote to layered exponents when needed; existing scientific saves still load, and huge totals retain meaningful comparisons, progress bars, and save data.
- Small scoring batches show intermediate values. Large batches show activation counts and automatically accelerate; enormous chains use compressed visual groups. 8x and reduced motion skip the receipt queue. Playback never mutates the run.
- No Relic values, prices, edition strengths, or balance settings changed.

The regression fixture with Echo Chamber, an Echoed Devourer containing two Echo Chambers, Conductor/Ghostwriter, Echoed Ascension, Mobius, four merges, and seals resolves all **663,552 triggers**. Its synthetic Ghostwriter x100,000 fixture scores approximately **8.41e51052**.

Eight Godot suites include an independent unbatched reference, the large build, inherited Echoes, huge powers/counters, save round trips, and adaptive playback. Browser acceptance compares the same saved result at 1x, 2x, 4x, 8x, and reduced motion.

---

# Fracture — 1.1.0

The expansion retains the original game's board statistics, Relic effects, upgrades, and ordered combos. Endless targets accelerate after floor eight.

## Content

- **10 boards:** Glasshouse, Treasury, Eclipse, Vortex, Hollow, Reactor, Twinfall, Nomad, Labyrinth, and Rich Get Richer.
- **30 Relics**, including six new Legendaries: The Conductor, Perpetuum, Devourer, Crown of Echoes, Paradox, and Mobius Engine. Compound Growth joins Legendary rarity without an effect change.
- **18 upgrades:** Storefront, Shatterproof, Satchel, Scrapyard, Wagers, and Fusion Lab, each with three tiers.
- **15 Fractures:** Liberation, Overexposure, Erosion, Rebirth, Schism, Transmutation, Genesis, Singularity Collapse, Transference, Pandemonium, Monoculture, Liquidation, Overdraft, Asceticism, and The Sovereign.
- **Five pack families**, two independent shop slots, and Standard/Jumbo/Mega sizes.
- **Normal/Cursed difficulty.** Cursed Relics offer more power while increasing gate danger. Unbound and Oversaturated editions alter slots and numerical effects.

## Polish and flow

Cards, panels, buttons, tiles, and print frames have rounded corners. Ordered scoring highlights the actual triggering Relic, shows retriggers and seal passes, and banks the exact total. Maximum speed and reduced motion skip playback.

Large inventories retain distinct full-size cards through paging. Extra shop offers use their own pager. Board previews preserve pending pack picks; Mega packs retain their second choice while you make room. Item details remain anchored beside the item, repeat clicks close them, and selling remains contextual.

The Workshop exposes abilities and upgrade actions with their requirements. Transformations highlight eligible targets and preserve the consumable when no valid change is possible. New artwork is built from manually specified pixel shapes with editable source.

## Saves and rules

Older native and HTML saves remain supported. Current offers and already-paid pack choices survive migration. New saves preserve difficulty, editions, copied abilities, contracts, reserve/phantom cards, and pending choices. Malformed imports are rejected before changing the live run.

For exact rules, chosen tuning, and implementation provenance, see [FRACTURE.md](FRACTURE.md). Tuning choices are provisional design decisions; the automated checks establish implementation consistency, not proven long-run balance.

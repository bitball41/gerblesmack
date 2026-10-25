# Fracture release checkpoint

## User-approved scope

Finish rounded UI rectangles and ordered scoring/retrigger presentation, skipped at 8x, together with the Fracture content update. Do not use image-generation models. Preserve existing combos, relic strengths, upgrades, and regular board stats. The only baseline balance change is stronger endless scaling.

Recovered prior decisions (2026-10-24 conversation): add 10 boards: Glasshouse, Treasury, Eclipse, Vortex, Hollow, Reactor, Twinfall, Nomad, Labyrinth, Rich Get Richer. Add 30 new relics and 18 new upgrades. Add Legendary rarity; Compound Growth belongs there without weakening its effect. Five pack types, two guaranteed shop pack slots, Standard/Jumbo/Mega sizes, Fracture cards, and Normal/Cursed difficulty. Individual unfinalized content definitions are implementation choices, not prior agreements.

Treasury grants no cleared-gate cash. Eclipse has exactly one maximum Life. Hollow always has 20% fewer moves. Glasshouse was considered too strong; give its new starting effect a relevant constraint. Rejected board proposals: Wildfire, Oracle, Gambler, Frostline, Cathedral, Mosaic. Rejected upgrades: Forecast, Artificer, Precision. Do not add these.

## Current checkpoint

Rounded cards, panels, controls, tile/grid frames, and print artwork restored after workspace reset. Scoring receipts preserve actual application order, seal passes, and retrigger counts without changing the saved run or RNG. Presentation waits until the slide settles, highlights active relics with numeric badges, and banks exact scientific totals. 8x and reduced motion build no playback queue. Menus and run changes safely settle or cancel it.

Validation: 2,057 legacy checks, 227 UI checks, 28 scoring checks. Full browser review and final release validation remain pending. Fracture content implementation is next.


## Recovered mechanics (prior proposals, preserved for implementation)

Board details: Glasshouse 50% Glass natural spawns, 50% shatter chance, 2 Life. Treasury $50 + Deep Pockets, no gate-clear cash. Eclipse alternates Gold/Glass gates, max Life exactly 1. Hollow 7 relic slots, $4, no Carbon Paper, 20% fewer moves every gate. Vortex rotates every fourth valid swipe. Reactor doubles smallest tile without score every eighth merge, -3 moves. Twinfall duplicates every sixth natural spawn. Nomad starts with a random relic choice and can exchange relics between floors. Labyrinth has one relocating blocked cell. Rich Get Richer starts Oversaturated Compound Growth (current x2, grows x2.5 per gate), +65% prices, +20% targets.

Packs: exactly two guaranteed slots; each independently draws equally from Standard (mixed), Reliquary (relics), Grimoire (Spells), Sigil (Runes), Fracture. Standard size 3 choices/1 pick; Jumbo 5/1; Mega 5/2. Duplicate types allowed. Unbound relics occupy no slot. Oversaturated doubles all printed numerical benefits including growth, multipliers, probabilities and payouts. Cursed is separate, and may coexist with Oversaturated. Normal has no Curse; Cursed difficulty adds stronger items and escalating gate danger. Exact Curse tuning was not finalized.

Fractures: powerful risky consumables. Erosion destroys a random relic. Rebirth destroys a selected relic and supplies a random same-rarity replacement. The Sovereign is random with a 3% chance and no downside. Additional details pending retrieval.

Thirty new relic proposals: Handbrake (refund one nonmerge swipe/gate); Matchbox (first Glass shatter sets next spawn Gold+Glass); Spare Change (Gold+Glass shatter pays $5); Copper Coil (first Steel merge coats adjacent tile); Seedling (Glass shatter raises next spawn, up to 3/gate); Shipping Crate (four distinct values generates a Spell); Leech (consume resulting enhancement for x1.15 permanent growth); Spore Cloud (20% enhancement copy); Cuckoo Clock (each seventh merge refunds a move, twice/gate); Morgue (first sealed Glass shatter transfers seal); Spare Parts (20% Rune refund); Body Double (first targeted Spell also affects another equal tile); Recycling Bin (first relic sale generates Rune); Pandora's Box (first mixed pack/floor gives two picks, second random); Red Thread (first sealed merge guarantees next sealed spawn); Double Exposure (first spawn with two enhancements makes a plain half-value copy); Clone Vat (first 1024+ merge makes a plain copy); Guillotine (optional highest-tile sacrifice after Guardian for x1.8 growth); Loan Shark (borrow up to $50/floor; repay 150% or lose Life); Stowaway (preserve one unbought shop item); Chain Reaction (Glass shatter doubles an adjacent tile, at most 3/gate); Ghostwriter (absorbs sold relic's current multiplier); Risky Investment (deposit half money before Guardian, triple on win, lose on fail); Chrysalis (mark plain tile; three merges grant all three enhancements and seal); Conductor (copies right relic scoring only); Perpetuum (phantom copy of last Spell/Rune on leaving shop, no pocket slot, expires next gate); Devourer (optional scoring relic sacrifice after Guardian; inherit up to two scoring abilities); Crown of Echoes (Guardian victory: permanently Echo one relic; score effects twice, growth/payouts once); Paradox (rewind previous valid swipe once/gate; restore state, reroll spawn); Mobius Engine (first scoring swipe/gate also runs chain in reverse, scoring only). Last six are Legendary.

Eighteen upgrades: Storefront I (extra relic offer), II (one reroll lock), III (choose between two permanent upgrades); Shatterproof I (prevent first shatter/gate), II (first two), III (prevented Glass also Gold, twice/gate); Satchel I (+2 pocket slots), II (two reserve slots), III (duplicate an owned consumable every third Guardian); Scrapyard I (consumable sale +$2), II (+50% relic resale), III (first relic sale/shop produces Common/Uncommon offer); Wagers I (bet up to $10/gate), II ($30), III (Guardian wins triple bet); Fusion Lab I (two Spells -> random Spell), II (two Runes -> chosen Rune), III (two Runes -> double-use Rune).


## Implementation checkpoint 2

Catalog assembled in `fracture_catalog.gd`: 30 new relics (54 total), 18 new upgrades (30 total), 10 new boards (25 total), 15 Fractures, five named pack families. Base catalog dictionaries remain available to frozen legacy fixtures; production uses the combined pools, with Compound Growth Legendary and no effect nerf. The runtime module hooks for boards, editions, copied scoring, new relic triggers, market state, Fractures, and Workshop actions are staged. Parse/import and all 2,057 frozen legacy checks pass. The legacy fixture helper explicitly selects original pools/version; new-game integration will be tested separately.

Exact additional recovered corrections: Deep Pockets is the existing `charity` relic. Treasury grants no gate-clear cash INCLUDING efficiency/interest; relic, merge, and sale income still works. Erosion destroys a random relic for +1 slot. The Sovereign creates a random Legendary at 3% per generated Fracture, with no downside. Monoculture sets every tile to the smallest tile value and adds Glass+seal. Liquidation destroys four random tiles for $25. Overdraft gives +2 slots, removes all money, and blocks three cleared gates of interest. Asceticism raises every Rune track once and destroys enhanced/sealed tiles.

Next: wire consumable metadata/targeting and sales hooks; validate all new models; draw new artwork; connect three board pages, Normal/Cursed selector, two pack slots and five-card Mega packs, and all Workshop choices. Browser regression and production deployment are still pending. Do not publish main until all of these are complete.


## Implementation checkpoint 3

Core models now pass 225 expansion checks, alongside all 2,057 frozen legacy checks. Coverage includes starts/save round trips for 25 boards in both difficulties; board downsides, blocking, Reactor/Twinfall, Nomad choice, editions/slots, Fracture transformations, Sovereign frequency, all pack families/sizes and pending Mega saves, Conductor/Mobius/Crown/Devourer/Paradox, reserves/Fusion/phantoms, financial contracts, and malformed-save rejection. Serialization now canonically preserves integer-valued fields through JSON.

Manually specified pixel artwork is drawn for all 30 relics, 18 upgrades, 15 Fractures, 10 boards, 15 pack wrappers, and 18 new voucher variants. Editable source is `tools/build_fracture_art.py`; no image models are used. The art contact sheet was visually reviewed.

Chosen tuning where the discussion was unfinished: Normal has no Curse. Cursed starts at 2 Curse; Cursed relics have x1.5 numerical power and add 2 Curse when acquired. Each Guardian attempt adds 1 Curse. Targets multiply by 1.15^Curse; each 5 Curse removes one starting move. Oversaturated is x2 and independent of Cursed. Endless adds 2^(d(d+1)/2) after floor 8, with d=floor-8. Pack-size weights are 60% Standard, 28% Jumbo, 12% Mega; each family is equally likely in each of two slots. New relic editions are 2% Unbound and 3% Oversaturated; Cursed-mode relics have a separate 30% Cursed roll. These tuning choices are implementation decisions, not falsely attributed prior approvals.

Still pending: frontend flows, model edge-case expansion, full UI/browser checks, final deployment. Keep checkpointing on fracture-release; main stays on the last working public polish build until release validation passes.


## Implementation checkpoint 4

Frontend paths are connected: three numbered board pages (original 10 / existing named 5 / Fracture 10), Normal/Cursed selection with retained seed, mandatory Nomad companion choice, actual blocked-cell drawing/sliding, independent two-slot typed packs, Jumbo/Mega choices, offer paging/locking/stowing, Storefront floor choice, relic/tile Fracture targeting, reserve/phantom consumption, Workshop choices and fusion, and a compact owned-upgrade gallery. New item foregrounds choose the stronger contrast against each unique card color.

Validation now includes 357 scene/UI checks, 126 expansion UI checks, 225 model checks, 51 gate-flow checks, 23 polish checks, and 28 scoring checks. The 2,057 frozen rule checks remain in CI. The new tests exercise UI callbacks, not only direct model operations. All current suites pass locally; browser visual review and final edge-case work remain pending.

Remaining before release: browser screenshots and clicks at desktop/laptop sizes; old-save shop/pack migration; rarity/edition edge-case review; complete help/release notes; final production export/save-reload test; public deployment verification. Do not treat this branch checkpoint as a finished public release.

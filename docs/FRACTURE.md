# Fracture rules and implementation

Fracture adds content while retaining the original 15 boards, 24 Relic strengths, 12 upgrades, and ordered combos. Compound Growth changes rarity to Legendary; its effect stays the same. The only baseline target change is accelerated endless scaling after floor eight. All artwork uses manually specified pixel shapes, without image-generation models.

## Boards

The original ten boards remain on page one, the existing five named boards on page two, and these ten additions on page three.

| Board | Starting rule and constraint |
| --- | --- |
| Glasshouse | 50% Glass natural spawns, Glass starting tiles, 2 Life, 50% shatter chance. |
| Treasury | $50 and the existing Deep Pockets Relic; no gate-clear, efficiency, or interest cash. Merge, sale, and Relic payouts still work. |
| Eclipse | Alternate Gold/Glass gates; exactly 1 maximum Life. |
| Vortex | Rotate clockwise after every fourth valid swipe, without scoring the turn. |
| Hollow | 7 relic slots, $4, no Carbon Paper; starts with Perishable Avalanche, expiring after three successful gate clears. 20% fewer starting moves every gate, including upgrade bonuses. |
| Reactor | Every eighth actual merge doubles the smallest tile without scoring; -3 starting moves. |
| Twinfall | Every sixth natural spawn makes one identical copy in an empty cell. Copies do not recurse. |
| Nomad | Choose a starting companion from three Relics. At each new floor, optionally exchange a Relic for a random same-rarity replacement. |
| Labyrinth | One blocked cell relocates to an empty square each gate. Tiles slide in separate segments around it. |
| Rich Get Richer | Oversaturated Compound Growth starts effective x2 and grows x2.5 each clear; shop prices +65%, targets +20%. |

Rejected board proposals remain excluded: Wildfire, Oracle, Gambler, Frostline, Cathedral, Mosaic. Rejected upgrades Forecast, Artificer, and Precision are excluded.

## Relics, upgrades, and Workshop

The catalog has 54 Relics, including 30 additions. Handbrake through Chrysalis introduce refunds, enhancement transfer, shatter effects, consumable generation, permanent growth, and financial choices. Six new Legendaries provide copied scoring (Conductor), phantom cards (Perpetuum), inherited abilities (Devourer), permanent Echoes (Crown of Echoes), state rewind (Paradox), and reverse scoring (Mobius Engine).

The Workshop exposes available actions and their requirements. Optional Guardian rewards remain available until used. Copies and reverse scoring apply scoring abilities; copied growth and money payouts do not run again. Permanent Echoes repeat scoring while physical growth/payout hooks run once. Devourer keeps acquired abilities if its edition later changes, but its current power limits further inheritance. Paradox restores the previous valid swipe's board, score, moves, money, and Relic state, spends a gate-limited charge, and rerolls the next tile.

Six new upgrade families each have three tiers:

| Family | I | II | III |
| --- | --- | --- | --- |
| Storefront | Extra shop offer | One reroll lock | Choose floor upgrade from two |
| Shatterproof | Prevent first shatter | Prevent first two | Saved Glass also becomes Gold |
| Satchel | +2 pocket slots | Two-slot reserve | Consumable duplication every third Guardian victory |
| Scrapyard | Consumable sale +$2 | Relic resale +50%, rounded up | First relic sale each shop creates a replacement offer |
| Wagers | Stake up to $10 | Stake up to $30 | Guardian wager wins return x3 |
| Fusion Lab | Two Spells -> random Spell | Two Runes -> chosen Rune | Two Runes -> chosen double-use Rune |

The complete names, costs, and printed effects are authoritative in [fracture_catalog.gd](../scripts/fracture_catalog.gd). These runtime entries extend the base catalog rather than rewriting it.

## Packs and editions

Every shop has exactly two independent slots. Each slot equally selects Standard mixed, Reliquary (Relics), Grimoire (Spells), Sigil (Runes), or Fracture. Duplicate families are allowed. Standard size offers 3 choices / 1 pick; Jumbo 5 / 1; Mega 5 / 2. A pending Mega keeps its remaining picks through previews, making room, and saves. Each slot can be charged only once.

Unbound uses no relic slot. Oversaturated doubles printed numerical benefits, including multipliers, growth rates, probabilities, payouts, capacities, and positive quantities. Integer benefits round upward; costs and eligibility requirements are not increased. Cursed is independent and stacks multiplicatively. New copies retain their metadata and unique identity. Once-per-gate physical activations track their owning Relic rather than collapsing duplicate cards into one activation.

## Fractures

| Card | Result and cost |
| --- | --- |
| Liberation | Selected Relic becomes Unbound; permanently -2 starting moves. |
| Overexposure | Selected Relic becomes Oversaturated; -1 maximum Life, never below 1. Converting Unbound requires a normal slot. |
| Erosion | Destroy a random Relic; +1 relic slot. |
| Rebirth | Destroy the selected Relic; receive one random same-rarity replacement. |
| Schism | Copy the selected Relic; destroy two other random Relics. |
| Transmutation | Randomly redistribute editions. Cursed/Echoed states stay attached. |
| Genesis | Copy the selected tile; destroy two other random tiles. Requires three tiles and an empty cell. |
| Singularity Collapse | Keep the three highest tiles and seal them. |
| Transference | Concentrate enhancements and seals on the selected tile. |
| Pandemonium | Shuffle tiles, add random enhancements, lose 1 Life; requires at least 2 Life. |
| Monoculture | All tiles become the smallest current value, Glass, and sealed. |
| Liquidation | Destroy four random tiles; gain $25. |
| Overdraft | +2 relic slots, lose all money, no interest for the next three clears. |
| Asceticism | Raise all five Rune tracks once; destroy enhanced/sealed tiles. |
| The Sovereign | Create a random Legendary; no downside. 3% chance per generated Fracture, with unique pack options. |

Invalid or already-completed transformations keep the card and do not consume RNG. Target pickers highlight eligible choices. Immediate uses with no valid result are disabled.

## Chosen tuning

These numbers resolve unfinished design details. They are implementation choices, not claims of prior approval or proven balance.

- Normal has no Curse. Cursed starts at 2 Curse. Cursed Relics have x1.5 numerical power and add 2 Curse on acquisition; each Guardian attempt adds 1 Curse. Targets multiply by 1.15^Curse; every 5 Curse removes one starting move.
- Oversaturated is x2, or x3 combined with Cursed. Relic rolls give 2% Unbound and 3% Oversaturated; Cursed mode separately rolls 30% Cursed.
- Pack-size weights: 60% Standard, 28% Jumbo, 12% Mega. Base costs: $5 / $8 / $10, with board markup. New pack Relic rarity weights: 55% Common, 32% Uncommon, 12% Rare, 1% Legendary, falling back only when a tier is exhausted.
- Endless adds 2^(d(d+1)/2) to the original target after floor eight, where d=floor-8.
- Loan repayment is 150% of principal. Default costs one Life. Risky Investment deposits half the balance and returns x3 on a Guardian clear. Ordinary winning wagers return x2; Wagers III returns x3 at Guardians.

## Presentation, persistence, and checks

Rounded rectangles are shared across panels, controls, cards, grid cells, and print frames. Scoring receipts preserve actual application order, seal passes, retriggers, and final scientific totals. Large chains accelerate as a group; 8x and reduced motion allocate no playback queue. Menus settle playback, and new runs cancel callbacks. Vortex turns follow the slide visibly. Large inventories and extra shop offers use pages at full card size.

Save version 3 retains expansion metadata, contracts, copied abilities, reserve/phantom cards, and unfinished packs. Versions 1/2 and original HTML JSON import remain supported. Old shop offers and already-paid pending choices survive migration. Imports validate before mutation. The rewind snapshot is serialized separately to prevent recursive state and numeric-decoding errors. Autoplay copies expansion state and uses isolated RNG; it respects blockers, board movement hooks, spawn rules, and shatter prevention.

Seven automated suites run before publication. They include frozen pre-Fracture source outputs, production-mode parity for every original Relic, all 25 board starts in both modes, expansion effects, save migration, invalid-use atomicity, and scene callback checks. Browser checks cover 1440x900 and 1366x768 layouts, actual shop/pack/target interactions, scoring-speed equivalence, and seeded Cursed-run reload. Test scenes and the QA bridge are excluded from production.

Remote checkpoints on `fracture-release` preserve each substantial stage. Final release verification is recorded in the Git commit and Pages workflow, rather than treating an intermediate checkpoint as a finished build.

## Retrigger correction (1.1.1)

Repeat producers still multiply the incoming trigger count by their existing value. Every trigger reaching a later addition applies that addition; every trigger reaching a multiplier applies that multiplier. For incoming count n, these batches are `points + bonus*n`, `points * factor^n`, and `points^(power^n)` respectively. Trigger producers apply their score multiplier n times and expand the count once by their fan-out, rather than recursively reapplying themselves to their own output. Resonance uses the product of its successive bonuses, whose exponent is `n*(position+1) + n*(n-1)/2`. Feedback preserves its point-copy rule and advances its carry using exact integer arithmetic, including generated triggers.

These are scoring corrections, with no changes to catalog numbers, prices, editions, or balance. Growth and cash remain tied to actual merges. Devourer's scoring passes multiply its host Echoes by each absorbed ability's own Echoes; regular physical relics count their own modifier once. Conductor retains its existing scoring-only copy behavior.

Ordinary scores retain the two-field scientific save representation. Beyond the precision of a native exponent, an optional third field records the exponent layer. `eeX` means `10^(10^X)`; each additional e adds another outer power of ten. Arithmetic retains scientific precision rather than allocating score digits. Animation receipts are transient and never replay into these rules.

## Huge numbers and temporary starts (1.1.2)

Singularity sales apply `Ghostwriter growth ^ (1.2 * Singularity power * Ghostwriter power)`, while ordinary scoring-relic sales keep multiplying by their existing current factor. This powers the stored growth permanently; it does not turn Ghostwriter into a power-effect scoring relic. Its rarity stays Rare.

Number formatting defaults to six significant digits, with higher precision available on hover. Nested e notation associates to the right: `1.23e4.56e7` means `1.23 * 10^(4.56 * 10^7)`. A leading `1e` on a layered magnitude adds an outer power of ten. The stored number representation and scoring remain independent of display precision.

Only new Hollow runs receive the three-clear Perishable Avalanche. Successful results decrement its persistent lifetime once, independent of merge/retrigger count; failed results leave it alone. Expiration removes the relic without sale rewards. An inherited temporary ability keeps its remaining lifetime and expires independently of Devourer. Rebirth and other trait-preserving transformations retain that lifetime.

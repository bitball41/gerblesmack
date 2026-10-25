extends RefCounted
## Fracture content. Existing item effects remain in the base catalog.
const RELICS = {
 "handbrake": {
  "id": "handbrake",
  "name": "Handbrake",
  "desc": "Refund the first valid swipe without a merge each gate.",
  "rarity": "Common",
  "cost": 5,
  "art": "handbrake",
  "accent": "#467b82",
  "type": "joker",
  "colors": [
   "#467b82",
   "#fff3d5"
  ]
 },
 "matchbox": {
  "id": "matchbox",
  "name": "Matchbox",
  "desc": "The first Glass shatter each gate makes the next natural tile Gold and Glass.",
  "rarity": "Common",
  "cost": 5,
  "art": "matchbox",
  "accent": "#ad6545",
  "type": "joker",
  "colors": [
   "#ad6545",
   "#fff3d5"
  ]
 },
 "spare_change": {
  "id": "spare_change",
  "name": "Spare Change",
  "desc": "A tile that is both Gold and Glass pays $5 when it shatters.",
  "rarity": "Common",
  "cost": 5,
  "art": "spare_change",
  "accent": "#c09b45",
  "type": "joker",
  "colors": [
   "#c09b45",
   "#1d2d35"
  ]
 },
 "copper_coil": {
  "id": "copper_coil",
  "name": "Copper Coil",
  "desc": "The first Steel merge each gate makes one adjacent tile Steel.",
  "rarity": "Common",
  "cost": 5,
  "art": "copper_coil",
  "accent": "#568675",
  "type": "joker",
  "colors": [
   "#568675",
   "#fff3d5"
  ]
 },
 "seedling": {
  "id": "seedling",
  "name": "Seedling",
  "desc": "Each Glass shatter raises the next natural spawn one tier, up to three times per gate.",
  "rarity": "Common",
  "cost": 5,
  "art": "seedling",
  "accent": "#88a758",
  "type": "joker",
  "colors": [
   "#88a758",
   "#1d2d35"
  ]
 },
 "shipping_crate": {
  "id": "shipping_crate",
  "name": "Shipping Crate",
  "desc": "Once per gate, finish a swipe with at least four distinct tile values to create a random Spell. Needs pocket space.",
  "rarity": "Common",
  "cost": 5,
  "art": "shipping_crate",
  "accent": "#8e704e",
  "type": "joker",
  "colors": [
   "#8e704e",
   "#fff3d5"
  ]
 },
 "leech": {
  "id": "leech",
  "name": "Leech",
  "desc": "Consume one enhancement from each resulting merged tile to grow its multiplier by x1.15. Starts at x1.",
  "rarity": "Uncommon",
  "cost": 7,
  "art": "leech",
  "accent": "#85617c",
  "type": "joker",
  "colors": [
   "#85617c",
   "#fff3d5"
  ]
 },
 "spore_cloud": {
  "id": "spore_cloud",
  "name": "Spore Cloud",
  "desc": "After a merge, 20% chance to copy its enhancements to one adjacent tile.",
  "rarity": "Common",
  "cost": 5,
  "art": "spore_cloud",
  "accent": "#6e9269",
  "type": "joker",
  "colors": [
   "#6e9269",
   "#1d2d35"
  ]
 },
 "cuckoo_clock": {
  "id": "cuckoo_clock",
  "name": "Cuckoo Clock",
  "desc": "Every seventh actual merge refunds one move, at most twice each gate.",
  "rarity": "Common",
  "cost": 5,
  "art": "cuckoo_clock",
  "accent": "#537d9a",
  "type": "joker",
  "colors": [
   "#537d9a",
   "#fff3d5"
  ]
 },
 "morgue": {
  "id": "morgue",
  "name": "Morgue",
  "desc": "The first sealed Glass tile to shatter each gate transfers its seal to another tile.",
  "rarity": "Uncommon",
  "cost": 7,
  "art": "morgue",
  "accent": "#6c6d8a",
  "type": "joker",
  "colors": [
   "#6c6d8a",
   "#fff3d5"
  ]
 },
 "spare_parts": {
  "id": "spare_parts",
  "name": "Spare Parts",
  "desc": "Using a Rune has a 20% chance to retain it. Its effect still applies.",
  "rarity": "Uncommon",
  "cost": 7,
  "art": "spare_parts",
  "accent": "#af8050",
  "type": "joker",
  "colors": [
   "#af8050",
   "#1d2d35"
  ]
 },
 "body_double": {
  "id": "body_double",
  "name": "Body Double",
  "desc": "The first targeted Spell each gate also affects another tile of the same starting value, when possible.",
  "rarity": "Uncommon",
  "cost": 7,
  "art": "body_double",
  "accent": "#6b6d9a",
  "type": "joker",
  "colors": [
   "#6b6d9a",
   "#fff3d5"
  ]
 },
 "recycling_bin": {
  "id": "recycling_bin",
  "name": "Recycling Bin",
  "desc": "The first relic sale each gate creates a random Rune if your pocket has space.",
  "rarity": "Uncommon",
  "cost": 7,
  "art": "recycling_bin",
  "accent": "#549783",
  "type": "joker",
  "colors": [
   "#549783",
   "#1d2d35"
  ]
 },
 "pandora": {
  "id": "pandora",
  "name": "Pandora's Box",
  "desc": "The first Standard mixed pack each floor grants one additional random reward after your last choice. Needs room.",
  "rarity": "Uncommon",
  "cost": 7,
  "art": "pandora",
  "accent": "#87659b",
  "type": "joker",
  "colors": [
   "#87659b",
   "#fff3d5"
  ]
 },
 "red_thread": {
  "id": "red_thread",
  "name": "Red Thread",
  "desc": "The first sealed-tile merge each gate guarantees a seal on the next natural spawn.",
  "rarity": "Uncommon",
  "cost": 7,
  "art": "red_thread",
  "accent": "#b35665",
  "type": "joker",
  "colors": [
   "#b35665",
   "#fff3d5"
  ]
 },
 "double_exposure": {
  "id": "double_exposure",
  "name": "Double Exposure",
  "desc": "The first natural spawn each gate with at least two enhancements creates a plain half-value copy in an empty cell.",
  "rarity": "Uncommon",
  "cost": 7,
  "art": "double_exposure",
  "accent": "#638ea3",
  "type": "joker",
  "colors": [
   "#638ea3",
   "#1d2d35"
  ]
 },
 "clone_vat": {
  "id": "clone_vat",
  "name": "Clone Vat",
  "desc": "The first merge into 1,024 or higher each gate creates a plain copy in an empty cell.",
  "rarity": "Rare",
  "cost": 10,
  "art": "clone_vat",
  "accent": "#6b9b9a",
  "type": "joker",
  "colors": [
   "#6b9b9a",
   "#1d2d35"
  ]
 },
 "guillotine": {
  "id": "guillotine",
  "name": "Guillotine",
  "desc": "After a Guardian victory, you may sacrifice your highest tile to grow this multiplier by x1.8. Starts at x1.",
  "rarity": "Rare",
  "cost": 10,
  "art": "guillotine",
  "accent": "#a25a57",
  "type": "joker",
  "colors": [
   "#a25a57",
   "#fff3d5"
  ]
 },
 "loan_shark": {
  "id": "loan_shark",
  "name": "Loan Shark",
  "desc": "Borrow up to $50 once each floor in the Workshop. Repay 150% by the Guardian, or lose 1 Life.",
  "rarity": "Rare",
  "cost": 10,
  "art": "loan_shark",
  "accent": "#6c8196",
  "type": "joker",
  "colors": [
   "#6c8196",
   "#fff3d5"
  ]
 },
 "stowaway": {
  "id": "stowaway",
  "name": "The Stowaway",
  "desc": "Choose an unpurchased shop offer to carry through rerolls and into the next shop. One stored offer at a time.",
  "rarity": "Rare",
  "cost": 10,
  "art": "stowaway",
  "accent": "#987449",
  "type": "joker",
  "colors": [
   "#987449",
   "#fff3d5"
  ]
 },
 "chain_reaction": {
  "id": "chain_reaction",
  "name": "Chain Reaction",
  "desc": "Each Glass shatter raises an adjacent tile one tier, at most three times per gate. It does not score.",
  "rarity": "Rare",
  "cost": 10,
  "art": "chain_reaction",
  "accent": "#9c694c",
  "type": "joker",
  "colors": [
   "#9c694c",
   "#fff3d5"
  ]
 },
 "ghostwriter": {
  "id": "ghostwriter",
  "name": "Ghostwriter",
  "desc": "When you sell another scoring relic, permanently multiply this relic by its current multiplier. Starts at x1.",
  "rarity": "Rare",
  "cost": 10,
  "art": "ghostwriter",
  "accent": "#777caa",
  "type": "joker",
  "colors": [
   "#777caa",
   "#fff3d5"
  ]
 },
 "risky_investment": {
  "id": "risky_investment",
  "name": "Risky Investment",
  "desc": "Before a Guardian, invest up to half your balance in the Workshop. A clear returns triple; a failure loses it.",
  "rarity": "Rare",
  "cost": 10,
  "art": "risky_investment",
  "accent": "#52856e",
  "type": "joker",
  "colors": [
   "#52856e",
   "#fff3d5"
  ]
 },
 "chrysalis": {
  "id": "chrysalis",
  "name": "Chrysalis",
  "desc": "Mark a plain tile in the Workshop. After that tile participates in three merges, it gains Gold, Glass, Steel, and a seal.",
  "rarity": "Rare",
  "cost": 10,
  "art": "chrysalis",
  "accent": "#789252",
  "type": "joker",
  "colors": [
   "#789252",
   "#1d2d35"
  ]
 },
 "conductor": {
  "id": "conductor",
  "name": "The Conductor",
  "desc": "Copies the scoring ability immediately to its right. Growth and money payouts are not copied.",
  "rarity": "Legendary",
  "cost": 20,
  "art": "conductor",
  "accent": "#b1914f",
  "type": "joker",
  "colors": [
   "#b1914f",
   "#1d2d35"
  ]
 },
 "perpetuum": {
  "id": "perpetuum",
  "name": "Perpetuum",
  "desc": "Leaving a shop creates a phantom copy of the last Spell or Rune used. No pocket slot; expires after the next gate.",
  "rarity": "Legendary",
  "cost": 20,
  "art": "perpetuum",
  "accent": "#597d9f",
  "type": "joker",
  "colors": [
   "#597d9f",
   "#fff3d5"
  ]
 },
 "devourer": {
  "id": "devourer",
  "name": "Devourer",
  "desc": "After a Guardian victory, sacrifice another scoring relic to inherit its ability. Holds up to two inherited abilities.",
  "rarity": "Legendary",
  "cost": 20,
  "art": "devourer",
  "accent": "#91667f",
  "type": "joker",
  "colors": [
   "#91667f",
   "#fff3d5"
  ]
 },
 "crown_echoes": {
  "id": "crown_echoes",
  "name": "Crown of Echoes",
  "desc": "After each Guardian victory, permanently Echo one relic. Its scoring resolves twice; growth and payouts occur once.",
  "rarity": "Legendary",
  "cost": 20,
  "art": "crown_echoes",
  "accent": "#a28849",
  "type": "joker",
  "colors": [
   "#a28849",
   "#1d2d35"
  ]
 },
 "paradox": {
  "id": "paradox",
  "name": "Paradox",
  "desc": "Once per gate, rewind the previous valid swipe, including score, moves, money, and relic state. The next spawn is rerolled.",
  "rarity": "Legendary",
  "cost": 20,
  "art": "paradox",
  "accent": "#685b9e",
  "type": "joker",
  "colors": [
   "#685b9e",
   "#fff3d5"
  ]
 },
 "mobius": {
  "id": "mobius",
  "name": "Mobius Engine",
  "desc": "On the first scoring swipe each gate, the relic chain also resolves right-to-left. The reverse pass copies only scoring abilities.",
  "rarity": "Legendary",
  "cost": 20,
  "art": "mobius",
  "accent": "#538f96",
  "type": "joker",
  "colors": [
   "#538f96",
   "#1d2d35"
  ]
 }
}
const UPGRADES = {
 "storefront1": {
  "id": "storefront1",
  "name": "Storefront I",
  "desc": "Add one extra relic offer to every shop. Browse it with the offer-page button.",
  "art": "storefront1",
  "rarity": "Upgrade",
  "cost": 7,
  "accent": "#b78a50",
  "type": "voucher"
 },
 "storefront2": {
  "id": "storefront2",
  "name": "Storefront II",
  "desc": "Lock one offer through rerolls. Requires Storefront I.",
  "art": "storefront2",
  "rarity": "Upgrade",
  "cost": 11,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "storefront1"
 },
 "storefront3": {
  "id": "storefront3",
  "name": "Storefront III",
  "desc": "Choose each floor upgrade from two candidates. Only one can be redeemed. Requires Storefront II.",
  "art": "storefront3",
  "rarity": "Upgrade",
  "cost": 16,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "storefront2"
 },
 "shatterproof1": {
  "id": "shatterproof1",
  "name": "Shatterproof I",
  "desc": "Prevent the first Glass shatter each gate.",
  "art": "shatterproof1",
  "rarity": "Upgrade",
  "cost": 7,
  "accent": "#b78a50",
  "type": "voucher"
 },
 "shatterproof2": {
  "id": "shatterproof2",
  "name": "Shatterproof II",
  "desc": "Prevent the first two Glass shatters each gate. Requires Shatterproof I.",
  "art": "shatterproof2",
  "rarity": "Upgrade",
  "cost": 11,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "shatterproof1"
 },
 "shatterproof3": {
  "id": "shatterproof3",
  "name": "Shatterproof III",
  "desc": "Prevented Glass also becomes Gold, up to twice each gate. Requires Shatterproof II.",
  "art": "shatterproof3",
  "rarity": "Upgrade",
  "cost": 16,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "shatterproof2"
 },
 "satchel1": {
  "id": "satchel1",
  "name": "Satchel I",
  "desc": "Permanently gain two pocket slots.",
  "art": "satchel1",
  "rarity": "Upgrade",
  "cost": 7,
  "accent": "#b78a50",
  "type": "voucher"
 },
 "satchel2": {
  "id": "satchel2",
  "name": "Satchel II",
  "desc": "Unlock a two-slot reserve in the Workshop. Stored cards can be retrieved when you have room. Requires Satchel I.",
  "art": "satchel2",
  "rarity": "Upgrade",
  "cost": 11,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "satchel1"
 },
 "satchel3": {
  "id": "satchel3",
  "name": "Satchel III",
  "desc": "Every third Guardian victory, duplicate one owned consumable in the Workshop. Needs room. Requires Satchel II.",
  "art": "satchel3",
  "rarity": "Upgrade",
  "cost": 16,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "satchel2"
 },
 "scrapyard1": {
  "id": "scrapyard1",
  "name": "Scrapyard I",
  "desc": "Consumable sales pay an additional $2.",
  "art": "scrapyard1",
  "rarity": "Upgrade",
  "cost": 7,
  "accent": "#b78a50",
  "type": "voucher"
 },
 "scrapyard2": {
  "id": "scrapyard2",
  "name": "Scrapyard II",
  "desc": "Relic resale values increase by 50%, rounded up. Requires Scrapyard I.",
  "art": "scrapyard2",
  "rarity": "Upgrade",
  "cost": 11,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "scrapyard1"
 },
 "scrapyard3": {
  "id": "scrapyard3",
  "name": "Scrapyard III",
  "desc": "The first relic sold each shop creates a Common or Uncommon replacement offer. Requires Scrapyard II.",
  "art": "scrapyard3",
  "rarity": "Upgrade",
  "cost": 16,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "scrapyard2"
 },
 "wagers1": {
  "id": "wagers1",
  "name": "Wagers I",
  "desc": "Before a gate, wager up to $10 in the Workshop. Clear without losing Life to receive double your stake.",
  "art": "wagers1",
  "rarity": "Upgrade",
  "cost": 7,
  "accent": "#b78a50",
  "type": "voucher"
 },
 "wagers2": {
  "id": "wagers2",
  "name": "Wagers II",
  "desc": "Raise the wager limit to $30. Requires Wagers I.",
  "art": "wagers2",
  "rarity": "Upgrade",
  "cost": 11,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "wagers1"
 },
 "wagers3": {
  "id": "wagers3",
  "name": "Wagers III",
  "desc": "Winning Guardian wagers return triple the stake. Other wins still return double. Requires Wagers II.",
  "art": "wagers3",
  "rarity": "Upgrade",
  "cost": 16,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "wagers2"
 },
 "fusion1": {
  "id": "fusion1",
  "name": "Fusion Lab I",
  "desc": "Combine two owned Spells into one random Spell in the Workshop.",
  "art": "fusion1",
  "rarity": "Upgrade",
  "cost": 7,
  "accent": "#b78a50",
  "type": "voucher"
 },
 "fusion2": {
  "id": "fusion2",
  "name": "Fusion Lab II",
  "desc": "Combine two Runes into one Rune of your choice. Requires Fusion Lab I.",
  "art": "fusion2",
  "rarity": "Upgrade",
  "cost": 11,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "fusion1"
 },
 "fusion3": {
  "id": "fusion3",
  "name": "Fusion Lab III",
  "desc": "Sacrifice two Runes to create one chosen Rune that applies twice. Requires Fusion Lab II.",
  "art": "fusion3",
  "rarity": "Upgrade",
  "cost": 16,
  "accent": "#b78a50",
  "type": "voucher",
  "req": "fusion2"
 }
}
const FRACTURES = {
 "liberation": {
  "id": "liberation",
  "name": "Liberation",
  "desc": "Make a selected relic Unbound: it no longer uses a relic slot. Permanently lose 2 starting moves each gate.",
  "art": "liberation",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "relic",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "overexposure": {
  "id": "overexposure",
  "name": "Overexposure",
  "desc": "Make a selected relic Oversaturated, doubling all its printed numerical benefits. Permanently lose 1 maximum Life. Cannot reduce maximum Life below 1.",
  "art": "overexposure",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "relic",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "erosion": {
  "id": "erosion",
  "name": "Erosion",
  "desc": "Destroy one random relic and permanently gain one relic slot.",
  "art": "erosion",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "none",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "rebirth": {
  "id": "rebirth",
  "name": "Rebirth",
  "desc": "Destroy one selected relic and receive one random relic of the same rarity.",
  "art": "rebirth",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "relic",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "schism": {
  "id": "schism",
  "name": "Schism",
  "desc": "Duplicate a selected relic, then destroy two other random relics. Requires at least three relics.",
  "art": "schism",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "relic",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "transmutation": {
  "id": "transmutation",
  "name": "Transmutation",
  "desc": "Randomly redistribute the Unbound and Oversaturated editions among your relics. Cursed and Echoed states stay attached.",
  "art": "transmutation",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "none",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "genesis": {
  "id": "genesis",
  "name": "Genesis",
  "desc": "Duplicate a selected tile, then destroy two other random tiles. Requires at least three tiles and an empty cell.",
  "art": "genesis",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "tile",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "collapse": {
  "id": "collapse",
  "name": "Singularity Collapse",
  "desc": "Keep your three highest tiles and seal them. Destroy all other tiles.",
  "art": "collapse",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "none",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "transference": {
  "id": "transference",
  "name": "Transference",
  "desc": "Move all enhancements and seals on the board onto one selected tile. Values are unchanged.",
  "art": "transference",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "tile",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "pandemonium": {
  "id": "pandemonium",
  "name": "Pandemonium",
  "desc": "Shuffle the board and give every tile one random enhancement. Lose 1 Life. Cannot be used at 1 Life.",
  "art": "pandemonium",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "none",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "monoculture": {
  "id": "monoculture",
  "name": "Monoculture",
  "desc": "Convert every tile to your smallest tile value. Each converted tile gains Glass and a seal.",
  "art": "monoculture",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "none",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "liquidation": {
  "id": "liquidation",
  "name": "Liquidation",
  "desc": "Destroy four random tiles and receive $25. Requires at least four tiles.",
  "art": "liquidation",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "none",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "overdraft": {
  "id": "overdraft",
  "name": "Overdraft",
  "desc": "Permanently gain two relic slots. Lose all money and receive no interest for the next three cleared gates.",
  "art": "overdraft",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "none",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "asceticism": {
  "id": "asceticism",
  "name": "Asceticism",
  "desc": "Upgrade all five Rune tracks once. Destroy every enhanced or sealed tile currently on your board.",
  "art": "asceticism",
  "rarity": "Fracture",
  "cost": 8,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "none",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 },
 "sovereign": {
  "id": "sovereign",
  "name": "The Sovereign",
  "desc": "Create one random Legendary relic. No downside. A 3% chance whenever a Fracture card is generated. Needs a relic slot.",
  "art": "sovereign",
  "rarity": "Fracture",
  "cost": 20,
  "accent": "#8b658e",
  "type": "fracture",
  "target": "none",
  "colors": [
   "#72527f",
   "#fff3d5"
  ]
 }
}
const BOARDS = [
 {
  "id": "glasshouse",
  "name": "Glasshouse",
  "color": "#80b7b4",
  "art": "board_glasshouse",
  "headline": "A fragile engine",
  "desc": "Half of natural spawns are Glass. Start with Glass tiles.",
  "downside": "2 Life. Glass has a 50% shatter chance.",
  "max_hp": 2,
  "start_fx": {
   "glass": true
  },
  "glass_chance": 0.5,
  "shatter_chance": 0.5
 },
 {
  "id": "treasury",
  "name": "Treasury",
  "color": "#bc964b",
  "art": "board_treasury",
  "headline": "$50 and Deep Pockets",
  "desc": "Start with Deep Pockets and a large balance. Merge, relic, and sale income still work.",
  "downside": "No cash for clearing gates, including interest and efficiency.",
  "start_money": 50,
  "relics": [
   "charity"
  ],
  "no_gate_cash": true
 },
 {
  "id": "eclipse",
  "name": "Eclipse",
  "color": "#63558d",
  "art": "board_eclipse",
  "headline": "Gold gives way to Glass",
  "desc": "Natural spawns alternate all Gold and all Glass each gate, starting Gold.",
  "downside": "Exactly 1 maximum Life.",
  "max_hp": 1,
  "start_fx": {
   "gold": true
  },
  "eclipse": true
 },
 {
  "id": "vortex",
  "name": "Vortex",
  "color": "#5b8c9a",
  "art": "board_vortex",
  "headline": "The board keeps turning",
  "desc": "Every fourth valid swipe rotates the grid clockwise. Rotation does not score.",
  "downside": "",
  "rotate_every": 4
 },
 {
  "id": "hollow",
  "name": "Hollow",
  "color": "#74858c",
  "art": "board_hollow",
  "headline": "Seven empty relic slots",
  "desc": "Start with seven relic slots, $4, and no Carbon Paper.",
  "downside": "20% fewer starting moves every gate.",
  "slots": 2,
  "start_money": 4,
  "no_carbon": true,
  "move_mult": 0.8
 },
 {
  "id": "reactor",
  "name": "Reactor",
  "color": "#af6b4d",
  "art": "board_reactor",
  "headline": "Waste becomes fuel",
  "desc": "Every eighth actual merge doubles your smallest tile without scoring it.",
  "downside": "Start each gate with 3 fewer moves.",
  "moves": -3,
  "reactor": true
 },
 {
  "id": "twinfall",
  "name": "Twinfall",
  "color": "#568c83",
  "art": "board_twinfall",
  "headline": "A second arrival",
  "desc": "Every sixth natural spawn creates an identical copy in an empty cell. Copies do not recursively duplicate.",
  "downside": "",
  "twinfall": true
 },
 {
  "id": "nomad",
  "name": "Nomad",
  "color": "#a27f55",
  "art": "board_nomad",
  "headline": "Choose a travelling companion",
  "desc": "Choose a starting relic from three. At each new floor you may exchange one relic for another of the same rarity.",
  "downside": "",
  "nomad": true
 },
 {
  "id": "labyrinth",
  "name": "Labyrinth",
  "color": "#6c7c68",
  "art": "board_labyrinth",
  "headline": "One moving obstacle",
  "desc": "One cell is blocked. Tiles slide in separate segments around it. The obstacle moves to an empty cell each gate.",
  "downside": "",
  "labyrinth": true
 },
 {
  "id": "rich_get_richer",
  "name": "Rich Get Richer",
  "color": "#a6874d",
  "art": "board_rich_get_richer",
  "headline": "Oversaturated Compound Growth",
  "desc": "Start with Oversaturated Compound Growth at x2. It grows by x2.5 on every cleared gate.",
  "downside": "Shop prices +65%. Gate targets +20%.",
  "relics": [
   "compound"
  ],
  "oversaturated_start": true,
  "markup": 1.65,
  "target_mult": 1.2
 }
]
const PACKS = {
 "standard": {
  "name": "Standard",
  "desc": "Relics, Spells, and Runes.",
  "color": "#75608f"
 },
 "reliquary": {
  "name": "Reliquary",
  "desc": "Relics only.",
  "color": "#aa8247"
 },
 "grimoire": {
  "name": "Grimoire",
  "desc": "Spells only.",
  "color": "#a2576e"
 },
 "sigil": {
  "name": "Sigil",
  "desc": "Runes only.",
  "color": "#527c9d"
 },
 "fracture": {
  "name": "Fracture",
  "desc": "Powerful transformations with explicit costs.",
  "color": "#7b4e83"
 }
}

extends RefCounted

# Content snapshot from the final pre-Fracture HTML game.
const BASE_RELICS = {
 "carbon": {
  "id": "carbon",
  "name": "Carbon Paper",
  "desc": "Add +8 points at this position in the Relic chain.",
  "art": "carbon",
  "rarity": "Common",
  "cost": 4,
  "accent": "#486b67",
  "type": "joker"
 },
 "corner": {
  "id": "corner",
  "name": "Cornerstone",
  "desc": "Merges that finish in a corner score ×2.",
  "art": "corner",
  "rarity": "Common",
  "cost": 5,
  "accent": "#8a6545",
  "type": "joker"
 },
 "echo": {
  "id": "echo",
  "name": "Echo Chamber",
  "desc": "Double points built so far and scoring triggers. Repeats activate Relics to the right.",
  "art": "echo",
  "rarity": "Uncommon",
  "cost": 7,
  "accent": "#526e91",
  "type": "joker"
 },
 "business": {
  "id": "business",
  "name": "Small Business",
  "desc": "Merging 2s or 4s pays $1. A payout happens once per actual merge.",
  "art": "coins",
  "rarity": "Common",
  "cost": 5,
  "accent": "#96752e",
  "type": "joker"
 },
 "resonance": {
  "id": "resonance",
  "name": "Resonance",
  "desc": "Each trigger reaching here gains a growing ×1.12 bonus. Repeats to the left build it faster. Resets each swipe.",
  "art": "fork",
  "rarity": "Uncommon",
  "cost": 7,
  "accent": "#ad4739",
  "type": "joker"
 },
 "domino": {
  "id": "domino",
  "name": "Domino Theory",
  "desc": "Each earlier merge doubles the final merge’s points so far and trigger count. Repeats activate Relics to the right.",
  "art": "domino",
  "rarity": "Uncommon",
  "cost": 7,
  "accent": "#3f6c76",
  "type": "joker"
 },
 "feedback": {
  "id": "feedback",
  "name": "Feedback Loop",
  "desc": "Every fifth trigger reaching here adds a copy of points so far. Extra triggers also count. Put repeat Relics to the left.",
  "art": "feedback",
  "rarity": "Rare",
  "cost": 10,
  "accent": "#96505b",
  "type": "joker"
 },
 "monolith": {
  "id": "monolith",
  "name": "Monolith",
  "desc": "When a merge matches or exceeds your previous highest tile, this Relic permanently gains ×1.15.",
  "art": "monolith",
  "rarity": "Rare",
  "cost": 9,
  "accent": "#57586b",
  "type": "joker"
 },
 "battery": {
  "id": "battery",
  "name": "Dry Cell",
  "desc": "A swipe with no merges stores +12 points. Add the stored bonus here to every merge next scoring swipe.",
  "art": "battery",
  "rarity": "Common",
  "cost": 5,
  "accent": "#a1722f",
  "type": "joker"
 },
 "steelworks": {
  "id": "steelworks",
  "name": "Steelworks",
  "desc": "Multiply points so far by ×1.2 for each Steel tile on the board. Stacks with Steel’s base ×1.25.",
  "art": "anvil",
  "rarity": "Uncommon",
  "cost": 7,
  "accent": "#5a6e67",
  "type": "joker"
 },
 "charity": {
  "id": "charity",
  "name": "Deep Pockets",
  "desc": "Score multiplier increases by +1 for every $10 you hold. No cap.",
  "art": "purse",
  "rarity": "Uncommon",
  "cost": 7,
  "accent": "#8f743b",
  "type": "joker"
 },
 "mirror": {
  "id": "mirror",
  "name": "Looking Glass",
  "desc": "Triple the first merge’s points so far and trigger count. Repeats activate Relics to the right.",
  "art": "mirror",
  "rarity": "Uncommon",
  "cost": 7,
  "accent": "#7c6a91",
  "type": "joker"
 },
 "redline": {
  "id": "redline",
  "name": "Last Resort",
  "desc": "All merges score ×3 with 5 or fewer moves remaining.",
  "art": "match",
  "rarity": "Common",
  "cost": 5,
  "accent": "#b24b3b",
  "type": "joker"
 },
 "odd": {
  "id": "odd",
  "name": "Odd Company",
  "desc": "Merges into 2, 8, 32, 128… score ×2. That is every odd power of two.",
  "art": "stair",
  "rarity": "Common",
  "cost": 4,
  "accent": "#557b58",
  "type": "joker"
 },
 "alchemy": {
  "id": "alchemy",
  "name": "Alchemist",
  "desc": "Every naturally spawned tile has a 25% chance to double before entering the queue.",
  "art": "flask",
  "rarity": "Uncommon",
  "cost": 6,
  "accent": "#4b807b",
  "type": "joker"
 },
 "compound": {
  "id": "compound",
  "name": "Compound Growth",
  "desc": "Starts at ×1. Each gate you clear permanently multiplies this Relic by ×1.25.",
  "art": "plant",
  "rarity": "Rare",
  "cost": 9,
  "accent": "#5e7e48",
  "type": "joker"
 },
 "horizon": {
  "id": "horizon",
  "name": "Low Ground",
  "desc": "Merges that finish on the bottom row score ×2.",
  "art": "horizon",
  "rarity": "Common",
  "cost": 5,
  "accent": "#a26543",
  "type": "joker"
 },
 "magnet": {
  "id": "magnet",
  "name": "Three’s Company",
  "desc": "Swipes with at least three separate merges score ×3.",
  "art": "magnet",
  "rarity": "Uncommon",
  "cost": 6,
  "accent": "#9b4642",
  "type": "joker"
 },
 "greed": {
  "id": "greed",
  "name": "Midas Touch",
  "desc": "Gold merge payouts increase from $2 to $4. This is paid once per actual merge.",
  "art": "hand",
  "rarity": "Uncommon",
  "cost": 7,
  "accent": "#a1802c",
  "type": "joker"
 },
 "avalanche": {
  "id": "avalanche",
  "name": "Avalanche",
  "desc": "The second merge scores ×2, the third ×4, and the fourth ×8 in each swipe.",
  "art": "mountain",
  "rarity": "Rare",
  "cost": 9,
  "accent": "#4f7489",
  "type": "joker"
 },
 "ascension": {
  "id": "ascension",
  "name": "Ascension",
  "desc": "Merges into 1,024 or higher triple points so far and trigger count. Repeats activate Relics to the right.",
  "art": "wings",
  "rarity": "Rare",
  "cost": 10,
  "accent": "#9f7541",
  "type": "joker"
 },
 "coupon": {
  "id": "coupon",
  "name": "Loose Change",
  "desc": "The first shop reroll at each gate is free.",
  "art": "ticket",
  "rarity": "Common",
  "cost": 4,
  "accent": "#6c7b48",
  "type": "joker"
 },
 "apprentice": {
  "id": "apprentice",
  "name": "Runekeeper",
  "desc": "Gains +0.25 multiplier for each Rune used this run. Applies to every merge.",
  "art": "telescope",
  "rarity": "Common",
  "cost": 5,
  "accent": "#606b9e",
  "type": "joker"
 },
 "singularity": {
  "id": "singularity",
  "name": "Singularity",
  "desc": "Raise points built so far to the power of 1.2.",
  "art": "orbit",
  "rarity": "Rare",
  "cost": 11,
  "accent": "#884c71",
  "type": "joker"
 }
}
const SPELLS = {
 "seed": {
  "id": "seed",
  "name": "Seed",
  "desc": "Place a 16 in an empty cell. Scales up with your natural spawn tier.",
  "art": "seed",
  "action": "spawn",
  "cost": 3,
  "accent": "#6a7d48",
  "type": "tarot",
  "rarity": "Spell",
  "e": 4
 },
 "star": {
  "id": "star",
  "name": "Conjure",
  "desc": "Place a 32 in an empty cell. Scales up with your natural spawn tier.",
  "art": "star",
  "action": "spawn",
  "cost": 4,
  "accent": "#a17b3b",
  "type": "tarot",
  "rarity": "Spell",
  "e": 5
 },
 "tower": {
  "id": "tower",
  "name": "Summon",
  "desc": "Place a 64 in an empty cell. Scales up with your natural spawn tier.",
  "art": "tower",
  "action": "spawn",
  "cost": 6,
  "accent": "#9b4c3c",
  "type": "tarot",
  "rarity": "Spell",
  "e": 6
 },
 "sun": {
  "id": "sun",
  "name": "Amplify",
  "desc": "Double one selected tile. Keeps its enhancements and seal. Does not score.",
  "art": "sun",
  "action": "double",
  "cost": 5,
  "accent": "#b17a31",
  "type": "tarot",
  "rarity": "Spell"
 },
 "twins": {
  "id": "twins",
  "name": "Duplicate",
  "desc": "Copy one tile, including its enhancements, into an empty cell.",
  "art": "twins",
  "action": "copy",
  "cost": 5,
  "accent": "#477570",
  "type": "tarot",
  "rarity": "Spell"
 },
 "void": {
  "id": "void",
  "name": "Shatter",
  "desc": "Destroy one selected tile and make a little room.",
  "art": "void",
  "action": "erase",
  "cost": 3,
  "accent": "#625b70",
  "type": "tarot",
  "rarity": "Spell"
 },
 "emperor": {
  "id": "emperor",
  "name": "Gild",
  "desc": "Make a tile Gold: merging it earns $2. Gold is inherited by the resulting tile.",
  "art": "crown",
  "action": "gold",
  "cost": 4,
  "accent": "#a07e30",
  "type": "tarot",
  "rarity": "Spell"
 },
 "prism": {
  "id": "prism",
  "name": "Crystallize",
  "desc": "Make a tile Glass: ×2 merge score, with a 1 in 4 chance to shatter after merging.",
  "art": "prism",
  "action": "glass",
  "cost": 4,
  "accent": "#4f8490",
  "type": "tarot",
  "rarity": "Spell"
 },
 "anvil": {
  "id": "anvil",
  "name": "Temper",
  "desc": "Make a tile Steel: while on the board, it gives ×1.25 to every merge.",
  "art": "anvil",
  "action": "steel",
  "cost": 4,
  "accent": "#5d7770",
  "type": "tarot",
  "rarity": "Spell"
 },
 "seal": {
  "id": "seal",
  "name": "Echo Mark",
  "desc": "Give a tile a red seal: its merges score twice. The seal is inherited.",
  "art": "seal",
  "action": "seal",
  "cost": 5,
  "accent": "#a94c3c",
  "type": "tarot",
  "rarity": "Spell"
 },
 "mercy": {
  "id": "mercy",
  "name": "Mend",
  "desc": "Restore 1 Life, up to your maximum. Can be used at the shop.",
  "art": "heart",
  "action": "heal",
  "cost": 5,
  "accent": "#a85a50",
  "type": "tarot",
  "rarity": "Spell"
 },
 "hourglass": {
  "id": "hourglass",
  "name": "Extra Time",
  "desc": "Add 4 moves to the current gate. Use before your final move.",
  "art": "hourglass",
  "action": "time",
  "cost": 4,
  "accent": "#9c7b43",
  "type": "tarot",
  "rarity": "Spell"
 }
}
const RUNES = {
 "mercury": {
  "id": "mercury",
  "name": "Growth Rune",
  "desc": "Improve natural spawns by one tier: 2/4 → more 4s → 4/8 → more 8s… Tiles below the new minimum rise to match.",
  "art": "mercury",
  "stat": "spawn",
  "cost": 5,
  "accent": "#587895",
  "type": "planet",
  "rarity": "Rune"
 },
 "venus": {
  "id": "venus",
  "name": "Gold Rune",
  "desc": "Permanently give natural spawns an 8% chance to be Gold. Repeated upgrades compound the chance.",
  "art": "venus",
  "stat": "gold",
  "cost": 5,
  "accent": "#9f7a38",
  "type": "planet",
  "rarity": "Rune"
 },
 "mars": {
  "id": "mars",
  "name": "Glass Rune",
  "desc": "Permanently give natural spawns an 8% chance to be Glass. Repeated upgrades compound the chance.",
  "art": "mars",
  "stat": "glass",
  "cost": 5,
  "accent": "#a25440",
  "type": "planet",
  "rarity": "Rune"
 },
 "saturn": {
  "id": "saturn",
  "name": "Steel Rune",
  "desc": "Permanently give natural spawns an 8% chance to be Steel. Repeated upgrades compound the chance.",
  "art": "saturn",
  "stat": "steel",
  "cost": 5,
  "accent": "#587868",
  "type": "planet",
  "rarity": "Rune"
 },
 "neptune": {
  "id": "neptune",
  "name": "Echo Rune",
  "desc": "Permanently give natural spawns a 6% chance to carry a red seal. Repeated upgrades compound the chance.",
  "art": "neptune",
  "stat": "seal",
  "cost": 6,
  "accent": "#696797",
  "type": "planet",
  "rarity": "Rune"
 }
}
const BASE_UPGRADES = {
 "auto1": {
  "id": "auto1",
  "name": "Auto-player I",
  "desc": "Plans two swipes ahead using your actual Relic scoring, board space, and visible next tile. Appears from floor 3; Robot starts with it.",
  "art": "auto",
  "cost": 12,
  "req": null,
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 },
 "auto2": {
  "id": "auto2",
  "name": "Auto-player II",
  "desc": "Tests sequences up to six swipes ahead across possible tile spawns. Uses actual Relic scoring, enhancements, and guardian rules.",
  "art": "auto",
  "cost": 12,
  "req": "auto1",
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 },
 "trade1": {
  "id": "trade1",
  "name": "World Trade Center I",
  "desc": "Raise your interest cap from $5 to $10 per cleared gate. Interest is paid per $5 saved.",
  "art": "trade",
  "cost": 8,
  "req": null,
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 },
 "trade2": {
  "id": "trade2",
  "name": "World Trade Center II",
  "desc": "Earn $2 interest per $5 saved. Raise the interest cap to $20.",
  "art": "trade",
  "cost": 12,
  "req": "trade1",
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 },
 "trade3": {
  "id": "trade3",
  "name": "World Trade Center III",
  "desc": "Every source of money pays ×2 its base value: rewards, interest, sales, Gold, and Relics.",
  "art": "trade",
  "cost": 18,
  "req": "trade2",
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 },
 "slot1": {
  "id": "slot1",
  "name": "Extra Slot I",
  "desc": "Permanently add one Relic slot for this run.",
  "art": "cards",
  "cost": 10,
  "req": null,
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 },
 "slot2": {
  "id": "slot2",
  "name": "Extra Slot II",
  "desc": "Add a second extra Relic slot.",
  "art": "cards",
  "cost": 15,
  "req": "slot1",
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 },
 "pocket1": {
  "id": "pocket1",
  "name": "Spell Pouch",
  "desc": "Add one consumable slot for this run.",
  "art": "purse",
  "cost": 7,
  "req": null,
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 },
 "moves1": {
  "id": "moves1",
  "name": "Long Division I",
  "desc": "Start every future gate with 3 extra moves.",
  "art": "hourglass",
  "cost": 8,
  "req": null,
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 },
 "moves2": {
  "id": "moves2",
  "name": "Long Division II",
  "desc": "Start future gates with 6 extra moves total.",
  "art": "hourglass",
  "cost": 12,
  "req": "moves1",
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 },
 "heart1": {
  "id": "heart1",
  "name": "Second Wind",
  "desc": "Raise maximum Life by 1 and immediately heal 1 Life.",
  "art": "heart",
  "cost": 10,
  "req": null,
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 },
 "sale1": {
  "id": "sale1",
  "name": "Friendly Faces",
  "desc": "All future shop prices are reduced by 25%, rounded up.",
  "art": "ticket",
  "cost": 9,
  "req": null,
  "accent": "#987339",
  "type": "voucher",
  "rarity": "Upgrade"
 }
}
const BASE_BOARDS = [
 {
  "id": "red",
  "name": "Red",
  "color": "#c65b4e",
  "edge": "#ffb29a",
  "ink": "#fff1d5",
  "badge": "+10",
  "headline": "+10 moves every gate",
  "desc": "Ten extra moves at every gate, including retries.",
  "relics": [],
  "upgrades": [],
  "moves": 10,
  "slots": 0,
  "money_gate": 0
 },
 {
  "id": "yellow",
  "name": "Yellow",
  "color": "#dfb34d",
  "edge": "#ffe6a1",
  "ink": "#343929",
  "badge": "+$7",
  "headline": "+$7 after every gate",
  "desc": "Start with Small Business. Gain $7 after each gate.",
  "relics": [
   "business"
  ],
  "upgrades": [],
  "moves": 0,
  "slots": 0,
  "money_gate": 7,
  "markup": 1.25,
  "downside": "All shop prices +25%."
 },
 {
  "id": "blue",
  "name": "Blue",
  "color": "#447fb4",
  "edge": "#a5d8ef",
  "ink": "#fff2d4",
  "badge": "×2",
  "headline": "Echo Chamber + 1 Relic slot",
  "desc": "Start with Echo Chamber and six Relic slots.",
  "relics": [
   "echo"
  ],
  "upgrades": [],
  "moves": 0,
  "slots": 1,
  "money_gate": 0
 },
 {
  "id": "robot",
  "name": "Robot",
  "color": "#778b92",
  "edge": "#d5edf0",
  "ink": "#f8f2d4",
  "badge": "AUTO",
  "headline": "Start with Auto-player I",
  "desc": "Auto-player is available from your first move.",
  "relics": [],
  "upgrades": [
   "auto1"
  ],
  "moves": 0,
  "slots": 0,
  "money_gate": 0,
  "maintenance": 3,
  "downside": "Maintenance per gate: $1 on floor 1, $2 on floor 2, $3 from floor 3. No debt."
 },
 {
  "id": "classic",
  "name": "Classic",
  "color": "#346a64",
  "edge": "#8cbcaf",
  "ink": "#fff1d0",
  "badge": "4×4",
  "headline": "Original rules",
  "desc": "Carbon Paper, 18 opening moves, and no board bonus.",
  "relics": [],
  "upgrades": [],
  "moves": 0,
  "slots": 0,
  "money_gate": 0
 },
 {
  "id": "green",
  "name": "Green",
  "color": "#488c5b",
  "edge": "#b7df93",
  "ink": "#fff1cf",
  "badge": "4/8",
  "headline": "Alchemist + two Growth upgrades",
  "desc": "Natural spawns start at 4/8, with a 25% chance to double.",
  "relics": [
   "alchemy"
  ],
  "upgrades": [],
  "moves": 0,
  "slots": 0,
  "money_gate": 0,
  "runes": {
   "spawn": 2
  }
 },
 {
  "id": "purple",
  "name": "Purple",
  "color": "#8453a3",
  "edge": "#ddb5f0",
  "ink": "#fff1d6",
  "badge": "ECHO",
  "headline": "Resonance + Echo-marked tiles",
  "desc": "Two Echo Rune upgrades. Both opening tiles score twice.",
  "relics": [
   "resonance"
  ],
  "upgrades": [],
  "moves": 0,
  "slots": 0,
  "money_gate": 0,
  "runes": {
   "seal": 2
  },
  "start_seal": true
 },
 {
  "id": "orange",
  "name": "Orange",
  "color": "#d78232",
  "edge": "#ffd094",
  "ink": "#fff2d0",
  "badge": "+48",
  "headline": "+48 stored points · +4 moves",
  "desc": "Start with a charged Dry Cell. Four extra moves every gate.",
  "relics": [
   "battery"
  ],
  "upgrades": [],
  "moves": 4,
  "slots": 0,
  "money_gate": 0,
  "charges": {
   "battery": 48
  }
 },
 {
  "id": "white",
  "name": "White",
  "color": "#e7e5d5",
  "edge": "#fff9e4",
  "ink": "#2d3c40",
  "badge": "5HP",
  "headline": "5 Life · heal 1 each floor",
  "desc": "Begin with five Life. Entering a new floor restores one Life.",
  "relics": [],
  "upgrades": [],
  "moves": -3,
  "slots": 0,
  "money_gate": 0,
  "max_hp": 5,
  "floor_heal": 1,
  "downside": "Start every gate with 3 fewer moves."
 },
 {
  "id": "black",
  "name": "Black",
  "color": "#302c49",
  "edge": "#b8accf",
  "ink": "#fff1cf",
  "badge": "^1.2",
  "headline": "Monolith + Singularity",
  "desc": "Start with both Rare Relics.",
  "relics": [
   "monolith",
   "singularity"
  ],
  "upgrades": [],
  "moves": 0,
  "slots": -1,
  "money_gate": 0,
  "target_mult": 1.25,
  "downside": "Four Relic slots. All gate targets +25%."
 },
 {
  "id": "foundry",
  "name": "Foundry",
  "color": "#3d8792",
  "edge": "#a2d9dc",
  "ink": "#fff0ce",
  "badge": "Fe",
  "headline": "Forge a Steel engine",
  "desc": "Steelworks, two Steel Rune upgrades, and Steel opening tiles.",
  "relics": [
   "steelworks"
  ],
  "upgrades": [],
  "moves": -2,
  "slots": 0,
  "money_gate": 0,
  "runes": {
   "steel": 2
  },
  "start_fx": {
   "steel": true
  },
  "downside": "Start every gate with 2 fewer moves."
 },
 {
  "id": "bazaar",
  "name": "Bazaar",
  "color": "#b9854a",
  "edge": "#f1d09a",
  "ink": "#fff2d4",
  "badge": "-25%",
  "headline": "Discounts + free first rerolls",
  "desc": "Start with Friendly Faces and Loose Change.",
  "relics": [
   "coupon"
  ],
  "upgrades": [
   "sale1"
  ],
  "moves": 0,
  "slots": 0,
  "money_gate": 0,
  "start_money": 8,
  "downside": "Start with $8 instead of $12."
 },
 {
  "id": "chronicle",
  "name": "Chronicle",
  "color": "#37698d",
  "edge": "#a8cee9",
  "ink": "#fff0d5",
  "badge": "+10",
  "headline": "Bank your unused moves",
  "desc": "Start with Long Division I. Carry up to 10 unused moves into the next gate.",
  "relics": [],
  "upgrades": [
   "moves1"
  ],
  "moves": 0,
  "slots": 0,
  "money_gate": 0,
  "bank_limit": 10,
  "no_efficiency": true,
  "downside": "Saved moves give no cash reward."
 },
 {
  "id": "archivist",
  "name": "Archivist",
  "color": "#7f658f",
  "edge": "#dfc6e9",
  "ink": "#fff3d4",
  "badge": "RUNES",
  "headline": "Build your Rune engine",
  "desc": "Runekeeper, Spell Pouch, and Growth, Glass, and Echo Runes in your pocket.",
  "relics": [
   "apprentice"
  ],
  "upgrades": [
   "pocket1"
  ],
  "moves": 0,
  "slots": 0,
  "money_gate": 0,
  "items": [
   "mercury",
   "mars",
   "neptune"
  ],
  "max_hp": 2,
  "downside": "Start with 2 Life."
 },
 {
  "id": "curio",
  "name": "Curio",
  "color": "#a85e74",
  "edge": "#f2c0ce",
  "ink": "#fff2d3",
  "badge": "FREE",
  "headline": "Free Supply Pack every shop",
  "desc": "Start with Spell Pouch. Each shop’s Supply Pack costs $0.",
  "relics": [],
  "upgrades": [
   "pocket1"
  ],
  "moves": 0,
  "slots": -1,
  "money_gate": 0,
  "free_packs": true,
  "downside": "Four Relic slots."
 }
]
const GUARDIANS = [
 {
  "name": "The Tollkeeper",
  "short": "Every fourth valid swipe costs an extra move.",
  "art": "coins",
  "id": "toll",
  "desc": "Every fourth valid swipe costs an extra move."
 },
 {
  "name": "The Echo",
  "short": "Repeating your last direction costs an extra move.",
  "art": "echo",
  "id": "repeat",
  "desc": "Repeating your last direction costs an extra move."
 },
 {
  "name": "The Balance",
  "short": "Only the largest merge in each swipe scores. Ties all score.",
  "art": "scales",
  "id": "largest",
  "desc": "Only the largest merge in each swipe scores. Ties all score."
 },
 {
  "name": "The Silence",
  "short": "All merges score ×0.75. Repeats still work.",
  "art": "seal",
  "id": "quiet",
  "desc": "All merges score ×0.75. Repeats still work."
 },
 {
  "name": "The Sundial",
  "short": "Begin this guardian gate with 3 fewer moves.",
  "art": "sun",
  "id": "short",
  "desc": "Begin this guardian gate with 3 fewer moves."
 }
]

const Fracture = preload("res://scripts/fracture_catalog.gd")
static var RELICS: Dictionary = {}
static var UPGRADES: Dictionary = {}
static var BOARDS: Array = []
static var FRACTURES: Dictionary = Fracture.FRACTURES
static var PACKS: Dictionary = Fracture.PACKS
static func _static_init() -> void:
 RELICS=BASE_RELICS.duplicate(true)
 RELICS.merge(Fracture.RELICS)
 RELICS["compound"]["rarity"]="Legendary"
 UPGRADES=BASE_UPGRADES.duplicate(true)
 UPGRADES.merge(Fracture.UPGRADES)
 BOARDS=BASE_BOARDS.duplicate(true)
 BOARDS.append_array(Fracture.BOARDS)

static func board_page(id: String) -> int:
 var index: int = BOARDS.find(board(id))
 return 0 if index<10 else 1 if index<15 else 2

static func boards_on_page(page: int) -> Array:
 return BOARDS.slice(0,10) if page==0 else BOARDS.slice(10,15) if page==1 else BOARDS.slice(15)

static func board(id: String) -> Dictionary:
 for b in BOARDS:
  if b.id == id: return b
 return BOARDS[4]

static func data_for(id: String) -> Dictionary:
 for pool in [RELICS,SPELLS,RUNES,UPGRADES,FRACTURES]:
  if pool.has(id): return pool[id]
 return {}

static func name_for(id: String) -> String:
 return str(data_for(id).get("name",id))

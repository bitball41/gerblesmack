extends RefCounted
const CARDS = {
 "carbon": {
  "id": "carbon",
  "art": "carbon",
  "colors": [
   "#2977ae",
   "#fff4d9"
  ],
  "short": "+8 per merge"
 },
 "corner": {
  "id": "corner",
  "art": "corner",
  "colors": [
   "#ce7638",
   "#fff2cc"
  ],
  "short": "Corners ×2"
 },
 "echo": {
  "id": "echo",
  "art": "echo",
  "colors": [
   "#7758a9",
   "#fff2df"
  ],
  "short": "Points & triggers ×2"
 },
 "business": {
  "id": "business",
  "art": "coins",
  "colors": [
   "#398461",
   "#f5f0c9"
  ],
  "short": "Small merges +$1"
 },
 "resonance": {
  "id": "resonance",
  "art": "fork",
  "colors": [
   "#b84562",
   "#fff1db"
  ],
  "short": "×1.12 per trigger"
 },
 "domino": {
  "id": "domino",
  "art": "domino",
  "colors": [
   "#e0d7b9",
   "#273948"
  ],
  "short": "More merges → repeats"
 },
 "feedback": {
  "id": "feedback",
  "art": "feedback",
  "colors": [
   "#aa427e",
   "#fff1d6"
  ],
  "short": "Every 5th → +1"
 },
 "monolith": {
  "id": "monolith",
  "art": "monolith",
  "colors": [
   "#4c6579",
   "#f6edd2"
  ],
  "short": "Highest merge → grow"
 },
 "battery": {
  "id": "battery",
  "art": "battery",
  "colors": [
   "#d2a43e",
   "#302f25"
  ],
  "short": "Store +12 points"
 },
 "steelworks": {
  "id": "steelworks",
  "art": "anvil",
  "colors": [
   "#337b7a",
   "#fcf3cd"
  ],
  "short": "×1.2 / Steel tile"
 },
 "charity": {
  "id": "charity",
  "art": "purse",
  "colors": [
   "#548047",
   "#fff1be"
  ],
  "short": "+$10 → +1 mult"
 },
 "mirror": {
  "id": "mirror",
  "art": "mirror",
  "colors": [
   "#91cbd9",
   "#203b50"
  ],
  "short": "First merge ×3"
 },
 "redline": {
  "id": "redline",
  "art": "match",
  "colors": [
   "#d3573e",
   "#fff0cb"
  ],
  "short": "Last 5 moves ×3"
 },
 "odd": {
  "id": "odd",
  "art": "stair",
  "colors": [
   "#9c83b5",
   "#202f43"
  ],
  "short": "Odd powers ×2"
 },
 "alchemy": {
  "id": "alchemy",
  "art": "flask",
  "colors": [
   "#6356a2",
   "#fff2d3"
  ],
  "short": "25% better spawns"
 },
 "compound": {
  "id": "compound",
  "art": "plant",
  "colors": [
   "#9ebf60",
   "#263832"
  ],
  "short": "Clear gate → ×1.25"
 },
 "horizon": {
  "id": "horizon",
  "art": "horizon",
  "colors": [
   "#c37d55",
   "#fff1cf"
  ],
  "short": "Bottom row ×2"
 },
 "magnet": {
  "id": "magnet",
  "art": "magnet",
  "colors": [
   "#a8474b",
   "#fff0c8"
  ],
  "short": "3+ merges → ×3"
 },
 "greed": {
  "id": "greed",
  "art": "hand",
  "colors": [
   "#e3b846",
   "#30352c"
  ],
  "short": "Gold pays $4"
 },
 "avalanche": {
  "id": "avalanche",
  "art": "mountain",
  "colors": [
   "#546cb4",
   "#f9eed9"
  ],
  "short": "×2 → ×4 → ×8"
 },
 "ascension": {
  "id": "ascension",
  "art": "wings",
  "colors": [
   "#c69757",
   "#2d3435"
  ],
  "short": "1,024+ → 3 repeats"
 },
 "coupon": {
  "id": "coupon",
  "art": "ticket",
  "colors": [
   "#d5c8a2",
   "#2c4050"
  ],
  "short": "First reroll free"
 },
 "apprentice": {
  "id": "apprentice",
  "art": "telescope",
  "colors": [
   "#3486a4",
   "#fff1d5"
  ],
  "short": "+0.25 mult / Rune"
 },
 "singularity": {
  "id": "singularity",
  "art": "orbit",
  "colors": [
   "#392f61",
   "#ffe2a0"
  ],
  "short": "Points so far ^1.2"
 },
 "seed": {
  "id": "seed",
  "art": "seed",
  "colors": [
   "#6c995d",
   "#fff1d2"
  ],
  "short": "Place a 16 tile"
 },
 "star": {
  "id": "star",
  "art": "star",
  "colors": [
   "#6c995d",
   "#fff1d2"
  ],
  "short": "Place a 32 tile"
 },
 "tower": {
  "id": "tower",
  "art": "tower",
  "colors": [
   "#6c995d",
   "#fff1d2"
  ],
  "short": "Place a 64 tile"
 },
 "sun": {
  "id": "sun",
  "art": "sun",
  "colors": [
   "#d99744",
   "#2f372f"
  ],
  "short": "Double one tile"
 },
 "twins": {
  "id": "twins",
  "art": "twins",
  "colors": [
   "#4a9ca0",
   "#fff3d4"
  ],
  "short": "Copy one tile"
 },
 "void": {
  "id": "void",
  "art": "void",
  "colors": [
   "#675a9f",
   "#fff1d2"
  ],
  "short": "Destroy one tile"
 },
 "emperor": {
  "id": "emperor",
  "art": "crown",
  "colors": [
   "#d3a136",
   "#2f382e"
  ],
  "short": "Make one tile Gold"
 },
 "prism": {
  "id": "prism",
  "art": "prism",
  "colors": [
   "#81c9db",
   "#1d3a4d"
  ],
  "short": "Make one tile Glass"
 },
 "anvil": {
  "id": "anvil",
  "art": "anvil",
  "colors": [
   "#8296a7",
   "#1e3447"
  ],
  "short": "Make one tile Steel"
 },
 "seal": {
  "id": "seal",
  "art": "seal",
  "colors": [
   "#c34b58",
   "#fff1cd"
  ],
  "short": "Add a scoring repeat"
 },
 "mercy": {
  "id": "mercy",
  "art": "heart",
  "colors": [
   "#b96272",
   "#fff0d5"
  ],
  "short": "Restore 1 Life"
 },
 "hourglass": {
  "id": "hourglass",
  "art": "hourglass",
  "colors": [
   "#a88b4e",
   "#fff4d5"
  ],
  "short": "+4 moves this gate"
 },
 "mercury": {
  "id": "mercury",
  "art": "mercury",
  "colors": [
   "#46799e",
   "#f9efcf"
  ],
  "short": "Upgrade natural spawn tier"
 },
 "venus": {
  "id": "venus",
  "art": "venus",
  "colors": [
   "#d5a73f",
   "#2f382f"
  ],
  "short": "More Gold spawns"
 },
 "mars": {
  "id": "mars",
  "art": "mars",
  "colors": [
   "#78c3d5",
   "#1f3c50"
  ],
  "short": "More Glass spawns"
 },
 "saturn": {
  "id": "saturn",
  "art": "saturn",
  "colors": [
   "#7e989e",
   "#1c3547"
  ],
  "short": "More Steel spawns"
 },
 "neptune": {
  "id": "neptune",
  "art": "neptune",
  "colors": [
   "#b94f69",
   "#fff0d2"
  ],
  "short": "More Echo-marked spawns"
 },
 "auto1": {
  "id": "auto1",
  "art": "auto",
  "colors": [
   "#4b97a5",
   "#fff4cc"
  ],
  "short": "Plans two swipes ahead using your actual Relic scoring, board space, and visible next tile. Appears from floor 3; Robot starts with it."
 },
 "auto2": {
  "id": "auto2",
  "art": "auto",
  "colors": [
   "#4b97a5",
   "#fff4cc"
  ],
  "short": "Tests sequences up to six swipes ahead across possible tile spawns. Uses actual Relic scoring, enhancements, and guardian rules."
 },
 "trade1": {
  "id": "trade1",
  "art": "trade",
  "colors": [
   "#e1b74d",
   "#2f392f"
  ],
  "short": "Raise your interest cap from $5 to $10 per cleared gate. Interest is paid per $5 saved."
 },
 "trade2": {
  "id": "trade2",
  "art": "trade",
  "colors": [
   "#e1b74d",
   "#2f392f"
  ],
  "short": "Earn $2 interest per $5 saved. Raise the interest cap to $20."
 },
 "trade3": {
  "id": "trade3",
  "art": "trade",
  "colors": [
   "#e1b74d",
   "#2f392f"
  ],
  "short": "Every source of money pays ×2 its base value: rewards, interest, sales, Gold, and Relics."
 },
 "slot1": {
  "id": "slot1",
  "art": "cards",
  "colors": [
   "#b78a50",
   "#fff5d5"
  ],
  "short": "Permanently add one Relic slot for this run."
 },
 "slot2": {
  "id": "slot2",
  "art": "cards",
  "colors": [
   "#b78a50",
   "#fff5d5"
  ],
  "short": "Add a second extra Relic slot."
 },
 "pocket1": {
  "id": "pocket1",
  "art": "purse",
  "colors": [
   "#b78a50",
   "#fff5d5"
  ],
  "short": "Add one consumable slot for this run."
 },
 "moves1": {
  "id": "moves1",
  "art": "hourglass",
  "colors": [
   "#b78a50",
   "#fff5d5"
  ],
  "short": "Start every future gate with 3 extra moves."
 },
 "moves2": {
  "id": "moves2",
  "art": "hourglass",
  "colors": [
   "#b78a50",
   "#fff5d5"
  ],
  "short": "Start future gates with 6 extra moves total."
 },
 "heart1": {
  "id": "heart1",
  "art": "heart",
  "colors": [
   "#b78a50",
   "#fff5d5"
  ],
  "short": "Raise maximum Life by 1 and immediately heal 1 Life."
 },
 "sale1": {
  "id": "sale1",
  "art": "ticket",
  "colors": [
   "#b78a50",
   "#fff5d5"
  ],
  "short": "All future shop prices are reduced by 25%, rounded up."
 }
}

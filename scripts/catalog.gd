extends RefCounted

# Snapshot of pre-Fracture Gatefold content. New editions and Curse are intentionally not enabled.
const RELICS = {
 "carbon":{"name":"Carbon Paper","rarity":"Common","cost":4,"desc":"+8 at its point in the chain."},
 "corner":{"name":"Cornerstone","rarity":"Common","cost":5,"desc":"Corner merges score x2."},
 "echo":{"name":"Echo Chamber","rarity":"Uncommon","cost":7,"desc":"Double points and following triggers."},
 "business":{"name":"Small Business","rarity":"Common","cost":5,"desc":"Merge 2s or 4s to earn $1."},
 "resonance":{"name":"Resonance","rarity":"Uncommon","cost":7,"desc":"Growing x1.12 per trigger during a swipe."},
 "domino":{"name":"Domino Theory","rarity":"Uncommon","cost":7,"desc":"Last merge retriggers for earlier merges."},
 "feedback":{"name":"Feedback Loop","rarity":"Rare","cost":10,"desc":"Every fifth chain trigger scores again."},
 "monolith":{"name":"Monolith","rarity":"Rare","cost":9,"desc":"High tile merges grow this x1.15."},
 "battery":{"name":"Dry Cell","rarity":"Common","cost":4,"desc":"Store 12 points when a swipe makes no merges."},
 "steelworks":{"name":"Steelworks","rarity":"Uncommon","cost":7,"desc":"x1.2 for each Steel tile on board."},
 "charity":{"name":"Golden Ratio","rarity":"Uncommon","cost":8,"desc":"x(1 + money / $10, rounded down)."},
 "mirror":{"name":"Mirror","rarity":"Rare","cost":10,"desc":"Triple first merge and following triggers."},
 "redline":{"name":"Redline","rarity":"Common","cost":5,"desc":"x3 when 5 or fewer moves remain."},
 "odd":{"name":"Oddity","rarity":"Common","cost":5,"desc":"Odd tile powers score x2."},
 "alchemy":{"name":"Alchemist","rarity":"Uncommon","cost":6,"desc":"25% of natural spawns gain one tier."},
 "compound":{"name":"Compound Growth","rarity":"Rare","cost":9,"desc":"x1.25 per cleared gate, permanently."},
 "horizon":{"name":"Low Ground","rarity":"Common","cost":5,"desc":"Bottom-row merges score x2."},
 "magnet":{"name":"Three's Company","rarity":"Uncommon","cost":6,"desc":"Three or more merges in a swipe score x3."},
 "greed":{"name":"Midas Touch","rarity":"Uncommon","cost":7,"desc":"Gold pays $4 instead of $2."},
 "avalanche":{"name":"Avalanche","rarity":"Rare","cost":9,"desc":"Second, third, fourth merges grow x2/x4/x8."},
 "ascension":{"name":"Ascension","rarity":"Rare","cost":10,"desc":"Tiles at least 1024 triple points and triggers."},
 "coupon":{"name":"Loose Change","rarity":"Common","cost":4,"desc":"First reroll each shop is free."},
 "apprentice":{"name":"Runekeeper","rarity":"Common","cost":5,"desc":"+0.25 multiplier per Rune used."},
 "singularity":{"name":"Singularity","rarity":"Rare","cost":11,"desc":"Raise points at this position to power 1.2."}
}
const SPELLS = {
 "seed":{"name":"Seed","cost":3,"action":"spawn","power":4,"desc":"Place a 16 tile."},
 "star":{"name":"Conjure","cost":4,"action":"spawn","power":5,"desc":"Place a 32 tile."},
 "tower":{"name":"Summon","cost":6,"action":"spawn","power":6,"desc":"Place a 64 tile."},
 "sun":{"name":"Amplify","cost":5,"action":"double","desc":"Double a tile without merging."},
 "twins":{"name":"Duplicate","cost":5,"action":"copy","desc":"Copy a tile into an empty cell."},
 "void":{"name":"Shatter","cost":3,"action":"erase","desc":"Destroy one tile."},
 "emperor":{"name":"Gild","cost":4,"action":"gold","desc":"Add Gold to one tile."},
 "prism":{"name":"Crystallize","cost":4,"action":"glass","desc":"Add Glass to one tile."},
 "anvil":{"name":"Temper","cost":4,"action":"steel","desc":"Add Steel to one tile."},
 "seal":{"name":"Echo Mark","cost":5,"action":"seal","desc":"Give a tile a scoring echo."},
 "mercy":{"name":"Mend","cost":5,"action":"heal","desc":"Recover 1 Life."},
 "hourglass":{"name":"Extra Time","cost":4,"action":"time","desc":"Add 4 moves."}
}
const RUNES = {
 "mercury":{"name":"Growth Rune","cost":5,"stat":"spawn","desc":"Increase natural spawn tier."},
 "venus":{"name":"Gold Rune","cost":5,"stat":"gold","desc":"+8% Gold chance each use."},
 "mars":{"name":"Glass Rune","cost":5,"stat":"glass","desc":"+8% Glass chance each use."},
 "saturn":{"name":"Steel Rune","cost":5,"stat":"steel","desc":"+8% Steel chance each use."},
 "neptune":{"name":"Echo Rune","cost":6,"stat":"seal","desc":"+6% Echo chance each use."}
}
const UPGRADES = {
 "auto1":{"name":"Auto-player I","cost":12,"desc":"Automatic moves (basic search)."},
 "auto2":{"name":"Auto-player II","cost":12,"req":"auto1","desc":"Advanced automatic moves."},
 "trade1":{"name":"World Trade Center I","cost":8,"desc":"Interest cap $10."},
 "trade2":{"name":"World Trade Center II","cost":12,"req":"trade1","desc":"Interest $2 per $5, cap $20."},
 "trade3":{"name":"World Trade Center III","cost":18,"req":"trade2","desc":"Double income sources."},
 "slot1":{"name":"Extra Slot I","cost":10,"desc":"One extra relic slot."},
 "slot2":{"name":"Extra Slot II","cost":15,"req":"slot1","desc":"Second extra relic slot."},
 "pocket1":{"name":"Spell Pouch","cost":7,"desc":"One extra consumable slot."},
 "moves1":{"name":"Long Division I","cost":8,"desc":"+3 moves at every gate."},
 "moves2":{"name":"Long Division II","cost":12,"req":"moves1","desc":"+6 moves total per gate."},
 "heart1":{"name":"Second Wind","cost":10,"desc":"+1 maximum Life and heal."},
 "sale1":{"name":"Friendly Faces","cost":9,"desc":"Shops 25% cheaper."}
}
const BOARDS = [
 {"id":"red","name":"Red","moves":10,"badge":"+10","desc":"Ten extra moves every gate."},
 {"id":"yellow","name":"Yellow","relics":["business"],"money_gate":7,"markup":1.25,"badge":"+$7","desc":"Start with Small Business, +$7 per gate, shops +25%."},
 {"id":"blue","name":"Blue","relics":["echo"],"slots":1,"badge":"x2","desc":"Echo Chamber and one extra relic slot."},
 {"id":"robot","name":"Robot","upgrades":["auto1"],"maintenance":3,"badge":"AUTO","desc":"Start with Auto-player I, pay maintenance."},
 {"id":"classic","name":"Classic","badge":"4x4","desc":"Original 4x4 rules, no starting bonuses."},
 {"id":"green","name":"Green","relics":["alchemy"],"runes":{"spawn":2},"badge":"4/8","desc":"Alchemist; 4/8 natural spawns."},
 {"id":"purple","name":"Purple","relics":["resonance"],"runes":{"seal":2},"start_seal":true,"badge":"ECHO","desc":"Resonance and Echo starting tiles."},
 {"id":"orange","name":"Orange","relics":["battery"],"charge":48,"moves":4,"badge":"+48","desc":"Dry Cell with 48 charge; +4 moves."},
 {"id":"white","name":"White","max_hp":5,"moves":-3,"floor_heal":1,"badge":"5HP","desc":"5 Life, heal each floor, -3 moves."},
 {"id":"black","name":"Black","relics":["monolith","singularity"],"slots":-1,"target_mult":1.25,"badge":"^1.2","desc":"Monolith & Singularity; fewer slots and tougher gates."},
 {"id":"foundry","name":"Foundry","relics":["steelworks"],"runes":{"steel":2},"start_fx":{"steel":true},"moves":-2,"badge":"Fe","desc":"Steelworks and Steel opening tiles."},
 {"id":"bazaar","name":"Bazaar","relics":["coupon"],"upgrades":["sale1"],"badge":"-25%","desc":"Discounts and free first reroll."},
 {"id":"chronicle","name":"Chronicle","upgrades":["moves1"],"bank_limit":10,"badge":"+10","desc":"Bank up to 10 unused moves."},
 {"id":"archivist","name":"Archivist","relics":["apprentice"],"upgrades":["pocket1"],"items":["mercury","mars","neptune"],"badge":"RUNES","desc":"Start with Runekeeper and three Runes."},
 {"id":"curio","name":"Curio","upgrades":["pocket1"],"slots":-1,"free_packs":true,"badge":"FREE","desc":"Free Supply Packs, but one fewer relic slot."}
]
const GUARDIANS = [
 {"id":"toll","name":"The Tollkeeper","desc":"Every fourth valid swipe costs another move."},
 {"id":"repeat","name":"The Echo","desc":"Same direction twice costs another move."},
 {"id":"largest","name":"The Balance","desc":"Only largest merge scores."},
 {"id":"quiet","name":"The Silence","desc":"Every merge scores x0.75."},
 {"id":"short","name":"The Sundial","desc":"Begin with three fewer moves."}
]

static func board(id: String) -> Dictionary:
 for b in BOARDS:
  if b.id == id:
   return b
 return BOARDS[4]

static func name_for(id: String) -> String:
 for pool in [RELICS,SPELLS,RUNES,UPGRADES]:
  if pool.has(id):
   return pool[id].name
 return id

static func data_for(id: String) -> Dictionary:
 for pool in [RELICS,SPELLS,RUNES,UPGRADES]:
  if pool.has(id):
   return pool[id]
 return {}

extends RefCounted
const Cat = preload("res://scripts/catalog.gd")
const SAVE_PATH = "user://gatefold-godot-v1.json"
var rng := RandomNumberGenerator.new()
var cells: Array = []
var relics: Array = []
var inventory: Array = []
var upgrades: Array = []
var rune_levels := {"spawn":0,"gold":0,"glass":0,"steel":0,"seal":0}
var rune_uses := 0
var board_id := "classic"
var floor_num := 1
var gate := 0
var hp := 3
var max_hp := 3
var moves := 18
var money := 12.0
var score := 0.0
var total_score := 0.0
var best_exp := 1
var cleared := 0
var swipes := 0
var gate_swipes := 0
var last_dir := ""
var banked := 0
var phase := "home"
var result_text := ""
var last_merge := 0.0
var last_triggers := 0
var shop_offers: Array = []
var shop_upgrade := ""
var shop_rerolls := 0
var shop_pack_bought := false
var pack_choices: Array = []
var shop_heal_bought := false
var next_tile: Dictionary = {}
var selected_spell := ""
var selected_source := -1
var _pending_outcome := true

func b() -> Dictionary:
 return Cat.board(board_id)

func guardian() -> Dictionary:
 return Cat.GUARDIANS[(floor_num - 1) % Cat.GUARDIANS.size()]

func has_relic(id: String) -> bool:
 for r in relics:
  if r.id == id:
   return true
 return false

func has_upgrade(id: String) -> bool:
 return upgrades.has(id)

func max_relics() -> int:
 return maxi(1, 5 + int(b().get("slots", 0)) + int(has_upgrade("slot1")) + int(has_upgrade("slot2")))

func max_pocket() -> int:
 return 3 + int(has_upgrade("pocket1"))

func target() -> float:
 return 256.0 * pow(3.0, floor_num - 1) * float(b().get("target_mult",1.0)) if gate == 2 else [96.0,160.0][gate] * pow(3.0, floor_num - 1) * float(b().get("target_mult",1.0))

func budget() -> int:
 return [18,17,16][gate] + int(b().get("moves",0)) + banked + (6 if has_upgrade("moves2") else 3 if has_upgrade("moves1") else 0) - (3 if gate == 2 and guardian().id == "short" else 0)

func spawn_min() -> int:
 return 1 + int(rune_levels.spawn / 2.0)

func tile(e: int, fx: Dictionary = {}, seal: bool = false) -> Dictionary:
 return {"e":e,"fx":fx.duplicate(true),"seal":seal}

func roll_tile() -> Dictionary:
 var chance := 0.10 + (0.35 if rune_levels.spawn % 2 == 1 else 0.0)
 var e := spawn_min() + int(rng.randf() < chance)
 if has_relic("alchemy") and rng.randf() < .25:
  e += 1
 var fx := {}
 for key in ["gold","glass","steel"]:
  if rng.randf() < 1.0 - pow(.92, rune_levels[key]):
   fx[key] = true
 return tile(e,fx,rng.randf() < 1.0 - pow(.94,rune_levels.seal))

func spawn() -> void:
 var free: Array = []
 for i in range(16):
  if cells[i] == null:
   free.append(i)
 if free.is_empty():
  return
 cells[free[rng.randi_range(0,free.size()-1)]] = next_tile.duplicate(true)
 next_tile = roll_tile()

func _grant(id: String) -> bool:
 if Cat.RELICS.has(id):
  if has_relic(id) or relics.size() >= max_relics(): return false
  relics.append({"id":id,"growth":1.0,"charge":0.0,"carry":0})
  return true
 if Cat.SPELLS.has(id) or Cat.RUNES.has(id):
  if inventory.size() >= max_pocket(): return false
  inventory.append(id)
  return true
 if Cat.UPGRADES.has(id):
  if has_upgrade(id): return false
  var data: Dictionary = Cat.UPGRADES[id]
  if data.has("req") and not has_upgrade(data.req): return false
  if id.begins_with("auto") and floor_num < 3 and board_id != "robot": return false
  upgrades.append(id)
  if id == "heart1":
   max_hp += 1
   hp += 1
  return true
 return false

func new_run(id: String = "classic") -> void:
 rng.randomize()
 board_id = id
 var board_def := b()
 cells.clear()
 cells.resize(16)
 cells.fill(null)
 relics = [{"id":"carbon","growth":1.0,"charge":0.0,"carry":0}]
 inventory.clear()
 upgrades.clear()
 rune_levels = {"spawn":0,"gold":0,"glass":0,"steel":0,"seal":0}
 rune_uses = 0
 floor_num = 1
 gate = 0
 max_hp = int(board_def.get("max_hp",3))
 hp = max_hp
 money = float(board_def.get("start_money",12))
 score = 0.0
 total_score = 0.0
 best_exp = 1
 cleared = 0
 swipes = 0
 gate_swipes = 0
 last_dir = ""
 banked = 0
 phase = "play"
 var initial_runes: Dictionary = board_def.get("runes",{})
 for key in initial_runes:
  rune_levels[key] = initial_runes[key]
  rune_uses += initial_runes[key]
 best_exp = spawn_min()
 cells[12] = tile(best_exp,board_def.get("start_fx",{}),board_def.get("start_seal",false))
 cells[13] = tile(best_exp,board_def.get("start_fx",{}),board_def.get("start_seal",false))
 next_tile = roll_tile()
 for r in board_def.get("relics",[]):
  _grant(r)
 for u in board_def.get("upgrades",[]):
  _grant(u)
 for item in board_def.get("items",[]):
  _grant(item)
 for r in relics:
  if r.id == "battery":
   r.charge = float(board_def.get("charge",0))
 moves = budget()
 shop_offers.clear()
 shop_upgrade = ""
 shop_rerolls = 0
 shop_pack_bought = false
 pack_choices.clear()
 save_run()

func slide(direction: String) -> Dictionary:
 var out: Array = []
 out.resize(16)
 out.fill(null)
 var events: Array = []
 var changed := false
 for line in range(4):
  var positions: Array = []
  for p in range(4):
   var idx := 0
   match direction:
    "left": idx = line * 4 + p
    "right": idx = line * 4 + 3-p
    "up": idx = p*4 + line
    "down": idx = (3-p)*4 + line
   positions.append(idx)
  var src: Array = []
  for idx in positions:
   if cells[idx] != null:
    src.append({"tile":cells[idx],"from":idx})
  var k := 0
  var w := 0
  while k < src.size():
   var a: Dictionary = src[k]
   var dest: int = positions[w]
   if k+1 < src.size() and a.tile.e == src[k+1].tile.e:
    var other: Dictionary = src[k+1].tile
    var merged: Dictionary = tile(int(a.tile.e)+1,a.tile.fx,a.tile.seal or other.seal)
    for fx_name in other.fx:
     merged.fx[fx_name] = true
    out[dest] = merged
    events.append({"tile":merged,"index":dest})
    changed = true
    k += 2
   else:
    out[dest] = a.tile.duplicate(true)
    if a.from != dest: changed = true
    k += 1
   w += 1
 return {"board":out,"events":events,"changed":changed}

func is_corner(i: int) -> bool:
 return [0,3,12,15].has(i)

func earn(base: float) -> float:
 var value := base * (2.0 if has_upgrade("trade3") else 1.0)
 money += value
 return value

func score_merges(events: Array, previous_highest: int) -> Dictionary:
 var full := 0.0
 var trigger_count := 0
 var steel_count := 0
 var max_e := 0
 var chain_pos := 0
 for c in cells:
  if c != null and c.fx.get("steel",false): steel_count += 1
 for ev in events:
  max_e = maxi(max_e,int(ev.tile.e))
 var battery_charge := 0.0
 for r in relics:
  if r.id == "battery":
   battery_charge = r.charge
 if events.is_empty():
  for r in relics:
   if r.id == "battery":
    r.charge += 12.0
  return {"score":0.0,"triggers":0}
 for ei in range(events.size()):
  var ev: Dictionary = events[ei]
  var t: Dictionary = ev.tile
  var eligible := not (gate==2 and guardian().id=="largest" and t.e != max_e)
  if t.fx.get("gold",false):
   earn(4.0 if has_relic("greed") else 2.0)
  var points := 0.0
  for pass_idx in range(2 if t.seal else 1):
   var value := pow(2.0,float(t.e)) * pow(1.25,steel_count) * (2.0 if t.fx.get("glass",false) else 1.0)
   var repeats := 1
   for r in relics:
    var id: String = r.id
    if id == "business" and pass_idx == 0 and t.e <= 3: earn(1)
    if id == "monolith" and pass_idx == 0 and t.e >= previous_highest: r.growth *= 1.15
    if not eligible: continue
    match id:
     "carbon": value += 8.0 * repeats
     "battery": value += battery_charge * repeats
     "corner": 
      if is_corner(ev.index): value *= 2
     "horizon":
      if ev.index >= 12: value *= 2
     "redline":
      if moves <= 5: value *= 3
     "odd":
      if int(t.e) % 2 == 1: value *= 2
     "magnet":
      if events.size() >= 3: value *= 3
     "avalanche":
      if ei > 0: value *= pow(2.0,ei)
     "steelworks":
      if steel_count > 0: value *= pow(1.2,steel_count)
     "charity": value *= floorf(money/10.0)+1.0
     "apprentice": value *= 1.0 + rune_uses * 0.25
     "monolith","compound": value *= float(r.growth)
     "echo": value *= 2; repeats *= 2
     "mirror":
      if ei == 0: value *= 3; repeats *= 3
     "ascension":
      if t.e >= 10: value *= 3; repeats *= 3
     "domino":
      if ei == events.size()-1 and events.size() > 1:
       var factor := int(pow(2.0,events.size()-1))
       value *= factor
       repeats *= factor
     "feedback":
      var extra := maxi(0, int((int(r.carry)+repeats-1)/4.0))
      if extra > 0: value *= float(repeats+extra)/float(repeats)
      repeats += extra
      r.carry = (int(r.carry)+repeats)%5
     "resonance":
      var sum := pow(1.12,chain_pos+1) * (pow(1.12,repeats)-1.0)/0.12
      value *= sum/float(repeats)
      chain_pos += repeats
     "singularity":
      if value > 0.0: value = pow(value,1.2)
   if eligible:
    points += value
    trigger_count += repeats
  if gate == 2 and guardian().id == "quiet": points *= .75
  full += floorf(points)
  if t.fx.get("glass",false) and rng.randf() < .25:
   # The merged tile may have moved since events were collected.
   cells[ev.index] = null
 for r in relics:
  if r.id == "battery": r.charge = 0.0
 return {"score":full,"triggers":trigger_count}

func can_slide() -> bool:
 for direction in ["up","down","left","right"]:
  if slide(direction).changed: return true
 return false

func move(direction: String) -> bool:
 if phase != "play": return false
 var outcome := slide(direction)
 if not outcome.changed: return false
 var prior_highest := 1
 for c in cells:
  if c != null: prior_highest = maxi(prior_highest,int(c.e))
 cells = outcome.board
 swipes += 1
 gate_swipes += 1
 var cost := 1
 if gate == 2:
  if guardian().id=="repeat" and last_dir == direction: cost += 1
  if guardian().id=="toll" and gate_swipes % 4 == 0: cost += 1
 last_dir = direction
 moves = maxi(0,moves-cost)
 var gain: Dictionary = score_merges(outcome.events,prior_highest)
 last_merge = gain.score
 last_triggers = gain.triggers
 score += gain.score
 total_score += gain.score
 for c in cells:
  if c != null: best_exp = maxi(best_exp,int(c.e))
 spawn()
 if score >= target(): finish_gate(true)
 elif moves <= 0: finish_gate(false)
 elif not can_slide(): result_text = "Board locked. Clear tiles with a Spell or take a hit."
 save_run()
 return true

func interest() -> float:
 var rate := 2.0 if has_upgrade("trade2") else 1.0
 var cap := 20.0 if has_upgrade("trade2") else 10.0 if has_upgrade("trade1") else 5.0
 return minf(cap, floorf(money/5.0)*rate)

func finish_gate(win: bool) -> void:
 if phase != "play": return
 _pending_outcome = win
 var basic := float([4,5,7][gate]) if win else 0.0
 var efficiency := float(int(moves/3.0)) if win else 0.0
 var inc := interest() if win else 0.0
 var bonus := float(b().get("money_gate",0))
 var income := earn(basic+efficiency+inc+bonus)
 var fee := minf(money,minf(float(b().get("maintenance",0)),float(floor_num)))
 money -= fee
 banked = mini(int(b().get("bank_limit",0)), moves) if win else 0
 if win:
  cleared += 1
  for r in relics:
   if r.id == "compound": r.growth *= 1.25
  phase = "reward"
  result_text = "GATE CLEARED! +$%d (interest $%d)" % [int(income-fee),int(inc)]
 else:
  hp -= 1
  var occupied: Array = []
  for i in range(16):
   if cells[i] != null: occupied.append({"index":i,"e":cells[i].e})
  occupied.sort_custom(func(a,b): return a.e < b.e)
  for i in range(mini(2,occupied.size())):
   cells[occupied[i].index] = null
  while filled() < 2: spawn()
  phase = "failed" if hp > 0 else "over"
  result_text = "GATE FAILED. Lost 1 Life."

func filled() -> int:
 var total := 0
 for c in cells:
  if c != null: total += 1
 return total

func _random_offer(pool: Dictionary) -> String:
 var keys: Array = pool.keys()
 if keys.is_empty(): return ""
 return keys[rng.randi_range(0,keys.size()-1)]

func _random_relic() -> String:
 var available: Array = []
 for id in Cat.RELICS:
  if has_relic(id): continue
  var rarity := Cat.RELICS[id].rarity
  var weight := 60 if rarity == "Common" else 32 if rarity == "Uncommon" else 8
  for _i in range(weight):
   available.append(id)
 return available[rng.randi_range(0,available.size()-1)] if not available.is_empty() else ""

func _make_shop() -> void:
 shop_offers = [_random_relic(),_random_relic(),_random_offer(Cat.SPELLS),_random_offer(Cat.RUNES)]
 var eligible: Array = []
 for id in Cat.UPGRADES:
  if has_upgrade(id): continue
  var def: Dictionary = Cat.UPGRADES[id]
  if def.has("req") and not has_upgrade(def.req): continue
  if id.begins_with("auto") and floor_num < 3 and board_id != "robot": continue
  eligible.append(id)
 shop_upgrade = eligible[rng.randi_range(0,eligible.size()-1)] if not eligible.is_empty() else ""

func open_shop() -> void:
 if phase != "reward" and phase != "failed": return
 phase = "shop"
 shop_rerolls = 0
 shop_pack_bought = false
 shop_heal_bought = false
 pack_choices.clear()
 _make_shop()
 save_run()

func price(base: int) -> int:
 return int(ceil(base*float(b().get("markup",1.0))*(0.75 if has_upgrade("sale1") else 1.0)))

func cost_for(id: String) -> int:
 return price(int(Cat.data_for(id).get("cost",0)))

func buy_item(id: String) -> bool:
 if phase != "shop": return false
 if id == "" or not Cat.data_for(id): return false
 if id != shop_upgrade and not shop_offers.has(id): return false
 var amount := cost_for(id)
 if money < amount: return false
 if not _grant(id): return false
 money -= amount
 if id == shop_upgrade: shop_upgrade = ""
 else:
  shop_offers.erase(id)
 result_text = "Purchased " + Cat.name_for(id)
 save_run()
 return true

func sell_relic(index: int) -> bool:
 if phase != "shop" or index < 0 or index >= relics.size(): return false
 var id: String = relics[index].id
 earn(maxf(1.0,float(int(Cat.RELICS[id].cost/2))))
 relics.remove_at(index)
 save_run()
 return true

func reroll() -> bool:
 if phase != "shop": return false
 var amount := 0 if shop_rerolls == 0 and has_relic("coupon") else price(3+shop_rerolls)
 if money < amount: return false
 money -= amount
 shop_rerolls += 1
 _make_shop()
 save_run()
 return true

func pack_open() -> bool:
 if phase != "shop" or shop_pack_bought: return false
 var amount := 0 if b().get("free_packs",false) else price(5)
 if money < amount: return false
 money -= amount
 shop_pack_bought = true
 var choices: Array = []
 var pool: Array = Cat.RELICS.keys() + Cat.SPELLS.keys() + Cat.RUNES.keys()
 pool.shuffle()
 for id in pool:
  if (not Cat.RELICS.has(id) or not has_relic(id)) and choices.size() < 3:
   choices.append(id)
 pack_choices = choices
 save_run()
 return true

func pack_choose(id: String) -> bool:
 if phase != "shop" or not pack_choices.has(id): return false
 if not _grant(id): return false
 pack_choices.clear()
 save_run()
 return true

func heal_shop() -> bool:
 if phase != "shop" or shop_heal_bought or hp>=max_hp: return false
 var amount := price(5)
 if money < amount: return false
 money -= amount
 hp += 1
 shop_heal_bought = true
 save_run()
 return true

func leave_shop() -> void:
 if phase != "shop": return
 if _pending_outcome:
  gate += 1
  if gate == 3:
   gate = 0
   floor_num += 1
   hp = mini(max_hp, hp + int(b().get("floor_heal",0)))
 phase = "play"
 score = 0.0
 moves = budget()
 banked = 0
 gate_swipes = 0
 last_dir = ""
 shop_offers.clear()
 pack_choices.clear()
 result_text = ""
 while filled() < 2: spawn()
 if not can_slide():
  var first := cells.find(null)
  if first < 0: cells[0] = null
 save_run()

func use_item(index: int, cell: int = -1, dest: int = -1) -> bool:
 if index < 0 or index >= inventory.size(): return false
 if phase not in ["shop","play"]: return false
 var id: String = inventory[index]
 if Cat.RUNES.has(id):
  var stat: String = Cat.RUNES[id].stat
  rune_levels[stat] += 1
  rune_uses += 1
  if stat == "spawn":
   for t in cells:
    if t != null: t.e = maxi(t.e,spawn_min())
  next_tile = roll_tile()
 elif id == "mercy":
  if hp >= max_hp: return false
  hp += 1
 elif id == "hourglass":
  if phase != "play": return false
  moves += 4
 else:
  if phase != "play" or cell < 0 or cell >= 16: return false
  var action: String = Cat.SPELLS[id].action
  var t = cells[cell]
  if action == "spawn":
   if t != null: return false
   cells[cell] = tile(maxi(int(Cat.SPELLS[id].power),spawn_min()+2))
  else:
   if t == null: return false
   match action:
    "double": t.e += 1
    "copy":
     if dest < 0 or dest >= 16 or cells[dest] != null: return false
     cells[dest] = t.duplicate(true)
    "erase": cells[cell] = null
    "seal": t.seal = true
    "gold","glass","steel": t.fx[action] = true
 inventory.remove_at(index)
 save_run()
 return true

func auto_move() -> bool:
 if phase != "play" or not has_upgrade("auto1"): return false
 var best_dir := ""
 var best_grade := -1.0e300
 for d in ["left","up","right","down"]:
  var result := slide(d)
  if not result.changed: continue
  var vacancies := 0
  var merges: Array = result.events
  var max_e := 0
  var corner_bonus := 0
  for i in range(16):
   var t = result.board[i]
   if t == null: vacancies += 1
   else:
    max_e = maxi(max_e,int(t.e))
    if [0,3,12,15].has(i): corner_bonus = maxi(corner_bonus,int(t.e))
  var grade := vacancies * 120.0 + merges.size()*65.0 + max_e*10.0 + corner_bonus*3.0
  if grade > best_grade:
   best_grade = grade
   best_dir = d
 return move(best_dir) if best_dir != "" else false

func save_run() -> void:
 if phase == "home": return
 var payload := {"version":1,"board_id":board_id,"cells":cells,"relics":relics,"inventory":inventory,"upgrades":upgrades,"runes":rune_levels,"rune_uses":rune_uses,"floor_num":floor_num,"gate":gate,"hp":hp,"max_hp":max_hp,"moves":moves,"money":money,"score":score,"total_score":total_score,"best_exp":best_exp,"cleared":cleared,"swipes":swipes,"gate_swipes":gate_swipes,"last_dir":last_dir,"banked":banked,"phase":phase,"result_text":result_text,"next_tile":next_tile,"shop_offers":shop_offers,"shop_upgrade":shop_upgrade,"shop_rerolls":shop_rerolls,"shop_pack_bought":shop_pack_bought,"pack_choices":pack_choices,"shop_heal_bought":shop_heal_bought,"pending_outcome":_pending_outcome,"rng_state":rng.state}
 var f := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
 if f: f.store_string(JSON.stringify(payload))

func load_run() -> bool:
 if not FileAccess.file_exists(SAVE_PATH): return false
 var f := FileAccess.open(SAVE_PATH,FileAccess.READ)
 if not f: return false
 var data = JSON.parse_string(f.get_as_text())
 if typeof(data) != TYPE_DICTIONARY or data.get("version",0) != 1: return false
 board_id = str(data.get("board_id","classic"))
 cells = data.get("cells",[])
 relics = data.get("relics",[])
 inventory = data.get("inventory",[])
 upgrades = data.get("upgrades",[])
 rune_levels = data.get("runes",rune_levels)
 rune_uses = int(data.get("rune_uses",0))
 floor_num = int(data.get("floor_num",1))
 gate = int(data.get("gate",0))
 hp = int(data.get("hp",3))
 max_hp = int(data.get("max_hp",3))
 moves = int(data.get("moves",18))
 money = float(data.get("money",12.0))
 score = float(data.get("score",0.0))
 total_score = float(data.get("total_score",0.0))
 best_exp = int(data.get("best_exp",1))
 cleared = int(data.get("cleared",0))
 swipes = int(data.get("swipes",0))
 gate_swipes = int(data.get("gate_swipes",0))
 last_dir = str(data.get("last_dir",""))
 banked = int(data.get("banked",0))
 phase = str(data.get("phase","play"))
 result_text = str(data.get("result_text",""))
 next_tile = data.get("next_tile",{})
 shop_offers = data.get("shop_offers",[])
 shop_upgrade = str(data.get("shop_upgrade",""))
 shop_rerolls = int(data.get("shop_rerolls",0))
 shop_pack_bought = bool(data.get("shop_pack_bought",false))
 pack_choices = data.get("pack_choices",[])
 shop_heal_bought = bool(data.get("shop_heal_bought",false))
 _pending_outcome = bool(data.get("pending_outcome",true))
 rng.state = int(data.get("rng_state",0))
 return cells.size()==16

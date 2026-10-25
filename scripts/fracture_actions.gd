extends RefCounted
const Cat = preload("res://scripts/catalog.gd")
const Num = preload("res://scripts/num.gd")
const Rules = preload("res://scripts/fracture_rules.gd")
const Market = preload("res://scripts/fracture_market.gd")

static func valid_relic(game, index: int) -> bool:
 return index>=0 and index<game.relics.size()

static func fracture_reason(game, id: String, target: int = -1) -> String:
 if not Cat.FRACTURES.has(id): return "Unknown Fracture."
 if game.phase not in ["play","shop"]: return "Use Fractures during play or in the shop."
 var type: String = Cat.FRACTURES[id].target
 if type=="relic" and not valid_relic(game,target): return "Choose an eligible relic."
 if type=="tile" and (target<0 or target>=16 or game.cells[target]==null): return "Choose an occupied tile."
 var selected: Dictionary = game.relics[target] if type=="relic" else {}
 var tiles: Array = Rules.occupied(game)
 match id:
  "liberation":
   if selected.get("edition","")=="unbound": return "This relic is already Unbound."
  "overexposure":
   if selected.get("edition","")=="oversaturated": return "This relic is already Oversaturated."
   if game.max_hp<=1 or game.board_id=="eclipse": return "Requires at least 2 maximum Life."
   if selected.get("edition","")=="unbound" and Rules.bound_count(game)>=game.max_relics(): return "Make room for this relic's normal slot first."
  "erosion":
   if game.relics.is_empty(): return "Requires an owned relic."
  "rebirth":
   if game._eligible_relics().filter(func(item): return Cat.RELICS[item].rarity==Cat.RELICS[selected.id].rarity and item!=selected.id).is_empty(): return "No same-rarity replacement is available."
  "schism":
   if game.relics.size()<3: return "Requires at least 3 relics."
  "transmutation":
   var editions: Array = game.relics.map(func(r): return r.get("edition",""))
   if editions.size()<2 or editions.all(func(e): return e==editions[0]): return "Requires at least two different editions to redistribute."
  "genesis":
   if tiles.size()<3 or Rules.free_cells(game).is_empty(): return "Requires at least 3 tiles and an empty cell."
  "collapse":
   if tiles.size()<=3 and tiles.all(func(i): return game.cells[i].seal): return "The remaining tiles are already sealed."
  "transference":
   if not tiles.any(func(i): return i!=target and (not game.cells[i].fx.is_empty() or game.cells[i].seal)): return "Another tile must hold an enhancement or seal."
  "pandemonium":
   if game.hp<=1: return "Requires at least 2 Life."
   if tiles.is_empty(): return "Requires occupied tiles."
  "monoculture":
   if tiles.is_empty(): return "Requires occupied tiles."
   if tiles.all(func(i): return game.cells[i].e==game.cells[tiles[0]].e and game.cells[i].fx.get("glass",false) and game.cells[i].seal): return "These tiles already form a Glass, sealed monoculture."
  "liquidation":
   if tiles.size()<4: return "Requires at least 4 tiles."
  "sovereign":
   if Rules.bound_count(game)>=game.max_relics(): return "Make room in your relic slots first."
   if game._eligible_relics().filter(func(item): return Cat.RELICS[item].rarity=="Legendary").is_empty(): return "All Legendary relics are already owned."
 return ""

static func usable_fracture(game, id: String) -> bool:
 if not Cat.FRACTURES.has(id): return false
 var type: String = Cat.FRACTURES[id].target
 if type=="none": return fracture_reason(game,id).is_empty()
 var count: int = game.relics.size() if type=="relic" else 16
 return range(count).any(func(index): return fracture_reason(game,id,index).is_empty())

static func use_fracture(game, id: String, target: int = -1) -> bool:
 if not fracture_reason(game,id,target).is_empty(): return false
 var type: String = Cat.FRACTURES[id].target
 if type=="relic" and not valid_relic(game,target): return false
 if type=="tile" and (target<0 or target>=16 or game.cells[target]==null): return false
 var selected: Dictionary = game.relics[target] if type=="relic" else {}
 var tiles: Array = Rules.occupied(game)
 match id:
  "liberation":
   if selected.get("edition","")=="unbound": return false
   selected.edition="unbound"
   game.f.move_penalty+=2
  "overexposure":
   if selected.get("edition","")=="oversaturated" or game.max_hp<=1 or game.board_id=="eclipse": return false
   # An Unbound relic becoming Oversaturated needs a normal slot.
   if selected.get("edition","")=="unbound" and Rules.bound_count(game)>=game.max_relics(): return false
   selected.edition="oversaturated"
   game.max_hp-=1
   game.hp=mini(game.hp,game.max_hp)
  "erosion":
   if game.relics.is_empty(): return false
   game.relics.remove_at(int(game.rng.pick(range(game.relics.size()))))
   game.f.extra_slots+=1
  "rebirth":
   var rarity: String = Cat.RELICS[selected.id].rarity
   var pool: Array = game._eligible_relics().filter(func(item): return Cat.RELICS[item].rarity==rarity and item!=selected.id)
   if pool.is_empty(): return false
   var replacement: String = game.rng.pick(pool)
   var tags: Dictionary = {}
   for key in ["edition","cursed","echoed","echo_passes","perishable_clears"]:
    if selected.has(key): tags[key]=selected[key]
   game.relics.remove_at(target)
   game._grant(replacement,tags)
  "schism":
   if game.relics.size()<3: return false
   var others: Array = range(game.relics.size())
   others.erase(target)
   var destroy: Array = []
   for count in range(2):
    var index: int = game.rng.pick(others)
    destroy.append(index)
    others.erase(index)
   var copy: Dictionary = selected.duplicate(true)
   Rules.attach(game,copy,copy)
   destroy.sort()
   destroy.reverse()
   for index in destroy: game.relics.remove_at(index)
   game.relics.append(copy)
  "transmutation":
   if game.relics.size()<2 or not game.relics.any(func(r): return r.has("edition")): return false
   var editions: Array = game.relics.map(func(r): return r.get("edition",""))
   for relic in game.relics:
    var edition: String = game.rng.pick(editions)
    editions.erase(edition)
    if edition=="": relic.erase("edition")
    else: relic.edition=edition
  "genesis":
   if tiles.size()<3 or Rules.free_cells(game).is_empty(): return false
   var copy: Dictionary = game.cells[target].duplicate(true)
   tiles.erase(target)
   var destroy: Array = []
   for count in range(2):
    var index: int = game.rng.pick(tiles)
    destroy.append(index)
    tiles.erase(index)
   Rules.copy_tile(game,copy)
   for index in destroy: game.cells[index]=null
  "collapse":
   if tiles.is_empty(): return false
   tiles.sort_custom(func(a,b): return game.cells[a].e>game.cells[b].e or (game.cells[a].e==game.cells[b].e and a<b))
   for offset in range(tiles.size()):
    if offset<3: game.cells[tiles[offset]].seal=true
    else: game.cells[tiles[offset]]=null
  "transference":
   var fx: Dictionary = game.cells[target].fx
   var sealed: bool = bool(game.cells[target].seal)
   for index in tiles:
    if index==target: continue
    fx.merge(game.cells[index].fx,true)
    sealed=sealed or bool(game.cells[index].seal)
    game.cells[index].fx={}
    game.cells[index].seal=false
   game.cells[target].fx=fx
   game.cells[target].seal=sealed
  "pandemonium":
   if game.hp<=1 or tiles.is_empty(): return false
   var empty_and_tiles: Array = range(16)
   empty_and_tiles.erase(int(game.f.block))
   var contents: Array = []
   for index in empty_and_tiles: contents.append(game.cells[index])
   for index in empty_and_tiles:
    var pick: int = int(game.rng.pick(range(contents.size())))
    var tile = contents[pick]
    contents.remove_at(pick)
    if tile!=null: tile.fx[game.rng.pick(["gold","glass","steel"])]=true
    game.cells[index]=tile
   game.hp-=1
  "monoculture":
   if tiles.is_empty(): return false
   var minimum: int = game.cells[tiles[0]].e
   for index in tiles: minimum=mini(minimum,int(game.cells[index].e))
   for index in tiles:
    game.cells[index].e=minimum
    game.cells[index].fx.glass=true
    game.cells[index].seal=true
  "liquidation":
   if tiles.size()<4: return false
   for count in range(4):
    var index: int = game.rng.pick(tiles)
    game.cells[index]=null
    tiles.erase(index)
   game.earn(25)
  "overdraft":
   game.f.extra_slots+=2
   game.money=Num.new()
   game.f.no_interest+=3
  "asceticism":
   for key in game.rune_levels: game.rune_levels[key]+=1
   game.rune_uses+=5
   for index in tiles:
    if not game.cells[index].fx.is_empty() or game.cells[index].seal: game.cells[index]=null
    elif game.cells[index].e<game.spawn_min(): game.cells[index].e=game.spawn_min()
   game.next_tile=game.roll_tile()
  "sovereign":
   var pool: Array = game._eligible_relics().filter(func(item): return Cat.RELICS[item].rarity=="Legendary")
   if pool.is_empty() or Rules.bound_count(game)>=game.max_relics(): return false
   game._grant(game.rng.pick(pool))
  _: return false
 return true

static func choose_nomad(game, id: String) -> bool:
 if game.phase!="gates" or not game.f.nomad_choices.has(id) or not game._grant(id): return false
 game.f.nomad_choices=[]
 game.save_run()
 return true

static func exchange_nomad(game, index: int) -> bool:
 if game.phase!="gates" or game.board_id!="nomad" or not game.f.nomad_trade or not valid_relic(game,index): return false
 var old: Dictionary = game.relics[index]
 var pool: Array = game._eligible_relics().filter(func(id): return Cat.RELICS[id].rarity==Cat.RELICS[old.id].rarity and id!=old.id)
 if pool.is_empty(): return false
 var id: String = game.rng.pick(pool)
 var tags: Dictionary = {}
 for key in ["edition","cursed","echoed","echo_passes","perishable_clears"]:
  if old.has(key): tags[key]=old[key]
 game.relics.remove_at(index)
 game._grant(id,tags)
 game.f.nomad_trade=false
 game.save_run()
 return true

static func rewind(game) -> bool:
 if not Rules.can_rewind(game): return false
 var used: int = int(game.f.paradox_used)
 var state = JSON.parse_string(str(game.f.rewind.get("json","")))
 if state is not Dictionary: return false
 var rng_after: int = game.rng.state
 if not game.restore(state): return false
 game.f.rewind={}
 game.f.paradox_used=used+1
 game.rng.state=rng_after
 game.next_tile=game.roll_tile()
 game.f.notice="Paradox / swipe rewound"
 game.save_run()
 return true

static func workshop(game, action: String, index: int = -1, other: int = -1, choice: String = "", amount: int = 0) -> bool:
 if action=="rewind": return rewind(game)
 if game.phase not in ["shop","gates","reward"] and not (action=="chrysalis" and game.phase=="play"): return false
 match action:
  "borrow":
   if not game.has_relic("loan_shark") or game.f.floor.get("loan",false) or amount<=0 or amount>int(50*Rules.amount(game,"loan_shark")): return false
   game.f.floor.loan=true
   game.f.debt=Num.of(game.f.debt).plus(amount)
   game.money=game.money.plus(amount)
  "repay":
   var due = Num.of(game.f.debt).times(1.5)
   if due.m==0 or game.money.cmp(due)<0: return false
   game.money=game.money.minus(due)
   game.f.debt=Num.new()
  "invest":
   if not game.has_relic("risky_investment") or game.gate!=2 or game.phase!="gates" or Num.of(game.f.investment).m>0: return false
   var value = game.money.div(2).floored()
   if value.m==0: return false
   game.money=game.money.minus(value)
   game.f.investment=value
  "wager":
   var limit: int = 30 if game.has_upgrade("wagers2") else 10 if game.has_upgrade("wagers1") else 0
   if game.phase!="gates" or amount<=0 or amount>limit or Num.of(game.f.wager).m>0 or game.money.cmp(amount)<0: return false
   game.money=game.money.minus(amount)
   game.f.wager=Num.of(amount)
   game.f.wager_hp=game.hp
  "guillotine":
   if int(game.f.pending.get("guillotine",0))<=0 or not game.has_relic("guillotine"): return false
   var tiles: Array = Rules.occupied(game)
   if tiles.is_empty(): return false
   tiles.sort_custom(func(a,b): return game.cells[a].e>game.cells[b].e)
   game.cells[tiles[0]]=null
   var relic: Dictionary = Rules.actor(game,"guillotine")
   relic.growth=Num.of(relic.growth).times(1.8*Rules.power(relic))
   game.f.pending.guillotine-=1
  "devour":
   if int(game.f.pending.get("devourer",0))<=0 or not valid_relic(game,index) or game.relics[index].id not in Rules.COPIABLE: return false
   var consumers: Array = game.relics.filter(func(r): return r.id=="devourer" and r.get("abilities",[]).size()<int(ceil(2*Rules.power(r))))
   if consumers.is_empty(): return false
   var relic: Dictionary = consumers[0]
   if not relic.has("abilities"): relic.abilities=[]
   relic.abilities.append(game.relics[index].duplicate(true))
   game.relics.remove_at(index)
   game.f.pending.devourer-=1
  "echo":
   if int(game.f.pending.get("crown_echoes",0))<=0 or not valid_relic(game,index) or game.relics[index].get("echoed",false) or game.relics[index].id not in Rules.SCORING: return false
   game.relics[index].echoed=true
   game.relics[index].echo_passes=maxi(2,int(ceil(2*game.relics.filter(func(r): return r.id=="crown_echoes").reduce(func(value,r): return maxf(value,Rules.power(r)),1.0))))
   game.f.pending.crown_echoes-=1
  "duplicate":
   if int(game.f.pending.get("satchel",0))<=0 or index<0 or index>=game.inventory.size(): return false
   if not Market.add_item(game,game.inventory[index],Market.item_tags(game,index)): return false
   game.f.pending.satchel-=1
  "chrysalis":
   if not game.has_relic("chrysalis") or index<0 or index>=16 or game.cells[index]==null or not game.cells[index].fx.is_empty() or game.cells[index].seal or game.cells[index].has("chrysalis"): return false
   game.cells[index].chrysalis=0
   game.cells[index].chrysalis_goal=maxi(1,int(ceil(3/Rules.amount(game,"chrysalis"))))
  "fusion_spell","fusion_rune","fusion_double":
   var req: String = "fusion1" if action=="fusion_spell" else "fusion2" if action=="fusion_rune" else "fusion3"
   if not game.has_upgrade(req) or index==other or index<0 or other<0 or index>=game.inventory.size() or other>=game.inventory.size(): return false
   var pool: Dictionary = Cat.SPELLS if action=="fusion_spell" else Cat.RUNES
   if not pool.has(game.inventory[index]) or not pool.has(game.inventory[other]): return false
   if action!="fusion_spell" and not Cat.RUNES.has(choice): return false
   var output: String = game.rng.pick(Cat.SPELLS.keys()) if action=="fusion_spell" else choice
   Market.remove_item(game,maxi(index,other))
   Market.remove_item(game,mini(index,other))
   Market.add_item(game,output,{"double":true} if action=="fusion_double" else {})
  _: return false
 if game.filled()==0: game.spawn()
 game.jammed=game.phase=="play" and not game.can_slide()
 game.save_run()
 return true

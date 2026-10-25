extends RefCounted
## Run-state hooks. Presentation never calls these methods to replay scoring.
const Cat = preload("res://scripts/catalog.gd")
const Num = preload("res://scripts/num.gd")
const SCORING = ["carbon","battery","corner","horizon","redline","odd","magnet","avalanche","steelworks","charity","apprentice","monolith","compound","echo","mirror","ascension","domino","feedback","resonance","singularity","leech","guillotine","ghostwriter","conductor","devourer","mobius"]
const COPIABLE = ["carbon","battery","corner","horizon","redline","odd","magnet","avalanche","steelworks","charity","apprentice","monolith","compound","echo","mirror","ascension","domino","feedback","resonance","singularity","leech","guillotine","ghostwriter"]

static func defaults(mode: String = "normal") -> Dictionary:
 return {"difficulty":mode,"curse":2 if mode=="cursed" else 0,"serial":0,"extra_slots":0,"move_penalty":0,"no_interest":0,"gate":{},"floor":{},"merges":0,"spawns":0,"block":-1,"last_used":"","last_used_tags":{},"phantoms":[],"reserve":[],"item_tags":{},"pack_offers":[],"pack_tags":{},"pack_remaining":0,"pack_type":"standard","pack_size":"Standard","offer_tags":{},"floor_choices":[],"locked_offer":"","stowed":{},"nomad_choices":[],"nomad_trade":false,"debt":Num.new(),"wager":Num.new(),"wager_hp":0,"investment":Num.new(),"pending":{},"rewind":{},"paradox_used":false,"notice":""}

static func power(relic: Dictionary) -> float:
 return (2.0 if relic.get("edition","")=="oversaturated" else 1.0)*(1.5 if relic.get("cursed",false) else 1.0)

static func actor(game, id: String) -> Dictionary:
 for relic in game.relics:
  if relic.id==id: return relic
 return {}

static func amount(game, id: String) -> float:
 var found: Dictionary = actor(game,id)
 return power(found) if not found.is_empty() else 0.0

static func attach(game, relic: Dictionary, tags: Dictionary = {}) -> void:
 game.f.serial+=1
 relic.uid=game.f.serial
 for key in ["edition","cursed","echoed"]:
  if tags.has(key): relic[key]=tags[key]
 if relic.get("cursed",false) and game.f.difficulty=="cursed": game.f.curse+=2

static func bound_count(game) -> int:
 return game.relics.filter(func(r): return r.get("edition","")!="unbound").size()

static func setup(game) -> void:
 if game.b().get("no_carbon",false): game.relics.clear()
 if game.b().get("oversaturated_start",false):
  var compound: Dictionary = actor(game,"compound")
  if not compound.is_empty(): compound.edition="oversaturated"
 for relic in game.relics:
  if not relic.has("uid"): attach(game,relic)
 if game.board_id=="nomad":
  var pool: Array = game._eligible_relics().filter(func(id): return Cat.RELICS[id].rarity in ["Common","Uncommon"])
  for index in range(3):
   if pool.is_empty(): break
   var id: String = game.rng.pick(pool)
   game.f.nomad_choices.append(id)
   pool.erase(id)
 prepare_gate(game)

static func prepare_gate(game) -> void:
 game.f.gate={}
 game.f.paradox_used=false
 game.f.rewind={}
 if game.board_id=="labyrinth": relocate_block(game)
 if game.board_id=="eclipse":
  game.max_hp=1
  game.hp=mini(game.hp,1)
  var gold: bool = (game.floor_num*3+game.gate)%2==1
  game.next_tile.fx.erase("glass" if gold else "gold")
  game.next_tile.fx["gold" if gold else "glass"]=true

static func relocate_block(game) -> void:
 var free: Array = []
 for index in range(16):
  if game.cells[index]==null: free.append(index)
 if free.is_empty(): return
 var pool: Array = free.filter(func(index): return index!=game.f.block)
 game.f.block=int(game.rng.pick(pool if not pool.is_empty() else free))

static func before_move(game) -> void:
 game.f.notice=""
 if game.has_relic("paradox") and not game.f.paradox_used:
  game.f.rewind={}
  game.f.rewind={"json":game.export_run()}

static func after_spawn(game, index: int) -> void:
 game.f.spawns+=1
 var tile: Dictionary = game.cells[index]
 if game.board_id=="twinfall" and int(game.f.spawns)%6==0:
  copy_tile(game,tile)
  game.f.notice="Twinfall / second arrival"
 if game.has_relic("double_exposure") and not game.f.gate.get("exposure",false) and tile.fx.size()>=2 and tile.e>1:
  if copy_tile(game,game.tile(int(tile.e)-1))>=0:
   game.f.gate.exposure=true
   game.f.notice="Double Exposure / plain copy"

static func free_cells(game) -> Array:
 var free: Array = []
 for index in range(16):
  if game.cells[index]==null and index!=int(game.f.block): free.append(index)
 return free

static func occupied(game) -> Array:
 var found: Array = []
 for index in range(16):
  if game.cells[index]!=null: found.append(index)
 return found

static func copy_tile(game, tile: Dictionary) -> int:
 var free: Array = free_cells(game)
 if free.is_empty(): return -1
 var index: int = game.rng.pick(free)
 game.cells[index]=tile.duplicate(true)
 return index

static func adjacent(index: int) -> Array:
 var list: Array = []
 if index%4>0: list.append(index-1)
 if index%4<3: list.append(index+1)
 if index>=4: list.append(index-4)
 if index<12: list.append(index+4)
 return list

static func neighbor(game, index: int) -> int:
 var list: Array = adjacent(index).filter(func(i): return game.cells[i]!=null)
 return int(game.rng.pick(list)) if not list.is_empty() else -1

static func inherit_mark(merged: Dictionary, a: Dictionary, b: Dictionary) -> void:
 if a.has("chrysalis") or b.has("chrysalis"):
  var count: int = maxi(int(a.get("chrysalis",0)),int(b.get("chrysalis",0)))+1
  if count>=3:
   merged.fx={"gold":true,"glass":true,"steel":true}
   merged.seal=true
  else: merged.chrysalis=count

static func sequence(game, reverse: bool = false) -> Array:
 var result: Array = []
 var indices: Array = range(game.relics.size())
 if reverse: indices.reverse()
 for index in indices:
  var relic: Dictionary = game.relics[index]
  var effects: Array = [relic]
  if relic.id=="conductor":
   effects=[]
   if index+1<game.relics.size() and game.relics[index+1].id in COPIABLE: effects.append(game.relics[index+1])
  elif relic.id=="devourer": effects=relic.get("abilities",[])
  for effect in effects:
   var boost: float = power(relic)*(power(effect) if effect!=relic else 1.0)
   result.append({"relic":effect,"actor":relic,"slot":index,"only_score":reverse or relic.id=="conductor","boost":boost})
   if relic.get("echoed",false): result.append({"relic":effect,"actor":relic,"slot":index,"only_score":true,"boost":boost})
 return result

static func on_merge(game, event: Dictionary, preview: bool = false) -> Array:
 var cues: Array = []
 var tile: Dictionary = event.tile
 game.f.merges+=1
 for relic in game.relics:
  var boost: float = power(relic)
  var note := ""
  match relic.id:
   "leech":
    for key in ["glass","steel","gold"]:
     if tile.fx.get(key,false):
      tile.fx.erase(key)
      relic.growth=Num.of(relic.growth).times(1.15*boost)
      note="Growth x"+str(snappedf(1.15*boost,.001))
      break
   "cuckoo_clock":
    relic.carry=int(relic.carry)+1
    if int(relic.carry)%7==0 and int(game.f.gate.get("clock",0))<2:
     game.f.gate.clock=int(game.f.gate.get("clock",0))+1
     game.moves+=int(boost)
     note="+%d move" % int(boost)
   "copper_coil":
    if not preview and tile.fx.get("steel",false) and not game.f.gate.get("coil",false):
     var target: int = neighbor(game,event.index)
     if target>=0:
      game.cells[target].fx.steel=true
      game.f.gate.coil=true
      note="Steel spread"
   "spore_cloud":
    if not preview and not tile.fx.is_empty():
     var neighbors: Array = adjacent(event.index).filter(func(i): return game.cells[i]!=null)
     if not neighbors.is_empty() and game.rng.randf()<minf(1,.2*boost):
      game.cells[game.rng.pick(neighbors)].fx.merge(tile.fx,true)
      note="Enhancements copied"
   "red_thread":
    if tile.seal and not game.f.gate.get("red_thread",false):
     game.next_tile.seal=true
     game.f.gate.red_thread=true
     note="Next: sealed"
   "clone_vat":
    if not preview and tile.e>=10 and not game.f.gate.get("clone",false):
     if copy_tile(game,game.tile(int(tile.e)))>=0:
      game.f.gate.clone=true
      note="Plain copy"
  if not note.is_empty(): cues.append({"id":relic.id,"slot":game.relics.find(relic),"text":note})
 return cues

static func prevent_shatter(game, tile: Dictionary) -> bool:
 var limit: int = 2 if game.has_upgrade("shatterproof2") else 1 if game.has_upgrade("shatterproof1") else 0
 var count: int = int(game.f.gate.get("saved_glass",0))
 if count>=limit: return false
 game.f.gate.saved_glass=count+1
 if game.has_upgrade("shatterproof3"): tile.fx.gold=true
 return true

static func on_shatter(game, event: Dictionary) -> Array:
 var cues: Array = []
 for relic in game.relics:
  var boost: float = power(relic)
  var note := ""
  match relic.id:
   "matchbox":
    if not game.f.gate.get("matchbox",false):
     game.next_tile.fx.gold=true
     game.next_tile.fx.glass=true
     game.f.gate.matchbox=true
     note="Next: Gold + Glass"
   "spare_change":
    if event.tile.fx.get("gold",false):
     var paid = game.earn(5*boost)
     note="+$"+paid.fmt()
   "seedling":
    var count: int = int(game.f.gate.get("seedling",0))
    if count<int(3*boost):
     game.next_tile.e+=1
     game.f.gate.seedling=count+1
     note="Next spawn +1 tier"
   "morgue":
    if event.tile.seal and not game.f.gate.get("morgue",false):
     var list: Array = occupied(game).filter(func(i): return not game.cells[i].seal)
     if not list.is_empty():
      game.cells[game.rng.pick(list)].seal=true
      game.f.gate.morgue=true
      note="Seal transferred"
   "chain_reaction":
    if int(game.f.gate.get("chain_reaction",0))<int(3*boost):
     var target: int = neighbor(game,event.index)
     if target>=0:
      game.cells[target].e+=1
      game.f.gate.chain_reaction=int(game.f.gate.get("chain_reaction",0))+1
      note="Adjacent +1 tier"
  if not note.is_empty(): cues.append({"id":relic.id,"slot":game.relics.find(relic),"text":note})
 return cues

static func after_move(game, events: Array) -> void:
 if events.is_empty() and game.has_relic("handbrake") and not game.f.gate.get("handbrake",false):
  game.moves+=int(amount(game,"handbrake"))
  game.f.gate.handbrake=true
  game.f.notice="Handbrake / move refunded"
 if game.board_id=="vortex" and game.swipes%4==0:
  var cells: Array = game.cells.duplicate(true)
  for index in range(16): game.cells[(index%4)*4+3-int(index/4.0)]=cells[index]
  game.f.notice="Vortex / clockwise turn"
 if game.board_id=="reactor" and not events.is_empty() and int(game.f.merges)/8>int((game.f.merges-events.size())/8):
  var list: Array = occupied(game)
  list.sort_custom(func(a,b): return game.cells[a].e<game.cells[b].e)
  if not list.is_empty():
   game.cells[list[0]].e+=1
   game.f.notice="Reactor / smallest tile +1 tier"
 if game.has_relic("shipping_crate") and not game.f.gate.get("shipping",false) and game.inventory.size()<game.max_pocket():
  var values: Array = []
  for tile in game.cells:
   if tile!=null and not values.has(tile.e): values.append(tile.e)
  if values.size()>=4:
   game._grant(game.rng.pick(Cat.SPELLS.keys()))
   game.f.gate.shipping=true
   game.f.notice="Shipping Crate / Spell received"

static func growth_after_win(game) -> void:
 for relic in game.relics:
  var abilities: Array = relic.get("abilities",[])
  for effect in abilities:
   if effect.id=="compound": effect.growth=Num.of(effect.growth).times(1.25*power(relic))

static func after_result(game, win: bool) -> void:
 game.f.phantoms=[]
 if win and int(game.f.no_interest)>0: game.f.no_interest-=1
 if game.gate==2:
  if game.f.difficulty=="cursed": game.f.curse+=1
  var debt = Num.of(game.f.debt)
  if debt.m>0:
   var due = debt.times(1.5)
   if game.money.cmp(due)>=0: game.money=game.money.minus(due)
   else: game.hp-=1
   game.f.debt=Num.new()
  var investment = Num.of(game.f.investment)
  if win and investment.m>0: game.earn(investment.times(3))
  game.f.investment=Num.new()
  if win:
   for id in ["guillotine","devourer","crown_echoes"]:
    if game.has_relic(id): game.f.pending[id]=int(game.f.pending.get(id,0))+game.relics.filter(func(r): return r.id==id).size()
   if game.has_upgrade("satchel3") and int(game.cleared/3.0)%3==0: game.f.pending.satchel=int(game.f.pending.get("satchel",0))+1
 var wager = Num.of(game.f.wager)
 if win and game.hp>=int(game.f.wager_hp) and wager.m>0: game.earn(wager.times(3 if game.gate==2 and game.has_upgrade("wagers3") else 2))
 game.f.wager=Num.new()
 if game.hp<=0: game.phase="over"

static func after_shop(game, previous_floor: int) -> void:
 if game.floor_num!=previous_floor:
  game.f.floor={}
  if game.board_id=="nomad": game.f.nomad_trade=true
 if game.has_relic("perpetuum") and not str(game.f.last_used).is_empty():
  for index in range(int(amount(game,"perpetuum"))): game.f.phantoms.append({"id":game.f.last_used,"tags":game.f.last_used_tags.duplicate(true)})
 prepare_gate(game)

static func current_factor(game, relic: Dictionary):
 var id: String = relic.id
 var value = Num.new(1)
 if id in ["monolith","compound","leech","guillotine","ghostwriter"]: value=Num.of(relic.growth)
 elif id=="charity": value=game.money.div(10).floored().plus(1)
 elif id=="apprentice": value=Num.of(1+game.rune_uses*.25)
 elif id in ["corner","horizon","odd","echo"]: value=Num.new(2)
 elif id in ["redline","magnet","mirror","ascension"]: value=Num.new(3)
 elif id=="steelworks": value=Num.power(1.2,game.cells.filter(func(t): return t!=null and t.fx.get("steel",false)).size())
 return value.times(power(relic)) if power(relic)!=1 else value

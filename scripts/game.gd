extends RefCounted
const Cat = preload("res://scripts/catalog.gd")
const Num = preload("res://scripts/num.gd")
const TriggerCount = preload("res://scripts/trigger_count.gd")
const RunRng = preload("res://scripts/run_rng.gd")
const Rules = preload("res://scripts/fracture_rules.gd")
const Market = preload("res://scripts/fracture_market.gd")
const Geometry = preload("res://scripts/grid_geometry.gd")
const Actions = preload("res://scripts/fracture_actions.gd")
const SAVE_PATH = "user://gatefold-godot-v1.json"
const PHASES = ["play","reward","failed","shop","gates","over"]
var rng = RunRng.new()
# Test harness only; imported old saves use the corrected production scorer.
var legacy_compat := false
var f: Dictionary = Rules.defaults()
var seed_text := ""
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
var money = Num.new(12)
var score = Num.new()
var total_score = Num.new()
var best_exp := 1
var cleared := 0
var failed := 0
var swipes := 0
var gate_swipes := 0
var last_dir := ""
var banked := 0
var phase := "home"
var result_text := ""
var result_summary := {}
var last_merge = Num.new()
var last_triggers = 0
var last_entries: Array = []
var fired_relics: Array = []
# Ephemeral presentation receipts; never serialized or replayed into the rules.
var last_score_steps: Array = []
var shop_offers: Array = []
var shop_upgrade := ""
var floor_upgrade := ""
var floor_upgrade_floor := 0
var floor_upgrade_bought := false
var shop_rerolls := 0
var shop_pack_bought := false
var pack_choices: Array = []
var shop_heal_bought := false
var next_tile: Dictionary = {}
var pending_outcome := true
var jammed := false
var endless := false
var persist_enabled := true
var storage_error := ""

func b() -> Dictionary:
 return Cat.board(board_id)

func guardian() -> Dictionary:
 return Cat.GUARDIANS[(floor_num-1)%Cat.GUARDIANS.size()]

func has_relic(id: String) -> bool:
 return relics.any(func(r): return r.id == id)

func has_upgrade(id: String) -> bool:
 return upgrades.has(id)

func max_relics() -> int:
 return 5+int(b().get("slots",0))+int(has_upgrade("slot1"))+int(has_upgrade("slot2"))+int(f.extra_slots)

func max_pocket() -> int:
 return 3+int(has_upgrade("pocket1"))+(2 if has_upgrade("satchel1") else 0)

func target(index: int = -1):
 if index<0 and phase in ["reward","failed","over"] and result_summary.has("target"): return Num.of(result_summary.target)
 var selected: int = gate if index<0 else index
 var value = Num.power(3,floor_num-1).times([96,160,256][selected]).times(b().get("target_mult",1))
 if not legacy_compat and floor_num>8:
  var depth: float = floor_num-8
  value=value.times(Num.power(2,depth*(depth+1)/2))
 if f.difficulty=="cursed": value=value.times(Num.power(1.15,f.curse))
 return value

func budget(index: int = -1, include_banked: bool = true) -> int:
 var selected: int = gate if index<0 else index
 var value: int = [18,17,16][selected]+int(b().get("moves",0))+(banked if include_banked else 0)+(6 if has_upgrade("moves2") else 3 if has_upgrade("moves1") else 0)-(3 if selected==2 and guardian().id=="short" else 0)-int(f.move_penalty)
 if f.difficulty=="cursed": value-=int(f.curse/5.0)
 return maxi(1,int(floor(value*float(b().get("move_mult",1)))))

func spawn_min() -> int:
 return 1+int(int(rune_levels.spawn)/2.0)

func tile(e: int, fx: Dictionary = {}, seal: bool = false) -> Dictionary:
 return {"e":e,"fx":fx.duplicate(true),"seal":seal}

func roll_tile() -> Dictionary:
 var chance: float = .10+.35*(int(rune_levels.spawn)%2)
 var exponent: int = spawn_min()+int(rng.randf()<chance)
 if has_relic("alchemy") and rng.randf()<minf(1,.25*Rules.amount(self,"alchemy")): exponent+=int(ceil(Rules.amount(self,"alchemy")))
 var fx := {}
 for key in ["gold","glass","steel"]:
  var chance_fx: float = 1.0-pow(.92,rune_levels[key])
  if board_id=="glasshouse" and key=="glass": chance_fx=maxf(chance_fx,.5)
  if board_id=="eclipse" and key==("gold" if (floor_num*3+gate)%2==1 else "glass"): chance_fx=1
  if rng.randf()<chance_fx: fx[key]=true
 return tile(exponent,fx,rng.randf()<1.0-pow(.94,rune_levels.seal))

func spawn() -> void:
 var free: Array = []
 for i in range(16):
  if cells[i]==null and i!=int(f.block): free.append(i)
 if free.is_empty(): return
 var index: int = rng.pick(free)
 cells[index] = next_tile.duplicate(true) if not next_tile.is_empty() else roll_tile()
 if not legacy_compat: Rules.after_spawn(self,index)
 next_tile = roll_tile()

func upgrade_allowed(id: String) -> bool:
 return not id.begins_with("auto") or board_id=="robot" or floor_num>=3

func can_grant(id: String, tags: Dictionary = {}) -> bool:
 if Cat.RELICS.has(id):
  var actual: Dictionary = tags if not tags.is_empty() else Market.tags_for(self,id)
  return not has_relic(id) and (actual.get("edition","")=="unbound" or Rules.bound_count(self)<max_relics())
 if Cat.SPELLS.has(id) or Cat.RUNES.has(id) or Cat.FRACTURES.has(id): return inventory.size()<max_pocket()
 if Cat.UPGRADES.has(id):
  if board_id=="eclipse" and id=="heart1": return false
  var requirement = Cat.UPGRADES[id].get("req")
  return not has_upgrade(id) and upgrade_allowed(id) and (requirement==null or has_upgrade(requirement))
 return false

func _grant(id: String, tags: Dictionary = {}) -> bool:
 if not can_grant(id,tags): return false
 if Cat.RELICS.has(id):
  var relic: Dictionary = {"id":id,"growth":Num.new(1),"charge":0.0,"carry":0}
  if tags.get("edition","")!="unbound" and Rules.bound_count(self)>=max_relics(): return false
  Rules.attach(self,relic,tags)
  relics.append(relic)
  if id=="alchemy": next_tile=roll_tile()
 elif Cat.SPELLS.has(id) or Cat.RUNES.has(id) or Cat.FRACTURES.has(id): inventory.append(id)
 else:
  upgrades.append(id)
  if id=="heart1":
   max_hp+=1
   hp+=1
 return true

func new_run(id: String = "classic", run_seed: String = "", difficulty: String = "normal") -> void:
 f=Rules.defaults(difficulty if difficulty in ["normal","cursed"] else "normal")
 floor_upgrade=""
 floor_upgrade_floor=0
 floor_upgrade_bought=false
 board_id = Cat.board(id).id
 var raw_seed: String = run_seed if not run_seed.is_empty() else "%X" % Time.get_ticks_usec()
 seed_text = raw_seed.to_upper()
 rng.state = RunRng.seed_hash(raw_seed)
 cells = []
 cells.resize(16)
 cells.fill(null)
 relics = [{"id":"carbon","growth":Num.new(1),"charge":0.0,"carry":0}]
 inventory = []
 upgrades = []
 rune_levels = {"spawn":0,"gold":0,"glass":0,"steel":0,"seal":0}
 rune_uses = 0
 floor_num = 1
 gate = 0
 max_hp = int(b().get("max_hp",3))
 hp = max_hp
 money = Num.of(b().get("start_money",12))
 score = Num.new()
 total_score = Num.new()
 last_merge = Num.new()
 last_triggers = 0
 last_entries = []
 fired_relics = []
 last_score_steps = []
 cleared = 0
 failed = 0
 swipes = 0
 gate_swipes = 0
 last_dir = ""
 banked = 0
 jammed = false
 endless = false
 pending_outcome = true
 phase = "play"
 result_text = ""
 result_summary = {}
 for key in b().get("runes",{}):
  rune_levels[key] = b().runes[key]
  rune_uses += int(b().runes[key])
 best_exp = spawn_min()
 cells[12] = tile(best_exp,b().get("start_fx",{}),b().get("start_seal",false))
 cells[13] = cells[12].duplicate(true)
 next_tile = roll_tile()
 for starting_id in b().get("relics",[])+b().get("upgrades",[])+b().get("items",[]): _grant(starting_id)
 for relic in relics:
  relic.charge = float(b().get("charges",{}).get(relic.id,0))
 if not legacy_compat: Rules.setup(self)
 moves = budget()
 _clear_shop()
 save_run()

func slide(direction: String, source: Array = []) -> Dictionary:
 var input: Array = cells if source.is_empty() else source
 if direction not in ["left","right","up","down"] or input.size()!=16:
  return {"board":input.duplicate(true),"events":[],"changed":false}
 var out: Array = []
 out.resize(16)
 out.fill(null)
 var events: Array = []
 var changed := false
 for positions in Geometry.lines(direction,int(f.block)):
  var src: Array = []
  for index in positions:
   if input[index]!=null: src.append({"tile":input[index],"from":index})
  var k := 0
  var w := 0
  while k<src.size():
   var a: Dictionary = src[k]
   var dest: int = positions[w]
   if k+1<src.size() and a.tile.e==src[k+1].tile.e:
    var other: Dictionary = src[k+1].tile
    var merged: Dictionary = tile(int(a.tile.e)+1,a.tile.fx,a.tile.seal or other.seal)
    merged.fx.merge(other.fx,true)
    Rules.inherit_mark(merged,a.tile,other)
    out[dest] = merged
    events.append({"tile":merged,"index":dest})
    changed = true
    k+=2
   else:
    out[dest]=a.tile.duplicate(true)
    if a.from!=dest: changed=true
    k+=1
   w+=1
 return {"board":out,"events":events,"changed":changed}

func is_corner(index: int) -> bool:
 return index in [0,3,12,15]

func earn(base):
 var value = Num.of(base).times(2 if has_upgrade("trade3") else 1)
 money = money.plus(value)
 return value

func score_merges(events: Array, previous_highest: int, preview: bool = false, capture_steps: bool = false) -> Dictionary:
 var record: bool = capture_steps and not preview
 var steps: Array = []
 var full = Num.new()
 var income = Num.new()
 var trigger_count = TriggerCount.new()
 var steel_count := 0
 var max_e := 0
 var chain_pos = TriggerCount.new()
 var fired: Array = []
 var entries: Array = []
 var reverse_chain: bool = has_relic("mobius") and int(self.f.gate.get("mobius",0))<int(ceil(Rules.amount(self,"mobius"))) and not events.is_empty()
 for cell in cells:
  if cell!=null and cell.fx.get("steel",false): steel_count+=1
 for event in events: max_e=maxi(max_e,int(event.tile.e))
 if events.is_empty():
  for entry in Rules.physical_effects(self):
   var relic: Dictionary = entry.relic
   if relic.id=="battery":
    relic.charge+=12.0
    fired.append(entry.actor.id)
    if record: steps.append({"kind":"relic","id":entry.actor.id,"slot":entry.slot,"value":full,"text":"+%s stored" % _factor_text(12*entry.boost)})
  return {"score":full,"triggers":0,"money":income,"entries":entries,"fired":fired,"steps":steps}
 for ei in range(events.size()):
  var event: Dictionary = events[ei]
  var t: Dictionary = event.tile
  var eligible: bool = not (gate==2 and guardian().id=="largest" and t.e!=max_e)
  if t.fx.get("gold",false):
   income=income.plus(earn(4*Rules.amount(self,"greed") if has_relic("greed") else 2))
   if has_relic("greed"):
    fired.append("greed")
    if record: steps.append({"kind":"relic","id":"greed","value":Num.new(),"text":"+$%d Gold" % int(4*Rules.amount(self,"greed")*(2 if has_upgrade("trade3") else 1))})
  var points = Num.new()
  var event_triggers = TriggerCount.new()
  for pass_index in range(2 if t.seal else 1):
   var value = Num.power(2,t.e).times(Num.power(1.25,steel_count)).times(2 if t.fx.get("glass",false) else 1)
   var repeats = TriggerCount.new(1)
   if record: steps.append({"kind":"merge","index":event.index,"value":value if eligible else Num.new(),"text":"Seal retrigger" if pass_index>0 else "Merge %d / %d" % [ei+1,events.size()]})
   var applications: Array = Rules.sequence(self)
   if reverse_chain: applications.append_array(Rules.sequence(self,true))
   for application in applications:
    var relic: Dictionary = application.relic
    var physical: Dictionary = application.actor
    var boost: float = float(application.boost)
    var only_score: bool = bool(application.only_score)
    var id: String = relic.id
    var fired_before: int = fired.size()
    var repeats_before = repeats.copy()
    var scoring_repeats = TriggerCount.new(1) if legacy_compat else repeats_before
    var income_before = income
    var value_before = value
    var operation := ""
    var operand = Num.new()
    if id=="business" and not only_score and pass_index==0 and t.e<=3:
     income=income.plus(earn(boost))
     fired.append(physical.id)
    if id=="monolith" and not only_score and pass_index==0 and t.e>=previous_highest:
     relic.growth=Num.of(relic.growth).times(1.15*boost)
     fired.append(physical.id)
    if not eligible:
     if record and fired.size()>fired_before:
      steps.append({"kind":"relic","id":physical.id,"slot":application.slot,"value":Num.new(),"text":"Growth x"+_factor_text(1.15*boost) if id=="monolith" else "+$"+income.minus(income_before).fmt()})
     continue
    var factor = null
    match id:
     "carbon":
      operation="add"; operand=Num.of(8*boost)
      value=value.plus(operand.times(scoring_repeats.number())); fired.append(physical.id)
     "battery":
      if float(relic.charge)>0:
       operation="add"; operand=Num.of(float(relic.charge)*boost)
       value=value.plus(operand.times(scoring_repeats.number())); fired.append(physical.id)
     "corner":
      if is_corner(event.index): factor=2
     "horizon":
      if event.index>=12: factor=2
     "redline":
      if moves<=int(ceil(5*boost)): factor=3
     "odd":
      if int(t.e)%2==1: factor=2
     "magnet":
      if events.size()>=3: factor=3
     "avalanche":
      if ei>0: factor=pow(2,ei)
     "steelworks":
      if steel_count>0: factor=Num.power(1.2*boost,steel_count)
     "charity": factor=money.div(10).floored().plus(1)
     "apprentice": factor=1+rune_uses*.25
     "monolith","compound","leech","guillotine","ghostwriter": factor=relic.growth
     "echo": factor=2; repeats=repeats.times(maxi(1,int(2*boost)))
     "mirror":
      if ei==0: factor=3; repeats=repeats.times(maxi(1,int(3*boost)))
     "ascension":
      if t.e>=10: factor=3; repeats=repeats.times(maxi(1,int(3*boost)))
     "domino":
      if ei==events.size()-1 and events.size()>1:
       factor=pow(2*boost,events.size()-1)
       repeats=repeats.times(maxi(1,int(factor)))
     "feedback":
      # Every generated trigger also advances this counter. Exact integer
      # division keeps carries correct even beyond the native int range.
      var extra = repeats.plus(TriggerCount.new(int(relic.carry))).minus_one().div_small(4)
      extra=extra.times(int(roundf(boost*2))).div_small(2)
      var expanded = repeats.plus(extra)
      if not extra.digits.is_empty(): factor=expanded.number().div(repeats.number())
      repeats=expanded
      relic.carry=repeats.plus(TriggerCount.new(int(relic.carry))).mod_small(5)
     "resonance":
      # Product of the growing bonuses, rather than their old average.
      var n = repeats.number()
      var exponent = n.times(chain_pos.number().plus(1)).plus(n.times(repeats.minus_one().number()).div(2))
      factor=Num.power(1.12*boost,exponent)
      if legacy_compat:
       var rate: float = 1.12*boost
       factor=Num.power(rate,chain_pos.number().plus(1)).times(Num.power(rate,n).minus(1)).div(rate-1).div(n)
      chain_pos=chain_pos.plus(repeats)
     "singularity":
      operation="power"; operand=Num.of(1.2*boost)
      value=value.raised(Num.power(1.2*boost,scoring_repeats.number()))
      fired.append(physical.id)
    if factor!=null:
     if boost!=1 and id not in ["resonance","feedback","steelworks","domino"]: factor=Num.of(factor).times(boost)
     var applied_factor = Num.of(factor) if id in ["resonance","feedback"] else Num.of(factor).raised(scoring_repeats.number())
     if id not in ["resonance","feedback"]: operation="multiply"; operand=Num.of(factor)
     value=value.times(applied_factor)
     fired.append(physical.id)
    if record and fired.size()>fired_before:
     var note: String = "x"+_factor_text(factor) if factor!=null else "+"+_factor_text(8*boost) if id=="carbon" else "+"+_factor_text(float(relic.charge)*boost) if id=="battery" else "^"+_factor_text(1.2*boost) if id=="singularity" else "+$"+income.minus(income_before).fmt()
     steps.append({"kind":"relic","id":physical.id,"slot":application.slot,"index":event.index,"value":value,"text":note})
     steps[-1].operation=operation
     steps[-1].operand=operand
     steps[-1].before=value_before
     steps[-1].activations=repeats_before.scalar()
     steps[-1].activation_text=repeats_before.text()
     if repeats.number().cmp(repeats_before.number())>0:
      steps.append({"kind":"retrigger","id":physical.id,"slot":application.slot,"value":value,"activations":repeats.scalar(),"activation_text":repeats.text(),"text":repeats.text()+" triggers"})
   if eligible:
    points=points.plus(value)
    event_triggers=event_triggers.plus(repeats)
  if gate==2 and guardian().id=="quiet": points=points.times(.75)
  points=points.floored()
  full=full.plus(points)
  if record: steps.append({"kind":"bank","index":event.index,"value":points,"subtotal":full,"text":"Blocked by guardian" if not eligible else "Guardian x0.75" if gate==2 and guardian().id=="quiet" else "Merge scored"})
  trigger_count=trigger_count.plus(event_triggers)
  entries.append({"e":t.e,"index":event.index,"points":points,"triggers":event_triggers.scalar(),"muted":not eligible})
  if not legacy_compat:
   var cues: Array = Rules.on_merge(self,event,preview)
   if record:
    for cue in cues:
     cue.kind="relic"; cue.value=full; steps.append(cue)
  if not preview and t.fx.get("glass",false) and rng.randf()<float(b().get("shatter_chance",.25)):
   if Rules.prevent_shatter(self,t):
    if record: steps.append({"kind":"merge","index":event.index,"value":full,"text":"Shatterproof / saved"})
   else:
    cells[event.index]=null
    if not legacy_compat:
     var cues: Array = Rules.on_shatter(self,event)
     if record:
      for cue in cues:
       cue.kind="relic"; cue.value=full; steps.append(cue)
 for entry in Rules.physical_effects(self):
  if entry.relic.id=="battery": entry.relic.charge=0.0
 if reverse_chain: self.f.gate.mobius=int(self.f.gate.get("mobius",0))+1
 var ordered_fired: Array = []
 for relic in relics:
  if fired.has(relic.id): ordered_fired.append(relic.id)
 return {"score":full,"triggers":trigger_count.scalar(),"money":income,"entries":entries,"fired":ordered_fired,"steps":steps}

static func _factor_text(value) -> String:
 var n = Num.of(value)
 if n.e>=5: return n.fmt()
 var amount: float = snappedf(n.to_float(),.001)
 return str(int(amount)) if amount==floorf(amount) else str(amount)

func can_slide(source: Array = []) -> bool:
 for direction in ["left","right","up","down"]:
  if slide(direction,source).changed: return true
 return false

func highest(source: Array = []) -> int:
 var value := 0
 for cell in (cells if source.is_empty() else source):
  if cell!=null: value=maxi(value,int(cell.e))
 return value

func move(direction: String, capture_steps: bool = true) -> bool:
 if phase!="play" or jammed: return false
 var outcome: Dictionary = slide(direction)
 if not outcome.changed: return false
 if not legacy_compat: Rules.before_move(self)
 var previous_highest: int = highest()
 cells=outcome.board
 swipes+=1
 gate_swipes+=1
 var cost := 1
 if gate==2:
  if guardian().id=="repeat" and last_dir==direction: cost+=1
  if guardian().id=="toll" and gate_swipes%4==0: cost+=1
 last_dir=direction
 moves=maxi(0,moves-cost)
 var gain: Dictionary = score_merges(outcome.events,previous_highest,false,capture_steps)
 last_merge=gain.score
 last_triggers=gain.triggers
 last_entries=gain.entries
 fired_relics=gain.fired
 last_score_steps=gain.steps
 score=score.plus(gain.score)
 total_score=total_score.plus(gain.score)
 if not legacy_compat:
  Rules.after_move(self,outcome.events)
  if board_id=="vortex" and swipes%4==0:
   for step in last_score_steps:
    if step.has("index"): step.index=(int(step.index)%4)*4+3-int(step.index/4.0)
 best_exp=maxi(best_exp,highest())
 spawn()
 if not legacy_compat: Rules.after_arrival(self)
 if score.cmp(target())>=0: finish_gate(true)
 elif moves<=0: finish_gate(false)
 elif not can_slide():
  jammed=true
  result_text="Board locked. Use a Spell or take a hit."
 save_run()
 return true

func interest():
 if int(f.no_interest)>0 or b().get("no_gate_cash",false): return Num.new()
 var amount = money.div(5).floored().times(2 if has_upgrade("trade2") else 1)
 var cap: int = 20 if has_upgrade("trade2") else 10 if has_upgrade("trade1") else 5
 return Num.of(cap) if amount.cmp(cap)>0 else amount

func recover_board() -> void:
 var occupied: Array = []
 for index in range(16):
  if cells[index]!=null: occupied.append({"index":index,"e":cells[index].e})
 occupied.sort_custom(func(a,b): return a.e<b.e or (a.e==b.e and a.index<b.index))
 for index in range(mini(2,occupied.size())): cells[occupied[index].index]=null
 while filled()<2: spawn()

func finish_gate(win: bool) -> void:
 var completed_target = target()
 if phase!="play": return
 pending_outcome=win
 jammed=false
 var basic: int = [4,5,7][gate] if win else 0
 var efficiency: int = int(moves/3.0) if win and not b().get("no_efficiency",false) else 0
 var inc = interest() if win else Num.new()
 var bonus: int = int(b().get("money_gate",0))
 if b().get("no_gate_cash",false): basic=0; efficiency=0; bonus=0
 var gross = earn(Num.of(basic).plus(efficiency).plus(inc).plus(bonus))
 var fee: int = mini(int(b().get("maintenance",0)),floor_num)
 var paid_fee = Num.of(fee) if money.cmp(fee)>=0 else money
 money=money.minus(paid_fee)
 banked=mini(int(b().get("bank_limit",0)),moves) if win else 0
 result_summary={"base":basic,"efficiency":efficiency,"interest":inc,"board_bonus":bonus,"gross":gross,"fee":paid_fee,"banked":banked}
 if not legacy_compat: result_summary.target=completed_target
 if win:
  cleared+=1
  for relic in relics:
   if relic.id=="compound": relic.growth=Num.of(relic.growth).times(1.25*Rules.power(relic))
  phase="reward"
  result_text="GATE CLEARED · +$%s · fee $%s" % [gross.fmt(),paid_fee.fmt()]
 else:
  hp-=1
  failed+=1
  recover_board()
  phase="failed" if hp>0 else "over"
  result_text="Lost 1 Life. Two smallest tiles cleared."
 if not legacy_compat:
  if win: Rules.growth_after_win(self)
  Rules.after_result(self,win)
 save_run()

func filled() -> int:
 return cells.filter(func(c): return c!=null).size()

func _eligible_relics() -> Array:
 return (Cat.BASE_RELICS.keys() if legacy_compat else Cat.RELICS.keys()).filter(func(id): return not has_relic(id))

func _random_relic() -> String:
 var available: Array = _eligible_relics()
 var value: float = rng.randf()
 var rarity: String = "Common" if value<.6 else "Uncommon" if value<.92 else "Rare" if legacy_compat or value<.99 else "Legendary"
 var tier: Array = available.filter(func(id): return (Cat.BASE_RELICS[id].rarity if legacy_compat else Cat.RELICS[id].rarity)==rarity)
 var result = rng.pick(tier if not tier.is_empty() else available)
 return result if result!=null else ""

func _eligible_upgrades() -> Array:
 return (Cat.BASE_UPGRADES.keys() if legacy_compat else Cat.UPGRADES.keys()).filter(func(id): return can_grant(id))

func _make_offers() -> void:
 var first: String = _random_relic()
 var second: String = _random_relic()
 if first!="" and second==first:
  var replacement = rng.pick(_eligible_relics().filter(func(id): return id!=first))
  if replacement!=null: second=replacement
 shop_offers=[first,second,rng.pick(Cat.SPELLS.keys()),rng.pick(Cat.RUNES.keys())]
 if not legacy_compat:
  if has_upgrade("storefront1"):
   var extra: Array = _eligible_relics().filter(func(id): return not shop_offers.has(id))
   if not extra.is_empty(): shop_offers.append(rng.pick(extra))
  Market.tag_offers(self)

func _make_shop() -> void:
 if floor_upgrade_floor==floor_num:
  shop_upgrade="" if floor_upgrade_bought else floor_upgrade
  _make_offers()
  return
 var pool: Array = _eligible_upgrades()
 var selected = rng.pick(pool)
 var higher: Array = pool.filter(func(id): return Cat.UPGRADES[id].get("req")!=null)
 if not higher.is_empty() and rng.randf()<.65: selected=rng.pick(higher)
 shop_upgrade=selected if selected!=null else ""
 floor_upgrade=shop_upgrade
 f.floor_choices=[shop_upgrade] if shop_upgrade!="" else []
 if not legacy_compat and has_upgrade("storefront3"):
  var alternatives: Array = pool.filter(func(id): return id!=shop_upgrade)
  if not alternatives.is_empty(): f.floor_choices.append(rng.pick(alternatives))
 floor_upgrade_floor=floor_num
 floor_upgrade_bought=false
 _make_offers()

func _clear_shop() -> void:
 shop_offers=[]
 shop_upgrade=""
 shop_rerolls=0
 shop_pack_bought=false
 shop_heal_bought=false
 pack_choices=[]

func open_shop() -> void:
 if phase not in ["reward","failed"]: return
 if phase=="reward" and floor_num==8 and gate==2: endless=true
 phase="shop"
 _clear_shop()
 _make_shop()
 if not legacy_compat: Market.make_packs(self)
 save_run()

func price(base: int) -> int:
 return int(ceil(base*float(b().get("markup",1))*(.75 if has_upgrade("sale1") else 1)))

func cost_for(id: String) -> int:
 var base: int = int(Cat.data_for(id).get("cost",0))
 # Original requested restriction: automation costs 1.5x away from Robot.
 if id.begins_with("auto") and board_id!="robot": base=int(base*1.5)
 return price(base)

func buy_item(id: String) -> bool:
 if phase!="shop" or id=="" or (id!=shop_upgrade and not shop_offers.has(id)): return false
 var cost: int = cost_for(id)
 if money.cmp(cost)<0 or not _grant(id,Market.tags_for(self,id)): return false
 money=money.minus(cost)
 if id==shop_upgrade:
  shop_upgrade=""
  floor_upgrade_bought=true
 else: shop_offers[shop_offers.find(id)]=""
 if f.locked_offer==id: f.locked_offer=""
 if f.stowed.get("id","")==id: f.stowed={}
 else: f.stowed.erase(id)
 if id=="storefront1" and shop_offers.size()==4:
  var pool: Array = _eligible_relics().filter(func(item): return not shop_offers.has(item))
  if not pool.is_empty():
   var extra: String = rng.pick(pool)
   shop_offers.append(extra)
   f.offer_tags[extra]=Market.roll_tags(self)
 result_text="Purchased "+Cat.name_for(id)
 save_run()
 return true

func sell_relic(index: int) -> bool:
 if phase!="shop" or index<0 or index>=relics.size(): return false
 var sold: Dictionary = relics[index].duplicate(true)
 var factor = Rules.current_factor(self,sold)
 earn(sale_base(sold.id))
 relics.remove_at(index)
 if not legacy_compat: Rules.on_sale(self,sold,factor)
 save_run()
 return true

func sell_item(index: int) -> bool:
 if phase!="shop" or index<0 or index>=inventory.size(): return false
 earn(sale_base(inventory[index]))
 Market.remove_item(self,index)
 save_run()
 return true

func reroll_cost() -> int:
 return 0 if shop_rerolls==0 and has_relic("coupon") else price(3+shop_rerolls)

func reroll() -> bool:
 if phase!="shop" or money.cmp(reroll_cost())<0: return false
 money=money.minus(reroll_cost())
 _make_offers()
 shop_rerolls+=1
 save_run()
 return true

func pack_open(slot: int = 0) -> bool:
 if not legacy_compat: return Market.open_pack(self,slot)
 var cost: int = 0 if b().get("free_packs",false) else price(5)
 if phase!="shop" or shop_pack_bought or money.cmp(cost)<0: return false
 money=money.minus(cost)
 shop_pack_bought=true
 var choices: Array = []
 var pool: Array = _eligible_relics()+Cat.SPELLS.keys()+Cat.RUNES.keys()
 while choices.size()<3 and not pool.is_empty():
  var id: String = rng.pick(pool)
  choices.append(id)
  pool.erase(id)
 pack_choices=choices
 save_run()
 return true

func pack_choose(id: String) -> bool:
 if not legacy_compat: return Market.choose_pack(self,id)
 if phase!="shop" or not pack_choices.has(id) or not _grant(id): return false
 pack_choices=[]
 save_run()
 return true

func heal_shop() -> bool:
 var cost: int = price(5)
 if phase!="shop" or shop_heal_bought or hp>=max_hp or money.cmp(cost)<0: return false
 money=money.minus(cost)
 hp+=1
 shop_heal_bought=true
 save_run()
 return true

func leave_shop() -> void:
 if phase!="shop": return
 var old_floor: int = floor_num
 if pending_outcome:
  gate+=1
  if gate==3:
   gate=0
   floor_num+=1
   hp=mini(max_hp,hp+int(b().get("floor_heal",0)))
 phase="play"
 score=Num.new()
 moves=budget()
 banked=0
 gate_swipes=0
 last_dir=""
 jammed=false
 _clear_shop()
 result_text=""
 result_summary={}
 if not legacy_compat: Rules.after_shop(self,old_floor)
 while filled()<2: spawn()
 if not can_slide(): recover_board()
 save_run()

func consumable_at(index: int, source: String = "pocket") -> String:
 return Market.item_id(self,index,source)

func consumable_tags(index: int, source: String = "pocket") -> Dictionary:
 return Market.item_tags(self,index,source)

func use_item(index: int, cell: int = -1, dest: int = -1, source: String = "pocket") -> bool:
 var id: String = consumable_at(index,source)
 if id=="" or phase not in ["shop","play"]: return false
 var tags: Dictionary = consumable_tags(index,source).duplicate(true)
 var count: int = 2 if tags.get("double",false) else 1
 var original_e: int = int(cells[cell].e) if cell>=0 and cell<16 and cells[cell]!=null else -1
 if Cat.FRACTURES.has(id):
  if not Actions.use_fracture(self,id,cell): return false
 elif Cat.RUNES.has(id):
  var stat: String = Cat.RUNES[id].stat
  rune_levels[stat]+=count
  rune_uses+=count
  if stat=="spawn":
   for value in cells:
    if value!=null: value.e=maxi(int(value.e),spawn_min())
  next_tile=roll_tile()
 elif not _apply_spell(id,cell,dest): return false
 if Cat.SPELLS.has(id) and cell>=0 and original_e>0 and has_relic("body_double") and int(f.gate.get("body_double",0))<int(ceil(Rules.amount(self,"body_double"))):
  var applied := 0
  for target in range(16):
   if target==cell or cells[target]==null or int(cells[target].e)!=original_e: continue
   var empty: Array = Rules.free_cells(self)
   if _apply_spell(id,target,int(empty[0]) if not empty.is_empty() else -1):
    applied+=1
    if applied>=int(ceil(Rules.amount(self,"body_double"))): break
  if applied>0: f.gate.body_double=int(f.gate.get("body_double",0))+1
 var retain: bool = Cat.RUNES.has(id) and has_relic("spare_parts") and rng.randf()<minf(1,.2*Rules.amount(self,"spare_parts"))
 if not retain: Market.remove_item(self,index,source)
 if Cat.RUNES.has(id) or Cat.SPELLS.has(id):
  f.last_used=id
  f.last_used_tags=tags
 best_exp=maxi(best_exp,highest())
 if filled()==0: spawn()
 jammed=not can_slide()
 result_text=""
 save_run()
 return true

func _apply_spell(id: String, cell: int, dest: int) -> bool:
 if not Cat.SPELLS.has(id): return false
 if id=="mercy":
  if hp>=max_hp: return false
  hp+=1
  return true
 if id=="hourglass":
  if phase!="play": return false
  moves+=4
  return true
 if phase!="play" or cell<0 or cell>=16 or cell==int(f.block): return false
 var action: String = Cat.SPELLS[id].action
 var value = cells[cell]
 if action=="spawn":
  if value!=null: return false
  cells[cell]=tile(maxi(int(Cat.SPELLS[id].e),spawn_min()+2))
 else:
  if value==null: return false
  match action:
   "double": value.e+=1
   "copy":
    if dest<0 or dest>=16 or dest==int(f.block) or cells[dest]!=null: return false
    cells[dest]=value.duplicate(true)
   "erase": cells[cell]=null
   "seal":
    if value.seal: return false
    value.seal=true
   "gold","glass","steel":
    if value.fx.get(action,false): return false
    value.fx[action]=true
 return true

func sale_base(id: String) -> int:
 var value: int = maxi(1,int(Cat.data_for(id).cost/2.0))
 if Cat.RELICS.has(id) and has_upgrade("scrapyard2"): value=int(ceil(value*1.5))
 elif not Cat.RELICS.has(id) and has_upgrade("scrapyard1"): value+=2
 return value

func sell_value(id: String) -> int:
 return sale_base(id)*(2 if has_upgrade("trade3") else 1)

func workshop_action(action: String, index: int = -1, other: int = -1, choice: String = "", amount: int = 0) -> bool:
 return Actions.workshop(self,action,index,other,choice,amount)

func choose_floor_upgrade(id: String) -> bool:
 if phase!="shop" or floor_upgrade_bought or not f.floor_choices.has(id) or not can_grant(id): return false
 floor_upgrade=id
 shop_upgrade=id
 save_run()
 return true

func choose_auto_move(advanced: bool = false) -> String:
 var Autoplayer = load("res://scripts/autoplayer.gd")
 return Autoplayer.choose(self,advanced)

func auto_move() -> bool:
 if phase!="play" or not has_upgrade("auto1") or jammed: return false
 var direction: String = choose_auto_move(has_upgrade("auto2"))
 return move(direction) if direction!="" else false

static func encode(value):
 if value is Num: return value.encode()
 if value is Dictionary:
  var output := {}
  for key in value: output[key]=encode(value[key])
  return output
 if value is Array: return value.map(func(item): return encode(item))
 if value is float and is_finite(value) and absf(value)<9e15 and value==floorf(value): return int(value)
 return value

static func decode(value):
 if value is Dictionary:
  if value.has("__num"): return Num.of(value)
  var output := {}
  for key in value: output[key]=decode(value[key])
  return output
 if value is Array: return value.map(func(item): return decode(item))
 if value is float and is_finite(value) and absf(value)<9e15 and value==floorf(value): return int(value)
 return value

func snapshot() -> Dictionary:
 var state := {}
 for key in ["seed_text","board_id","cells","relics","inventory","upgrades","rune_levels","rune_uses","floor_num","gate","hp","max_hp","moves","money","score","total_score","best_exp","cleared","failed","swipes","gate_swipes","last_dir","banked","phase","result_text","result_summary","last_merge","last_triggers","last_entries","fired_relics","f","next_tile","shop_offers","shop_upgrade","floor_upgrade","floor_upgrade_floor","floor_upgrade_bought","shop_rerolls","shop_pack_bought","pack_choices","shop_heal_bought","pending_outcome","jammed","endless"]:
  state[key]=get(key)
 state.version=2 if legacy_compat else 3
 state.rng_state=rng.state
 return encode(state)

static func _valid_num(value) -> bool:
 if value is int or value is float: return is_finite(float(value)) and value>=0
 if value is not Dictionary or value.get("__num") is not Array or value.__num.size() not in [2,3]: return false
 return _finite(value.__num[0]) and _finite(value.__num[1]) and float(value.__num[0])>=0 and (value.__num.size()==2 or (_finite(value.__num[2]) and value.__num[2]>=0 and value.__num[2]==floorf(value.__num[2])))

static func _finite(value) -> bool:
 return (value is int or value is float) and is_finite(float(value))

static func _valid_tile(value) -> bool:
 return value is Dictionary and _finite(value.get("e")) and float(value.e)>=1 and value.get("fx") is Dictionary and value.get("seal") is bool

func restore(state) -> bool:
 # Validate before mutating the live run or writing over its save.
 if state is not Dictionary or int(state.get("version",0)) not in [1,2,3]: return false
 if state.get("phase") not in PHASES or state.get("cells") is not Array or state.cells.size()!=16: return false
 if state.get("next_tile") is not Dictionary or not _valid_tile(state.next_tile): return false
 for cell in state.cells:
  if cell!=null and not _valid_tile(cell): return false
 if state.get("board_id")!=Cat.board(str(state.get("board_id",""))).id: return false
 for key in ["money","score","total_score"]:
  if not _valid_num(state.get(key)): return false
 for key in ["gate","floor_num","hp","max_hp","moves","rng_state"]:
  if not _finite(state.get(key)): return false
 if state.gate<0 or state.gate>2 or state.floor_num<1 or state.hp<0 or state.max_hp<1 or state.hp>state.max_hp or state.moves<0: return false
 for key in ["relics","inventory","upgrades","shop_offers","pack_choices"]:
  if state.get(key,[]) is not Array: return false
 var seen: Array = []
 var uids: Array = []
 for relic in state.get("relics",[]):
  if relic is not Dictionary or not Cat.RELICS.has(relic.get("id")) or (seen.has(relic.id) and int(state.get("version",0))<3) or not _valid_num(relic.get("growth")): return false
  if not _finite(relic.get("charge")) or not _finite(relic.get("carry")): return false
  if relic.get("edition","") not in ["","unbound","oversaturated"] or relic.get("cursed",false) is not bool or relic.get("echoed",false) is not bool: return false
  if not _finite(relic.get("echo_passes",2)) or relic.get("echo_passes",2)<2: return false
  if relic.get("abilities",[]) is not Array or relic.get("abilities",[]).size()>6: return false
  for ability in relic.get("abilities",[]):
   if ability is not Dictionary or ability.get("id") not in Rules.COPIABLE or not _valid_num(ability.get("growth")) or not _finite(ability.get("charge")) or not _finite(ability.get("carry")) or ability.get("edition","") not in ["","unbound","oversaturated"] or ability.get("cursed",false) is not bool: return false
   if ability.get("echoed",false) is not bool or not _finite(ability.get("echo_passes",2)) or ability.get("echo_passes",2)<2: return false
  if relic.has("uid"):
   if not _finite(relic.uid) or relic.uid<1 or uids.has(relic.uid): return false
   uids.append(relic.uid)
  seen.append(relic.id)
 for id in state.get("inventory",[]):
  if not Cat.SPELLS.has(id) and not Cat.RUNES.has(id) and not Cat.FRACTURES.has(id): return false
 for id in state.get("upgrades",[]):
  if not Cat.UPGRADES.has(id): return false
 for id in state.get("shop_offers",[])+state.get("pack_choices",[]):
  if id!="" and Cat.data_for(id).is_empty(): return false
 if state.get("shop_upgrade","")!="" and not Cat.UPGRADES.has(state.shop_upgrade): return false
 if state.get("floor_upgrade","")!="" and not Cat.UPGRADES.has(state.floor_upgrade): return false
 if state.has("floor_upgrade_floor") and (not _finite(state.floor_upgrade_floor) or state.floor_upgrade_floor<0): return false
 if state.has("floor_upgrade_bought") and state.floor_upgrade_bought is not bool: return false
 var runes = state.get("rune_levels",state.get("runes",{}))
 if runes is not Dictionary: return false
 for key in ["spawn","gold","glass","steel","seal"]:
  if not _finite(runes.get(key)) or runes[key]<0: return false
 if state.get("result_summary",{}) is not Dictionary: return false
 if state.get("result_summary",{}).has("target") and not _valid_num(state.result_summary.target): return false
 if state.has("f") and not Rules.valid_state(state.f): return false
 if state.has("f") and uids.any(func(uid): return uid>state.f.get("serial",0)): return false
 if state.has("f") and int(state.f.get("block",-1))>=0 and state.cells[int(state.f.block)]!=null: return false
 last_score_steps=[]
 f=Rules.defaults()
 var restored: Dictionary = decode(state)
 for key in snapshot().keys():
  if key not in ["version","rng_state"] and restored.has(key): set(key,restored[key])
 f=Rules.defaults().merged(f,true)
 if f.difficulty=="normal": f.curse=0
 rune_levels=decode(runes)
 rng.state=int(state.rng_state)&RunRng.MASK
 # Version 1 native saves used plain floats.
 money=Num.of(money)
 score=Num.of(score)
 total_score=Num.of(total_score)
 last_merge=Num.of(last_merge)
 for relic in relics: relic.growth=Num.of(relic.growth)
 if not state.has("floor_upgrade_floor"):
  floor_upgrade=shop_upgrade
  floor_upgrade_floor=floor_num if phase=="shop" else 0
  floor_upgrade_bought=phase=="shop" and shop_upgrade.is_empty()
 pending_outcome=bool(state.get("pending_outcome",true))
 if not state.has("f") and not legacy_compat:
  for relic in relics: Rules.attach(self,relic)
  Market.make_packs(self)
  if shop_pack_bought or not pack_choices.is_empty():
   f.pack_offers[0]={"type":"standard","size":"Standard","bought":true}
  if not pack_choices.is_empty(): f.pack_remaining=1
 if board_id=="eclipse":
  max_hp=1
  hp=mini(hp,1)
 return true

func export_run() -> String:
 return JSON.stringify(snapshot())

func import_run(text: String) -> bool:
 var data = JSON.parse_string(text)
 if data is not Dictionary: return false
 if data.has("board") and data.has("jokers"): data=_legacy_state(data)
 if data.is_empty() or not restore(data): return false
 save_run()
 return true

func _legacy_state(data: Dictionary) -> Dictionary:
 if data.get("board") is not Array or data.get("jokers") is not Array or data.get("inventory") is not Array: return {}
 var state: Dictionary = snapshot()
 state.version=2
 state.erase("f")
 var names := {"seed":"seed_text","boardId":"board_id","board":"cells","jokers":"relics","vouchers":"upgrades","planets":"rune_levels","planetUses":"rune_uses","floor":"floor_num","totalScore":"total_score","bestTile":"best_exp","gateSwipes":"gate_swipes","lastDir":"last_dir","bankedMoves":"banked","rng":"rng_state"}
 for key in ["phase","gate","hp","maxHp","moves","money","score","cleared","failed","swipes","next","jammed","endless"]:
  var native_key: String = "max_hp" if key=="maxHp" else "next_tile" if key=="next" else key
  if data.has(key): state[native_key]=data[key]
 for key in names:
  if data.has(key): state[names[key]]=data[key]
 state.inventory=[]
 for item in data.inventory:
  if item is not Dictionary or not item.has("id"): return {}
  state.inventory.append(item.id)
 state.last_dir=str(data.get("lastDir", "")) if data.get("lastDir")!=null else ""
 state.pending_outcome=data.get("result",{}).get("success",true) if data.get("result") is Dictionary else true
 state.result_text="Imported saved run."
 var shop = data.get("shop")
 state.shop_offers=[]
 state.shop_upgrade=""
 state.pack_choices=[]
 state.erase("floor_upgrade")
 state.erase("floor_upgrade_floor")
 state.erase("floor_upgrade_bought")
 if shop is Dictionary:
  if shop.get("offers") is not Array: return {}
  for offer in shop.offers: state.shop_offers.append(offer.id if offer is Dictionary and not offer.get("sold",false) else "")
  if shop.get("voucher") is Dictionary and not shop.voucher.get("sold",false): state.shop_upgrade=shop.voucher.id
  state.shop_rerolls=shop.get("rerolls",0)
  state.shop_pack_bought=shop.get("packBought",false)
  state.pack_choices=shop.pack if shop.get("pack") is Array else []
  state.shop_heal_bought=shop.get("healBought",false)
 return state

func save_run() -> void:
 if not persist_enabled or phase=="home": return
 var file := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
 if file: file.store_string(export_run())
 storage_error="" if file else "Saving unavailable. Export your run from the menu."

func load_run() -> bool:
 if FileAccess.file_exists(SAVE_PATH):
  var file := FileAccess.open(SAVE_PATH,FileAccess.READ)
  if file and import_run(file.get_as_text()): return true
 if OS.has_feature("web"):
  var legacy = JavaScriptBridge.eval("localStorage.getItem('gatefold.run.v1')",true)
  if legacy is String and import_run(legacy): return true
 return false

## UI pacing state: committed next gate, awaiting explicit entry.
func queue_gate() -> bool:
 if phase!="play": return false
 phase="gates"
 save_run()
 return true

func begin_gate() -> bool:
 if phase!="gates" or not f.nomad_choices.is_empty(): return false
 phase="play"
 f.nomad_trade=false
 save_run()
 return true

func gate_previews() -> Array[Dictionary]:
 var previews: Array[Dictionary] = []
 for index in range(3):
  var goal = target(index)
  var move_count: int = moves if index==gate else budget(index,false)
  previews.append({"index":index,"name":guardian().name if index==2 else ["Entry Gate","Inner Gate"][index],"rule":guardian().desc if index==2 else "No special rule.","art":guardian().get("art","gate") if index==2 else "gate","target":goal.fmt(),"moves":move_count,"reward":0 if b().get("no_gate_cash",false) else [4,5,7][index],"status":"Cleared" if index<gate else "Ready" if index==gate else "Upcoming"})
 return previews

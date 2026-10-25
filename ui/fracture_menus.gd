extends RefCounted
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
const Rules = preload("res://scripts/fracture_rules.gd")
const Market = preload("res://scripts/fracture_market.gd")
const Actions = preload("res://scripts/fracture_actions.gd")
const CARD = preload("res://scenes/ui/card.tscn")
const BOARD = preload("res://scenes/ui/board.tscn")

static func note(text: String) -> Label:
 var label: Label = UIStyle.label(text,27,UIStyle.MUTED,false,true)
 label.add_theme_font_size_override("font_size",27)
 return label

static func row(host, col: VBoxContainer, title: String, detail: String, action: String, callback: Callable, enabled: bool = true) -> void:
 var line: HBoxContainer = UIStyle.row(20)
 var copy: VBoxContainer = UIStyle.column(4)
 copy.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 copy.add_child(UIStyle.label(title,36,UIStyle.CREAM))
 copy.add_child(note(detail))
 line.add_child(copy)
 var button: Button = host._button(action,callback,Color("745884"))
 button.size_flags_horizontal=Control.SIZE_SHRINK_END
 button.custom_minimum_size=Vector2(280,54)
 button.disabled=not enabled
 line.add_child(button)
 col.add_child(line)

static func owned_entries(host, predicate: Callable) -> Array:
 var entries: Array = []
 for index in range(host.g.relics.size()):
  var relic: Dictionary = host.g.relics[index]
  if predicate.call(relic,index): entries.append({"id":relic.id,"index":index,"state":relic,"live":Rules.status(host.g,relic)})
 return entries

static func pocket_entries(host, predicate: Callable) -> Array:
 var entries: Array = []
 for index in range(host.g.inventory.size()):
  var id: String = host.g.inventory[index]
  if predicate.call(id,index): entries.append({"id":id,"index":index,"double":host.g.consumable_tags(index).get("double",false)})
 return entries

static func picker(host, title: String, detail: String, entries: Array, callback: Callable, label: String = "Choose", can_close: bool = true) -> void:
 var height: int = 580 if entries.size()<=4 else 740
 var col: VBoxContainer = host._open(title,"choice",Vector2(1000,height),can_close)
 col.add_child(note(detail))
 var grid := GridContainer.new()
 grid.columns=4
 grid.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
 grid.add_theme_constant_override("h_separation",24)
 grid.add_theme_constant_override("v_separation",24)
 col.add_child(grid)
 for entry in entries:
  var stack: VBoxContainer = UIStyle.column(10)
  stack.custom_minimum_size.x=164
  var card: Control = CARD.instantiate()
  card.item_id=entry.id
  card.item_state=entry.get("state",{})
  card.double_use=entry.get("double",false)
  card.live_note=entry.get("live","")
  card.motion_enabled=not host.reduced_motion
  card.custom_minimum_size=Vector2(164,192)
  stack.add_child(card)
  var choose: Callable = func(): callback.call(entry)
  card.inspected.connect(func(_id): host._show_choice_context(entry.id,card,"" if label=="Details" else label,Callable() if label=="Details" else choose,entry.get("live","")))
  var button: Button = host._button(label,choose,Color("497b68"))
  button.custom_minimum_size=Vector2(164,48)
  stack.add_child(button)
  grid.add_child(stack)
 if entries.is_empty(): col.add_child(UIStyle.label("No valid choices right now.",36,UIStyle.CREAM))
 if can_close: col.add_child(host._button("Cancel",host._close_overlay,Color("425e68")))
 else: col.add_child(host._button("Change board",host._show_new_run,Color("425e68")))

static func choose_owned(host, title: String, detail: String, predicate: Callable, callback: Callable, label: String = "Choose") -> void:
 picker(host,title,detail,owned_entries(host,predicate),func(entry): callback.call(int(entry.index)),label)

static func choose_pocket(host, title: String, detail: String, predicate: Callable, callback: Callable, label: String = "Choose") -> void:
 picker(host,title,detail,pocket_entries(host,predicate),func(entry): callback.call(int(entry.index)),label)

static func tile_picker(host, title: String, detail: String, predicate: Callable, callback: Callable) -> void:
 var col: VBoxContainer = host._open(title,"tile_choice",Vector2(820,760))
 col.add_child(note(detail))
 var board: Control = BOARD.instantiate()
 board.name="TargetBoard"
 board.motion_enabled=false
 board.targeting=true
 board.blocked_cell=int(host.g.f.block)
 board.custom_minimum_size=Vector2(420,420)
 board.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
 for index in range(16):
  if predicate.call(index): board.allowed_targets.append(index)
 if board.allowed_targets.is_empty():
  board.allowed_targets=[-2]
  col.add_child(note("No eligible tiles right now."))
 col.add_child(board)
 board.show_cells(host.g.cells)
 board.cell_selected.connect(func(index):
  if predicate.call(index): callback.call(index)
  else: host._toast("Choose a highlighted tile.")
 )
 col.add_child(host._button("Cancel",host._close_overlay,Color("425e68")))

static func show_nomad(host) -> void:
 var entries: Array = []
 for id in host.g.f.nomad_choices: entries.append({"id":id})
 picker(host,"Nomad's companion","Choose one starting relic. Browsing does not reroll these choices.",entries,func(entry):
  if Actions.choose_nomad(host.g,entry.id):
   host._refresh_run(false)
   host._show_gates()
 ,"Take",false)

static func show_upgrades(host) -> void:
 var entries: Array = []
 for id in host.g.upgrades: entries.append({"id":id,"live":"Owned permanent upgrade"})
 picker(host,"Permanent upgrades","These upgrades are already active. Click a card to read its rules.",entries,func(_entry): pass,"Details")
 # Read-only detail buttons should open the same item-relative tooltip as the card.
 var cards: Array = host.overlay.find_children("*","Button",true,false).filter(func(n): return n.get_script()!=null and n.get_script().resource_path=="res://ui/card_view.gd")
 for card in cards:
  var stack: VBoxContainer = card.get_parent()
  var button: Button = stack.get_child(1)
  for connection in button.pressed.get_connections(): button.pressed.disconnect(connection.callable)
  button.pressed.connect(func(): host._show_choice_context(card.item_id,card,"",Callable(),"Owned permanent upgrade"))

static func floor_upgrade(host) -> void:
 var entries: Array = []
 for id in host.g.f.floor_choices:
  if host.g.can_grant(id): entries.append({"id":id,"live":"Cost $%d / choose one upgrade for this floor" % host.g.cost_for(id)})
 picker(host,"Choose the floor upgrade","Storefront III offers two candidates. Choose one, then redeem its ticket in the shop.",entries,func(entry):
  if host.g.choose_floor_upgrade(entry.id):
   host._refresh_run(false)
   host._show_shop()
   if host.shop_view._sources.has(entry.id): host._inspect_upgrade(entry.id,host.shop_view._sources[entry.id])
 ,"Select")

static func fracture_target(host, pocket_index: int, source: String) -> void:
 var id: String = host.g.consumable_at(pocket_index,source)
 if not Cat.FRACTURES.has(id): return
 var definition: Dictionary = Cat.FRACTURES[id]
 if definition.target=="relic":
  choose_owned(host,definition.name,definition.desc,func(_relic,index):
   return Actions.fracture_reason(host.g,id,index).is_empty()
  ,func(index): host._use_fracture(pocket_index,index,source),"Transform")
 elif definition.target=="tile":
  tile_picker(host,definition.name,definition.desc,func(index): return Actions.fracture_reason(host.g,id,index).is_empty(),func(index): host._use_fracture(pocket_index,index,source))
 else: host._use_fracture(pocket_index,-1,source)

static func fusion(host, mode: String, first: int = -1) -> void:
 var spells: bool = mode=="fusion_spell"
 choose_pocket(host,"Fusion Lab","Choose two Spells." if spells else "Choose two Runes.",func(id,index): return index!=first and (Cat.SPELLS.has(id) if spells else Cat.RUNES.has(id)),func(index):
  if first<0: fusion(host,mode,index)
  elif spells: host._workshop_commit(mode,first,index)
  else:
   var entries: Array = []
   for id in Cat.RUNES: entries.append({"id":id,"double":mode=="fusion_double"})
   picker(host,"Choose the resulting Rune","The two selected Runes are consumed only when you choose the result.",entries,func(entry): host._workshop_commit(mode,first,index,entry.id),"Fuse")
 ,"First" if first<0 else "Second")

static func reserve(host) -> void:
 var entries: Array = []
 for index in range(host.g.f.reserve.size()):
  var held: Dictionary = host.g.f.reserve[index]
  entries.append({"id":held.id,"index":index,"double":held.tags.get("double",false),"live":"Stored in your reserve"})
 picker(host,"Reserve","Retrieve stored cards when your pocket has room. To store a card, select it in your pocket.",entries,func(entry):
  if Market.take_from_reserve(host.g,entry.index):
   host._refresh_run(false)
   reserve(host)
  else: host._toast("Make room in your pocket first.")
 ,"Retrieve")

static func workshop(host) -> void:
 var g=host.g
 var col: VBoxContainer = host._open("WORKSHOP","workshop",Vector2(1040,760))
 col.add_child(note("Relic abilities, permanent upgrades, and stored cards."))
 if g.has_relic("paradox"):
  row(host,col,"Paradox","Rewind the last valid swipe. Board, points, money, moves, and relic state return; the spawn is rerolled.","Rewind",func(): host._workshop_commit("rewind"),Rules.can_rewind(g))
 if g.has_relic("loan_shark"):
  var limit: int = int(50*Rules.amount(g,"loan_shark"))
  row(host,col,"Loan Shark","Borrow once per floor. Guardian repayment is 150%; an unpaid loan costs one Life.","Borrow $%d" % limit,func(): host._workshop_commit("borrow",-1,-1,"",limit),g.phase in ["shop","gates","reward"] and not g.f.floor.get("loan",false))
  if num_value(g.f.debt)>0:
   var due = UIStyle.Num.of(g.f.debt).times(1.5)
   row(host,col,"Repay the loan","Settle your full debt before the Guardian.","Repay $"+due.fmt(),func(): host._workshop_commit("repay"),g.money.cmp(due)>=0)
 if g.has_relic("risky_investment"):
  row(host,col,"Risky Investment","Before a Guardian, deposit half your balance. A win returns x%s; a failure loses it." % Rules.number(3*Rules.amount(g,"risky_investment")),"Invest $"+g.money.div(2).floored().fmt(),func(): host._workshop_commit("invest"),g.phase=="gates" and g.gate==2 and num_value(g.f.investment)==0 and g.money.cmp(2)>=0)
 if g.has_upgrade("wagers1"):
  var limit: int = 30 if g.has_upgrade("wagers2") else 10
  for stake in [5,10,30]:
   if stake>limit: continue
   row(host,col,"Wager $%d" % stake,"Clear this gate without losing Life. Returns x3 on a Guardian with Wagers III; otherwise x2.","Stake $%d" % stake,func(): host._workshop_commit("wager",-1,-1,"",stake),g.phase=="gates" and num_value(g.f.wager)==0 and g.money.cmp(stake)>=0)
  if num_value(g.f.wager)>0: col.add_child(UIStyle.label("Current stake  $"+UIStyle.Num.of(g.f.wager).fmt(),36,UIStyle.GOLD))
 if g.has_relic("guillotine"):
  row(host,col,"Guillotine","Sacrifice the highest tile after a Guardian victory. Current multiplier grows by x1.8.","Offer tile",func(): host._workshop_commit("guillotine"),int(g.f.pending.get("guillotine",0))>0 and g.filled()>0)
 if g.has_relic("devourer"):
  row(host,col,"Devourer","Sacrifice another scoring relic and inherit its ability. Capacity scales with this relic's power.","Choose relic",func(): choose_owned(host,"Feed Devourer","The selected relic is destroyed; its scoring ability is inherited.",func(relic,index): return relic.id in Rules.COPIABLE,func(index): host._workshop_commit("devour",index),"Sacrifice"),int(g.f.pending.get("devourer",0))>0 and g.relics.any(func(r): return r.id=="devourer" and r.get("abilities",[]).size()<int(ceil(2*Rules.power(r)))))
 if g.has_relic("crown_echoes"):
  row(host,col,"Crown of Echoes","After a Guardian victory, permanently double a relic's scoring activations. Growth and payouts still occur once.","Choose relic",func(): choose_owned(host,"Crown of Echoes","Permanently Echo one eligible relic.",func(relic,index): return relic.id in Rules.SCORING and not relic.get("echoed",false),func(index): host._workshop_commit("echo",index),"Echo"),int(g.f.pending.get("crown_echoes",0))>0)
 if g.has_relic("chrysalis"):
  row(host,col,"Chrysalis","Mark a plain tile. After %d merges it gains Gold, Glass, Steel, and a seal." % maxi(1,int(ceil(3/Rules.amount(g,"chrysalis")))),"Choose tile",func(): tile_picker(host,"Chrysalis","Choose a plain, unsealed tile to mark.",func(index): return g.cells[index]!=null and g.cells[index].fx.is_empty() and not g.cells[index].seal and not g.cells[index].has("chrysalis"),func(index): host._workshop_commit("chrysalis",index)),true)
 if g.f.nomad_trade and g.phase=="gates":
  row(host,col,"Nomad exchange","At the start of this floor, exchange one relic for another of the same rarity. Its edition is kept.","Choose relic",func(): choose_owned(host,"Nomad exchange","Choose a relic to exchange. The replacement is random within its rarity.",func(relic,index): return not g._eligible_relics().filter(func(id): return Cat.RELICS[id].rarity==Cat.RELICS[relic.id].rarity).is_empty(),func(index):
   if Actions.exchange_nomad(g,index): host._workshop_changed()
  ,"Exchange"))
 if g.has_upgrade("satchel2"):
  row(host,col,"Reserve","%d / 2 cards stored. Storing cards never uses a pocket slot." % g.f.reserve.size(),"Open reserve",func(): reserve(host))
 if int(g.f.pending.get("satchel",0))>0:
  row(host,col,"Satchel III","Choose an owned consumable to duplicate. A reward is earned every third Guardian victory.","Duplicate",func(): choose_pocket(host,"Duplicate a consumable","The original stays in your pocket.",func(id,index): return true,func(index): host._workshop_commit("duplicate",index),"Duplicate"),g.inventory.size()<g.max_pocket())
 for mode in ["fusion_spell","fusion_rune","fusion_double"]:
  var upgrade: String = "fusion1" if mode=="fusion_spell" else "fusion2" if mode=="fusion_rune" else "fusion3"
  if not g.has_upgrade(upgrade): continue
  var required: Dictionary = Cat.SPELLS if mode=="fusion_spell" else Cat.RUNES
  var count: int = g.inventory.filter(func(id): return required.has(id)).size()
  row(host,col,Cat.name_for(upgrade),"Combine two Spells into a random Spell." if mode=="fusion_spell" else "Combine two Runes into a chosen Rune." if mode=="fusion_rune" else "Combine two Runes into a chosen double-use Rune.","Choose two",func(): fusion(host,mode),count>=2 and g.phase in ["shop","gates","reward"])
 col.add_child(host._button("Return",host._close_overlay,Color("425e68")))

static func num_value(value) -> float:
 return UIStyle.Num.of(value).m

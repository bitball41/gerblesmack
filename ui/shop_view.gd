extends Control
## Open tabletop: compact offers, contextual purchase, one floor upgrade.
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
const Game = preload("res://scripts/game.gd")
const CARD: PackedScene = preload("res://scenes/ui/card.tscn")
const BUTTON: PackedScene = preload("res://scenes/ui/action_button.tscn")
const WALLET: PackedScene = preload("res://scenes/ui/wallet.tscn")
signal buy_requested(id: String)
signal item_inspected(id: String)
signal upgrade_inspected(id: String, source: Control)
signal reroll_requested
signal pack_requested
signal heal_requested
signal next_requested
var motion_enabled := true
var wallet: Control
var offers: Array[Dictionary] = []
var _next_round: Button
var _reroll: Button
var _specials: Control
var _special_signature := ""
var _sources: Dictionary = {}
var selected_offer := -1

func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_STOP
 resized.connect(func():
  if is_instance_valid(_specials): _specials.position.y=size.y-174
  if is_instance_valid(_next_round): _next_round.position.y=size.y-126
  if is_instance_valid(_reroll): _reroll.position.y=size.y-126
 )
 wallet=WALLET.instantiate()
 wallet.visible=false
 add_child(wallet)
 _next_round=_button("Next\nround",Rect2(20,454,144,108),func(): next_requested.emit(),Color("bd594c"),null,30)
 _reroll=_button("Reroll\n$3",Rect2(180,454,144,108),func(): reroll_requested.emit(),Color("328a69"),null,30)
 _specials=Control.new()
 UIStyle.place(_specials,self,Rect2(340,406,432,156))
 for index in range(4):
  var slot := Control.new()
  UIStyle.place(slot,self,Rect2(20+index*188,28,164,330))
  offers.append({"id":"__unset","root":slot,"buy":null,"card":null})

func _draw() -> void:
 # A single recessed tray, with quiet table around every card.
 draw_rect(Rect2(12,12,756,344),Color("172b3350"))
 draw_rect(Rect2(20,382,752,2),Color("78928a65"))

func _text(text: String, rect: Rect2, font_size: int, color: Color = UIStyle.CREAM, parent: Node = null, wrap: bool = false) -> Label:
 var label: Label = UIStyle.label(text,font_size,color,true,wrap)
 UIStyle.place(label,self if parent==null else parent,rect)
 return label

func _button(text: String, rect: Rect2, action: Callable, color: Color = Color("438368"), parent: Node = null, font_size: int = 32, item: bool = false) -> Button:
 var button: Button = load("res://ui/item_button.gd").new() if item else BUTTON.instantiate()
 button.custom_minimum_size=Vector2.ZERO
 button.text=text
 button.base_color=color
 button.edge_color=color.lightened(.25)
 button.display_size=font_size
 button.padding=5
 button.motion_enabled=motion_enabled
 button.pressed.connect(action)
 UIStyle.place(button,self if parent==null else parent,rect)
 return button

func sync(game: Game) -> void:
 wallet.motion_enabled=motion_enabled
 wallet.set_amount(game.money)
 _reroll.text="Reroll\n$%d" % game.reroll_cost()
 _reroll.disabled=game.money.cmp(game.reroll_cost())<0
 for index in range(4):
  var id: String = game.shop_offers[index] if index<game.shop_offers.size() else ""
  var slot: Dictionary = offers[index]
  if slot.id!=id: _fill_offer(index,id)
  if id!="" and is_instance_valid(slot.buy):
   slot.buy.disabled=not game.can_grant(id) or game.money.cmp(game.cost_for(id))<0
   slot.root.get_node("Price").text="$%d" % game.cost_for(id)
 var signature: String = str([game.shop_upgrade,game.shop_pack_bought,game.shop_heal_bought,game.hp,game.max_hp,game.floor_num])
 if signature!=_special_signature:
  _fill_specials(game)
  _special_signature=signature
 for child in _specials.find_children("*","Button",true,false):
  var id: String = str(child.get_meta("purchase_id",""))
  var cost: int = int(child.get_meta("cost",0))
  child.disabled=game.money.cmp(cost)<0 or (id!="" and not game.can_grant(id))

func _select_offer(index: int) -> void:
 item_inspected.emit(str(offers[index].id))

func _fill_offer(index: int, id: String) -> void:
 var slot: Dictionary = offers[index]
 var root: Control = slot.root
 for child in root.get_children(): root.remove_child(child); child.queue_free()
 slot.id=id
 slot.buy=null
 slot.card=null
 if selected_offer==index: selected_offer=-1
 if id=="":
  var sold: Label = _text("SOLD",Rect2(8,118,120,40),20,Color("7f9a8e"),root)
  sold.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  return
 var card: Control = CARD.instantiate()
 card.item_id=id
 card.motion_enabled=motion_enabled
 card.custom_minimum_size=Vector2.ZERO
 UIStyle.place(card,root,Rect2(0,46,164,192))
 card.inspected.connect(func(_item: String): _select_offer(index))
 slot.card=card
 var price: Label = _text("",Rect2(0,2,164,38),30,UIStyle.GOLD,root)
 price.name="Price"
 price.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 slot.buy=_button("BUY",Rect2(0,262,164,46),func(): buy_requested.emit(id),Color("328a69"),root,20)
 slot.buy.name="Buy"+id.capitalize()
 slot.buy.visible=false
 if motion_enabled:
  card.modulate.a=.3
  card.create_tween().tween_property(card,"modulate:a",1.0,.16).set_delay(index*.035)

func _fill_specials(game: Game) -> void:
 for child in _specials.get_children(): _specials.remove_child(child); child.queue_free()
 _sources.clear()
 _text("Floor %d upgrade" % game.floor_num,Rect2(0,0,252,40),15,UIStyle.MUTED,_specials)
 if game.shop_upgrade!="":
  var id: String = game.shop_upgrade
  var ticket: Button = _button(Cat.name_for(id)+"\n$%d" % game.cost_for(id),Rect2(0,48,252,108),func(): upgrade_inspected.emit(id,_sources[id]),Color("8f7446"),_specials,32,true)
  ticket.set_meta("purchase_id",id)
  ticket.set_meta("cost",game.cost_for(id))
  ticket.set_meta("item_id",id)
  ticket.display_size=32
  ticket.padding=5
  ticket.text=""
  var icon: TextureRect = UIStyle.texture(Cat.UPGRADES[id].art)
  UIStyle.place(icon,ticket,Rect2(10,30,48,48))
  _text(Cat.name_for(id),Rect2(66,4,176,64),32,UIStyle.CREAM,ticket,true)
  _text("$%d" % game.cost_for(id),Rect2(66,72,176,36),32,UIStyle.CREAM,ticket)
  _sources[id]=ticket
 else: _text("REDEEMED",Rect2(12,84,228,36),20,Color("7f9a8e"),_specials)
 _text("Supply pack",Rect2(268,0,164,40),15,UIStyle.MUTED,_specials)
 if not game.shop_pack_bought:
  var cost: int = 0 if game.b().get("free_packs",false) else game.price(5)
  var open: Button = _button("Open\n$%d" % cost,Rect2(268,48,164,108),func(): pack_requested.emit(),Color("6e598d"),_specials,20)
  open.set_meta("cost",cost)
  _sources["pack"]=open
 else: _text("OPENED",Rect2(276,84,156,36),20,Color("7f9a8e"),_specials)
 if game.hp<game.max_hp and not game.shop_heal_bought:
  var heal: Button = _button("Heal  $%d" % game.price(5),Rect2(-320,0,304,42),func(): heal_requested.emit(),Color("9a5665"),_specials,32)
  heal.set_meta("cost",game.price(5))


func source_rect(id: String) -> Rect2:
 for slot in offers:
  if slot.id==id and is_instance_valid(slot.card): return slot.card.get_global_rect()
 if _sources.has(id) and is_instance_valid(_sources[id]): return _sources[id].get_global_rect()
 return Rect2(global_position+Vector2(400,160),Vector2(112,156))

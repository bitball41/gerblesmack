extends Control
## Persistent shop: purchases replace one offer, not the whole screen or wallet.
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
const Game = preload("res://scripts/game.gd")
const CARD: PackedScene = preload("res://scenes/ui/card.tscn")
const BUTTON: PackedScene = preload("res://scenes/ui/action_button.tscn")
const WALLET: PackedScene = preload("res://scenes/ui/wallet.tscn")
signal buy_requested(id: String)
signal item_inspected(id: String)
signal reroll_requested
signal pack_requested
signal heal_requested
signal next_requested
var motion_enabled := true
var wallet: Control
var offers: Array[Dictionary] = []
var _reroll: Button
var _specials: Control
var _special_signature := ""
var _sources: Dictionary = {}
var _lamps: Control
var _time := 0.0

func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_STOP
 _text("TRADING POST",Rect2(28,24,340,40),29,UIStyle.GOLD)
 _text("BUILD SOMETHING UNFAIR.",Rect2(30,68,330,22),12,UIStyle.MUTED)
 wallet=WALLET.instantiate()
 wallet.display_size=42
 UIStyle.place(wallet,self,Rect2(350,25,160,60))
 _reroll=_button("REROLL  $3",Rect2(535,30,250,52),func(): reroll_requested.emit(),Color("695776"))
 _button("NEXT GATE  >",Rect2(806,30,304,52),func(): next_requested.emit(),Color("438368"))
 _specials=Control.new()
 UIStyle.place(_specials,self,Rect2(24,484,1088,82))
 _lamps=Control.new()
 _lamps.mouse_filter=Control.MOUSE_FILTER_IGNORE
 _lamps.draw.connect(_draw_lamps)
 add_child(_lamps)
 for index in range(4):
  var slot := Control.new()
  UIStyle.place(slot,self,Rect2(26+index*270,112,258,334))
  offers.append({"id":"__unset","root":slot,"buy":null,"card":null})
 queue_redraw()

func _draw() -> void:
 UIStyle.pixel_rect(self,Rect2(18,103,1102,350),Color("182b32"),Color("4b686c"))
 draw_rect(Rect2(24,442,1088,8),Color("95653b"))
 draw_rect(Rect2(24,440,1088,3),Color("c19a5d"))
 draw_rect(Rect2(24,465,1088,2),Color("587479"))

func _process(delta: float) -> void:
 if not motion_enabled: return
 _time+=delta
 if int(_time*5)!=int((_time-delta)*5): _lamps.queue_redraw()

func _draw_lamps() -> void:
 for index in range(43):
  var light: Color = UIStyle.GOLD if (index+int(_time*5))%3==0 else Color("9d7543")
  _lamps.draw_rect(Rect2(30+index*25,97,6,4),light)

func _text(text: String, rect: Rect2, font_size: int, color: Color = UIStyle.CREAM, parent: Node = null, wrap: bool = false) -> Label:
 var label: Label = UIStyle.label(text,font_size,color,true,wrap)
 UIStyle.place(label,self if parent==null else parent,rect)
 return label

func _button(text: String, rect: Rect2, action: Callable, color: Color = Color("438368"), parent: Node = null, font_size: int = 20) -> Button:
 var button: Button = BUTTON.instantiate()
 button.custom_minimum_size=Vector2.ZERO
 button.text=text
 button.base_color=color
 button.edge_color=color.lightened(.35)
 button.display_size=font_size
 button.padding=5
 button.motion_enabled=motion_enabled
 button.pressed.connect(action)
 UIStyle.place(button,self if parent==null else parent,rect)
 return button

func sync(game: Game) -> void:
 wallet.motion_enabled=motion_enabled
 wallet.set_amount(game.money)
 _reroll.text="REROLL  $%d" % game.reroll_cost()
 _reroll.disabled=game.money.cmp(game.reroll_cost())<0
 for index in range(4):
  var id: String = game.shop_offers[index] if index<game.shop_offers.size() else ""
  var slot: Dictionary = offers[index]
  if slot.id!=id: _fill_offer(index,id)
  if id!="" and is_instance_valid(slot.buy):
   slot.buy.disabled=not game.can_grant(id) or game.money.cmp(game.cost_for(id))<0
   slot.buy.tooltip_text="Not enough money." if game.money.cmp(game.cost_for(id))<0 else "No available slot, or already owned." if not game.can_grant(id) else "Buy "+Cat.name_for(id)
   slot.root.get_node("Price").text="$%d" % game.cost_for(id)
 var signature: String = str([game.shop_upgrade,game.shop_pack_bought,game.shop_heal_bought,game.hp,game.max_hp])
 if signature!=_special_signature:
  _fill_specials(game)
  _special_signature=signature
 for child in _specials.find_children("*","Button",true,false):
  var id: String = str(child.get_meta("purchase_id",""))
  var cost: int = int(child.get_meta("cost",0))
  child.disabled=game.money.cmp(cost)<0 or (id!="" and not game.can_grant(id))

func _fill_offer(index: int, id: String) -> void:
 var slot: Dictionary = offers[index]
 var root: Control = slot.root
 for child in root.get_children(): root.remove_child(child); child.queue_free()
 slot.id=id
 slot.buy=null
 slot.card=null
 if id=="":
  var sold: Label = _text("SOLD",Rect2(10,90,238,64),30,Color("6c8a85"),root)
  sold.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  sold.rotation=deg_to_rad(-7)
  _text("GOOD CHOICE.",Rect2(60,163,180,28),12,Color("728d87"),root)
  return
 var data: Dictionary = Cat.data_for(id)
 var card: Control = CARD.instantiate()
 card.item_id=id
 card.motion_enabled=motion_enabled
 card.custom_minimum_size=Vector2.ZERO
 UIStyle.place(card,root,Rect2(48,0,162,216))
 card.inspected.connect(func(item: String): item_inspected.emit(item))
 slot.card=card
 _text(UIStyle.summary(data.desc,238,14),Rect2(10,225,238,52),14,UIStyle.MUTED,root)
 var price: Label = _text("",Rect2(12,286,118,40),28,UIStyle.GOLD,root)
 price.name="Price"
 slot.buy=_button("BUY",Rect2(134,284,112,40),func(): buy_requested.emit(id),Color("438368"),root,20)
 slot.buy.name="Buy"+id.capitalize()
 if motion_enabled:
  card.position.y=-16
  card.modulate.a=.3
  var arrival: Tween = card.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
  arrival.tween_property(card,"position:y",0.0,.26).set_delay(index*.035)
  arrival.tween_property(card,"modulate:a",1.0,.16).set_delay(index*.035)

func _fill_specials(game: Game) -> void:
 for child in _specials.get_children(): _specials.remove_child(child); child.queue_free()
 _sources.clear()
 if game.shop_upgrade!="":
  var id: String = game.shop_upgrade
  var panel: PanelContainer = UIStyle.panel(Color("493e34"),Color("a98a54"),0)
  UIStyle.place(panel,_specials,Rect2(0,0,442,76))
  var icon: TextureRect = UIStyle.texture(Cat.UPGRADES[id].art)
  UIStyle.place(icon,_specials,Rect2(8,8,52,52))
  _text(Cat.name_for(id),Rect2(66,9,236,28),17,UIStyle.GOLD,_specials)
  _text(Cat.UPGRADES[id].desc,Rect2(66,34,232,36),11,UIStyle.MUTED,_specials,true)
  var buy: Button = _button("BUY $%d" % game.cost_for(id),Rect2(308,16,124,44),func(): buy_requested.emit(id),Color("a27743"),_specials,17)
  buy.set_meta("purchase_id",id)
  buy.set_meta("cost",game.cost_for(id))
  _sources[id]=icon
 else: _text("UPGRADE REDEEMED",Rect2(40,22,370,32),18,Color("718a80"),_specials)
 var pack_panel: PanelContainer = UIStyle.panel(Color("3a3450"),Color("9780b2"),0)
 UIStyle.place(pack_panel,_specials,Rect2(460,0,356,76))
 var pack: TextureRect = UIStyle.texture("pack")
 UIStyle.place(pack,_specials,Rect2(466,10,52,52))
 _text("SUPPLY PACK",Rect2(524,12,198,22),17,UIStyle.CREAM,_specials)
 _text("CHOOSE 1 OF 3",Rect2(524,40,170,20),11,UIStyle.MUTED,_specials)
 if not game.shop_pack_bought:
  var cost: int = 0 if game.b().get("free_packs",false) else game.price(5)
  var open: Button = _button("OPEN $%d" % cost,Rect2(688,36,118,30),func(): pack_requested.emit(),Color("75608f"),_specials,14)
  open.set_meta("cost",cost)
  _sources["pack"]=pack
 else: _text("OPENED",Rect2(706,34,106,30),14,Color("a69bb6"),_specials)
 var heart: TextureRect = UIStyle.texture("heart")
 UIStyle.place(heart,_specials,Rect2(840,15,44,44))
 if game.hp<game.max_hp and not game.shop_heal_bought:
  var heal: Button = _button("HEAL $%d" % game.price(5),Rect2(894,17,184,44),func(): heal_requested.emit(),Color("a75c68"),_specials,18)
  heal.set_meta("cost",game.price(5))
 else: _text("LIFE %d/%d" % [game.hp,game.max_hp],Rect2(898,26,180,34),20,UIStyle.MUTED,_specials)
 _sources["heal"]=heart

func source_rect(id: String) -> Rect2:
 for slot in offers:
  if slot.id==id and is_instance_valid(slot.card): return slot.card.get_global_rect()
 if _sources.has(id) and is_instance_valid(_sources[id]): return _sources[id].get_global_rect()
 return Rect2(global_position+Vector2(480,240),Vector2(162,216))

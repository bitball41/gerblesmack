extends Control
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
signal pack_requested(slot: int)
signal heal_requested
signal next_requested
var motion_enabled := true
var wallet: Control
var offers: Array[Dictionary] = []
var _next_round: Button
var _reroll: Button
var _heal: Button
var _more: Button
var _market_page := 0
var _game: Game
var _specials: Control
var _special_signature := ""
var _sources: Dictionary = {}
var selected_offer := -1

func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_STOP
 resized.connect(func():
  if is_instance_valid(_specials): _specials.position.y=size.y-180
 )
 wallet=WALLET.instantiate()
 wallet.visible=false
 add_child(wallet)
 _next_round=_button("Next\nround",Rect2(20,74,144,86),func(): next_requested.emit(),Color("bd594c"))
 _reroll=_button("Reroll\n$3",Rect2(20,180,144,86),func(): reroll_requested.emit(),Color("328a69"))
 _more=_button("Offers >",Rect2(20,290,144,48),func():
  _market_page=(_market_page+1)%maxi(1,int(ceil(_game.shop_offers.size()/4.0)))
  sync(_game)
 ,Color("425c69"))
 _more.hide()
 _specials=Control.new()
 UIStyle.place(_specials,self,Rect2(20,400,856,160))
 for index in range(4):
  var slot := Control.new()
  UIStyle.place(slot,self,Rect2(184+index*172,28,164,330))
  offers.append({"id":"__unset","root":slot,"buy":null,"card":null})

func _draw() -> void:
 draw_rect(Rect2(20,382,856,2),Color("78928a65"))

func _text(text: String, rect: Rect2, font_size: int, color: Color = UIStyle.CREAM, parent: Node = null, wrap: bool = false) -> Label:
 var label: Label = UIStyle.label(text,font_size,color,true,wrap)
 UIStyle.place(label,self if parent==null else parent,rect)
 return label

func _button(text: String, rect: Rect2, action: Callable, color: Color, parent: Node = null) -> Button:
 var button: Button = BUTTON.instantiate()
 button.custom_minimum_size=Vector2.ZERO
 button.text=text
 button.base_color=color
 button.edge_color=color.lightened(.25)
 button.display_size=32
 button.padding=5
 button.motion_enabled=motion_enabled
 button.pressed.connect(action)
 UIStyle.place(button,self if parent==null else parent,rect)
 return button

func sync(game: Game) -> void:
 _game=game
 wallet.motion_enabled=motion_enabled
 wallet.set_amount(game.money)
 _reroll.text="Reroll\n$%d" % game.reroll_cost()
 _reroll.disabled=game.money.cmp(game.reroll_cost())<0
 _market_page=mini(_market_page,maxi(0,int(ceil(game.shop_offers.size()/4.0))-1))
 for index in range(4):
  var actual: int = _market_page*4+index
  var id: String = game.shop_offers[actual] if actual<game.shop_offers.size() else ""
  var slot: Dictionary = offers[index]
  if slot.id!=id: _fill_offer(index,id)
  if id!="" and is_instance_valid(slot.buy):
   slot.buy.disabled=not game.can_grant(id) or game.money.cmp(game.cost_for(id))<0
   slot.root.get_node("Price").text="$%d" % game.cost_for(id)
   slot.card.item_state=game.f.offer_tags.get(id,{})
   var preview: Dictionary = {"id":id,"growth":UIStyle.Num.new(1),"charge":0,"carry":0}
   preview.merge(slot.card.item_state,true)
   slot.card.live_note=Game.Rules.status(game,preview) if Cat.RELICS.has(id) else ""
   if game.f.locked_offer==id: slot.card.live_note+="\nLocked through rerolls"
   slot.card.queue_redraw()
 var signature: String = str([game.shop_upgrade,game.f.pack_offers,game.shop_heal_bought,game.hp,game.max_hp,game.floor_num])
 if signature!=_special_signature:
  _fill_specials(game)
  _special_signature=signature
 _more.visible=game.shop_offers.size()>4
 _more.text="Offers >" if _market_page==0 else "< Offers"
 _more.position.y=332 if is_instance_valid(_heal) else 290
 if is_instance_valid(_heal): _heal.disabled=game.money.cmp(game.price(5))<0
 for child in _specials.find_children("*","Button",true,false):
  if child.has_meta("pack_slot"):
   var slot: int = int(child.get_meta("pack_slot"))
   child.disabled=game.money.cmp(Game.Market.pack_cost(game,slot))<0 or not Game.Market.has_pack_room(game,slot)
  else:
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
 if id=="": return
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
 slot.buy=_button("BUY",Rect2(0,262,164,46),func(): buy_requested.emit(id),Color("328a69"),root)
 slot.buy.name="Buy"+id.capitalize()
 slot.buy.visible=false
 if motion_enabled:
  card.modulate.a=.3
  card.create_tween().tween_property(card,"modulate:a",1.0,.16).set_delay(index*.035)

func _fill_specials(game: Game) -> void:
 if is_instance_valid(_heal): remove_child(_heal); _heal.queue_free()
 _heal=null
 for child in _specials.get_children(): _specials.remove_child(child); child.queue_free()
 _sources.clear()
 if game.shop_upgrade!="":
  var id: String = game.shop_upgrade
  var ticket: Button = load("res://ui/art_button.gd").new()
  ticket.item_id=id
  ticket.custom_minimum_size=Vector2.ZERO
  ticket.pressed.connect(func(): upgrade_inspected.emit(id,_sources[id]))
  UIStyle.place(ticket,_specials,Rect2(0,0,332,160))
  ticket.set_meta("purchase_id",id)
  ticket.set_meta("cost",game.cost_for(id))
  var art := TextureRect.new()
  art.texture=load("res://assets/plates/voucher_"+id+".png")
  art.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
  art.mouse_filter=Control.MOUSE_FILTER_IGNORE
  UIStyle.place(art,ticket,Rect2(0,40,160,112))
  var price := _text("$%d" % game.cost_for(id),Rect2(0,0,160,36),30,UIStyle.GOLD,ticket)
  price.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  var name_label: Label = _text(Cat.name_for(id),Rect2(176,40,156,120),36,UIStyle.CREAM,ticket,true)
  for word in Cat.name_for(id).split(" "):
   if UIStyle.BODY.get_string_size(word,HORIZONTAL_ALIGNMENT_LEFT,-1,36).x>156: name_label.add_theme_font_size_override("font_size",27)
  _sources[id]=ticket
 else: _text("REDEEMED",Rect2(0,80,300,36),27,Color("7f9a8e"),_specials)
 for index in range(game.f.pack_offers.size()):
  var offer: Dictionary = game.f.pack_offers[index]
  var x: float = 500+index*188
  if offer.bought:
   var opened := _text("OPENED",Rect2(x,80,168,36),27,Color("7f9a8e"),_specials)
   opened.add_theme_font_size_override("font_size",27)
   opened.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
   continue
  var pack: Button = load("res://ui/art_button.gd").new()
  pack.custom_minimum_size=Vector2.ZERO
  pack.pressed.connect(func(slot: int = index): pack_requested.emit(slot))
  UIStyle.place(pack,_specials,Rect2(x,0,168,160))
  pack.set_meta("pack_slot",index)
  var art := TextureRect.new()
  art.texture=load("res://assets/plates/pack_"+str(offer.type)+"_"+str(offer.size).to_lower()+".png")
  art.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
  art.mouse_filter=Control.MOUSE_FILTER_IGNORE
  UIStyle.place(art,pack,Rect2(20,32,128,128))
  var price := _text("$%d" % Game.Market.pack_cost(game,index),Rect2(0,0,168,36),30,UIStyle.GOLD,pack)
  price.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  _sources["pack"+str(index)]=pack
 if game.hp<game.max_hp and not game.shop_heal_bought:
  _heal=_button("Heal $%d" % game.price(5),Rect2(20,278,144,48),func(): heal_requested.emit(),Color("9a5665"))

func source_rect(id: String) -> Rect2:
 for slot in offers:
  if slot.id==id and is_instance_valid(slot.card): return slot.card.get_global_rect()
 if _sources.has(id) and is_instance_valid(_sources[id]): return _sources[id].get_global_rect()
 return Rect2(global_position+Vector2(400,160),Vector2(112,156))

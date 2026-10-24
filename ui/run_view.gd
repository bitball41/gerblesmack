extends Control
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
const Game = preload("res://scripts/game.gd")
const BUTTON_SCENE: PackedScene = preload("res://scenes/ui/action_button.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/ui/card.tscn")
const TILE_SCENE: PackedScene = preload("res://scenes/ui/tile.tscn")
const WALLET_SCENE: PackedScene = preload("res://scenes/ui/wallet.tscn")
signal action_requested(action: String)
signal item_inspected(kind: String, index: int)
signal relic_reordered(from_index: int, to_index: int)
var sound_icon: TextureRect
var motion_enabled := true
var relic_cards: Array[Control] = []
var pocket_cards: Array[Control] = []
var _relic_signature := ""
var _pocket_signature := ""
var _target_label: Label
var _gate_name: Label
var _gate_subtitle: Label
var _guardian_note: Label
var _score_label: Label
var _remaining: Label
var _progress: ProgressBar
var _moves: Label
var _money: Label
var wallet: Control
var _hearts: Control
var _floor: Label
var _route: Control
var _relic_count: Label
var _pocket_count: Label
var _next: Control
var _board_tag: Label
var _spawn_badge: Label
var _receipt_points: Label
var _receipt_counts: Label
var _action: Button
var _auto: Button
var _speed: Button
var _seed: Label
var _target_note: Label
var _upgrade_zone: Control
var _score_tween: Tween
var _last_score: String = ""
var _displayed_score := 0.0
var _progress_tween: Tween
var _built := false
@onready var board: Control = $Board
@onready var rack: Control = $RelicRack
@onready var pocket: Control = $Pocket

func _ready() -> void:
 rack.z_index=3
 pocket.z_index=3
 board.z_index=1
 _build()

func _panel(rect: Rect2, bg: Color = UIStyle.PANEL, edge: Color = Color("526571")) -> PanelContainer:
 var node: PanelContainer = UIStyle.panel(bg,edge,10)
 UIStyle.place(node,self,rect)
 return node

func _text(text: String, rect: Rect2, font_size: int = 16, color: Color = UIStyle.TEXT, display: bool = false, parent: Node = null, wrap: bool = false) -> Label:
 var node: Label = UIStyle.label(text,font_size,color,display,wrap)
 UIStyle.place(node,parent if parent!=null else self,rect)
 return node

func _button(text: String, rect: Rect2, action: String, color: Color = Color("345a66"), edge: Color = Color("7b9eaa"), font_size: int = 21) -> Button:
 var node: Button = BUTTON_SCENE.instantiate()
 node.custom_minimum_size=Vector2.ZERO
 node.padding=4 if rect.size.y<40 else 12
 node.text=text
 node.display_size=font_size
 node.base_color=color
 node.edge_color=edge
 node.motion_enabled=motion_enabled
 node.pressed.connect(func(): action_requested.emit(action))
 UIStyle.place(node,self,rect)
 return node

func _build() -> void:
 _panel(Rect2(20,20,236,850))
 var mark: TextureRect = UIStyle.texture("gate",UIStyle.GOLD)
 UIStyle.place(mark,self,Rect2(36,37,32,43))
 _text("GATEFOLD",Rect2(74,40,170,48),32,UIStyle.CREAM,true)
 _panel(Rect2(34,102,208,177),Color("344855"),Color("6e8d98"))
 _gate_subtitle=_text("GATE 1 / 3",Rect2(44,113,188,18),11,UIStyle.MUTED)
 _gate_subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 _gate_name=_text("ENTRY GATE",Rect2(42,135,192,35),25,UIStyle.CREAM,true)
 _gate_name.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 _text("TARGET SCORE",Rect2(47,179,182,18),10,UIStyle.MUTED).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 _target_label=_text("96",Rect2(44,196,188,62),51,UIStyle.GOLD,true)
 _target_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 _guardian_note=_text("",Rect2(40,285,196,35),11,UIStyle.MUTED,false,self,true)
 _panel(Rect2(34,330,208,160),Color("17252e"),Color("405764"))
 _text("GATE SCORE",Rect2(47,344,180,20),11,UIStyle.MUTED)
 _score_label=_text("0",Rect2(47,365,182,67),60,UIStyle.CREAM,true)
 _progress=ProgressBar.new()
 _progress.show_percentage=false
 _progress.add_theme_stylebox_override("background",UIStyle.box(Color("0c1b23"),Color("405560"),3,0,0))
 _progress.add_theme_stylebox_override("fill",UIStyle.box(UIStyle.BLUE,UIStyle.BLUE,3,0,0))
 UIStyle.place(_progress,self,Rect2(48,438,180,9))
 _remaining=_text("96 TO GO",Rect2(47,459,185,20),10,UIStyle.MUTED)
 _panel(Rect2(34,506,100,105),Color("192932"),Color("46616e"))
 _panel(Rect2(144,506,98,105),Color("192932"),Color("46616e"))
 _text("MOVES",Rect2(40,518,87,18),11,UIStyle.MUTED).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 _text("BALANCE",Rect2(149,518,87,18),11,UIStyle.MUTED).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 _moves=_text("18",Rect2(40,543,87,56),45,UIStyle.BLUE,true)
 wallet=WALLET_SCENE.instantiate()
 wallet.display_size=38
 UIStyle.place(wallet,self,Rect2(152,543,82,56))
 _money=wallet.value_label
 _moves.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 _money.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 _panel(Rect2(34,629,208,50),Color("192b34"),Color("445a65"))
 _text("LIFE",Rect2(45,644,42,20),11,UIStyle.MUTED)
 _hearts=Control.new()
 UIStyle.place(_hearts,self,Rect2(89,637,144,33))
 _panel(Rect2(34,695,208,53),Color("192b34"),Color("445a65"))
 _text("FLOOR",Rect2(45,711,54,22),11,UIStyle.MUTED)
 _floor=_text("1 / 8",Rect2(105,704,78,37),28,UIStyle.GOLD,true)
 _route=Control.new()
 UIStyle.place(_route,self,Rect2(183,713,53,16))
 _button("MENU",Rect2(34,782,151,48),"menu",Color("db9850"),Color("efbe75"),22)
 _button("?",Rect2(196,782,46,48),"help",Color("447f99"),Color("8bb9c9"),23)
 _button("NEW RUN",Rect2(65,839,143,21),"new",Color("253440"),Color("253440"),12)
 _panel(Rect2(280,20,855,225),Color("102731a8"),Color("59777c88"))
 _panel(Rect2(1151,20,269,225),Color("102731a8"),Color("59777c88"))
 _text("RELIC ENGINE",Rect2(294,34,290,18),11,Color("d5e4df"))
 _relic_count=_text("1 / 5",Rect2(1042,31,76,25),17,UIStyle.CREAM,true)
 _relic_count.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 _text("SPELLS & RUNES",Rect2(1166,34,185,18),11,Color("d5e4df"))
 _pocket_count=_text("0 / 3",Rect2(1355,31,50,25),17,UIStyle.CREAM,true)
 _board_tag=_text("CLASSIC BOARD",Rect2(427,281,270,28),20,Color("abc9c4"),true)
 _text("NEXT",Rect2(762,289,42,17),11,UIStyle.MUTED)
 _next=TILE_SCENE.instantiate()
 UIStyle.place(_next,self,Rect2(809,282,34,34))
 _spawn_badge=_text("TIER 1",Rect2(851,291,115,20),10,Color("90b7b1"))
 board.position=Vector2(427,329)
 board.size=Vector2(490,490)
 _panel(Rect2(973,330,270,160),Color("e9dcaf"),Color("fbefc7"))
 _text("LAST SWIPE",Rect2(990,343,234,20),11,Color("6b6a55"))
 _receipt_points=_text("+0",Rect2(990,368,234,68),55,Color("293a40"),true)
 _receipt_counts=_text("MERGES 0    TRIGGERS 0",Rect2(990,455,234,20),11,Color("59675f"))
 _target_note=_text("",Rect2(425,830,506,28),15,UIStyle.GOLD,false,self,true)
 _action=_button("GATE CLEARED  →",Rect2(973,519,270,58),"phase",Color("d69d42"),Color("f4c46b"),25)
 _auto=_button("START AUTO  I",Rect2(973,601,270,52),"auto",Color("477f78"),Color("8ab7a7"),23)
 _upgrade_zone=Control.new()
 UIStyle.place(_upgrade_zone,self,Rect2(973,682,270,130))
 _text("UPGRADES",Rect2(0,0,250,20),11,UIStyle.MUTED,false,_upgrade_zone)
 _speed=_button("SPEED 1×",Rect2(1263,768,137,37),"speed",Color("284c57"),Color("577b81"),17)
 _seed=_text("CLASSIC BOARD · SEED",Rect2(284,865,700,22),10,Color("8fb4b2"))
 _text("WASD / ARROWS · SWIPE · SPACE TO AUTO",Rect2(880,865,450,22),10,Color("8fb4b2"))
 var sound: Button = _button("",Rect2(1330,843,36,34),"sound",Color("234752"),Color("577a80"),20)
 sound_icon=UIStyle.texture("ui_sound",Color("b2d2cd"))
 UIStyle.place(sound_icon,sound,Rect2(7,6,22,22))
 var fullscreen: Button = _button("",Rect2(1380,843,36,34),"fullscreen",Color("234752"),Color("577a80"),20)
 UIStyle.place(UIStyle.texture("ui_fullscreen",Color("b2d2cd")),fullscreen,Rect2(7,6,22,22))
 _built=true

func sync(game: Game, redraw_board: bool = true, auto_on: bool = false, speed: int = 1, target_text: String = "") -> void:
 if not _built: return
 var target = game.target()
 _target_label.text=target.fmt()
 UIStyle.fit(_target_label,50,18)
 _gate_subtitle.text="GATE %d / 3" % (game.gate+1)
 _gate_name.text=game.guardian().name.to_upper() if game.gate==2 else ["ENTRY GATE","INNER GATE"][game.gate]
 UIStyle.fit(_gate_name,24)
 _guardian_note.text=game.guardian().desc if game.gate==2 else ""
 var score_text: String = game.score.fmt()
 if score_text!=_last_score:
  if _score_tween and _score_tween.is_valid(): _score_tween.kill()
  if motion_enabled and game.swipes>0 and game.score.e<12 and game.score.m>0:
   _score_tween=create_tween()
   _score_tween.tween_method(_draw_score,_displayed_score,game.score.to_float(),.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
  else:
   _score_label.text=score_text
   _displayed_score=game.score.to_float() if game.score.e<12 else 0.0
  _last_score=score_text
 UIStyle.fit(_score_label,60,18)
 var ratio: float = clampf(pow(10,game.score.log10_value()-target.log10_value()),0,1) if game.score.m>0 else 0.0
 if _progress_tween and _progress_tween.is_valid(): _progress_tween.kill()
 if motion_enabled:
  _progress_tween=create_tween()
  _progress_tween.tween_property(_progress,"value",ratio*100,.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 else: _progress.value=ratio*100
 _remaining.text="GATE CLEARED" if ratio>=1 else target.minus(game.score).fmt()+" TO GO"
 _moves.text=str(game.moves)
 _moves.add_theme_color_override("font_color",UIStyle.RED if game.moves<=5 else UIStyle.BLUE)
 wallet.motion_enabled=motion_enabled
 wallet.set_amount(game.money)
 for child in _hearts.get_children(): _hearts.remove_child(child); child.queue_free()
 var heart_size: int = 23 if game.max_hp<=5 else 17
 for index in range(game.max_hp):
  var heart: TextureRect = UIStyle.texture("ui_heart")
  heart.modulate=Color.WHITE if index<game.hp else Color(.28,.33,.38)
  UIStyle.place(heart,_hearts,Rect2(144-game.max_hp*(heart_size+3)+index*(heart_size+3),5,heart_size,heart_size))
 _floor.text="%d / %s" % [game.floor_num,"INF" if game.endless else "8"]
 for child in _route.get_children(): _route.remove_child(child); child.queue_free()
 for index in range(3):
  var step: PanelContainer = UIStyle.panel(UIStyle.GREEN if index<game.gate else UIStyle.GOLD if index==game.gate else Color("101f28"),Color("6d848d"),0)
  UIStyle.place(step,_route,Rect2(index*17,0,12,12))
 _board_tag.text=game.b().name.to_upper()+" BOARD"
 _next.configure(game.next_tile)
 _spawn_badge.text="TIER %d" % (int(game.rune_levels.spawn)+1)
 _receipt_points.text="+"+game.last_merge.fmt()
 UIStyle.fit(_receipt_points,54,18)
 _receipt_counts.text="MERGES %d     TRIGGERS %d" % [game.last_entries.size(),game.last_triggers]
 _seed.text=game.b().name.to_upper()+" BOARD · SEED: "+game.seed_text
 _auto.visible=game.has_upgrade("auto1") and game.phase=="play" and not game.jammed
 _auto.text=("STOP AUTO " if auto_on else "START AUTO ")+("II" if game.has_upgrade("auto2") else "I")
 _speed.text="SPEED %d×" % speed
 _speed.visible=game.has_upgrade("auto1")
 _action.visible=game.phase!="play" or game.jammed or not target_text.is_empty()
 _action.text="CANCEL SPELL" if not target_text.is_empty() else "SHOP" if game.phase=="shop" else "RUN RESULTS" if game.phase=="over" else "TAKE A HIT  ·  −1 LIFE" if game.jammed else "GATE CLEARED" if game.phase=="reward" else "CONTINUE"
 _target_note.text=target_text
 board.targeting=not target_text.is_empty()
 board.motion_enabled=motion_enabled
 if redraw_board: board.show_cells(game.cells)
 _sync_cards(game)
 _sync_upgrades(game)

func _sync_cards(game: Game) -> void:
 var ids: Array = game.relics.map(func(relic): return relic.id)
 var signature: String = "|".join(ids)+str(game.max_relics())
 if signature!=_relic_signature:
  for node in rack.get_children(): rack.remove_child(node); node.queue_free()
  relic_cards.clear()
  var slot_width: float = (827.0-8*(game.max_relics()-1))/game.max_relics()
  for index in range(game.max_relics()):
   if index<ids.size():
    var card: Control = CARD_SCENE.instantiate()
    card.item_id=ids[index]
    card.drag_index=index
    card.motion_enabled=motion_enabled
    card.custom_minimum_size=Vector2.ZERO
    rack.add_child(card)
    card.position=Vector2(index*(slot_width+8),0)
    card.size=Vector2(slot_width,172)
    card.inspected.connect(func(_id: String, pos: int = index): item_inspected.emit("relic",pos))
    card.reorder_requested.connect(func(from: int,to: int): relic_reordered.emit(from,to))
    relic_cards.append(card)
   else:
    var empty: PanelContainer = UIStyle.panel(Color("15303855"),Color("6b8e8a55"),0)
    rack.add_child(empty)
    empty.position=Vector2(index*(slot_width+8),0)
    empty.size=Vector2(slot_width,172)
    var plus: Label = UIStyle.label("+",34,Color("9abdb640"),true)
    plus.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    plus.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
    empty.add_child(plus)
  _relic_signature=signature
 _relic_count.text="%d / %d" % [ids.size(),game.max_relics()]
 var pocket_signature: String = "|".join(game.inventory)+str(game.max_pocket())
 if pocket_signature!=_pocket_signature:
  for node in pocket.get_children(): pocket.remove_child(node); node.queue_free()
  pocket_cards.clear()
  var width: float = (241.0-7*(game.max_pocket()-1))/game.max_pocket()
  for index in range(game.max_pocket()):
   if index<game.inventory.size():
    var card: Control = CARD_SCENE.instantiate()
    card.item_id=game.inventory[index]
    card.custom_minimum_size=Vector2.ZERO
    card.motion_enabled=motion_enabled
    pocket.add_child(card)
    card.position=Vector2(index*(width+7),17)
    card.size=Vector2(width,142)
    card.inspected.connect(func(_id: String, pos: int = index): item_inspected.emit("inventory",pos))
    pocket_cards.append(card)
   else:
    var empty: PanelContainer = UIStyle.panel(Color("15303855"),Color("6b8e8a55"),0)
    pocket.add_child(empty)
    empty.position=Vector2(index*(width+7),34)
    empty.size=Vector2(width,110)
  _pocket_signature=pocket_signature
 _pocket_count.text="%d / %d" % [game.inventory.size(),game.max_pocket()]

func _sync_upgrades(game: Game) -> void:
 for child in _upgrade_zone.get_children():
  if child is TextureRect: _upgrade_zone.remove_child(child); child.queue_free()
 for index in range(game.upgrades.size()):
  var id: String = game.upgrades[index]
  var icon: TextureRect = UIStyle.texture(Cat.UPGRADES[id].art,UIStyle.GOLD)
  UIStyle.place(icon,_upgrade_zone,Rect2((index%6)*43,25+int(index/6.0)*44,36,40))
  icon.mouse_filter=Control.MOUSE_FILTER_STOP
  icon.tooltip_text=Cat.UPGRADES[id].name+"\n"+Cat.UPGRADES[id].desc

func destination_rect(id: String) -> Rect2:
 var destination: Control = card_for(id)
 return destination.get_global_rect() if destination!=null else Rect2(Vector2(1000,706),Vector2(40,40))

func card_for(id: String) -> Control:
 for card in relic_cards:
  if card.item_id==id: return card
 for index in range(pocket_cards.size()-1,-1,-1):
  if pocket_cards[index].item_id==id: return pocket_cards[index]
 for icon in _upgrade_zone.get_children():
  if icon is TextureRect and icon.tooltip_text.begins_with(Cat.name_for(id)+"\n"): return icon
 return null

func pulse_acquired(id: String, delay: float = 0.0) -> void:
 for card in relic_cards+pocket_cards:
  if card.item_id==id: card.pulse(delay)

func pulse_scoring(game: Game) -> void:
 if not motion_enabled: return
 var order := 0
 for index in range(game.relics.size()):
  if game.fired_relics.has(game.relics[index].id) and index<relic_cards.size():
   relic_cards[index].pulse(order*.03)
   order+=1
 if game.last_merge.m>0:
  _score_label.pivot_offset=Vector2(60,30)
  _score_label.scale=Vector2(1.08,1.08)
  create_tween().tween_property(_score_label,"scale",Vector2.ONE,.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw_score(value: float) -> void:
 _displayed_score=value
 _score_label.text=UIStyle.number(roundf(value))
 UIStyle.fit(_score_label,60,18)

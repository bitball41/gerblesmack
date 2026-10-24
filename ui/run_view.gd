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
var _play_controls: Array[CanvasItem] = []
var _sidebar_background: PanelContainer
var _sidebar_bottom: Array[Control] = []
var _sidebar_play: Array[CanvasItem] = []
var _phase_heading: Label
var _balance_heading: Label
var _controls_hint: Label
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
 _sidebar_background=_panel(Rect2(0,0,252,900),Color("23343c"),Color("536268"))
 _text("GATEFOLD",Rect2(28,32,200,48),32,UIStyle.CREAM,true)
 var sidebar_start: int = get_child_count()
 _gate_subtitle=_text("Gate 1 / 3",Rect2(32,108,188,36),32,UIStyle.MUTED)
 _gate_name=_text("Entry Gate",Rect2(32,146,188,72),32,UIStyle.CREAM,false,self,true)
 _text("Target",Rect2(32,228,188,36),32,UIStyle.MUTED)
 _target_label=_text("96",Rect2(32,260,188,72),64,UIStyle.GOLD,true)
 _text("Gate score",Rect2(32,346,188,36),32,UIStyle.MUTED)
 _score_label=_text("0",Rect2(32,378,188,72),64,UIStyle.CREAM,true)
 _progress=ProgressBar.new()
 _progress.show_percentage=false
 _progress.add_theme_stylebox_override("background",UIStyle.box(Color("14242b"),Color("14242b"),0,0,0))
 _progress.add_theme_stylebox_override("fill",UIStyle.box(UIStyle.BLUE,UIStyle.BLUE,0,0,0))
 UIStyle.place(_progress,self,Rect2(32,454,188,6))
 _remaining=_text("96 to go",Rect2(32,467,188,36),32,UIStyle.MUTED)
 _text("Moves",Rect2(32,514,120,36),32,UIStyle.MUTED)
 _moves=_text("18",Rect2(152,510,76,48),48,UIStyle.BLUE,true)
 for index in range(sidebar_start,get_child_count()): _sidebar_play.append(get_child(index))
 _phase_heading=_text("Shop",Rect2(32,124,188,166),48,UIStyle.CREAM,false,self,true)
 _phase_heading.visible=false
 _balance_heading=_text("Balance",Rect2(32,590,188,36),32,UIStyle.MUTED)
 wallet=WALLET_SCENE.instantiate()
 wallet.display_size=48
 UIStyle.place(wallet,self,Rect2(32,624,196,64))
 _money=wallet.value_label
 var bottom_start: int = get_child_count()
 _text("Life",Rect2(32,708,80,36),32,UIStyle.MUTED)
 _hearts=Control.new()
 UIStyle.place(_hearts,self,Rect2(90,708,144,33))
 _floor=_text("1 / 8",Rect2(32,758,120,48),48,UIStyle.GOLD,true)
 _route=Control.new()
 UIStyle.place(_route,self,Rect2(177,773,53,16))
 _button("Options",Rect2(28,832,196,48),"menu",Color("bd8536"),Color("e1b96a"),32)
 for index in range(bottom_start,get_child_count()): _sidebar_bottom.append(get_child(index))
 _text("RELICS",Rect2(330,65,170,20),15,UIStyle.MUTED)
 _relic_count=_text("1 / 5",Rect2(1010,65,75,24),15,UIStyle.MUTED)
 _text("POCKET",Rect2(1150,65,160,20),15,UIStyle.MUTED)
 _pocket_count=_text("0 / 3",Rect2(1310,65,65,24),15,UIStyle.MUTED)
 rack.position=Vector2(288,106)
 rack.size=Vector2(848,192)
 pocket.position=Vector2(1150,106)
 pocket.size=Vector2(225,156)
 var play_start: int = get_child_count()
 _board_tag=_text("CLASSIC BOARD",Rect2(510,321,340,40),32,UIStyle.MUTED,true)
 _text("NEXT",Rect2(852,323,74,36),32,UIStyle.MUTED)
 _next=TILE_SCENE.instantiate()
 UIStyle.place(_next,self,Rect2(936,321,36,36))
 _spawn_badge=_text("TIER 1",Rect2(1024,744,300,36),32,UIStyle.MUTED)
 board.position=Vector2(510,370)
 board.size=Vector2(420,420)
 _text("Last swipe",Rect2(1024,393,300,38),32,UIStyle.MUTED)
 _receipt_points=_text("+0",Rect2(1024,434,300,64),64,UIStyle.CREAM,true)
 _receipt_counts=_text("MERGES 0\nTRIGGERS 0",Rect2(1024,514,300,72),32,UIStyle.MUTED)
 _target_note=_text("",Rect2(510,807,620,42),15,UIStyle.GOLD,false,self,true)
 _action=_button("CONTINUE",Rect2(1024,606,340,54),"phase",Color("b95e50"),Color("dd8d72"),20)
 _auto=_button("START AUTO I",Rect2(1024,676,220,48),"auto",Color("327a69"),Color("78b99b"),20)
 _guardian_note=_text("",Rect2(1024,250,360,104),32,UIStyle.MUTED,false,self,true)
 _upgrade_zone=Control.new()
 UIStyle.place(_upgrade_zone,self,Rect2(1150,235,225,90))
 _text("Upgrades",Rect2(0,0,225,36),32,UIStyle.MUTED,false,_upgrade_zone)
 _speed=_button("SPEED 1x",Rect2(1256,676,138,48),"speed",Color("345360"),Color("6f8b93"),15)
 for index in range(play_start,get_child_count()): _play_controls.append(get_child(index))
 _seed=_text("",Rect2(288,866,750,22),15,Color("75918f"))
 _controls_hint=_text("WASD / ARROWS / SWIPE",Rect2(1080,859,300,22),15,Color("75918f"))
 _seed.add_theme_font_size_override("font_size",16)
 _controls_hint.add_theme_font_size_override("font_size",16)
 # Audio and display controls live in Options; no permanent utility buttons.
 sound_icon=UIStyle.texture("ui_sound")
 sound_icon.visible=false
 add_child(sound_icon)
 _built=true

func sync(game: Game, redraw_board: bool = true, auto_on: bool = false, speed: int = 1, target_text: String = "") -> void:
 if not _built: return
 var in_play: bool = game.phase not in ["shop","gates"]
 for control in _play_controls: control.visible=in_play
 for control in _sidebar_play: control.visible=in_play
 board.visible=in_play
 _phase_heading.visible=not in_play
 _phase_heading.text="Shop" if game.phase=="shop" else "Choose your next gate"
 _phase_heading.add_theme_font_size_override("font_size",48 if game.phase=="shop" else 32)
 _balance_heading.position.y=590 if in_play else 350
 wallet.position.y=624 if in_play else 388
 _seed.visible=in_play
 _controls_hint.visible=in_play
 _upgrade_zone.visible=not game.upgrades.is_empty()
 _controls_hint.text="CLICK A CARD TO SELECT" if game.phase=="shop" else "WASD / ARROWS / SWIPE"
 var target = game.target()
 _target_label.text=target.fmt()
 UIStyle.fit(_target_label,64,32)
 _gate_subtitle.text="GATE %d / 3" % (game.gate+1)
 _gate_name.text=game.guardian().name if game.gate==2 else ["Entry Gate","Inner Gate"][game.gate]
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
 UIStyle.fit(_score_label,64,32)
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
 UIStyle.fit(_receipt_points,64,32)
 _receipt_counts.text="MERGES %d\nTRIGGERS %d" % [game.last_entries.size(),game.last_triggers]
 _seed.text=game.b().name.to_upper()+" BOARD · SEED: "+game.seed_text
 _auto.visible=game.has_upgrade("auto1") and game.phase=="play" and not game.jammed
 _auto.text=("STOP AUTO " if auto_on else "START AUTO ")+("II" if game.has_upgrade("auto2") else "I")
 _speed.text="SPEED %d×" % speed
 _speed.visible=game.has_upgrade("auto1") and game.phase=="play"
 _action.visible=game.phase not in ["shop","gates"] and (game.phase!="play" or game.jammed or not target_text.is_empty())
 _action.text="CANCEL SPELL" if not target_text.is_empty() else "SHOP" if game.phase=="shop" else "RUN RESULTS" if game.phase=="over" else "TAKE A HIT  ·  -1 LIFE" if game.jammed else "GATE CLEARED" if game.phase=="reward" else "CONTINUE"
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
  var slot_width := 164.0
  var step: float = minf(180.0,(848.0-slot_width)/maxi(1,game.max_relics()-1))
  for index in range(ids.size()):
   var card: Control = CARD_SCENE.instantiate()
   card.item_id=ids[index]
   card.drag_index=index
   card.motion_enabled=motion_enabled
   card.custom_minimum_size=Vector2.ZERO
   rack.add_child(card)
   card.position=Vector2(index*step,0)
   card.size=Vector2(slot_width,192)
   card.inspected.connect(func(_id: String, pos: int = index): item_inspected.emit("relic",pos))
   card.reorder_requested.connect(func(from: int,to: int): relic_reordered.emit(from,to))
   relic_cards.append(card)
  _relic_signature=signature
 _relic_count.text="%d / %d" % [ids.size(),game.max_relics()]
 var pocket_signature: String = "|".join(game.inventory)+str(game.max_pocket())
 if pocket_signature!=_pocket_signature:
  for node in pocket.get_children(): pocket.remove_child(node); node.queue_free()
  pocket_cards.clear()
  var width := 68.0
  var step: float = minf(79.0,(225.0-width)/maxi(1,game.max_pocket()-1))
  for index in range(game.inventory.size()):
   var card: Control = CARD_SCENE.instantiate()
   card.item_id=game.inventory[index]
   card.custom_minimum_size=Vector2.ZERO
   card.motion_enabled=motion_enabled
   pocket.add_child(card)
   card.position=Vector2(index*step,0)
   card.size=Vector2(width,112)
   card.inspected.connect(func(_id: String, pos: int = index): item_inspected.emit("inventory",pos))
   pocket_cards.append(card)
  _pocket_signature=pocket_signature
 _pocket_count.text="%d / %d" % [game.inventory.size(),game.max_pocket()]
 for index in range(relic_cards.size()):
  relic_cards[index].live_note=live_state(game,game.relics[index])

func _sync_upgrades(game: Game) -> void:
 for child in _upgrade_zone.get_children():
  if child is TextureRect: _upgrade_zone.remove_child(child); child.queue_free()
 for index in range(game.upgrades.size()):
  var id: String = game.upgrades[index]
  var icon: TextureRect = UIStyle.texture(Cat.UPGRADES[id].art,UIStyle.GOLD)
  UIStyle.place(icon,_upgrade_zone,Rect2((index%6)*36,38+int(index/6.0)*36,30,30))
  icon.mouse_filter=Control.MOUSE_FILTER_STOP
  icon.set_meta("item_id",id)
  icon.mouse_entered.connect(func():
   var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
   if host: host._show_item_preview(id,"Owned upgrade",icon)
  )
  icon.mouse_exited.connect(func():
   var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
   if host: host._hide_item_preview(icon)
  )

func destination_rect(id: String) -> Rect2:
 var destination: Control = card_for(id)
 return destination.get_global_rect() if destination!=null else Rect2(Vector2(1000,706),Vector2(40,40))

func card_for(id: String) -> Control:
 for card in relic_cards:
  if card.item_id==id: return card
 for index in range(pocket_cards.size()-1,-1,-1):
  if pocket_cards[index].item_id==id: return pocket_cards[index]
 for icon in _upgrade_zone.get_children():
  if icon is TextureRect and icon.get_meta("item_id","")==id: return icon
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
 UIStyle.fit(_score_label,64,32)

static func live_state(game: Game, relic: Dictionary) -> String:
 match relic.id:
  "monolith","compound": return "Current  x"+UIStyle.precise(relic.growth)
  "battery": return "Stored  +"+UIStyle.precise(relic.charge)+" points"
  "charity": return "Current  x"+UIStyle.precise(game.money.div(10).floored().plus(1))
  "apprentice": return "Current  x"+UIStyle.precise(1+game.rune_uses*.25)+" / "+str(game.rune_uses)+" runes used"
  "steelworks":
   var count: int = game.cells.filter(func(tile): return tile!=null and tile.fx.get("steel",false)).size()
   return "Current  x"+UIStyle.precise(UIStyle.Num.power(1.2,count))+" / "+str(count)+" steel tiles"
  "feedback": return "Trigger progress  "+str(int(relic.carry))+" / 5"
  "resonance": return "Resets each swipe"
 return ""

func adapt_canvas(dimensions: Vector2) -> void:
 if not _built: return
 _sidebar_background.size.y=dimensions.y
 for control in _sidebar_bottom:
  if not control.has_meta("original_y"): control.set_meta("original_y",control.position.y)
  control.position.y=float(control.get_meta("original_y"))+dimensions.y-900
 _seed.position.y=dimensions.y-34
 _controls_hint.position.y=dimensions.y-34

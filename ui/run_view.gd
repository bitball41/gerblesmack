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
var _receipt_heading: Label
var scoring := false
var visible_score = UIStyle.Num.new()
var _active_relic: Control
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
var _life_heading: Label
var _floor_heading: Label
var _route_heading: Label
var _options: Button
var _sidebar_rules: Array[ColorRect] = []
var _shop_sign: TextureRect
var _in_play := true
var _canvas_size := Vector2(1440,900)
var _relic_meter: Control
var _pocket_meter: Control
var _sidebar_play: Array[CanvasItem] = []
var _phase_heading: Label
var _balance_heading: Label
var board_button: Button
var _board_art: TextureRect
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
 var sidebar_skin: StyleBoxFlat = _sidebar_background.get_theme_stylebox("panel")
 sidebar_skin.corner_radius_top_left=0
 sidebar_skin.corner_radius_bottom_left=0
 _text("GATEFOLD",Rect2(28,28,200,48),32,UIStyle.CREAM,true)
 for y in [96,464,664]:
  var rule := ColorRect.new()
  rule.color=Color("71878060")
  rule.mouse_filter=Control.MOUSE_FILTER_IGNORE
  UIStyle.place(rule,self,Rect2(28,y,196,2))
  _sidebar_rules.append(rule)
 _shop_sign=TextureRect.new()
 _shop_sign.texture=preload("res://assets/plates/shop_sign.png")
 _shop_sign.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 _shop_sign.mouse_filter=Control.MOUSE_FILTER_IGNORE
 UIStyle.place(_shop_sign,self,Rect2(30,128,192,96))
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
 _life_heading=_text("Life",Rect2(28,708,80,36),32,UIStyle.MUTED)
 _hearts=Control.new()
 UIStyle.place(_hearts,self,Rect2(80,708,144,33))
 _floor=_text("1 / 8",Rect2(28,758,120,48),48,UIStyle.CREAM,true)
 _floor_heading=_text("Floor",Rect2(28,552,92,36),27,UIStyle.MUTED)
 _route_heading=_text("Gates",Rect2(28,608,92,36),27,UIStyle.MUTED)
 _route=Control.new()
 UIStyle.place(_route,self,Rect2(177,773,53,16))
 _options=_button("Options",Rect2(28,832,196,48),"menu",Color("34515b"),Color("708c90"),32)
 _text("RELICS",Rect2(288,60,116,36),27,UIStyle.MUTED)
 _relic_count=_text("1 / 5",Rect2(404,60,100,36),27,UIStyle.CREAM)
 _relic_meter=load("res://ui/slot_meter.gd").new()
 UIStyle.place(_relic_meter,self,Rect2(520,76,160,12))
 _text("POCKET",Rect2(1150,60,98,36),27,UIStyle.MUTED)
 _pocket_count=_text("0 / 3",Rect2(1248,60,80,36),27,UIStyle.CREAM)
 _pocket_meter=load("res://ui/slot_meter.gd").new()
 UIStyle.place(_pocket_meter,self,Rect2(1340,76,64,12))
 rack.position=Vector2(288,106)
 rack.size=Vector2(848,192)
 pocket.position=Vector2(1150,106)
 pocket.size=Vector2(225,156)
 var play_start: int = get_child_count()
 _board_tag=_text("CLASSIC BOARD",Rect2(510,321,340,40),32,UIStyle.MUTED,true)
 _text("NEXT",Rect2(852,323,74,36),32,UIStyle.MUTED)
 _next=TILE_SCENE.instantiate()
 UIStyle.place(_next,self,Rect2(934,310,48,48))
 _spawn_badge=_text("TIER 1",Rect2(1024,744,300,36),32,UIStyle.MUTED)
 board.position=Vector2(510,370)
 board.size=Vector2(420,420)
 _receipt_heading=_text("Last swipe",Rect2(1024,393,300,38),32,UIStyle.MUTED)
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
 board_button=load("res://ui/art_button.gd").new()
 board_button.board_stack=true
 board_button.custom_minimum_size=Vector2.ZERO
 board_button.name="ViewBoard"
 board_button.pressed.connect(func(): action_requested.emit("board"))
 UIStyle.place(board_button,self,Rect2(1212,704,160,176))
 _board_art=TextureRect.new()
 _board_art.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 _board_art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 _board_art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 _board_art.mouse_filter=Control.MOUSE_FILTER_IGNORE
 UIStyle.place(_board_art,board_button,Rect2(12,4,128,160))
 board_button.hide()
 _built=true

func sync(game: Game, redraw_board: bool = true, auto_on: bool = false, speed: int = 1, target_text: String = "") -> void:
 if not _built: return
 var in_play: bool = game.phase not in ["shop","gates"]
 _in_play=in_play
 for control in _play_controls: control.visible=in_play
 for control in _sidebar_play: control.visible=in_play
 board.visible=in_play
 _phase_heading.visible=game.phase=="gates"
 _shop_sign.visible=game.phase=="shop"
 _phase_heading.text="Shop" if game.phase=="shop" else "Choose your next gate"
 _phase_heading.add_theme_font_size_override("font_size",54 if game.phase=="shop" else 36)
 _layout_sidebar()
 _seed.visible=in_play
 _controls_hint.visible=in_play
 board_button.visible=game.phase=="shop"
 _board_art.texture=UIStyle.sprite("board_"+game.board_id)
 _upgrade_zone.visible=not game.upgrades.is_empty()
 _controls_hint.text="CLICK A CARD TO SELECT" if game.phase=="shop" else "WASD / ARROWS / SWIPE"
 var target = game.target()
 _target_label.text=target.fmt()
 UIStyle.fit(_target_label,64,32)
 _gate_subtitle.text="GATE %d / 3" % (game.gate+1)
 _gate_name.text=game.guardian().name if game.gate==2 else ["Entry Gate","Inner Gate"][game.gate]
 _guardian_note.text=game.guardian().desc if game.gate==2 else ""
 _paint_score(visible_score if scoring else game.score,target,motion_enabled and not scoring and speed<8 and game.swipes>0)
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
 if not scoring:
  _receipt_heading.text="Last swipe"
  _receipt_points.text="+"+game.last_merge.fmt()
  _receipt_points.add_theme_color_override("font_color",UIStyle.CREAM)
  UIStyle.fit(_receipt_points,64,32)
  _receipt_counts.text="MERGES %d\nTRIGGERS %d" % [game.last_entries.size(),game.last_triggers]
  _receipt_counts.add_theme_color_override("font_color",UIStyle.MUTED)
 _seed.text=game.b().name.to_upper()+" BOARD / SEED: "+game.seed_text
 _auto.visible=game.has_upgrade("auto1") and game.phase=="play" and not game.jammed
 _auto.text=("STOP AUTO " if auto_on else "START AUTO ")+("II" if game.has_upgrade("auto2") else "I")
 _speed.text="SPEED %d×" % speed
 _speed.visible=game.has_upgrade("auto1") and game.phase=="play"
 _action.visible=not scoring and game.phase not in ["shop","gates"] and (game.phase!="play" or game.jammed or not target_text.is_empty())
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
  var step: float = minf(180.0,(848.0-slot_width)/maxi(1,ids.size()-1))
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
 _relic_meter.sync(ids.size(),game.max_relics())
 var pocket_signature: String = "|".join(game.inventory)+str(game.max_pocket())
 if pocket_signature!=_pocket_signature:
  for node in pocket.get_children(): pocket.remove_child(node); node.queue_free()
  pocket_cards.clear()
  var width := 68.0
  var step: float = minf(79.0,(225.0-width)/maxi(1,game.inventory.size()-1))
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
 _pocket_meter.sync(game.inventory.size(),game.max_pocket())
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

func begin_score_display(before) -> void:
 cancel_score_display()
 scoring=true
 visible_score=before
 _receipt_heading.text="Scoring"
 _receipt_points.text="0"
 _receipt_counts.text=""

func show_score_step(step: Dictionary, before, target) -> void:
 if not scoring: return
 if is_instance_valid(_active_relic): _active_relic.clear_score_feedback()
 _active_relic=null
 _receipt_points.text=UIStyle.Num.of(step.value).fmt()
 _receipt_points.add_theme_color_override("font_color",UIStyle.BLUE if step.kind=="retrigger" else UIStyle.GOLD)
 UIStyle.fit(_receipt_points,64,32)
 _receipt_counts.text=str(step.text)
 _receipt_counts.add_theme_color_override("font_color",UIStyle.CREAM)
 if step.has("id"):
  _active_relic=relic_cards[int(step.slot)] if step.has("slot") and int(step.slot)<relic_cards.size() else card_for(step.id)
  if is_instance_valid(_active_relic): _active_relic.score_trigger(step.text,step.kind=="retrigger")
  _receipt_counts.text=Cat.name_for(step.id)+"\n"+str(step.text)
 elif step.kind=="merge" and board.tiles.has(step.index):
  board.tiles[step.index].pop()
 if step.kind=="bank":
  visible_score=UIStyle.Num.of(before).plus(step.subtotal)
  _paint_score(visible_score,target,false)
  _receipt_points.text="+"+UIStyle.Num.of(step.subtotal).fmt()

func cancel_score_display() -> void:
 scoring=false
 if is_instance_valid(_active_relic): _active_relic.clear_score_feedback()
 _active_relic=null
 for card in relic_cards:
  if card.scoring_active: card.clear_score_feedback()

func _paint_score(value, target, animate: bool) -> void:
 var score_text: String = value.fmt()
 if score_text!=_last_score:
  if _score_tween and _score_tween.is_valid(): _score_tween.kill()
  if animate and value.e<12 and value.m>0:
   _score_tween=create_tween()
   _score_tween.tween_method(_draw_score,_displayed_score,value.to_float(),.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
  else:
   _score_label.text=score_text
   _displayed_score=value.to_float() if value.e<12 else 0.0
  _last_score=score_text
 UIStyle.fit(_score_label,64,32)
 var ratio: float = clampf(pow(10,value.log10_value()-target.log10_value()),0,1) if value.m>0 else 0.0
 if _progress_tween and _progress_tween.is_valid(): _progress_tween.kill()
 if animate:
  _progress_tween=create_tween()
  _progress_tween.tween_property(_progress,"value",ratio*100,.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 else: _progress.value=ratio*100
 _remaining.text="GATE CLEARED" if ratio>=1 else target.minus(value).fmt()+" TO GO"

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

func _layout_sidebar() -> void:
 var delta: float = _canvas_size.y-900
 _balance_heading.position=Vector2(28,590 if _in_play else 336)
 wallet.position=Vector2(28,624 if _in_play else 376)
 _life_heading.position.y=708+delta if _in_play else 488
 _hearts.position.y=_life_heading.position.y
 _floor_heading.visible=not _in_play
 _route_heading.visible=not _in_play
 _floor.position=Vector2(28,758+delta) if _in_play else Vector2(120,548)
 _floor.size.x=120 if _in_play else 104
 _floor.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT if _in_play else HORIZONTAL_ALIGNMENT_RIGHT
 _floor.add_theme_font_size_override("font_size",54 if _in_play else 36)
 _route.position=Vector2(177,773+delta) if _in_play else Vector2(178,620)
 _options.position.y=_canvas_size.y-68
 for index in range(_sidebar_rules.size()): _sidebar_rules[index].visible=index==0 or not _in_play

func adapt_canvas(dimensions: Vector2) -> void:
 if not _built: return
 _canvas_size=dimensions
 _sidebar_background.size.y=dimensions.y
 board_button.position=Vector2(dimensions.x-228,dimensions.y-196)
 _layout_sidebar()
 _seed.position.y=dimensions.y-34
 _controls_hint.position.y=dimensions.y-34

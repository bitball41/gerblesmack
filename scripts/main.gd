extends Control
const UIStyle = preload("res://ui/skin.gd")
const Game = preload("res://scripts/game.gd")
const Cat = preload("res://scripts/catalog.gd")
const Num = preload("res://scripts/num.gd")
const BUTTON_SCENE: PackedScene = preload("res://scenes/ui/action_button.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/ui/card.tscn")
const RUN_SELECT_SCENE: PackedScene = preload("res://scenes/ui/run_select.tscn")
const SHOP_SCENE: PackedScene = preload("res://scenes/ui/shop.tscn")
const PACK_SCENE: PackedScene = preload("res://scenes/ui/pack.tscn")
@export_range(.06,.3) var slide_duration := .135
@export_range(1,4) var buffered_input_limit := 3
var g: Game = Game.new()
var chosen_board := "red"
var board_page := 0
var seed_input := ""
var sound_on := true
var reduced_motion := false
var auto_speed := 1
var auto_on := false
var auto_thinking := false
var home_active := true
var has_run := false
var awaiting_spell := -1
var first_target := -1
var moving := false
var _input_buffer: Array[String] = []
var _action_epoch := 0
var _auto_epoch := 0
var _move_epoch := 0
var _move_exponent := 0
var _inspector_return := ""
var _collection_category := "relic"
var _stick := Vector2.ZERO
var _stick_latched := false
var _record_floor := 0
var _record_score = Num.new()
var shop_view: Control
var run_selector: Control
var _toast_node: Label
var _toast_panel: PanelContainer
var auto_timer: Timer
@onready var home: Control = $Home
@onready var run_view: Control = $Run
@onready var overlay: Control = $Overlay
@onready var effects: Node2D = $Feedback
@onready var backdrop: ColorRect = $Backdrop

func _ready() -> void:
 theme=UIStyle.default_theme()
 _load_preferences()
 effects.sound_enabled=sound_on
 effects.motion_enabled=not reduced_motion
 home.motion_enabled=not reduced_motion
 run_view.motion_enabled=not reduced_motion
 overlay.motion_enabled=not reduced_motion
 backdrop.material.set_shader_parameter("motion",0.0 if reduced_motion else 1.0)
 home.action_requested.connect(_home_action)
 run_view.action_requested.connect(_run_action)
 run_view.item_inspected.connect(_inspect_item)
 run_view.relic_reordered.connect(_reorder_to)
 run_view.wallet.count_tick.connect(func(): effects.play("coin"))
 run_view.board.swiped.connect(_request_move)
 run_view.board.cell_selected.connect(_tile_click)
 run_view.board.animation_finished.connect(_finish_move)
 overlay.close_requested.connect(_close_overlay)
 auto_timer=Timer.new()
 auto_timer.wait_time=.25/maxi(1,auto_speed)
 auto_timer.timeout.connect(_tick_auto)
 add_child(auto_timer)
 has_run=g.load_run()
 if has_run:
  chosen_board=g.board_id
  board_page=int(Cat.BOARDS.find(Cat.board(chosen_board))/10.0)
 _update_record()
 _show_home()

func _notification(what: int) -> void:
 if what==NOTIFICATION_WM_CLOSE_REQUEST: g.save_run()

func _input(event: InputEvent) -> void:
 # Gameplay owns directional input even if a card was last focused.
 if event is InputEventKey and not home_active and not overlay.visible:
  if event.pressed and not event.alt_pressed and not event.ctrl_pressed and not event.meta_pressed:
   var direction: String = {KEY_LEFT:"left",KEY_A:"left",KEY_RIGHT:"right",KEY_D:"right",KEY_UP:"up",KEY_W:"up",KEY_DOWN:"down",KEY_S:"down"}.get(event.keycode,"")
   if direction!="":
    if not event.echo: _request_move(direction)
    get_viewport().set_input_as_handled()
 if event is InputEventJoypadButton and event.pressed:
  if event.button_index in [JOY_BUTTON_START,JOY_BUTTON_B]:
   if overlay.visible and overlay.closable: _close_overlay()
   elif awaiting_spell>=0: _cancel_target()
   elif not home_active and not overlay.visible: _show_menu()
   get_viewport().set_input_as_handled()
  elif not home_active and not overlay.visible:
   var direction: String = {JOY_BUTTON_DPAD_LEFT:"left",JOY_BUTTON_DPAD_RIGHT:"right",JOY_BUTTON_DPAD_UP:"up",JOY_BUTTON_DPAD_DOWN:"down"}.get(event.button_index,"")
   if direction!="": _request_move(direction); get_viewport().set_input_as_handled()
 if event is InputEventJoypadMotion and event.axis in [JOY_AXIS_LEFT_X,JOY_AXIS_LEFT_Y]:
  if event.axis==JOY_AXIS_LEFT_X: _stick.x=event.axis_value
  else: _stick.y=event.axis_value
  if _stick.length()<.25: _stick_latched=false
  elif _stick.length()>.65 and not _stick_latched and not home_active and not overlay.visible:
   _stick_latched=true
   _request_move(("right" if _stick.x>0 else "left") if absf(_stick.x)>absf(_stick.y) else ("down" if _stick.y>0 else "up"))
   get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void:
 if event is not InputEventKey or not event.pressed: return
 var key_event: InputEventKey = event
 if key_event.keycode==KEY_ESCAPE:
  if overlay.visible:
   if overlay.closable: _close_overlay()
  elif awaiting_spell>=0: _cancel_target()
  elif not home_active: _show_menu()
  get_viewport().set_input_as_handled()
  return
 if overlay.visible or home_active or key_event.echo or key_event.alt_pressed or key_event.ctrl_pressed or key_event.meta_pressed: return
 var direction := ""
 match key_event.keycode:
  KEY_LEFT,KEY_A: direction="left"
  KEY_RIGHT,KEY_D: direction="right"
  KEY_UP,KEY_W: direction="up"
  KEY_DOWN,KEY_S: direction="down"
  KEY_SPACE: _toggle_auto()
 if direction!="": _request_move(direction)
 if direction!="" or key_event.keycode==KEY_SPACE: get_viewport().set_input_as_handled()

func _button(text: String, callback: Callable, color: Color = Color("345a66"), edge: Color = Color("7b9eaa"), font_size: int = 21) -> Button:
 var button: Button = BUTTON_SCENE.instantiate()
 button.text=text
 button.display_size=font_size
 button.base_color=color
 button.edge_color=edge
 button.motion_enabled=not reduced_motion
 button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 button.custom_minimum_size.y=45
 button.pressed.connect(func(): effects.play("click"); callback.call())
 button.mouse_entered.connect(func(): effects.play("hover"))
 return button

func _paragraph(text: String, color: Color = UIStyle.MUTED, font_size: int = 15) -> Label:
 var label: Label = UIStyle.label(text,font_size,color,false,true)
 label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 return label

func _open(title: String, id: String, dimensions: Vector2 = Vector2(930,710), closable: bool = true, top: float = -1) -> VBoxContainer:
 _stop_auto()
 _input_buffer.clear()
 _inspector_return=""
 return overlay.open(title,id,dimensions,closable,top)

func _close_overlay() -> void:
 var return_to: String = _inspector_return
 _inspector_return=""
 overlay.close()
 if return_to=="shop": _show_shop()
 elif return_to=="collection": _show_collection()
 elif not home_active: _refresh_run(false)

func _show_home() -> void:
 effects.clear_transients(true)
 backdrop.material.set_shader_parameter("shop",0.0)
 home_active=true
 _action_epoch+=1
 _stop_auto()
 moving=false
 _input_buffer.clear()
 run_view.board.cancel_animation()
 overlay.close()
 run_view.hide()
 home.show()
 home.build(g,has_run,_record_floor,_record_score.fmt())
 _update_sound_icons()

func _go_home() -> void:
 g.save_run()
 _update_record()
 _show_home()

func _home_action(action: String) -> void:
 effects.play("click")
 match action:
  "new": _show_new_run()
  "continue": _continue_run()
  "collection": _show_collection()
  "help": _show_help()
  "settings": _show_settings()
  "sound": _toggle_sound()
  "fullscreen": _toggle_fullscreen()

func _run_action(action: String) -> void:
 effects.play("click")
 match action:
  "menu": _show_menu()
  "new": _show_new_run()
  "help": _show_help()
  "phase":
   if awaiting_spell>=0: _cancel_target()
   elif g.jammed:
    g.finish_gate(false)
    _refresh_run()
    _show_result()
   elif g.phase=="shop": _show_shop()
   else: _show_result()
  "auto": _toggle_auto()
  "speed": _cycle_speed()
  "sound": _toggle_sound()
  "fullscreen": _toggle_fullscreen()

func _continue_run() -> void:
 if not has_run: return
 run_view.wallet.reset(g.money)
 home_active=false
 home.hide()
 run_view.show()
 _refresh_run()
 if g.phase=="shop": _show_shop()
 elif g.phase in ["reward","failed","over"]: _show_result()

func start_run(board_id: String = chosen_board, run_seed: String = seed_input) -> void:
 _action_epoch+=1
 moving=false
 run_view.board.cancel_animation()
 _input_buffer.clear()
 _stop_auto()
 awaiting_spell=-1
 first_target=-1
 effects.clear_transients(true)
 g.new_run(board_id,run_seed.strip_edges().to_upper())
 run_view.wallet.reset(g.money)
 board_page=int(Cat.BOARDS.find(Cat.board(board_id))/10.0)
 chosen_board=board_id
 has_run=true
 home_active=false
 overlay.close()
 home.hide()
 run_view.show()
 _refresh_run()
 effects.play("start")
 effects.banner("FLOOR 1",run_view._gate_name.text)

func _render() -> void:
 if home_active:
  home.build(g,has_run,_record_floor,_record_score.fmt())
  _update_sound_icons()
 else: _refresh_run()

func _target_text() -> String:
 if awaiting_spell<0 or awaiting_spell>=g.inventory.size(): return ""
 var id: String = g.inventory[awaiting_spell]
 var action: String = Cat.SPELLS[id].action
 return Cat.name_for(id)+": "+("choose an empty cell" if first_target>=0 or action=="spawn" else "choose a tile")

func _refresh_run(redraw: bool = true) -> void:
 var income: bool = run_view.wallet._initialized and g.money.cmp(run_view.wallet.target_amount)>0
 run_view.motion_enabled=not reduced_motion
 run_view.sync(g,redraw,auto_on,auto_speed,_target_text())
 backdrop.material.set_shader_parameter("shop",1.0 if g.phase=="shop" else 0.0)
 if income: effects.coin_stream(Vector2(674,550),run_view.wallet.global_position+Vector2(36,28),7)
 if g.storage_error!="": _toast(g.storage_error)

func _request_move(direction: String) -> void:
 if home_active or overlay.visible or awaiting_spell>=0 or g.phase!="play": return
 _stop_auto()
 if moving:
  if _input_buffer.size()<buffered_input_limit: _input_buffer.append(direction)
  return
 _play(direction)

func _play(direction: String) -> void:
 if moving or home_active or overlay.visible or awaiting_spell>=0 or g.phase!="play": return
 var before: Array = g.cells.duplicate(true)
 var slid: Dictionary = g.slide(direction)
 if not slid.changed: return
 if not g.move(direction): return
 moving=true
 _move_epoch=_action_epoch
 _refresh_run(false)
 run_view.pulse_scoring(g)
 var max_merged := 0
 for event in slid.events: max_merged=maxi(max_merged,int(event.tile.e))
 effects.play("merge" if not slid.events.is_empty() else "slide",clampi(max_merged-2,0,5))
 _move_exponent=max_merged
 if reduced_motion:
  run_view.board.show_cells(g.cells)
  _finish_move()
 else:
  run_view.board.animate_move(before,g.cells,direction,slide_duration/maxi(1,auto_speed) if auto_on else slide_duration)

func _finish_move() -> void:
 if _move_epoch!=_action_epoch or not moving: return
 var max_merged: int = _move_exponent
 moving=false
 if g.last_merge.m>0:
  effects.number_popup(Vector2(673,309),"+"+g.last_merge.fmt(),UIStyle.GOLD,max_merged>=10)
 if max_merged>=7: effects.burst(Vector2(673,565),UIStyle.GOLD,6 if max_merged<10 else 16)
 _update_record()
 if g.phase!="play":
  _input_buffer.clear()
  _stop_auto()
  effects.play("win" if g.phase=="reward" else "fail")
  if not overlay.visible: _show_result()
 elif g.jammed:
  _stop_auto()
  _toast("Board locked. Use a Spell or take a hit.")
 elif not _input_buffer.is_empty() and not overlay.visible:
  var next_direction: String = _input_buffer.pop_front()
  _play(next_direction)

func _stop_auto() -> void:
 _auto_epoch+=1
 auto_on=false
 if is_instance_valid(auto_timer): auto_timer.stop()

func _toggle_auto() -> void:
 if not g.has_upgrade("auto1") or home_active or overlay.visible or g.phase!="play" or g.jammed or awaiting_spell>=0: return
 auto_on=not auto_on
 if auto_on: auto_timer.start()
 else: _stop_auto()
 _refresh_run(false)

func _tick_auto() -> void:
 if auto_thinking or moving: return
 if home_active or overlay.visible or not auto_on or g.phase!="play" or g.jammed:
  _stop_auto()
  return
 auto_thinking=true
 var original: String = g.export_run()
 var simulation: Game = Game.new()
 simulation.persist_enabled=false
 simulation.restore(g.snapshot())
 var Autoplayer = load("res://scripts/autoplayer.gd")
 var owner_ref: WeakRef = weakref(self)
 var search_epoch: int = _auto_epoch
 var cancelled: Callable = func() -> bool:
  var owner = owner_ref.get_ref()
  return owner==null or not owner.is_inside_tree() or owner._auto_epoch!=search_epoch or not owner.auto_on
 var direction: String = await Autoplayer.choose_async(simulation,g.has_upgrade("auto2"),get_tree(),cancelled)
 if owner_ref.get_ref()==null: return
 auto_thinking=false
 if not auto_on or home_active or overlay.visible or original!=g.export_run(): return
 if direction=="": _stop_auto()
 else: _play(direction)

func _reorder_to(from: int, to: int) -> void:
 if from<0 or to<0 or from>=g.relics.size() or to>=g.relics.size() or from==to: return
 _stop_auto()
 var relic: Dictionary = g.relics.pop_at(from)
 g.relics.insert(to,relic)
 g.save_run()
 effects.play("click")
 _refresh_run(false)

func _inspect_item(kind: String, index: int) -> void:
 var id: String = ""
 if kind=="relic" and index>=0 and index<g.relics.size(): id=g.relics[index].id
 elif kind=="inventory" and index>=0 and index<g.inventory.size(): id=g.inventory[index]
 if id=="": return
 _show_info(id,kind,index,"shop" if g.phase=="shop" else "")

func _show_info(id: String, kind: String = "collection", index: int = -1, return_to: String = "collection") -> void:
 var data: Dictionary = Cat.data_for(id)
 var col: VBoxContainer = _open(data.name,"inspector",Vector2(690,490))
 _inspector_return=return_to
 var row: HBoxContainer = UIStyle.row(25)
 col.add_child(row)
 var card: Control = CARD_SCENE.instantiate()
 card.item_id=id
 card.motion_enabled=not reduced_motion
 card.custom_minimum_size=Vector2(195,265)
 card.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
 row.add_child(card)
 var info: VBoxContainer = UIStyle.column(14)
 info.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 row.add_child(info)
 info.add_child(_paragraph(data.rarity.to_upper(),UIStyle.GOLD,12))
 info.add_child(_paragraph(data.desc,UIStyle.CREAM,17))
 if kind=="relic":
  var relic: Dictionary = g.relics[index]
  if id in ["monolith","compound"]: info.add_child(_paragraph("Current multiplier: ×"+Num.of(relic.growth).fmt(),UIStyle.GOLD))
  if id=="battery": info.add_child(_paragraph("Stored points: "+str(int(relic.charge)),UIStyle.GOLD))
  if index>0: info.add_child(_button("MOVE LEFT",func(): _reorder_to(index,index-1); _show_info(id,kind,index-1,return_to)))
  if index<g.relics.size()-1: info.add_child(_button("MOVE RIGHT",func(): _reorder_to(index,index+1); _show_info(id,kind,index+1,return_to)))
  if g.phase=="shop": info.add_child(_button("SELL  ·  $%d" % maxi(1,int(data.cost/2.0)),func(): _sell("relic",index),UIStyle.RED,Color("f4aa86")))
 elif kind=="inventory":
  if g.phase in ["play","shop"]: info.add_child(_button("USE",func(): _select_item(index),Color("438c75"),Color("84bd9c")))
  if g.phase=="shop": info.add_child(_button("SELL  ·  $%d" % maxi(1,int(data.cost/2.0)),func(): _sell("inventory",index),UIStyle.RED,Color("f4aa86")))

func _select_item(index: int) -> void:
 if index<0 or index>=g.inventory.size(): return
 var id: String = g.inventory[index]
 if Cat.RUNES.has(id) or id in ["mercy","hourglass"]:
  if not g.use_item(index):
   _toast("Life is full." if id=="mercy" else "That card cannot be used here.")
   return
  effects.play("buy")
  awaiting_spell=-1
  first_target=-1
  _refresh_run()
  if g.phase=="shop": _show_shop()
  else: overlay.close()
 else:
  if g.phase!="play": _toast("Use board Spells during a gate."); return
  awaiting_spell=index
  first_target=-1
  overlay.close()
  _refresh_run(false)

func _tile_click(index: int) -> void:
 if home_active or overlay.visible or moving: return
 if awaiting_spell<0: return
 if awaiting_spell>=g.inventory.size(): _cancel_target(); return
 var id: String = g.inventory[awaiting_spell]
 if id=="twins" and first_target<0:
  if g.cells[index]!=null:
   first_target=index
   run_view.board.selected_cell=index
   _refresh_run(false)
   run_view.board.queue_redraw()
  else: _toast("Choose an occupied source tile.")
  return
 if g.use_item(awaiting_spell,first_target if first_target>=0 else index,index if first_target>=0 else -1):
  awaiting_spell=-1
  first_target=-1
  effects.play("buy")
  effects.burst(Vector2(427,329)+run_view.board._cell_position(index)+run_view.board._cell_size()*.5,UIStyle.BLUE,8)
  _refresh_run()
 else: _toast("Choose a valid tile. Escape cancels the Spell.")

func _cancel_target() -> void:
 awaiting_spell=-1
 first_target=-1
 run_view.board.selected_cell=-1
 _refresh_run(false)
 run_view.board.queue_redraw()

func _show_result() -> void:
 if g.phase not in ["reward","failed","over"]: return
 var won: bool = g.phase=="reward"
 var ending: bool = won and g.floor_num==8 and g.gate==2 and not g.endless
 var title: String = "EIGHT FLOORS CLEARED" if ending else "GATE CLEARED" if won else "RUN OVER" if g.phase=="over" else "GATE FAILED"
 var col: VBoxContainer = _open(title,"result",Vector2(570,570))
 var art: TextureRect = UIStyle.texture("gate" if won else "heart" if g.hp>0 else "void",UIStyle.GOLD if won else UIStyle.RED)
 art.custom_minimum_size=Vector2(160,132)
 col.add_child(art)
 col.add_child(_paragraph("FLOOR %d · GATE %d / 3" % [g.floor_num,g.gate+1],UIStyle.MUTED,12))
 col.add_child(UIStyle.label("%s / %s" % [g.score.fmt(),g.target().fmt()],31,UIStyle.CREAM,true))
 if not won: col.add_child(_paragraph("−1 Life. Your two smallest tiles were cleared. Visit the shop, then retry this gate." if g.hp>0 else "Your engine reached floor %d and cleared %d gates." % [g.floor_num,g.cleared]))
 if not g.result_summary.is_empty():
  var summary: Dictionary = g.result_summary
  col.add_child(_paragraph("REWARD $%s   ·   INTEREST $%s   ·   FEE $%s" % [Num.of(summary.gross).fmt(),Num.of(summary.interest).fmt(),Num.of(summary.fee).fmt()],UIStyle.GOLD,14))
  if int(summary.get("banked",0))>0: col.add_child(_paragraph("%d moves banked for the next gate." % summary.banked))
 if g.phase!="over": col.add_child(_button("CONTINUE ENDLESS  →" if ending else "GO TO SHOP  →",func(): g.open_shop(); _refresh_run(false); _show_shop(),Color("438c75"),Color("84bd9c"),25))
 else: col.add_child(_button("NEW RUN",_show_new_run,Color("cf8050"),Color("f6c991"),25))
 col.add_child(_button("VIEW BOARD",func(): overlay.close()))

func _show_shop() -> void:
 if g.phase!="shop": return
 if not g.pack_choices.is_empty(): _show_pack(); return
 if overlay.visible and overlay.view_id=="shop" and is_instance_valid(shop_view) and shop_view.is_inside_tree():
  shop_view.sync(g)
  return
 _stop_auto()
 _input_buffer.clear()
 _inspector_return=""
 var host: Control = overlay.open_custom("shop",Vector2(1138,590),true,280)
 overlay.panel.position.x=280
 _shop_shade()
 shop_view=SHOP_SCENE.instantiate()
 shop_view.motion_enabled=not reduced_motion
 host.add_child(shop_view)
 shop_view.size=Vector2(1138,590)
 shop_view.buy_requested.connect(_buy)
 shop_view.item_inspected.connect(func(id: String): _show_info(id,"offer",-1,"shop"))
 shop_view.reroll_requested.connect(_reroll_shop)
 shop_view.pack_requested.connect(_open_shop_pack)
 shop_view.heal_requested.connect(_heal_shop)
 shop_view.next_requested.connect(_leave_shop)
 shop_view.sync(g)

func _shop_shade() -> void:
 overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var shade: ColorRect = overlay.get_child(0)
 shade.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
 shade.position=Vector2(270,260)
 shade.size=Vector2(1170,640)

func _buy(id: String) -> bool:
 var source: Rect2 = shop_view.source_rect(id) if is_instance_valid(shop_view) and shop_view.is_inside_tree() else Rect2(700,400,162,216)
 var cost: int = g.cost_for(id)
 if not g.buy_item(id):
  effects.play("fail")
  _toast("Check your balance and available slots.")
  return false
 _refresh_run(false)
 _show_shop()
 effects.play("buy")
 effects.coin_stream(run_view.wallet.global_position+Vector2(36,28),source.get_center(),mini(cost,8))
 effects.acquire_card(id,source,run_view.destination_rect(id),run_view.card_for(id))
 run_view.pulse_acquired(id,.34)
 return true

func _reroll_shop() -> void:
 if not g.reroll(): _toast("Not enough money to reroll."); return
 effects.play("shuffle")
 effects.coin_stream(run_view.wallet.global_position+Vector2(36,28),Vector2(942,340),5)
 _refresh_run(false)
 _show_shop()

func _open_shop_pack() -> void:
 if not g.pack_open(): _toast("Not enough money."); return
 effects.play("pack")
 _refresh_run(false)
 _show_pack()

func _heal_shop() -> void:
 if not g.heal_shop(): _toast("Not enough money to heal."); return
 effects.play("buy")
 effects.number_popup(Vector2(202,646),"+1 LIFE",UIStyle.RED)
 effects.burst(Vector2(192,650),UIStyle.RED,8)
 _refresh_run(false)
 _show_shop()

func _leave_shop() -> void:
 if g.phase!="shop" or not g.pack_choices.is_empty(): return
 g.leave_shop()
 overlay.close()
 _refresh_run()
 effects.play("start")
 effects.banner("FLOOR %d" % g.floor_num,run_view._gate_name.text)

func _sell(kind: String, index: int) -> void:
 var sold: bool = g.sell_relic(index) if kind=="relic" else g.sell_item(index)
 if not sold: return
 effects.play("cash")
 _refresh_run(false)
 _show_shop()

func _show_pack() -> void:
 _stop_auto()
 _input_buffer.clear()
 _inspector_return=""
 var host: Control = overlay.open_custom("pack",Vector2(1138,590),false,280)
 overlay.panel.position.x=280
 _shop_shade()
 var pack: Control = PACK_SCENE.instantiate()
 pack.choices=g.pack_choices.duplicate()
 pack.motion_enabled=not reduced_motion
 for id in pack.choices: pack.available[id]=g.can_grant(id)
 host.add_child(pack)
 pack.size=Vector2(1138,590)
 pack.picked.connect(_pick_pack)
 pack.skipped.connect(func(): g.pack_choices=[]; g.save_run(); _show_shop())

func _pick_pack(id: String) -> void:
 var source := Rect2(638,260,162,216)
 var cards: Array = overlay.find_children("*","Button",true,false).filter(func(node): return node.get_script()!=null and node.get_script().resource_path=="res://ui/card_view.gd")
 for card in cards:
  if card.item_id==id: source=card.get_global_rect(); break
 if not g.pack_choose(id): _toast("Your slots are full, or you already own that Relic."); return
 effects.play("buy")
 _refresh_run(false)
 _show_shop()
 effects.acquire_card(id,source,run_view.destination_rect(id),run_view.card_for(id))
 run_view.pulse_acquired(id,.34)

func _show_new_run() -> void:
 _stop_auto()
 _input_buffer.clear()
 _inspector_return=""
 var host: Control = overlay.open_custom("new",Vector2(1240,790),true,55)
 run_selector=RUN_SELECT_SCENE.instantiate()
 run_selector.chosen_board=chosen_board
 run_selector.page=board_page
 run_selector.seed_text=seed_input
 run_selector.motion_enabled=not reduced_motion
 host.add_child(run_selector)
 run_selector.size=Vector2(1240,790)
 run_selector.board_selected.connect(func(id: String): chosen_board=id)
 run_selector.page_changed.connect(func(index: int): board_page=index)
 run_selector.seed_changed.connect(func(value: String): seed_input=value)
 run_selector.start_requested.connect(start_run)
 run_selector.cancel_requested.connect(_close_overlay)
 run_selector.navigated.connect(func(): effects.play("select"))

func _show_menu() -> void:
 var col: VBoxContainer = _open("PAUSED","menu",Vector2(470,520))
 col.add_child(_button("RESUME",func(): overlay.close()))
 col.add_child(_button("MAIN MENU",_go_home))
 col.add_child(_button("NEW RUN",_show_new_run))
 col.add_child(_button("COLLECTION",_show_collection))
 col.add_child(_button("SETTINGS",_show_settings))
 col.add_child(_button("EXPORT RUN",func(): _save_dialog(false)))
 col.add_child(_paragraph("Runs save automatically.",UIStyle.MUTED,12))

func _show_help() -> void:
 var col: VBoxContainer = _open("HOW TO PLAY","help",Vector2(900,720))
 for section in [
  ["SLIDE. MERGE. BUILD.","WASD, arrow keys, or swipe. Equal tiles merge once per move. An invalid move costs nothing. Tiles have no maximum value."],
  ["FLOORS & GATES","Beat the target before your moves run out. Three gates make a floor. Targets triple each floor. Clear eight floors, then continue in endless."],
  ["LIFE & RETRIES","Missing a gate costs 1 Life and clears your two smallest tiles. Visit the shop, then retry. If the board locks, rescue it with a Spell or take a hit."],
  ["YOUR RELIC ENGINE","Relics resolve left to right. Drag them to reorder, inspect one for arrow buttons, or use Alt + Left/Right while focused. Flat bonuses and multipliers apply at their position. Repeats feed later Relics."],
  ["ENHANCED TILES","Gold pays $2 per merge. Glass scores ×2 but has a 25% shatter chance. Each Steel tile adds ×1.25 to every merge. An Echo mark runs scoring twice. Enhancements pass to merged tiles."],
  ["SPELLS, RUNES & UPGRADES","Inspect a pocket card to use it. Duplicate needs a source then an empty destination. Runes improve natural spawns. Upgrades last for the run. Space toggles purchased autoplay; manual input stops it. Escape cancels targeting or opens the menu."]
 ]:
  col.add_child(UIStyle.label(section[0],24,UIStyle.GOLD,true))
  col.add_child(_paragraph(section[1],UIStyle.CREAM,16))

func _show_collection(category: String = "") -> void:
 if category!="": _collection_category=category
 category=_collection_category
 var col: VBoxContainer = _open("COLLECTION","collection",Vector2(1050,755))
 var tabs: HBoxContainer = UIStyle.row(10)
 col.add_child(tabs)
 for entry in [["relic","RELICS"],["spell","SPELLS"],["rune","RUNES"],["upgrade","UPGRADES"]]:
  tabs.add_child(_button(entry[1],func(value: String = entry[0]): _show_collection(value),Color("345a66"),UIStyle.GOLD if entry[0]==category else Color("7b9eaa")))
 var pool: Dictionary = Cat.RELICS if category=="relic" else Cat.SPELLS if category=="spell" else Cat.RUNES if category=="rune" else Cat.UPGRADES
 var grid := GridContainer.new()
 grid.columns=5
 grid.add_theme_constant_override("h_separation",16)
 grid.add_theme_constant_override("v_separation",18)
 col.add_child(grid)
 for id in pool:
  var card: Control = CARD_SCENE.instantiate()
  card.item_id=id
  card.custom_minimum_size=Vector2(181,245)
  card.motion_enabled=not reduced_motion
  card.inspected.connect(func(item: String): _show_info(item,"collection",-1,"collection"))
  grid.add_child(card)

func _show_settings() -> void:
 var col: VBoxContainer = _open("SETTINGS","settings",Vector2(610,650))
 col.add_child(_button("SOUND EFFECTS  ·  "+("ON" if sound_on else "OFF"),func(): _toggle_sound(); _show_settings()))
 col.add_child(_button("REDUCED MOTION  ·  "+("ON" if reduced_motion else "OFF"),func(): _toggle_motion(); _show_settings()))
 col.add_child(_paragraph("Stops background drift, tile/card motion, flying coins, and animated counters. Moves resolve instantly.",UIStyle.MUTED,13))
 col.add_child(_button("AUTOPLAYER SPEED  ·  %d×" % auto_speed,func(): _cycle_speed(); _show_settings()))
 col.add_child(_button("TOGGLE FULLSCREEN",_toggle_fullscreen))
 if has_run: col.add_child(_button("EXPORT SAVED RUN",func(): _save_dialog(false)))
 col.add_child(_button("IMPORT SAVE",func(): _save_dialog(true)))
 col.add_child(_paragraph("Import accepts native saves and JSON from the original HTML game.",UIStyle.MUTED,13))

func _save_dialog(importing: bool) -> void:
 var col: VBoxContainer = _open("IMPORT SAVED RUN" if importing else "EXPORT SAVED RUN","save",Vector2(800,600))
 col.add_child(_paragraph("Paste your saved JSON below. A successful import replaces your current run." if importing else "Select and copy this JSON to back up your run.",UIStyle.CREAM,15))
 var editor := TextEdit.new()
 editor.name="SaveData"
 editor.custom_minimum_size=Vector2(0,320)
 editor.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
 if not importing: editor.text=g.export_run()
 col.add_child(editor)
 if importing:
  col.add_child(_button("IMPORT RUN",func():
   if g.import_run(editor.text):
    has_run=true
    awaiting_spell=-1
    first_target=-1
    chosen_board=g.board_id
    overlay.close()
    _continue_run()
   else: _toast("Invalid save. Your existing run is unchanged.")
  ,Color("438c75"),Color("84bd9c")))
 else:
  col.add_child(_button("SELECT ALL",func(): editor.grab_focus(); editor.select_all()))

func _toggle_sound() -> void:
 sound_on=not sound_on
 effects.sound_enabled=sound_on
 if not sound_on: effects.stop_audio()
 _update_sound_icons()
 _save_preferences()
 effects.play("click")

func _toggle_motion() -> void:
 reduced_motion=not reduced_motion
 effects.motion_enabled=not reduced_motion
 run_view.motion_enabled=not reduced_motion
 home.motion_enabled=not reduced_motion
 overlay.motion_enabled=not reduced_motion
 run_view.wallet.motion_enabled=not reduced_motion
 if is_instance_valid(shop_view) and shop_view.is_inside_tree():
  shop_view.motion_enabled=not reduced_motion
  shop_view.wallet.motion_enabled=not reduced_motion
 if is_instance_valid(run_selector) and run_selector.is_inside_tree(): run_selector.motion_enabled=not reduced_motion
 if reduced_motion:
  effects.clear_transients()
  run_view.wallet.reset(g.money)
  if is_instance_valid(shop_view) and shop_view.is_inside_tree(): shop_view.wallet.reset(g.money)
 backdrop.material.set_shader_parameter("motion",0.0 if reduced_motion else 1.0)
 for card in run_view.relic_cards+run_view.pocket_cards: card.set_motion(not reduced_motion)
 run_view.board.motion_enabled=not reduced_motion
 _save_preferences()

func _cycle_speed() -> void:
 auto_speed=[1,2,4,8][([1,2,4,8].find(auto_speed)+1)%4]
 auto_timer.wait_time=.25/auto_speed
 _save_preferences()
 if not home_active: _refresh_run(false)

func _toggle_fullscreen() -> void:
 DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)

func _load_preferences() -> void:
 var file := ConfigFile.new()
 if file.load("user://preferences.cfg")==OK:
  sound_on=bool(file.get_value("game","sound",true))
  reduced_motion=bool(file.get_value("game","reduced_motion",false))
  auto_speed=int(file.get_value("game","speed",1))
  if auto_speed not in [1,2,4,8]: auto_speed=1
 if file.load("user://records.cfg")==OK:
  _record_floor=int(file.get_value("records","floor",0))
  var stored = JSON.parse_string(str(file.get_value("records","score",'{"__num":[0,0]}')))
  if stored is Dictionary: _record_score=Num.of(stored)

func _save_preferences() -> void:
 var file := ConfigFile.new()
 file.set_value("game","sound",sound_on)
 file.set_value("game","reduced_motion",reduced_motion)
 file.set_value("game","speed",auto_speed)
 file.save("user://preferences.cfg")

func _update_record() -> void:
 if not has_run: return
 _record_floor=maxi(_record_floor,g.floor_num)
 if g.total_score.cmp(_record_score)>0: _record_score=g.total_score
 var file := ConfigFile.new()
 file.set_value("records","floor",_record_floor)
 file.set_value("records","score",JSON.stringify(_record_score.encode()))
 if g.persist_enabled: file.save("user://records.cfg")

func _toast(text: String) -> void:
 if is_instance_valid(_toast_panel): _toast_panel.queue_free()
 _toast_node=UIStyle.label(text,16,UIStyle.CREAM,false,true)
 var panel: PanelContainer = UIStyle.panel(Color("193644"),UIStyle.GOLD,14)
 _toast_panel=panel
 panel.z_index=120
 add_child(panel)
 panel.position=Vector2(380,22)
 panel.size=Vector2(680,50)
 panel.add_child(_toast_node)
 var tween: Tween = panel.create_tween()
 tween.tween_interval(2.7)
 tween.tween_property(panel,"modulate:a",0.0,.2)
 tween.tween_callback(panel.queue_free)

func _update_sound_icons() -> void:
 var texture: Texture2D = UIStyle.sprite("ui_sound" if sound_on else "ui_mute")
 for icon in [home.sound_icon,run_view.sound_icon]:
  if is_instance_valid(icon): icon.texture=texture

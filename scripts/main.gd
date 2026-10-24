extends Control
const Cat = preload("res://scripts/catalog.gd")
const Game = preload("res://scripts/game.gd")
var g = Game.new()
var chosen_board := "classic"
var auto_on := false
var auto_thinking := false
var awaiting_spell := -1
var first_target := -1
var touch_origin := Vector2.ZERO
var auto_timer: Timer
var board_page := 0
var seed_input := ""
var sound_on := true
var auto_speed := 1
var board_area: Control
var swipe_started := false
var active_dialog: Window
var tone_player: AudioStreamPlayer

const BG = Color("#101d25")
const PANEL = Color("#1a3039")
const PANEL_ALT = Color("#23444b")
const TEXT = Color("#f4e9d1")
const DIM = Color("#b9c9c1")
const GOLD = Color("#eec870")
const TILE_COLORS = ["#eee1ba","#f2c76e","#e3a052","#d4784a","#c25c61","#9569a7","#5883b4","#439a9a","#9cb15a","#e4b444","#e4cd8b"]
const GATE_NAMES = ["ENTRY GATE","INNER GATE","GUARDIAN GATE"]

func _ready() -> void:
 var preferences := ConfigFile.new()
 if preferences.load("user://preferences.cfg") == OK:
  sound_on=preferences.get_value("game","sound",true)
  auto_speed=int(preferences.get_value("game","speed",1))
 tone_player=AudioStreamPlayer.new()
 tone_player.volume_db=-18
 add_child(tone_player)
 auto_timer = Timer.new()
 auto_timer.wait_time = .22/maxi(1,auto_speed)
 auto_timer.timeout.connect(_tick_auto)
 add_child(auto_timer)
 if g.load_run():
  chosen_board = g.board_id
 g.phase = "home"
 _render()

func _notification(what: int) -> void:
 if what == NOTIFICATION_WM_CLOSE_REQUEST:
  g.save_run()

func _input(event: InputEvent) -> void:
 if is_instance_valid(active_dialog) and active_dialog.visible: return
 if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
  if awaiting_spell>=0:
   awaiting_spell=-1
   first_target=-1
   _render()
  elif g.phase!="home": _go_home()
  return
 if g.phase != "play": return
 if event is InputEventKey and event.pressed and not event.echo:
  var dir := ""
  match event.keycode:
   KEY_LEFT, KEY_A: dir = "left"
   KEY_RIGHT, KEY_D: dir = "right"
   KEY_UP, KEY_W: dir = "up"
   KEY_DOWN, KEY_S: dir = "down"
   KEY_SPACE:
    if g.has_upgrade("auto1"):
     _toggle_auto()
    get_viewport().set_input_as_handled()
    return
  if dir != "":
   _play(dir)
   get_viewport().set_input_as_handled()
 if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT):
  if awaiting_spell>=0 or not is_instance_valid(board_area): return
  if event.pressed:
   swipe_started=board_area.get_global_rect().has_point(event.position)
   touch_origin=event.position
  elif swipe_started:
   swipe_started=false
   var diff: Vector2 = event.position-touch_origin
   if diff.length()>25:
    _play(("right" if diff.x>0 else "left") if absf(diff.x)>absf(diff.y) else ("down" if diff.y>0 else "up"))

func _panel(color: Color = PANEL) -> PanelContainer:
 var p := PanelContainer.new()
 var style := StyleBoxFlat.new()
 style.bg_color = color
 style.set_corner_radius_all(10)
 style.content_margin_left = 15
 style.content_margin_right = 15
 style.content_margin_top = 13
 style.content_margin_bottom = 13
 p.add_theme_stylebox_override("panel",style)
 return p

func _label(s: String, size: int = 16, color: Color = TEXT) -> Label:
 var l := Label.new()
 l.text = s
 l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 l.add_theme_font_size_override("font_size",size)
 l.add_theme_color_override("font_color",color)
 l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 return l

func _button(s: String, call: Callable, active: bool=true) -> Button:
 var btn := Button.new()
 btn.text = s
 btn.disabled = not active
 btn.custom_minimum_size = Vector2(64,38)
 btn.focus_mode = Control.FOCUS_NONE
 btn.pressed.connect(call)
 return btn

func _stack(gap: int = 10) -> VBoxContainer:
 var col := VBoxContainer.new()
 col.add_theme_constant_override("separation",gap)
 return col

func _row(gap: int = 8) -> HBoxContainer:
 var h := HBoxContainer.new()
 h.add_theme_constant_override("separation",gap)
 return h

func _clear_screen() -> void:
 for n in get_children():
  if n != auto_timer and n != tone_player:
   remove_child(n)
   n.queue_free()

func _render() -> void:
 _clear_screen()
 var backdrop := ColorRect.new()
 backdrop.color = BG
 backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(backdrop)
 var margin := MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 margin.add_theme_constant_override("margin_left",20)
 margin.add_theme_constant_override("margin_right",20)
 margin.add_theme_constant_override("margin_top",14)
 margin.add_theme_constant_override("margin_bottom",14)
 add_child(margin)
 var scroll := ScrollContainer.new()
 scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 margin.add_child(scroll)
 var page := _stack(10)
 page.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 scroll.add_child(page)
 var head := _row()
 page.add_child(head)
 head.add_child(_label("GATEFOLD",32,GOLD))
 head.add_spacer(false)
 head.add_child(_button("HELP",_show_help))
 head.add_child(_button("SETTINGS",_show_settings))
 if g.phase != "home":
  head.add_child(_button("MAIN MENU",func(): _go_home()))
 if g.phase == "home":
  awaiting_spell=-1
  first_target=-1
  _show_home(page)
  return
 var stats_panel := _panel()
 page.add_child(stats_panel)
 var stats := _row(26)
 stats_panel.add_child(stats)
 stats.add_child(_label("FLOOR %d / %s" % [g.floor_num,"∞" if g.endless else "8"],20,GOLD))
 stats.add_child(_label("GATE %d/3 · %s" % [g.gate+1,GATE_NAMES[g.gate]],18))
 stats.add_child(_label("LIFE %d/%d" % [g.hp,g.max_hp],18))
 stats.add_child(_label("MOVES %d" % g.moves,18))
 stats.add_child(_label("$%s" % pretty(g.money),20,GOLD))
 var scores := _row(14)
 page.add_child(scores)
 scores.add_child(_label("SCORE  %s" % pretty(g.score),23,GOLD))
 scores.add_child(_label("TARGET  %s" % pretty(g.target()),20,DIM))
 scores.add_child(_label("LAST  +%s · %d triggers" % [pretty(g.last_merge),g.last_triggers],14,DIM))
 var rack_panel := _panel()
 page.add_child(rack_panel)
 var rack := _stack(6)
 rack_panel.add_child(rack)
 rack.add_child(_label("RELICS  %d/%d  ·  LEFT → RIGHT" % [g.relics.size(),g.max_relics()],14,DIM))
 var relic_row := _row(6)
 var relic_scroll := ScrollContainer.new()
 relic_scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 relic_scroll.custom_minimum_size=Vector2(0,88)
 rack.add_child(relic_scroll)
 relic_scroll.add_child(relic_row)
 for i in range(g.relics.size()):
  var item: Dictionary = g.relics[i]
  var rbox := _stack(4)
  rbox.custom_minimum_size.x=135
  relic_row.add_child(rbox)
  rbox.tooltip_text=Cat.RELICS[item.id].desc
  rbox.add_child(_label(Cat.name_for(item.id),13,GOLD if Cat.RELICS[item.id].rarity == "Rare" else TEXT))
  if item.id in ["compound","monolith"]:
   rbox.add_child(_label("×%s" % pretty(item.growth),12,DIM))
  var buttons := _row(2)
  rbox.add_child(buttons)
  if i > 0:
   var previous := _button("◀",func(pos=i): _reorder(pos,-1))
   previous.custom_minimum_size=Vector2(30,28)
   buttons.add_child(previous)
  if i < g.relics.size()-1:
   var following := _button("▶",func(pos=i): _reorder(pos,1))
   following.custom_minimum_size=Vector2(30,28)
   buttons.add_child(following)
  if g.phase == "shop":
   var sell := _button("SELL",func(pos=i): _sell(pos))
   sell.custom_minimum_size=Vector2(46,28)
   buttons.add_child(sell)
 var middle := _row(15)
 middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
 page.add_child(middle)
 var board_panel := _panel(PANEL_ALT)
 middle.add_child(board_panel)
 board_area=board_panel
 var grid := GridContainer.new()
 grid.columns = 4
 grid.add_theme_constant_override("h_separation",6)
 grid.add_theme_constant_override("v_separation",6)
 board_panel.add_child(grid)
 for i in range(16):
  grid.add_child(_tile_button(i))
 var side_panel := _panel()
 side_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 middle.add_child(side_panel)
 var side_scroll := ScrollContainer.new()
 side_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 side_scroll.custom_minimum_size=Vector2(280,370)
 side_panel.add_child(side_scroll)
 var side := _stack(8)
 side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 side_scroll.add_child(side)
 if g.phase == "play":
  _show_play(side)
 elif g.phase in ["reward","failed","over"]:
  _show_gate_end(side)
 elif g.phase == "shop":
  _show_shop(side)
 var bottom := _panel()
 page.add_child(bottom)
 var inventory_row := _row(10)
 bottom.add_child(inventory_row)
 inventory_row.add_child(_label("SPELLS & RUNES  %d/%d" % [g.inventory.size(),g.max_pocket()],14,DIM))
 for j in range(g.inventory.size()):
  var id: String = g.inventory[j]
  var item_row := _stack(2)
  inventory_row.add_child(item_row)
  var use_button := _button(Cat.name_for(id),func(index=j): _select_item(index),g.phase in ["play","shop"])
  use_button.tooltip_text=Cat.data_for(id).desc
  item_row.add_child(use_button)
  if g.phase=="shop": item_row.add_child(_button("SELL",func(index=j): g.sell_item(index); _render()))
 if g.inventory.is_empty():
  inventory_row.add_child(_label("No consumables",14,DIM))
 if g.storage_error!="": page.add_child(_label(g.storage_error,14,GOLD))
 if g.result_text != "":
  page.add_child(_label(g.result_text,15,GOLD))

func _show_home(page: VBoxContainer) -> void:
 var splash := _panel()
 page.add_child(splash)
 var col := _stack(12)
 splash.add_child(col)
 col.add_child(_label("MERGE. BUILD. SURVIVE.",27,GOLD))
 col.add_child(_label("A 2048 roguelike. Build your Relic engine and clear eight floors.",17,DIM))
 var tabs := _row()
 col.add_child(tabs)
 tabs.add_child(_button("BOARDS 1–10",func(): board_page=0; _render(),board_page!=0))
 tabs.add_child(_button("BOARDS 11–15",func(): board_page=1; _render(),board_page!=1))
 var grid := GridContainer.new()
 grid.columns=5
 grid.add_theme_constant_override("h_separation",8)
 grid.add_theme_constant_override("v_separation",8)
 col.add_child(grid)
 for index in range(board_page*10,mini(Cat.BOARDS.size(),board_page*10+10)):
  var data: Dictionary = Cat.BOARDS[index]
  var button := _button(data.name+" · "+data.badge,func(id=data.id): chosen_board=id; _render())
  button.custom_minimum_size=Vector2(150,44)
  button.modulate=GOLD if data.id==chosen_board else Color.WHITE
  grid.add_child(button)
 var board: Dictionary = Cat.board(chosen_board)
 col.add_child(_label(board.name.to_upper()+" · "+board.headline,20,GOLD))
 col.add_child(_label(board.desc,16,TEXT))
 if board.has("downside"): col.add_child(_label(board.downside,15,DIM))
 var seed_field := LineEdit.new()
 seed_field.placeholder_text="Seed (leave blank for random)"
 seed_field.text=seed_input
 seed_field.max_length=64
 seed_field.text_changed.connect(func(value): seed_input=value)
 col.add_child(seed_field)
 col.add_child(_button("START NEW RUN",func(): awaiting_spell=-1; first_target=-1; g.new_run(chosen_board,seed_input.strip_edges().to_upper()); _render()))
 if FileAccess.file_exists(Game.SAVE_PATH):
  col.add_child(_button("CONTINUE SAVED RUN",func():
   if g.load_run(): _render()
  ))
 var tools := _row()
 col.add_child(tools)
 tools.add_child(_button("IMPORT SAVE",func(): _save_dialog(true)))
 tools.add_child(_button("COLLECTION",_show_collection))
 col.add_child(_label("WASD / Arrow keys / swipe · SPACE toggles purchased Auto-player · ESC returns to menu",14,DIM))

func _tile_button(i: int) -> Button:
 var c = g.cells[i]
 var btn := Button.new()
 btn.custom_minimum_size = Vector2(86,86)
 btn.focus_mode = Control.FOCUS_NONE
 var style := StyleBoxFlat.new()
 style.set_corner_radius_all(7)
 style.bg_color = Color("#35515a") if c == null else Color(TILE_COLORS[mini(int(c.e)-1,TILE_COLORS.size()-1)])
 btn.add_theme_stylebox_override("normal",style)
 btn.add_theme_stylebox_override("hover",style)
 if c != null:
  var e: int = c.e
  btn.text = Game.Num.power(2,e).fmt()
  if c.fx.get("gold",false): btn.text += "\nAu"
  if c.fx.get("glass",false): btn.text += " ◇"
  if c.fx.get("steel",false): btn.text += " Fe"
  if c.seal: btn.text += " ●"
  btn.add_theme_color_override("font_color",Color("#1c2f36") if e < 7 else Color.WHITE)
  btn.add_theme_font_size_override("font_size",21 if e < 13 else 16)
 btn.tooltip_text = "Empty cell" if c == null else Game.Num.power(2,c.e).fmt()+" · "+", ".join(c.fx.keys())+(" · Echo mark" if c.seal else "")
 btn.pressed.connect(func(index=i): _tile_click(index))
 return btn

func _show_play(side: VBoxContainer) -> void:
 side.add_child(_label("NEXT TILE",14,DIM))
 side.add_child(_label(Game.Num.power(2,g.next_tile.get("e",1)).fmt(),20,GOLD))
 if g.gate == 2:
  side.add_child(_label(g.guardian().name,19,GOLD))
  side.add_child(_label(g.guardian().desc,15,DIM))
 side.add_child(_label("Move with WASD, arrows, or swipe.",14,DIM))
 if awaiting_spell >= 0 and awaiting_spell < g.inventory.size():
  side.add_child(_label("Select a tile for %s%s" % [Cat.name_for(g.inventory[awaiting_spell])," (destination)" if first_target>=0 else ""],16,GOLD))
  side.add_child(_button("CANCEL TARGETING",func(): awaiting_spell=-1; first_target=-1; _render()))
 if g.has_upgrade("auto1"):
  side.add_child(_button("STOP AUTO" if auto_on else "START AUTO",func(): _toggle_auto()))
 side.add_child(_label("Every gate has its own score target and move budget. Tiles persist.",14,DIM))
 if not g.can_slide():
  side.add_child(_button("TAKE 1 DAMAGE",func(): g.finish_gate(false); _render()))

func _show_gate_end(side: VBoxContainer) -> void:
 side.add_child(_label("GATE CLEARED" if g.phase=="reward" else "RUN OVER" if g.phase=="over" else "GATE FAILED",26,GOLD))
 side.add_child(_label(g.result_text,16,DIM))
 if g.phase != "over":
  side.add_child(_button("CONTINUE ENDLESS →" if g.floor_num==8 and g.gate==2 and g.phase=="reward" else "GO TO SHOP →",func(): g.open_shop(); _render()))
 else:
  side.add_child(_button("NEW RUN",func(): _go_home()))

func _show_shop(side: VBoxContainer) -> void:
 side.add_child(_label("THE SHOP",24,GOLD))
 side.add_child(_label("RELICS · SPELLS · RUNES",13,DIM))
 for id in g.shop_offers:
  if id == "": continue
  var data: Dictionary = Cat.data_for(id)
  var holder := _row(6)
  side.add_child(holder)
  var info := _stack(2)
  info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  holder.add_child(info)
  info.add_child(_label(Cat.name_for(id),15))
  info.add_child(_label(data.get("desc",""),12,DIM))
  holder.add_child(_button("$%d" % g.cost_for(id),func(item=id): _buy(item),g.money.cmp(g.cost_for(id)) >= 0))
 if g.shop_upgrade != "":
  side.add_child(_label("UPGRADE",13,GOLD))
  var id: String = g.shop_upgrade
  var u: Dictionary = Cat.UPGRADES[id]
  side.add_child(_label(Cat.name_for(id)+" — "+u.get("desc",""),14,DIM))
  side.add_child(_button("BUY UPGRADE · $%d" % g.cost_for(id),func(item=id): _buy(item),g.money.cmp(g.cost_for(id)) >= 0))
 side.add_child(_button("REROLL · $%d" % (0 if g.shop_rerolls==0 and g.has_relic("coupon") else g.price(3+g.shop_rerolls)),func(): g.reroll(); _render()))
 if not g.shop_pack_bought:
  side.add_child(_button("SUPPLY PACK · $%d" % (0 if g.b().get("free_packs",false) else g.price(5)),func(): g.pack_open(); _render()))
 elif not g.pack_choices.is_empty():
  side.add_child(_label("PICK ONE FROM PACK",13,GOLD))
  for choice in g.pack_choices:
   side.add_child(_button(Cat.name_for(choice),func(item=choice): g.pack_choose(item); _render()))
 if g.hp < g.max_hp and not g.shop_heal_bought:
  side.add_child(_button("HEAL 1 LIFE · $%d" % g.price(5),func(): g.heal_shop(); _render()))
 side.add_child(_button("NEXT GATE →",func(): g.leave_shop(); _render()))

func _reorder(i: int, delta: int) -> void:
 var rel = g.relics[i]
 g.relics[i] = g.relics[i+delta]
 g.relics[i+delta] = rel
 g.save_run()
 _render()

func _sell(i: int) -> void:
 g.sell_relic(i)
 _render()

func _buy(id: String) -> void:
 if not g.buy_item(id):
  g.result_text = "Cannot purchase. Check money, prerequisites, or space."
 _render()

func _select_item(i: int) -> void:
 if i >= g.inventory.size(): return
 var id: String = g.inventory[i]
 if Cat.RUNES.has(id) or id in ["mercy","hourglass"]:
  if not g.use_item(i): g.result_text = "Cannot use that card right now."
  awaiting_spell=-1
 else:
  awaiting_spell=i
  first_target=-1
 _render()

func _tile_click(i: int) -> void:
 if awaiting_spell < 0: return
 if awaiting_spell >= g.inventory.size(): awaiting_spell=-1; return
 var card: String = g.inventory[awaiting_spell]
 if card == "twins" and first_target < 0:
  if g.cells[i] != null: first_target=i
  _render()
  return
 var okay := g.use_item(awaiting_spell,first_target if first_target>=0 else i,i if first_target>=0 else -1)
 if okay:
  awaiting_spell=-1
  first_target=-1
 else:
  g.result_text="Invalid tile for that Spell."
 _render()

func _toggle_auto() -> void:
 auto_on = not auto_on
 if auto_on: auto_timer.start()
 else: auto_timer.stop()
 _render()

func _tick_auto() -> void:
 if auto_thinking: return
 if g.phase!="play" or not auto_on:
  auto_on=false
  auto_timer.stop()
  return
 auto_thinking=true
 var original: String = g.export_run()
 var simulation=Game.new()
 simulation.persist_enabled=false
 simulation.restore(g.snapshot())
 var Autoplayer=load("res://scripts/autoplayer.gd")
 var direction: String = await Autoplayer.choose_async(simulation,g.has_upgrade("auto2"),get_tree())
 auto_thinking=false
 if not auto_on or g.phase!="play" or original!=g.export_run(): return
 if direction=="" or not g.move(direction):
  auto_on=false
  auto_timer.stop()
 if g.phase!="play":
  auto_on=false
  auto_timer.stop()
 _render()

func _play(d: String) -> void:
 if awaiting_spell >= 0: return
 auto_on=false
 auto_timer.stop()
 if g.move(d):
  _tone(520 if g.last_triggers>0 else 280)
  if g.phase != "play":
   auto_on = false
   auto_timer.stop()
  _render()

func _go_home() -> void:
 auto_on = false
 auto_timer.stop()
 g.save_run()
 g.phase = "home"
 _render()

static func pretty(value) -> String:
 return Game.Num.of(value).fmt()

func _dialog(title_text: String, width: int = 680) -> VBoxContainer:
 auto_on=false
 auto_timer.stop()
 if is_instance_valid(active_dialog):
  active_dialog.hide()
  active_dialog.queue_free()
 var dialog := AcceptDialog.new()
 dialog.title=title_text
 dialog.size=Vector2i(width,470)
 dialog.exclusive=true
 add_child(dialog)
 active_dialog=dialog
 var scroll := ScrollContainer.new()
 scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 scroll.offset_bottom=-45
 dialog.add_child(scroll)
 var col := _stack(12)
 col.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 col.custom_minimum_size.x=width-50
 scroll.add_child(col)
 dialog.popup_centered()
 return col

func _show_help() -> void:
 var col := _dialog("How to play")
 for text in ["Slide equal tiles together. A tile merges once per swipe. Invalid moves are free. Tiles have no maximum value.","Beat each gate's target before moves run out. Three gates make a floor; targets triple every floor. Clear floor 8, then continue in endless.","Missing a gate costs 1 Life and clears your two smallest tiles. Visit the shop, then retry that gate. A locked board can be rescued with a Spell or by taking a hit.","Relics resolve from left to right. Use the arrows to reorder them. Flat bonuses apply at their position. Echo, Looking Glass and similar Relics multiply points built so far and feed triggers to later Relics.","Gold pays $2 per merge. Glass doubles points but has a 25% shatter chance. Each Steel tile gives every merge ×1.25. Echo marks run the scoring chain twice. Enhancements are inherited.","Spells affect chosen tiles. Duplicate needs a source then an empty destination. Runes improve natural spawns. Upgrades last for your run. Auto-player I plans two swipes ahead; II tests up to six.","Runs save automatically. Import the original HTML game's saved JSON from the main menu, or export your current run in Settings."]:
  col.add_child(_label(text,16,DIM))

func _show_collection() -> void:
 var col := _dialog("Collection")
 for pool in [Cat.RELICS,Cat.SPELLS,Cat.RUNES,Cat.UPGRADES]:
  for id in pool:
   col.add_child(_label(Cat.name_for(id),17,GOLD))
   col.add_child(_label(pool[id].desc,14,DIM))

func _show_settings() -> void:
 var col := _dialog("Settings")
 var sound := CheckButton.new()
 sound.text="Sound effects"
 sound.button_pressed=sound_on
 sound.toggled.connect(func(value): sound_on=value; _save_preferences())
 col.add_child(sound)
 col.add_child(_label("Auto-player speed",17,GOLD))
 var speeds := OptionButton.new()
 for speed in [1,2,4]: speeds.add_item(str(speed)+"×",speed)
 speeds.select([1,2,4].find(auto_speed))
 speeds.item_selected.connect(func(index): auto_speed=[1,2,4][index]; auto_timer.wait_time=.22/auto_speed; _save_preferences())
 col.add_child(speeds)
 col.add_child(_button("TOGGLE FULLSCREEN",func():
  DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
 ))
 if g.phase!="home": col.add_child(_button("EXPORT SAVED RUN",func(): _save_dialog(false)))
 col.add_child(_button("IMPORT SAVE",func(): _save_dialog(true)))

func _save_preferences() -> void:
 var preferences := ConfigFile.new()
 preferences.set_value("game","sound",sound_on)
 preferences.set_value("game","speed",auto_speed)
 preferences.save("user://preferences.cfg")

func _save_dialog(importing: bool) -> void:
 var col := _dialog("Import saved run" if importing else "Export saved run",740)
 col.add_child(_label("Paste JSON from a Gatefold save. Import replaces your current saved run." if importing else "Select and copy this JSON to back up your run.",15,DIM))
 var editor := TextEdit.new()
 editor.custom_minimum_size=Vector2(680,290)
 editor.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
 if not importing: editor.text=g.export_run()
 col.add_child(editor)
 if importing:
  var result := _label("",14,GOLD)
  col.add_child(result)
  col.add_child(_button("IMPORT RUN",func():
   if g.import_run(editor.text):
    awaiting_spell=-1
    first_target=-1
    _render()
   else: result.text="This save is invalid. Your existing run is unchanged."
  ))

func _tone(frequency: float) -> void:
 if not sound_on: return
 var pcm := PackedByteArray()
 var count := 1100
 for index in range(count):
  var amplitude: int = int(sin(TAU*frequency*index/22050.0)*4000*(1.0-float(index)/count))
  pcm.append(amplitude&255)
  pcm.append((amplitude>>8)&255)
 var stream := AudioStreamWAV.new()
 stream.format=AudioStreamWAV.FORMAT_16_BITS
 stream.mix_rate=22050
 stream.data=pcm
 tone_player.stream=stream
 tone_player.play()

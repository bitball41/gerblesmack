extends Control
const Cat = preload("res://scripts/catalog.gd")
const Game = preload("res://scripts/game.gd")
var g = Game.new()
var chosen_board := "classic"
var auto_on := false
var awaiting_spell := -1
var first_target := -1
var touch_origin := Vector2.ZERO
var auto_timer: Timer

const BG = Color("#101d25")
const PANEL = Color("#1a3039")
const PANEL_ALT = Color("#23444b")
const TEXT = Color("#f4e9d1")
const DIM = Color("#b9c9c1")
const GOLD = Color("#eec870")
const TILE_COLORS = ["#eee1ba","#f2c76e","#e3a052","#d4784a","#c25c61","#9569a7","#5883b4","#439a9a","#9cb15a","#e4b444","#e4cd8b"]
const GATE_NAMES = ["ENTRY GATE","INNER GATE","GUARDIAN GATE"]

func _ready() -> void:
 auto_timer = Timer.new()
 auto_timer.wait_time = 0.22
 auto_timer.timeout.connect(_tick_auto)
 add_child(auto_timer)
 if g.load_run():
  chosen_board = g.board_id
 else:
  g.phase = "home"
 _render()

func _notification(what: int) -> void:
 if what == NOTIFICATION_WM_CLOSE_REQUEST:
  g.save_run()

func _input(event: InputEvent) -> void:
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
 if event is InputEventScreenTouch:
  if event.pressed: touch_origin = event.position
  else:
   var diff: Vector2 = event.position - touch_origin
   if diff.length() > 35:
    _play("right" if diff.x>0 else "left" if absf(diff.x)>absf(diff.y) else "down" if diff.y>0 else "up")

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
 l.add_theme_font_size_override("font_size",size)
 l.add_theme_color_override("font_color",color)
 l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 return l

func _button(s: String, call: Callable, active: bool=true) -> Button:
 var btn := Button.new()
 btn.text = s
 btn.disabled = not active
 btn.custom_minimum_size = Vector2(90,43)
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
  if n != auto_timer:
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
 var page := _stack(12)
 margin.add_child(page)
 var head := _row()
 page.add_child(head)
 head.add_child(_label("GATEFOLD",32,GOLD))
 head.add_spacer(false)
 head.add_child(_label("GODOT WEB · MIGRATION BUILD",13,DIM))
 if g.phase != "home":
  head.add_child(_button("MAIN MENU",func(): _go_home()))
 if g.phase == "home":
  _show_home(page)
  return
 var stats_panel := _panel()
 page.add_child(stats_panel)
 var stats := _row(26)
 stats_panel.add_child(stats)
 stats.add_child(_label("FLOOR %d / %s" % [g.floor_num,"∞" if g.floor_num>8 else "8"],20,GOLD))
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
 rack.add_child(relic_row)
 for i in range(g.relics.size()):
  var item: Dictionary = g.relics[i]
  var rbox := _stack(4)
  relic_row.add_child(rbox)
  rbox.add_child(_label(Cat.name_for(item.id),13,GOLD if Cat.RELICS[item.id].rarity == "Rare" else TEXT))
  if item.id in ["compound","monolith"]:
   rbox.add_child(_label("×%s" % pretty(float(item.growth)),12,DIM))
  var buttons := _row(2)
  rbox.add_child(buttons)
  if i > 0:
   buttons.add_child(_button("◀",func(pos=i): _reorder(pos,-1)))
  if i < g.relics.size()-1:
   buttons.add_child(_button("▶",func(pos=i): _reorder(pos,1)))
  if g.phase == "shop":
   buttons.add_child(_button("SELL",func(pos=i): _sell(pos)))
 var middle := _row(15)
 middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
 page.add_child(middle)
 var board_panel := _panel(PANEL_ALT)
 middle.add_child(board_panel)
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
  inventory_row.add_child(_button(Cat.name_for(id),func(index=j): _select_item(index)))
 if g.inventory.is_empty():
  inventory_row.add_child(_label("No consumables",14,DIM))
 if g.result_text != "":
  page.add_child(_label(g.result_text,15,GOLD))

func _show_home(page: VBoxContainer) -> void:
 var splash := _panel()
 page.add_child(splash)
 var c := _stack(14)
 splash.add_child(c)
 c.add_child(_label("MERGE. BUILD. SURVIVE.",27,GOLD))
 c.add_child(_label("2048 roguelike — native Godot port of the original Gatefold.",17,DIM))
 c.add_child(_label("SELECT A BOARD",16,TEXT))
 var picker := OptionButton.new()
 picker.custom_minimum_size = Vector2(240,48)
 for i in range(Cat.BOARDS.size()):
  picker.add_item(Cat.BOARDS[i].name,i)
  if Cat.BOARDS[i].id == chosen_board:
   picker.select(i)
 picker.item_selected.connect(func(index): chosen_board = Cat.BOARDS[index].id; _render())
 c.add_child(picker)
 c.add_child(_label(Cat.board(chosen_board).get("desc",""),17,DIM))
 c.add_child(_button("START NEW RUN",func(): g.new_run(chosen_board); _render()))
 if FileAccess.file_exists(Game.SAVE_PATH) and g.phase == "home":
  c.add_child(_button("CONTINUE SAVED RUN",func(): 
   if g.load_run(): _render()
  ))
 c.add_child(_label("WASD / Arrow keys / touch swipe · Auto-player via SPACE when purchased",14,DIM))
 c.add_child(_label("The Fracture Update is deliberately NOT included in this port.",13,DIM))

func _tile_button(i: int) -> Button:
 var c = g.cells[i]
 var btn := Button.new()
 btn.custom_minimum_size = Vector2(100,100)
 btn.focus_mode = Control.FOCUS_NONE
 var style := StyleBoxFlat.new()
 style.set_corner_radius_all(7)
 style.bg_color = Color("#35515a") if c == null else Color(TILE_COLORS[mini(int(c.e)-1,TILE_COLORS.size()-1)])
 btn.add_theme_stylebox_override("normal",style)
 btn.add_theme_stylebox_override("hover",style)
 if c != null:
  var e: int = c.e
  btn.text = str(1 << e) if e < 29 else "2^%d" % e
  if c.fx.get("gold",false): btn.text += "\nAu"
  if c.fx.get("glass",false): btn.text += " ◇"
  if c.fx.get("steel",false): btn.text += " Fe"
  if c.seal: btn.text += " ●"
  btn.add_theme_color_override("font_color",Color("#1c2f36") if e < 7 else Color.WHITE)
  btn.add_theme_font_size_override("font_size",21 if e < 13 else 16)
 btn.pressed.connect(func(index=i): _tile_click(index))
 return btn

func _show_play(side: VBoxContainer) -> void:
 side.add_child(_label("NEXT TILE",14,DIM))
 side.add_child(_label("2^%d" % g.next_tile.get("e",1),20,GOLD))
 if g.gate == 2:
  side.add_child(_label(g.guardian().name,19,GOLD))
  side.add_child(_label(g.guardian().desc,15,DIM))
 side.add_child(_label("Move with WASD, arrows, or swipe.",14,DIM))
 if awaiting_spell >= 0:
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
  side.add_child(_button("GO TO SHOP →",func(): g.open_shop(); _render()))
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
  holder.add_child(_button("$%d" % g.cost_for(id),func(item=id): _buy(item),g.money >= g.cost_for(id)))
 if g.shop_upgrade != "":
  side.add_child(_label("UPGRADE",13,GOLD))
  var id := g.shop_upgrade
  var u: Dictionary = Cat.UPGRADES[id]
  side.add_child(_label(Cat.name_for(id)+" — "+u.get("desc",""),14,DIM))
  side.add_child(_button("BUY UPGRADE · $%d" % g.cost_for(id),func(item=id): _buy(item),g.money >= g.cost_for(id)))
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
 if g.phase != "play" or not auto_on:
  auto_on = false
  auto_timer.stop()
  return
 if not g.auto_move():
  auto_on = false
  auto_timer.stop()
 _render()

func _play(d: String) -> void:
 if awaiting_spell >= 0: return
 if g.move(d):
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

static func pretty(value: float) -> String:
 if is_nan(value): return "NaN"
 if is_inf(value): return "∞"
 if value >= 1000000.0:
  var exponent := int(floorf(log(value)/log(10.0)))
  return "%.2fe%d" % [value/pow(10.0,exponent),exponent]
 return "%d" % int(roundf(value))

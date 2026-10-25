extends Control
## Two pages of board portraits, with one printed rules card for the selection.
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
const Game = preload("res://scripts/game.gd")
const OPTION = preload("res://ui/board_option.gd")
const BUTTON: PackedScene = preload("res://scenes/ui/action_button.tscn")
signal board_selected(id: String)
signal page_changed(index: int)
signal seed_changed(value: String)
signal start_requested(id: String, run_seed: String, difficulty: String)
signal cancel_requested
signal navigated
var chosen_board := "red"
var difficulty := "normal"
var _normal: Button
var _cursed: Button
var _mode_note: Label
var page := 0
var seed_text := ""
var motion_enabled := true
var seed_field: LineEdit
var hero: TextureRect
var _name: Label
var _headline: Label
var _description: Label
var _downside: Label
var _number: Label
var _stats: Array[Label] = []
var _loadout: Control
var _thumbs: Control
var _page_label: Label
var _previous: Button
var _next_page: Button
var _accent: ColorRect
var _change: Tween
var _visual_rng := RandomNumberGenerator.new()
const INK := Color("253941")

func _ready() -> void:
 _visual_rng.randomize()
 _build()
 _fill_portraits()
 _select(chosen_board,false)
 _focus_initial.call_deferred()

func _draw() -> void:
 draw_line(Vector2(654,100),Vector2(654,654),Color("5e7c7860"),2)

func _text(text: String, rect: Rect2, font_size: int, color: Color = UIStyle.CREAM, wrap: bool = false, compact: bool = false) -> Label:
 var result: Label = UIStyle.label(text,font_size,color,false,wrap)
 if compact:
  result.add_theme_font_size_override("font_size",font_size)
  if not wrap: result.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 UIStyle.place(result,self,rect)
 return result

func _button(text: String, rect: Rect2, action: Callable, color: Color = Color("416878")) -> Button:
 var button: Button = BUTTON.instantiate()
 button.custom_minimum_size=Vector2.ZERO
 button.text=text
 button.base_color=color
 button.edge_color=color.lightened(.25)
 button.display_size=36
 button.padding=6
 button.motion_enabled=motion_enabled
 button.pressed.connect(func(): navigated.emit(); action.call())
 UIStyle.place(button,self,rect)
 return button

func _build() -> void:
 _text("New run",Rect2(40,24,580,66),54)
 _text("Boards",Rect2(40,108,160,42),36,UIStyle.MUTED)
 _normal=_button("Normal",Rect2(248,108,168,42),func(): _set_difficulty("normal"),Color("3c7668"))
 _cursed=_button("Cursed",Rect2(434,108,168,42),func(): _set_difficulty("cursed"),Color("795582"))
 _thumbs=Control.new()
 _thumbs.name="BoardPortraits"
 UIStyle.place(_thumbs,self,Rect2(40,166,580,372))
 _previous=_button("<",Rect2(40,582,60,48),func(): _set_page(page-1))
 _page_label=_text("",Rect2(112,584,418,40),36,UIStyle.MUTED)
 _page_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 _next_page=_button(">",Rect2(544,582,60,48),func(): _set_page(page+1))
 var sheet: PanelContainer = UIStyle.panel(Color("e9e3cf"),Color("fcf3da"),0)
 UIStyle.place(sheet,self,Rect2(682,100,510,554))
 _accent=ColorRect.new()
 _accent.mouse_filter=Control.MOUSE_FILTER_IGNORE
 UIStyle.place(_accent,self,Rect2(688,106,498,5))
 hero=UIStyle.texture("board_red")
 hero.name="BoardPortrait"
 UIStyle.place(hero,self,Rect2(708,124,128,160))
 _name=_text("Red board",Rect2(858,128,312,68),54,INK,true)
 _number=_text("",Rect2(860,190,300,30),27,Color("5c6e70"),false,true)
 _stats.append(_text("",Rect2(860,228,36,36),36,INK))
 _text("Life",Rect2(902,228,80,36),27,Color("586c6e"),false,true)
 _stats.append(_text("",Rect2(860,266,42,36),36,INK))
 _text("moves",Rect2(908,266,96,36),27,Color("586c6e"),false,true)
 _stats.append(_text("",Rect2(1020,228,144,36),36,INK))
 _stats.append(_text("",Rect2(1020,266,36,36),36,INK))
 _text("slots",Rect2(1062,266,104,36),27,Color("586c6e"),false,true)
 var rule := ColorRect.new()
 rule.color=Color("abb5a3")
 rule.mouse_filter=Control.MOUSE_FILTER_IGNORE
 UIStyle.place(rule,self,Rect2(708,310,458,2))
 _headline=_text("",Rect2(708,328,458,76),36,Color("326c59"),true)
 _description=_text("",Rect2(708,414,458,80),27,INK,true,true)
 _downside=_text("",Rect2(708,508,458,68),27,Color("a14e43"),true,true)
 _mode_note=_text("",Rect2(708,572,458,28),27,Color("775483"),false,true)
 _text("Starts with",Rect2(708,600,132,32),27,Color("586c6e"),false,true)
 _loadout=Control.new()
 UIStyle.place(_loadout,self,Rect2(844,594,322,40))
 _button("Back",Rect2(40,698,148,60),func(): cancel_requested.emit(),Color("916447"))
 _button("Random",Rect2(204,698,180,60),_random_board,Color("6c5d83"))
 seed_field=LineEdit.new()
 seed_field.name="Seed"
 seed_field.text=seed_text
 seed_field.placeholder_text="Seed"
 seed_field.max_length=64
 seed_field.add_theme_font_size_override("font_size",36)
 UIStyle.place(seed_field,self,Rect2(404,698,220,60))
 seed_field.text_changed.connect(func(value: String): seed_text=value; seed_changed.emit(value))
 seed_field.text_submitted.connect(func(_value: String): start_requested.emit(chosen_board,seed_text,difficulty))
 _button("Start run",Rect2(832,698,360,60),func(): start_requested.emit(chosen_board,seed_text,difficulty),Color("418468"))

func _fill_portraits() -> void:
 for child in _thumbs.get_children(): _thumbs.remove_child(child); child.queue_free()
 var definitions: Array = Cat.boards_on_page(page)
 var count: int = definitions.size()
 for local_index in range(count):
  var definition: Dictionary = definitions[local_index]
  var option: Button = OPTION.new()
  option.definition=definition
  option.board_id=definition.id
  option.name=definition.id.capitalize()+"Portrait"
  option.selected=chosen_board==definition.id
  var y: float = int(local_index/5.0)*204 if count>5 else 102
  UIStyle.place(option,_thumbs,Rect2((local_index%5)*118,y,108,168))
  option.pressed.connect(func(id: String = definition.id): _select(id))
  option.focus_entered.connect(func(id: String = definition.id): _select(id))
 _page_label.text="Page %d / 3" % (page+1)
 _previous.disabled=page==0
 _next_page.disabled=page==2

func _set_page(index: int) -> void:
 page=clampi(index,0,2)
 page_changed.emit(page)
 _fill_portraits()

func _random_board() -> void:
 var definition: Dictionary = Cat.BOARDS[_visual_rng.randi_range(0,Cat.BOARDS.size()-1)]
 var index: int = Cat.BOARDS.find(definition)
 if Cat.board_page(definition.id)!=page: _set_page(Cat.board_page(definition.id))
 _select(definition.id)

func _select(id: String, animate: bool = true) -> void:
 if animate and chosen_board==id: return
 chosen_board=id
 board_selected.emit(id)
 var selected: Dictionary = Cat.board(id)
 var preview := Game.new()
 preview.persist_enabled=false
 preview.new_run(id,"BOARD-PREVIEW",difficulty)
 hero.texture=UIStyle.sprite("board_"+id)
 _accent.color=Color(selected.color)
 _name.text=selected.name
 _name.add_theme_font_size_override("font_size",54 if UIStyle.BODY.get_string_size(selected.name,HORIZONTAL_ALIGNMENT_LEFT,-1,54).x<=312 else 36)
 _headline.text=UIStyle.readable(selected.headline)
 _description.text=UIStyle.readable(selected.desc)
 _downside.text=UIStyle.readable(str(selected.get("downside","")))
 _number.text="Board %02d / %d" % [Cat.BOARDS.find(selected)+1,Cat.BOARDS.size()]
 _mode_note.text="No Curse." if difficulty=="normal" else "Cursed relics x1.5. Curse raises gate targets."
 _normal.modulate=Color.WHITE if difficulty=="normal" else Color(.7,.7,.7)
 _cursed.modulate=Color.WHITE if difficulty=="cursed" else Color(.7,.7,.7)
 var values: Array = [str(preview.hp),str(preview.moves),"$"+preview.money.fmt(),str(preview.max_relics())]
 for index in range(4): _stats[index].text=values[index]
 for option in _thumbs.get_children(): option.selected=option.board_id==id; option.queue_redraw()
 for child in _loadout.get_children(): _loadout.remove_child(child); child.queue_free()
 var items: Array = preview.relics.map(func(relic): return relic.id)+preview.upgrades+preview.inventory
 for index in range(items.size()):
  var data: Dictionary = Cat.data_for(items[index])
  var icon: TextureRect = UIStyle.texture(data.art)
  UIStyle.place(icon,_loadout,Rect2(index*48,0,36,36))
  icon.mouse_filter=Control.MOUSE_FILTER_STOP
  icon.set_meta("item_id",items[index])
  var kit_id: String = items[index]
  var kit_note: String = Game.Rules.status(preview,preview.relics[index]) if index<preview.relics.size() else "Starting kit"
  icon.mouse_entered.connect(func():
   var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
   if host: host._show_item_preview(kit_id,kit_note,icon)
  )
  icon.mouse_exited.connect(func():
   var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
   if host: host._hide_item_preview(icon)
  )
 if animate and motion_enabled:
  navigated.emit()
  if _change and _change.is_valid(): _change.kill()
  hero.modulate=Color(1.25,1.16,1.02)
  _change=create_tween()
  _change.tween_property(hero,"modulate",Color.WHITE,.16)

func _set_difficulty(value: String) -> void:
 difficulty=value
 _select(chosen_board,false)
 navigated.emit()

func _focus_initial() -> void:
 if not is_inside_tree(): return
 for option in _thumbs.get_children():
  if option.board_id==chosen_board:
   option.grab_focus()
   return

extends Control
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
const Game = preload("res://scripts/game.gd")
const OPTION = preload("res://ui/board_option.gd")
const BUTTON: PackedScene = preload("res://scenes/ui/action_button.tscn")
signal board_selected(id: String)
signal page_changed(index: int)
signal seed_changed(value: String)
signal start_requested(id: String, run_seed: String)
signal cancel_requested
signal navigated
var chosen_board := "red"
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
var _tabs: Array[Button] = []
var _change: Tween
var _visual_rng := RandomNumberGenerator.new()

func _ready() -> void:
 _visual_rng.randomize()
 _build()
 _fill_portraits()
 _select(chosen_board,false)
 _focus_initial.call_deferred()

func _text(text: String, rect: Rect2, font_size: int, color: Color = UIStyle.CREAM, wrap: bool = false) -> Label:
 var result: Label = UIStyle.label(text,font_size,color,true,wrap)
 UIStyle.place(result,self,rect)
 return result

func _button(text: String, rect: Rect2, action: Callable, color: Color = Color("416878")) -> Button:
 var button: Button = BUTTON.instantiate()
 button.custom_minimum_size=Vector2.ZERO
 button.text=text
 button.base_color=color
 button.edge_color=color.lightened(.32)
 button.display_size=20
 button.padding=6
 button.motion_enabled=motion_enabled
 button.pressed.connect(func(): navigated.emit(); action.call())
 UIStyle.place(button,self,rect)
 return button

func _build() -> void:
 _text("NEW RUN",Rect2(38,22,600,60),42)
 _text("CHOOSE AN ENGINE. MAKE IT BREAK.",Rect2(40,78,1000,24),16,UIStyle.MUTED)
 _number=_text("01 / 15",Rect2(1010,34,172,32),20,UIStyle.GOLD)
 _number.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 var pedestal: PanelContainer = UIStyle.panel(Color("17252f"),Color("526c72"),0)
 UIStyle.place(pedestal,self,Rect2(40,120,278,324))
 hero=UIStyle.texture("board_red")
 hero.name="BoardPortrait"
 UIStyle.place(hero,self,Rect2(56,118,248,310))
 _name=_text("RED BOARD",Rect2(352,122,810,60),44)
 _headline=_text("",Rect2(354,190,804,44),25,UIStyle.GREEN,true)
 _description=_text("",Rect2(354,242,804,76),18,UIStyle.CREAM,true)
 _downside=_text("",Rect2(354,322,804,76),17,UIStyle.RED,true)
 for index in range(4):
  var panel: PanelContainer = UIStyle.panel(Color("1c2b35"),Color("57717a"),0)
  UIStyle.place(panel,self,Rect2(352+index*205,410,191,80))
  _text(["LIFE","MOVES","CASH","RELIC SLOTS"][index],Rect2(364+index*205,410,170,36),12,UIStyle.MUTED)
  _stats.append(_text("",Rect2(364+index*205,448,170,38),28,UIStyle.GOLD))
 _text("STARTING KIT",Rect2(43,502,154,36),12,UIStyle.MUTED)
 _loadout=Control.new()
 UIStyle.place(_loadout,self,Rect2(220,502,962,38))
 _tabs.append(_button("FOUNDATIONS",Rect2(70,550,215,40),func(): _set_page(0)))
 _tabs.append(_button("ODDITIES",Rect2(300,550,180,40),func(): _set_page(1)))
 _page_label=_text("",Rect2(944,550,232,38),14,UIStyle.MUTED)
 _page_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 _thumbs=Control.new()
 _thumbs.name="BoardPortraits"
 UIStyle.place(_thumbs,self,Rect2(70,602,1100,96))
 _button("<",Rect2(13,616,44,64),func(): _set_page(1-page))
 _button(">",Rect2(1184,616,44,64),func(): _set_page(1-page))
 _button("BACK",Rect2(40,706,186,54),func(): cancel_requested.emit(),Color("a36f40"))
 _button("RANDOM",Rect2(244,706,182,54),_random_board,Color("68557c"))
 seed_field=LineEdit.new()
 seed_field.name="Seed"
 seed_field.text=seed_text
 seed_field.placeholder_text="Seed (optional)"
 seed_field.max_length=64
 seed_field.add_theme_font_size_override("font_size",36)
 UIStyle.place(seed_field,self,Rect2(446,706,364,54))
 seed_field.text_changed.connect(func(value: String): seed_text=value; seed_changed.emit(value))
 seed_field.text_submitted.connect(func(_value: String): start_requested.emit(chosen_board,seed_text))
 _button("PLAY  >",Rect2(838,706,350,54),func(): start_requested.emit(chosen_board,seed_text),Color("cb843e"))

func _fill_portraits() -> void:
 for child in _thumbs.get_children(): _thumbs.remove_child(child); child.queue_free()
 for index in range(page*10,mini(Cat.BOARDS.size(),page*10+10)):
  var definition: Dictionary = Cat.BOARDS[index]
  var option: Button = OPTION.new()
  option.definition=definition
  option.board_id=definition.id
  option.name=definition.id.capitalize()+"Portrait"
  option.selected=chosen_board==definition.id
  var x: float = (index-page*10)*110.0+(275 if page==1 else 0)
  UIStyle.place(option,_thumbs,Rect2(x,0,96,96))
  option.pressed.connect(func(id: String = definition.id): _select(id))
  option.focus_entered.connect(func(id: String = definition.id): _select(id))
 _page_label.text="%02d - %02d  /  15" % [page*10+1,mini(15,page*10+10)]
 for index in range(_tabs.size()): _tabs[index].modulate=Color.WHITE if page==index else Color(.7,.78,.8)

func _set_page(index: int) -> void:
 page=clampi(index,0,1)
 page_changed.emit(page)
 _fill_portraits()

func _random_board() -> void:
 var definition: Dictionary = Cat.BOARDS[_visual_rng.randi_range(0,Cat.BOARDS.size()-1)]
 var index: int = Cat.BOARDS.find(definition)
 if int(index/10.0)!=page: _set_page(int(index/10.0))
 _select(definition.id)

func _select(id: String, animate: bool = true) -> void:
 if animate and chosen_board==id: return
 chosen_board=id
 board_selected.emit(id)
 var selected: Dictionary = Cat.board(id)
 var preview := Game.new()
 preview.persist_enabled=false
 preview.new_run(id,"BOARD-PREVIEW")
 hero.texture=UIStyle.sprite("board_"+id)
 _name.text=selected.name.to_upper()+" BOARD"
 _name.add_theme_color_override("font_color",Color(selected.edge))
 _headline.text=UIStyle.readable(selected.headline)
 _description.text=UIStyle.readable(selected.desc)
 _downside.text=UIStyle.readable(str(selected.get("downside","No additional drawback.")))
 _downside.add_theme_color_override("font_color",UIStyle.RED if selected.has("downside") else UIStyle.MUTED)
 _number.text="%02d / 15" % [Cat.BOARDS.find(selected)+1]
 var values: Array = [str(preview.hp),str(preview.moves),"$"+preview.money.fmt(),str(preview.max_relics())]
 for index in range(4): _stats[index].text=values[index]
 for option in _thumbs.get_children(): option.selected=option.board_id==id; option.queue_redraw()
 for child in _loadout.get_children(): _loadout.remove_child(child); child.queue_free()
 var items: Array = preview.relics.map(func(relic): return relic.id)+preview.upgrades+preview.inventory
 for index in range(items.size()):
  var data: Dictionary = Cat.data_for(items[index])
  var icon: TextureRect = UIStyle.texture(data.art)
  UIStyle.place(icon,_loadout,Rect2(index*72,0,36,36))
  icon.mouse_filter=Control.MOUSE_FILTER_STOP
  icon.set_meta("item_id",items[index])
  var kit_id: String = items[index]
  icon.mouse_entered.connect(func():
   var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
   if host: host._show_item_preview(kit_id,"Starting kit",icon)
  )
  icon.mouse_exited.connect(func():
   var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
   if host: host._hide_item_preview(icon)
  )
 if animate and motion_enabled:
  navigated.emit()
  if _change and _change.is_valid(): _change.kill()
  hero.position=Vector2(48,110)
  hero.modulate=Color(1.3,1.18,.92)
  _change=create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
  _change.tween_property(hero,"position",Vector2(56,118),.2)
  _change.tween_property(hero,"modulate",Color.WHITE,.23)

func _focus_initial() -> void:
 if not is_inside_tree(): return
 for option in _thumbs.get_children():
  if option.board_id==chosen_board:
   option.grab_focus()
   return

extends Control
const UIStyle = preload("res://ui/skin.gd")
const Game = preload("res://scripts/game.gd")
const BUTTON_SCENE: PackedScene = preload("res://scenes/ui/action_button.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/ui/card.tscn")
const BOARD_SCENE: PackedScene = preload("res://scenes/ui/board.tscn")
const TILE_SCENE: PackedScene = preload("res://scenes/ui/tile.tscn")
signal action_requested(action: String)
var motion_enabled := true
var sound_icon: TextureRect
var _built := false
var _hero: Control
var _rest_y := 0.0
var _time := 0.0

func build(game: Game, has_save: bool, record_floor: int, record_score: String) -> void:
 for child in get_children():
  remove_child(child)
  child.queue_free()
 var shadow: Label = UIStyle.label("GATEFOLD",116,Color("092832"),true)
 UIStyle.place(shadow,self,Rect2(266,159,650,135))
 var gold_shadow: Label = UIStyle.label("GATEFOLD",116,Color("c79b4d"),true)
 UIStyle.place(gold_shadow,self,Rect2(266,153,650,135))
 var title: Label = UIStyle.label("GATEFOLD",116,Color("ffebaf"),true)
 title.name="Title"
 UIStyle.place(title,self,Rect2(266,150,650,135))
 var mark: TextureRect = UIStyle.texture("gate",UIStyle.GOLD)
 UIStyle.place(mark,self,Rect2(204,195,47,62))
 UIStyle.place(UIStyle.label("2 0 4 8   R O G U E L I K E",11,Color("a6c6be")),self,Rect2(271,285,550,25))
 _hero=Control.new()
 _hero.mouse_filter=Control.MOUSE_FILTER_IGNORE
 UIStyle.place(_hero,self,Rect2(213,337,550,430))
 _rest_y=337
 var board: Control = BOARD_SCENE.instantiate()
 board.decorative=true
 _hero.add_child(board)
 board.position=Vector2(15,0)
 board.size=Vector2(326,326)
 board.pivot_offset=Vector2(163,163)
 board.rotation=deg_to_rad(-11)
 var values: Array = [1,2,0,0,2,3,4,0,3,4,6,7,4,6,7,8]
 board.show_cells(values.map(func(exponent): return {"e":exponent,"fx":{},"seal":false} if exponent>0 else null))
 for index in range(3):
  var card: Control = CARD_SCENE.instantiate()
  card.item_id=["corner","echo","singularity"][index]
  card.mouse_filter=Control.MOUSE_FILTER_IGNORE
  card.rotation=deg_to_rad([-17,1,17][index])
  _hero.add_child(card)
  card.size=Vector2(128,182)
  card.position=Vector2(216+index*84,165+[-1,-9,3][index])
  card.motion_enabled=false
  card.focus_mode=Control.FOCUS_NONE
 var loose: Control = TILE_SCENE.instantiate()
 _hero.add_child(loose)
 loose.size=Vector2(107,107)
 loose.position=Vector2(16,302)
 loose.pivot_offset=Vector2(53,53)
 loose.rotation=deg_to_rad(8)
 loose.configure({"e":12,"fx":{},"seal":false})
 var y: float = 230.0 if has_save else 280.0
 if has_save:
  var continue_button: Button = _button("CONTINUE",Rect2(942,y,292,94),Color("47866b"),Color("9ed0a6"),"continue",33)
  continue_button.alignment=HORIZONTAL_ALIGNMENT_LEFT
  continue_button.grab_focus.call_deferred()
  var arrow: TextureRect = UIStyle.texture("ui_right",UIStyle.CREAM)
  UIStyle.place(arrow,continue_button,Rect2(242,24,28,28))
  var save_label: Label = UIStyle.label("%s · FLOOR %d · GATE %d / 3 · %s" % [game.b().name.to_upper(),game.floor_num,game.gate+1,game.phase.to_upper()],10,Color("d7ead4"))
  continue_button.add_child(save_label)
  save_label.position=Vector2(18,66)
  save_label.size=Vector2(260,16)
  continue_button.add_theme_constant_override("outline_size",0)
  y+=111
 var new_button: Button = _button("NEW RUN",Rect2(942,y,292,66),Color("cf8050") if has_save else Color("47866b"),Color("f6c991") if has_save else Color("9ed0a6"),"new",29 if has_save else 34)
 UIStyle.place(UIStyle.label("+",27,UIStyle.CREAM),new_button,Rect2(254,17,24,30))
 if not has_save: new_button.grab_focus.call_deferred()
 y+=87
 _button("COLLECTION",Rect2(942,y,292,54),Color("706390"),Color("b6a3c8"),"collection",25)
 y+=70
 _button("HOW TO PLAY",Rect2(942,y,292,54),Color("345a66"),Color("7b9eaa"),"help",25)
 y+=70
 _button("SETTINGS",Rect2(942,y,292,54),Color("345a66"),Color("7b9eaa"),"settings",25)
 y+=78
 UIStyle.place(UIStyle.label("BEST FLOOR",9,Color("9cbdb7")),self,Rect2(945,y,95,15))
 UIStyle.place(UIStyle.label("BEST SCORE",9,Color("9cbdb7")),self,Rect2(1040,y,190,15))
 UIStyle.place(UIStyle.label(str(record_floor),27,Color("eed5a0"),true),self,Rect2(945,y+16,95,32))
 UIStyle.place(UIStyle.label(record_score,27,Color("eed5a0"),true),self,Rect2(1040,y+16,190,32))
 UIStyle.place(UIStyle.label("WASD · ARROWS · SWIPE",10,Color("8cb1ad")),self,Rect2(208,850,350,20))
 var sound: Button = _button("",Rect2(1155,839,38,34),Color("234752"),Color("577a80"),"sound",21)
 sound_icon=UIStyle.texture("ui_sound",Color("b2d2cd"))
 UIStyle.place(sound_icon,sound,Rect2(8,6,22,22))
 var fullscreen: Button = _button("",Rect2(1205,839,38,34),Color("234752"),Color("577a80"),"fullscreen",21)
 UIStyle.place(UIStyle.texture("ui_fullscreen",Color("b2d2cd")),fullscreen,Rect2(8,6,22,22))
 _built=true

func _button(text: String, rect: Rect2, color: Color, edge: Color, action: String, font_size: int = 23) -> Button:
 var button: Button = BUTTON_SCENE.instantiate()
 button.custom_minimum_size=Vector2.ZERO
 button.padding=4 if rect.size.y<40 else 12
 button.text=text
 button.display_size=font_size
 button.base_color=color
 button.edge_color=edge
 button.motion_enabled=motion_enabled
 button.alignment=HORIZONTAL_ALIGNMENT_LEFT
 button.pressed.connect(func(): action_requested.emit(action))
 UIStyle.place(button,self,rect)
 return button

func _process(delta: float) -> void:
 if not _built or not visible or not motion_enabled: return
 _time+=delta
 _hero.position.y=_rest_y+sin(_time*.75)*2.2

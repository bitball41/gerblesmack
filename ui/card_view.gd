extends Button
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
signal inspected(item_id: String)
signal reorder_requested(from_index: int, to_index: int)
@export var item_id: String = "carbon"
@export var motion_enabled := true
var drag_index := -1
var _hover: Tween
var _pulse: Tween
var _rest_rotation := 0.0
var _caption := ""
@onready var illustration: TextureRect = $Art
@onready var title: Label = $Title
@onready var rarity: Label = $Rarity
@onready var caption: Label = $Caption

func _ready() -> void:
 _rest_rotation=rotation
 mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 focus_mode=Control.FOCUS_ALL
 pressed.connect(func(): inspected.emit(item_id))
 mouse_entered.connect(func(): _tilt(true))
 mouse_exited.connect(func(): _tilt(false))
 resized.connect(_layout)
 _refresh()
 _layout.call_deferred()

func configure(id: String, index: int = -1, note: String = "") -> void:
 item_id=id
 drag_index=index
 _caption=note
 if is_node_ready(): _refresh()

func _refresh() -> void:
 var data: Dictionary = Cat.data_for(item_id)
 if data.is_empty(): return
 var colors: Array = UIStyle.colors(item_id)
 var surface: StyleBoxFlat = UIStyle.box(colors[0],Color(colors[1],.68),7,5,7)
 surface.border_width_bottom=5
 add_theme_stylebox_override("normal",surface)
 add_theme_stylebox_override("hover",UIStyle.box(Color(colors[0]).lightened(.07),Color(colors[1],.9),7,7,7))
 add_theme_stylebox_override("pressed",surface)
 var focus: StyleBoxFlat = UIStyle.box(Color.TRANSPARENT,UIStyle.GOLD,8,0,0)
 focus.draw_center=false
 focus.set_border_width_all(3)
 add_theme_stylebox_override("focus",focus)
 title.text=data.name
 rarity.text=data.rarity.to_upper()
 caption.text=_caption
 for label_node in [title,rarity,caption]:
  label_node.add_theme_color_override("font_color",colors[1])
  label_node.mouse_filter=Control.MOUSE_FILTER_IGNORE
 title.add_theme_font_override("font",UIStyle.DISPLAY)
 title.add_theme_font_size_override("font_size",20)
 rarity.add_theme_font_override("font",UIStyle.BOLD)
 rarity.add_theme_font_size_override("font_size",9)
 caption.add_theme_font_override("font",UIStyle.BOLD)
 caption.add_theme_font_size_override("font_size",10)
 illustration.texture=load("res://assets/art/"+data.art+".svg")
 illustration.modulate=colors[1]
 tooltip_text=data.name+"\n"+data.desc
 queue_redraw()

func _layout() -> void:
 pivot_offset=size*Vector2(.5,.85)
 if not is_node_ready(): return
 illustration.position=Vector2(6,size.y*.12)
 illustration.size=Vector2(size.x-12,size.y*.53)
 rarity.position=Vector2(8,8)
 rarity.size=Vector2(size.x-16,14)
 caption.position=Vector2(5,size.y-21)
 caption.size=Vector2(size.x-10,14)
 caption.visible=not _caption.is_empty()
 var font_size: int = clampi(int(size.x*.15),13,23)
 var name_text: String = str(Cat.data_for(item_id).get("name",item_id))
 var words: PackedStringArray = name_text.split(" ")
 var lines: PackedStringArray = PackedStringArray([name_text])
 if words.size()>1 and (size.x<175 or UIStyle.DISPLAY.get_string_size(name_text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>size.x-12):
  var best_split := 1
  var best_width := INF
  for split_index in range(1,words.size()):
   var first: String = " ".join(words.slice(0,split_index))
   var second: String = " ".join(words.slice(split_index))
   var width: float = maxf(UIStyle.DISPLAY.get_string_size(first,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x,UIStyle.DISPLAY.get_string_size(second,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x)
   if width<best_width: best_width=width; best_split=split_index
  lines=PackedStringArray([" ".join(words.slice(0,best_split))," ".join(words.slice(best_split))])
 while font_size>10:
  var widest := 0.0
  for line in lines: widest=maxf(widest,UIStyle.DISPLAY.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x)
  if widest<=size.x-12: break
  font_size-=1
 title.autowrap_mode=TextServer.AUTOWRAP_OFF
 title.vertical_alignment=VERTICAL_ALIGNMENT_TOP
 title.add_theme_font_size_override("font_size",font_size)
 title.text="\n".join(lines)
 title.reset_size()
 title.position=Vector2(6,size.y*.65)
 title.size=Vector2(size.x-12,size.y*.28)
 queue_redraw()

func _draw() -> void:
 if item_id.is_empty(): return
 var colors: Array = UIStyle.colors(item_id)
 var ink: Color = Color(colors[1],.15)
 draw_rect(Rect2(Vector2(5,5),size-Vector2(10,13)),ink,false,1)
 for index in range(-3,12):
  var x: float = index*23.0
  draw_line(Vector2(clampf(x,0,size.x),5),Vector2(clampf(x+size.y,0,size.x),size.y-8),Color(colors[1],.018),2,true)
 var diamond := PackedVector2Array([Vector2(size.x-14,9),Vector2(size.x-9,14),Vector2(size.x-14,19),Vector2(size.x-19,14)])
 draw_colored_polygon(diamond,colors[1])

func _tilt(entered: bool) -> void:
 if not motion_enabled: return
 if _hover and _hover.is_valid(): _hover.kill()
 z_index=8 if entered else 0
 _hover=create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
 _hover.tween_property(self,"scale",Vector2(1.05,1.05) if entered else Vector2.ONE,.15)
 _hover.tween_property(self,"rotation",_rest_rotation-.035 if entered else _rest_rotation,.15)

func pulse(delay: float = 0.0) -> void:
 if not motion_enabled: return
 if _pulse and _pulse.is_valid(): _pulse.kill()
 _pulse=create_tween()
 _pulse.tween_interval(delay)
 _pulse.tween_property(self,"self_modulate",Color(1.38,1.25,1.06),.055)
 _pulse.tween_property(self,"self_modulate",Color.WHITE,.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _get_drag_data(_at_position: Vector2) -> Variant:
 if drag_index<0: return null
 var preview := TextureRect.new()
 preview.texture=illustration.texture
 preview.modulate=illustration.modulate
 preview.custom_minimum_size=Vector2(100,90)
 preview.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 preview.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 set_drag_preview(preview)
 return {"kind":"relic","from":drag_index}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
 return drag_index>=0 and data is Dictionary and data.get("kind")=="relic" and data.get("from") is int

func _drop_data(_at_position: Vector2, data: Variant) -> void:
 reorder_requested.emit(int(data.from),drag_index)

func _gui_input(event: InputEvent) -> void:
 if drag_index>=0 and event is InputEventKey and event.pressed and event.alt_pressed:
  if event.keycode in [KEY_LEFT,KEY_RIGHT]:
   reorder_requested.emit(drag_index,drag_index+(-1 if event.keycode==KEY_LEFT else 1))
   accept_event()

func _make_custom_tooltip(for_text: String) -> Object:
 var result: PanelContainer = UIStyle.panel(Color("152e3c"),Color("8caaa9"))
 var text: Label = UIStyle.label(for_text,14,UIStyle.CREAM,false,true)
 text.custom_minimum_size.x=270
 result.add_child(text)
 return result

extends Button
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
signal inspected(item_id: String)
signal reorder_requested(from_index: int, to_index: int)
@export var item_id: String = "carbon"
@export var motion_enabled := true
var live_note := ""
var selected := false
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
 mouse_entered.connect(func(): _tilt(true); _preview())
 focus_entered.connect(_preview)
 mouse_exited.connect(func(): _tilt(false); _hide_preview())
 focus_exited.connect(_hide_preview)
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
 var surface: StyleBoxFlat = UIStyle.box(colors[0],colors[0].lightened(.35),7,4,4)
 surface.border_width_bottom=5
 add_theme_stylebox_override("normal",surface)
 add_theme_stylebox_override("hover",UIStyle.box(colors[0].lightened(.08),UIStyle.GOLD,7,5,4))
 add_theme_stylebox_override("pressed",surface)
 var focus: StyleBoxFlat = UIStyle.box(Color.TRANSPARENT,UIStyle.GOLD,8,0,0)
 focus.draw_center=false
 focus.set_border_width_all(3)
 add_theme_stylebox_override("focus",focus)
 title.text=UIStyle.readable(data.name)
 rarity.text=data.rarity.to_upper()
 caption.text=_caption
 for label_node in [title,rarity,caption]:
  label_node.add_theme_color_override("font_color",colors[1])
  label_node.mouse_filter=Control.MOUSE_FILTER_IGNORE
 title.add_theme_font_override("font",UIStyle.BODY)
 title.add_theme_font_size_override("font_size",15)
 rarity.add_theme_font_override("font",UIStyle.BOLD)
 rarity.add_theme_font_size_override("font_size",9)
 caption.add_theme_font_override("font",UIStyle.BOLD)
 caption.add_theme_font_size_override("font_size",10)
 illustration.texture=UIStyle.sprite(data.art)
 illustration.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 illustration.modulate=Color.WHITE
 tooltip_text=""
 queue_redraw()

func _layout() -> void:
 pivot_offset=size*Vector2(.5,.8)
 if not is_node_ready(): return
 var art_size: float = minf(192,floorf(minf(size.x-12,size.y*.7)/48)*48)
 illustration.position=Vector2(roundf((size.x-art_size)/2),10)
 illustration.size=Vector2(art_size,art_size)
 rarity.visible=false
 caption.visible=false
 title.visible=size.x>=90
 title.text=UIStyle.readable(Cat.data_for(item_id).get("name",item_id))
 title.autowrap_mode=TextServer.AUTOWRAP_WORD
 title.max_lines_visible=2
 title.clip_text=true
 title.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 var name_size := 36
 for word in title.text.split(" "):
  if UIStyle.BODY.get_string_size(word,HORIZONTAL_ALIGNMENT_LEFT,-1,36).x>size.x-8: name_size=27
 title.add_theme_font_size_override("font_size",name_size)
 title.position=Vector2(4,art_size+10)
 title.size=Vector2(size.x-8,size.y-art_size-18)
 queue_redraw()

func _draw() -> void:
 if item_id.is_empty(): return
 var palette: Array = UIStyle.colors(item_id)
 var edge: Color = UIStyle.GOLD if selected else Color(palette[0]).lightened(.35)
 draw_rect(Rect2(3,3,size.x-6,size.y-9),edge,false,1)
 draw_rect(Rect2(6,size.y-8,size.x-12,2),Color(palette[0]).darkened(.35))

func _tilt(entered: bool) -> void:
 z_index=8 if entered else 0
 queue_redraw()

func _preview() -> void:
 var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
 if host: host._show_item_preview(item_id,live_note,self)

func _hide_preview() -> void:
 var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
 if host: host._hide_item_preview(self)

func pulse(delay: float = 0.0) -> void:
 if not motion_enabled: return
 if _pulse and _pulse.is_valid(): _pulse.kill()
 _pulse=create_tween()
 _pulse.tween_interval(delay)
 _pulse.tween_property(self,"self_modulate",Color(1.38,1.25,1.06),.055)
 _pulse.tween_property(self,"self_modulate",Color.WHITE,.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func set_motion(enabled: bool) -> void:
 motion_enabled=enabled
 if enabled: return
 if _hover and _hover.is_valid(): _hover.kill()
 if _pulse and _pulse.is_valid(): _pulse.kill()
 scale=Vector2.ONE
 rotation=_rest_rotation
 self_modulate=Color.WHITE

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

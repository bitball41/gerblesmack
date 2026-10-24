extends Button
const UIStyle = preload("res://ui/skin.gd")
@export var base_color: Color = Color("345a66")
@export var edge_color: Color = Color("7b9eaa")
@export var text_color: Color = UIStyle.CREAM
@export var display_size: int = 23
@export var motion_enabled: bool = true
@export var padding: int = 12
var _hover: Tween
var _text_key := ""

func _ready() -> void:
 clip_text=true
 if text.contains("→"):
  text=text.replace("→","").strip_edges()
  var arrow: TextureRect = UIStyle.texture("ui_right",text_color)
  arrow.name="ActionArrow"
  add_child(arrow)
  arrow.position=Vector2(size.x-33,(size.y-21)/2)
  arrow.size=Vector2(21,21)
  resized.connect(func(): arrow.position=Vector2(size.x-33,(size.y-21)/2))
 mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 focus_mode=Control.FOCUS_ALL
 add_theme_font_override("font",UIStyle.DISPLAY)
 add_theme_font_size_override("font_size",UIStyle.pixel_font_size(display_size))
 for key in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: add_theme_color_override(key,text_color)
 add_theme_color_override("font_disabled_color",Color(text_color,0.4))
 add_theme_stylebox_override("normal",UIStyle.box(base_color,edge_color,8,5,padding))
 add_theme_stylebox_override("hover",UIStyle.box(base_color.lightened(.12),edge_color.lightened(.12),8,6,padding))
 add_theme_stylebox_override("pressed",UIStyle.box(base_color.darkened(.1),edge_color,8,1,padding))
 add_theme_stylebox_override("disabled",UIStyle.box(base_color.darkened(.3),edge_color.darkened(.4),8,3,padding))
 var focus := UIStyle.box(Color.TRANSPARENT,UIStyle.GOLD,10,0,0)
 focus.draw_center=false
 focus.set_border_width_all(3)
 focus.expand_margin_left=4
 focus.expand_margin_right=4
 focus.expand_margin_top=4
 focus.expand_margin_bottom=4
 add_theme_stylebox_override("focus",focus)
 mouse_entered.connect(_entered)
 mouse_exited.connect(_exited)
 resized.connect(func(): pivot_offset=size*.5)
 pivot_offset=size*.5

func _process(_delta: float) -> void:
 var key: String = text+str(size.x)+str(display_size)
 if key==_text_key: return
 _text_key=key
 var font_size: int = display_size
 var available: float = size.x-padding*2-4-(30 if has_node("ActionArrow") else 0)
 while font_size>12 and UIStyle.DISPLAY.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>available: font_size-=1
 add_theme_font_size_override("font_size",UIStyle.pixel_font_size(font_size))

func _draw() -> void:
 if size.x<10 or size.y<10: return
 var light: Color = edge_color.lightened(.12) if is_hovered() and not disabled else edge_color
 draw_rect(Rect2(3,3,size.x-6,2),Color(light,.8))
 draw_rect(Rect2(3,size.y-6,size.x-6,3),Color(base_color.darkened(.45),.8))

func _entered() -> void:
 if disabled or not motion_enabled: return
 if _hover and _hover.is_valid(): _hover.kill()
 _hover=create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
 _hover.tween_property(self,"scale",Vector2(1.018,1.018),.13)

func _exited() -> void:
 if _hover and _hover.is_valid(): _hover.kill()
 _hover=create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
 _hover.tween_property(self,"scale",Vector2.ONE,.13)

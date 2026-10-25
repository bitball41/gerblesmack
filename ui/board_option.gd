extends Button
const UIStyle = preload("res://ui/skin.gd")
@export var board_id := "classic"
var selected := false
var definition: Dictionary = {}
var _portrait: Texture2D
func _ready() -> void:
 focus_mode=Control.FOCUS_ALL
 mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 _portrait=UIStyle.sprite("board_"+board_id)
 for state in ["normal","hover","pressed","focus"]: add_theme_stylebox_override(state,StyleBoxEmpty.new())
 focus_entered.connect(queue_redraw)
 focus_exited.connect(queue_redraw)
 mouse_entered.connect(queue_redraw)
 mouse_exited.connect(queue_redraw)
func _draw() -> void:
 var active: bool = selected or has_focus() or is_hovered()
 if active:
  draw_style_box(UIStyle.box(Color("2c4b50"),UIStyle.GOLD if selected else Color("7c9a9b"),12,0,0),Rect2(Vector2.ZERO,size))
 if _portrait: draw_texture_rect(_portrait,Rect2((size.x-80)/2,10,80,100),false)
 var name_text: String = str(definition.get("name",board_id))
 var font_size := 27
 var lines: PackedStringArray = UIStyle.summary(name_text,size.x-8,font_size,2).split("\n")
 for index in range(lines.size()):
  var line: String = lines[index]
  var text_width: float = UIStyle.BODY.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
  draw_string(UIStyle.BODY,Vector2((size.x-text_width)/2,146 if lines.size()==1 else 132+index*27),line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,UIStyle.GOLD if selected else UIStyle.CREAM)
 if selected: draw_rect(Rect2(18,size.y-4,size.x-36,3),UIStyle.GOLD)

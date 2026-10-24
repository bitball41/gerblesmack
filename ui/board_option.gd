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
 UIStyle.pixel_rect(self,Rect2(Vector2.ZERO,size-Vector2(0,18)),Color("20313c"),UIStyle.GOLD if active else Color("496571"))
 if _portrait:
  var width: float = floorf(minf(size.x-12,(size.y-28)*.8))
  draw_texture_rect(_portrait,Rect2(Vector2((size.x-width)/2,4 if active else 8),Vector2(width,width*1.25)),false)
 var name_text: String = str(definition.get("name",board_id))
 var font_size: int = 14
 var text_width: float = UIStyle.DISPLAY.get_string_size(name_text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
 draw_string(UIStyle.DISPLAY,Vector2((size.x-text_width)/2,size.y-3),name_text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,UIStyle.GOLD if selected else UIStyle.CREAM)
 if selected: draw_rect(Rect2(Vector2(size.x/2-3,-5),Vector2(6,6)),UIStyle.GOLD)

extends Button
const UIStyle = preload("res://ui/skin.gd")
@export var board_id := "classic"
var selected := false
var definition: Dictionary = {}

func _ready() -> void:
 focus_mode=Control.FOCUS_ALL
 mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 focus_entered.connect(queue_redraw)
 focus_exited.connect(queue_redraw)
 mouse_entered.connect(queue_redraw)
 mouse_exited.connect(queue_redraw)

func _draw() -> void:
 var color: Color = Color(definition.get("color","#346a64"))
 var edge: Color = UIStyle.GOLD if selected or has_focus() else Color(definition.get("edge","#8cbcaf"))
 var surface: StyleBoxFlat = UIStyle.box(color.lightened(.1) if is_hovered() else color,edge,8,5,0)
 surface.set_border_width_all(3 if selected else 2)
 draw_style_box(surface,Rect2(Vector2.ZERO,size-Vector2(0,4)))
 var ink: Color = Color(definition.get("ink","#fff1d0"))
 var values: Array = [1,2,0,0,2,3,4,0,3,4,6,7,4,6,7,8]
 for index in range(16):
  var position_in_grid: Vector2 = Vector2(13+(index%4)*12,17+int(index/4.0)*12)
  var tile_color: Color = UIStyle.tile_colors(values[index])[0] if values[index]>0 else color.darkened(.35)
  draw_style_box(UIStyle.box(tile_color,tile_color.lightened(.2),2,1,0),Rect2(position_in_grid,Vector2(10,10)))
 draw_string(UIStyle.DISPLAY,Vector2(74,37),str(definition.get("name",board_id)),HORIZONTAL_ALIGNMENT_LEFT,-1,23,ink)
 draw_string(UIStyle.BOLD,Vector2(75,60),str(definition.get("badge","4×4")),HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color(ink,.9))
 if selected:
  var check_mark := PackedVector2Array([Vector2(size.x-25,16),Vector2(size.x-21,20),Vector2(size.x-14,11)])
  draw_polyline(check_mark,ink,2,true)

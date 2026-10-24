extends Button
## The illustration is the control. Only hover/focus and selection add framing.
const UIStyle = preload("res://ui/skin.gd")
var item_id := ""
var selected := false
var board_stack := false
var motion_enabled := true
func _ready() -> void:
 mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 focus_mode=Control.FOCUS_ALL
 for state in ["normal","hover","pressed","disabled","focus"]: add_theme_stylebox_override(state,StyleBoxEmpty.new())
 mouse_entered.connect(func(): queue_redraw(); _preview())
 mouse_exited.connect(func(): queue_redraw(); _hide_preview())
 focus_entered.connect(func(): queue_redraw(); _preview())
 focus_exited.connect(func(): queue_redraw(); _hide_preview())
 resized.connect(queue_redraw)
func _process(_delta: float) -> void:
 # Keep unavailable product names legible; dim the illustration only.
 for child in get_children():
  if child is TextureRect: child.modulate.a=.55 if disabled else 1.0
func _draw() -> void:
 if board_stack:
  UIStyle.pixel_rect(self,Rect2(24,12,128,160),Color("c2b88f"),Color("e6d9b4"))
  UIStyle.pixel_rect(self,Rect2(18,8,128,160),Color("e0d1a6"),UIStyle.CREAM)
 if not disabled and (selected or has_focus() or is_hovered()):
  var color: Color = UIStyle.GOLD if selected or has_focus() else Color("b4c9bc")
  for corner in [Vector2(1,1),Vector2(size.x-1,1),Vector2(1,size.y-1),size-Vector2.ONE]:
   var dx: float = 10 if corner.x<size.x/2 else -10
   var dy: float = 10 if corner.y<size.y/2 else -10
   draw_line(corner,corner+Vector2(dx,0),color,2)
   draw_line(corner,corner+Vector2(0,dy),color,2)
func _preview() -> void:
 if item_id.is_empty(): return
 var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
 if host: host._show_item_preview(item_id,"One offer per floor",self)
func _hide_preview() -> void:
 var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
 if host: host._hide_item_preview(self)

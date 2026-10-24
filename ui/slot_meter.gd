extends Control
const UIStyle = preload("res://ui/skin.gd")
var used := 0
var capacity := 0
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
func sync(count: int, limit: int) -> void:
 used=count
 capacity=limit
 queue_redraw()
func _draw() -> void:
 for index in range(capacity):
  var rect := Rect2(index*16,0,10,12)
  if index<used: draw_rect(rect,UIStyle.CREAM)
  else: draw_rect(rect,Color("79938d"),false,2)

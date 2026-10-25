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
 if capacity<=0: return
 var shown: int = mini(capacity,12)
 var stride: float = minf(16,(size.x-7)/maxi(1,shown-1))
 for index in range(shown):
  var rect := Rect2(roundf(index*stride),0,minf(10,maxf(3,stride-3)),12)
  if index<used: draw_rect(rect,UIStyle.CREAM)
  else: draw_rect(rect,Color("79938d"),false,1)

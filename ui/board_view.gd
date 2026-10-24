extends Control
const UIStyle = preload("res://ui/skin.gd")
const TILE_SCENE: PackedScene = preload("res://scenes/ui/tile.tscn")
signal cell_selected(index: int)
signal swiped(direction: String)
signal animation_finished
@export var decorative := false
@export var motion_enabled := true
var cells: Array = []
var tiles: Dictionary = {}
var animating := false
var selected_cell := -1
var targeting := false
var _origin := Vector2.ZERO
var _pointer_started := false
var _animation: Tween
var _epoch := 0

func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE if decorative else Control.MOUSE_FILTER_STOP
 resized.connect(_resized)
 _resized()

func _draw() -> void:
 draw_style_box(UIStyle.box(Color("152731"),Color("77939b"),12,8,0),Rect2(Vector2.ZERO,size))
 var inner: Rect2 = _inner()
 var cell_size: Vector2 = _cell_size()
 for index in range(16):
  var position_in_grid: Vector2 = _cell_position(index)
  var style: StyleBoxFlat = UIStyle.box(Color("2a414c"),Color("102632"),6,0,0)
  if targeting:
   style.border_color=UIStyle.GOLD if selected_cell==index else Color("7ba49e")
   style.bg_color=Color("35515a")
  draw_style_box(style,Rect2(position_in_grid,cell_size))
 if inner.size.x<0: return

func _inner() -> Rect2:
 return Rect2(Vector2(13,13),size-Vector2(26,28))

func _cell_size() -> Vector2:
 return (_inner().size-Vector2(27,27))/4.0

func _cell_position(index: int) -> Vector2:
 return _inner().position+Vector2(index%4,int(index/4.0))*(_cell_size()+Vector2(9,9))

func _resized() -> void:
 queue_redraw()
 for index in tiles:
  if is_instance_valid(tiles[index]):
   tiles[index].position=_cell_position(index)
   tiles[index].size=_cell_size()

func show_cells(data: Array, pop_indices: Array = [], new_indices: Array = []) -> void:
 _epoch+=1
 if _animation and _animation.is_valid(): _animation.kill()
 animating=false
 for tile_node in tiles.values():
  if is_instance_valid(tile_node):
   remove_child(tile_node)
   tile_node.queue_free()
 tiles.clear()
 cells=data.duplicate(true)
 for index in range(cells.size()):
  if cells[index]==null: continue
  var tile_node: Control = TILE_SCENE.instantiate()
  tile_node.motion_enabled=motion_enabled
  add_child(tile_node)
  tile_node.position=_cell_position(index)
  tile_node.size=_cell_size()
  tile_node.configure(cells[index])
  tiles[index]=tile_node
  if pop_indices.has(index): tile_node.pop(int(cells[index].e)>=10)
  elif new_indices.has(index): tile_node.appear()
 queue_redraw()

func animate_move(before: Array, after: Array, direction: String, duration: float = .135) -> void:
 if not motion_enabled or not is_visible_in_tree():
  show_cells(after)
  animation_finished.emit()
  return
 show_cells(before)
 animating=true
 var token: int = _epoch
 var destinations: Dictionary = {}
 var merged: Array = []
 var departed: Array = []
 for line in range(4):
  var positions: Array = []
  for p in range(4):
   match direction:
    "left": positions.append(line*4+p)
    "right": positions.append(line*4+3-p)
    "up": positions.append(p*4+line)
    "down": positions.append((3-p)*4+line)
  var occupied: Array = positions.filter(func(index): return before[index]!=null)
  var k := 0
  var write := 0
  while k<occupied.size():
   var first: int = occupied[k]
   var destination: int = positions[write]
   destinations[first]=destination
   if k+1<occupied.size() and before[first].e==before[occupied[k+1]].e:
    destinations[occupied[k+1]]=destination
    departed.append(occupied[k+1])
    merged.append(destination)
    k+=2
   else: k+=1
   write+=1
 _animation=create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 for from_index in destinations:
  if not tiles.has(from_index): continue
  _animation.tween_property(tiles[from_index],"position",_cell_position(destinations[from_index]),duration)
  if departed.has(from_index): _animation.tween_property(tiles[from_index],"modulate:a",.1,duration)
 _animation.chain().tween_callback(func():
  if token!=_epoch or not is_inside_tree(): return
  _animation=null
  var appeared: Array = []
  var occupied_destinations: Array = destinations.values()
  for index in range(16):
   if after[index]!=null and not occupied_destinations.has(index): appeared.append(index)
  show_cells(after,merged,appeared)
  animation_finished.emit()
 )

func cancel_animation() -> void:
 var was_animating: bool = animating
 _epoch+=1
 animating=false
 if _animation and _animation.is_valid(): _animation.kill()
 if was_animating: animation_finished.emit()

func _gui_input(event: InputEvent) -> void:
 if decorative: return
 if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT):
  if event.pressed:
   _origin=event.position
   _pointer_started=true
  elif _pointer_started:
   _pointer_started=false
   var difference: Vector2 = event.position-_origin
   if not targeting and difference.length()>22:
    swiped.emit(("right" if difference.x>0 else "left") if absf(difference.x)>absf(difference.y) else ("down" if difference.y>0 else "up"))
   else:
    for index in range(16):
     if Rect2(_cell_position(index),_cell_size()).has_point(event.position):
      cell_selected.emit(index)
      break
   accept_event()

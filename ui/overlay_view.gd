extends Control
const UIStyle = preload("res://ui/skin.gd")
const BUTTON_SCENE: PackedScene = preload("res://scenes/ui/action_button.tscn")
signal close_requested
var closable := true
var view_id := ""
var body: VBoxContainer
var panel: PanelContainer
var _open_tween: Tween
var motion_enabled := true

func _ready() -> void:
 visible=false
 mouse_filter=Control.MOUSE_FILTER_STOP

func open(title_text: String, id: String, dimensions: Vector2 = Vector2(930,710), can_close: bool = true, top: float = -1) -> VBoxContainer:
 for node in get_children(): remove_child(node); node.queue_free()
 view_id=id
 closable=can_close
 var shade := ColorRect.new()
 shade.color=Color("061a24c7")
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(shade)
 shade.mouse_filter=Control.MOUSE_FILTER_STOP
 shade.gui_input.connect(func(event: InputEvent):
  if closable and event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT: close_requested.emit()
 )
 panel=UIStyle.panel(Color("283d49"),Color("9cbbc0"),22)
 add_child(panel)
 panel.mouse_filter=Control.MOUSE_FILTER_STOP
 panel.size=dimensions
 panel.position=Vector2((1440-dimensions.x)/2,(900-dimensions.y)/2 if top<0 else top)
 var layout: VBoxContainer = UIStyle.column(15)
 layout.size_flags_vertical=Control.SIZE_EXPAND_FILL
 panel.add_child(layout)
 var head: HBoxContainer = UIStyle.row(12)
 layout.add_child(head)
 var title_label: Label = UIStyle.label(title_text,34,UIStyle.CREAM,true)
 title_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 head.add_child(title_label)
 if closable:
  var close_button: Button = BUTTON_SCENE.instantiate()
  close_button.text="×"
  close_button.display_size=26
  close_button.custom_minimum_size=Vector2(38,38)
  close_button.pressed.connect(func(): close_requested.emit())
  head.add_child(close_button)
  close_button.grab_focus.call_deferred()
 var scroll := ScrollContainer.new()
 scroll.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
 scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 layout.add_child(scroll)
 body=UIStyle.column(14)
 body.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 scroll.add_child(body)
 visible=true
 if motion_enabled:
  if _open_tween and _open_tween.is_valid(): _open_tween.kill()
  panel.pivot_offset=dimensions*.5
  panel.scale=Vector2(.975,.975)
  panel.modulate.a=.6
  _open_tween=create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  _open_tween.tween_property(panel,"scale",Vector2.ONE,.16)
  _open_tween.tween_property(panel,"modulate:a",1.0,.13)
 return body

func close() -> void:
 if _open_tween and _open_tween.is_valid(): _open_tween.kill()
 visible=false
 view_id=""
 for node in get_children(): remove_child(node); node.queue_free()

func open_custom(id: String, dimensions: Vector2, can_close: bool = true, top: float = -1) -> Control:
 open("",id,dimensions,false,top)
 closable=can_close
 for child in panel.get_children(): panel.remove_child(child); child.queue_free()
 panel.add_theme_stylebox_override("panel",UIStyle.box(Color("293b45"),Color("98b2b3"),0,7,0))
 body=null
 var host := Control.new()
 host.name="CustomView"
 panel.add_child(host)
 panel.size=dimensions
 return host

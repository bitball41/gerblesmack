extends Control
## The model commits immediately; only the displayed balance is interpolated.
const UIStyle = preload("res://ui/skin.gd")
const Num = preload("res://scripts/num.gd")
signal count_tick
@export var display_size := 38
var motion_enabled := true
var value_label: Label
var target_amount = Num.new()
var displayed := 0.0
var _initialized := false
var _counter: Tween
var _pulse: Tween
var _delta: Label
var _last_tick := -1

func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 var coin: TextureRect = UIStyle.texture("coin")
 coin.name="Coin"
 add_child(coin)
 value_label=UIStyle.label("0",display_size,UIStyle.GOLD,true)
 value_label.name="Amount"
 add_child(value_label)
 resized.connect(_layout)
 _layout()

func _layout() -> void:
 if not is_node_ready(): return
 var coin_size: float = clampf(size.y*.55,18,42)
 get_node("Coin").position=Vector2(0,(size.y-coin_size)/2)
 get_node("Coin").size=Vector2(coin_size,coin_size)
 value_label.position=Vector2(coin_size+5,0)
 value_label.size=Vector2(maxf(1,size.x-coin_size-5),size.y)
 value_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER

func reset(amount) -> void:
 if _counter and _counter.is_valid(): _counter.kill()
 if _pulse and _pulse.is_valid(): _pulse.kill()
 target_amount=Num.of(amount)
 displayed=target_amount.to_float() if target_amount.e<12 else 0.0
 _initialized=true
 if value_label:
  value_label.text=target_amount.fmt()
  value_label.scale=Vector2.ONE
  value_label.modulate=Color.WHITE
  _fit()

func set_amount(amount, immediate: bool = false) -> void:
 var next = Num.of(amount)
 if not _initialized or immediate: reset(next); return
 var direction: int = next.cmp(target_amount)
 if direction==0: return
 var previous = target_amount
 target_amount=next
 if _counter and _counter.is_valid(): _counter.kill()
 if _pulse and _pulse.is_valid(): _pulse.kill()
 if not motion_enabled: reset(next); return
 var delta = next.minus(previous) if direction>0 else previous.minus(next)
 _show_delta(("+" if direction>0 else "-")+"$"+delta.fmt(),direction>0)
 value_label.pivot_offset=value_label.size*.5
 value_label.scale=Vector2(1.17,.94)
 value_label.modulate=Color("9bdfac") if direction>0 else Color("ff9a79")
 _pulse=create_tween().set_parallel(true)
 _pulse.tween_property(value_label,"scale",Vector2.ONE,.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
 _pulse.tween_property(value_label,"modulate",Color.WHITE,.46)
 if next.e<10 and previous.e<10:
  _last_tick=-1
  _counter=create_tween()
  _counter.tween_method(_set_count,displayed,next.to_float(),.42).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  _counter.tween_callback(func(): value_label.text=target_amount.fmt(); _fit())
 else: value_label.text=next.fmt(); _fit()

func _set_count(value: float) -> void:
 displayed=value
 var number: int = int(roundf(value))
 value_label.text=str(number)
 _fit()
 if number!=_last_tick: _last_tick=number; count_tick.emit()

func _fit() -> void:
 var font_size: int = display_size
 while font_size>12 and UIStyle.DISPLAY.get_string_size(value_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>value_label.size.x: font_size-=2
 value_label.add_theme_font_size_override("font_size",UIStyle.pixel_font_size(font_size))

func _show_delta(text: String, income: bool) -> void:
 if is_instance_valid(_delta): _delta.queue_free()
 _delta=UIStyle.label(text,22,UIStyle.GREEN if income else UIStyle.RED,true)
 _delta.z_index=10
 _delta.position=Vector2(12,-10)
 add_child(_delta)
 var node: Label = _delta
 var tween: Tween = create_tween().set_parallel(true)
 tween.tween_property(node,"position:y",-38.0,.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 tween.tween_property(node,"modulate:a",0.0,.25).set_delay(.4)
 tween.chain().tween_callback(node.queue_free)

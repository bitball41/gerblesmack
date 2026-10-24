extends Control
const UIStyle = preload("res://ui/skin.gd")
var value: Dictionary = {}
var motion_enabled := true
var _pop: Tween

func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 resized.connect(func(): pivot_offset=size*.5; queue_redraw())

func configure(data: Dictionary) -> void:
 value=data.duplicate(true)
 queue_redraw()

func _draw() -> void:
 if value.is_empty(): return
 var exponent: int = int(value.e)
 var palette: Array = UIStyle.tile_colors(exponent)
 var fx: Dictionary = value.get("fx",{})
 var edge: Color = Color("ffe59a") if fx.get("gold",false) else Color(palette[0]).lightened(.38)
 var panel: StyleBoxFlat = UIStyle.box(palette[0],edge,7,4,0)
 panel.border_width_bottom=6
 panel.border_color=Color(edge,.82)
 draw_style_box(panel,Rect2(Vector2.ZERO,size-Vector2(0,3)))
 var text: String = UIStyle.tile_text(exponent)
 var font_size: int = int(size.x*.49)
 while UIStyle.DISPLAY.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>size.x-10 and font_size>10: font_size-=1
 var measured: Vector2 = UIStyle.DISPLAY.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)
 var baseline: Vector2 = Vector2((size.x-measured.x)/2,size.y*.50+UIStyle.DISPLAY.get_ascent(font_size)*.32)
 draw_string(UIStyle.DISPLAY,baseline+Vector2(0,1),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("00000018"))
 draw_string(UIStyle.DISPLAY,baseline,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,palette[1])
 if fx.get("glass",false):
  draw_line(Vector2(size.x*.12,3),Vector2(size.x*.54,size.y-10),Color("ffffff25"),size.x*.12,true)
 var enhancement: String = ""
 for key in ["gold","steel","glass"]:
  if fx.get(key,false): enhancement+=("Au" if key=="gold" else "Fe" if key=="steel" else "◇")+" "
 if not enhancement.is_empty():
  var small: int = maxi(9,int(size.x*.13))
  var width: float = UIStyle.BOLD.get_string_size(enhancement,HORIZONTAL_ALIGNMENT_LEFT,-1,small).x
  draw_string(UIStyle.BOLD,Vector2((size.x-width)/2,size.y-10),enhancement,HORIZONTAL_ALIGNMENT_LEFT,-1,small,Color(palette[1],.8))
 if value.get("seal",false):
  draw_circle(Vector2(size.x-12,12),7,Color("8f303b"))
  draw_circle(Vector2(size.x-12,11),5,Color("f4836e"))
  draw_circle(Vector2(size.x-12,11),2,Color("fff0c9"))

func pop(large: bool = false) -> void:
 if not motion_enabled: return
 if _pop and _pop.is_valid(): _pop.kill()
 pivot_offset=size*.5
 scale=Vector2(1.16,0.91) if large else Vector2(1.10,.94)
 _pop=create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
 _pop.tween_property(self,"scale",Vector2.ONE,.21)

func appear() -> void:
 if not motion_enabled: return
 pivot_offset=size*.5
 scale=Vector2(.35,.35)
 modulate.a=.4
 var tween: Tween = create_tween().set_parallel(true)
 tween.tween_property(self,"scale",Vector2.ONE,.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
 tween.tween_property(self,"modulate:a",1.0,.12)

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
 UIStyle.pixel_rect(self,Rect2(Vector2.ZERO,size-Vector2(0,4)),palette[0],edge,2)
 draw_rect(Rect2(6,5,maxf(2,size.x*.25),2),Color(edge,.7))
 var text: String = UIStyle.tile_text(exponent)
 var font_size: int = int(size.x*.49)
 while UIStyle.DISPLAY.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>size.x-10 and font_size>10: font_size-=1
 font_size=UIStyle.pixel_font_size(font_size)
 var measured: Vector2 = UIStyle.DISPLAY.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)
 var baseline: Vector2 = Vector2((size.x-measured.x)/2,size.y*.50+UIStyle.DISPLAY.get_ascent(font_size)*.32)
 draw_string(UIStyle.DISPLAY,baseline+Vector2(0,1),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("00000018"))
 draw_string(UIStyle.DISPLAY,baseline,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,palette[1])
 if fx.get("glass",false):
  for index in range(7):
   draw_rect(Rect2(8+index*4,6+index*int(size.y/9),8,6),Color("ffffff35"))
 var enhancement: String = ""
 for key in ["gold","steel","glass"]:
  if fx.get(key,false): enhancement+=("Au" if key=="gold" else "Fe" if key=="steel" else "Gl")+" "
 if not enhancement.is_empty():
  var small: int = 16
  var width: float = UIStyle.BOLD.get_string_size(enhancement,HORIZONTAL_ALIGNMENT_LEFT,-1,small).x
  draw_string(UIStyle.BOLD,Vector2((size.x-width)/2,size.y-10),enhancement,HORIZONTAL_ALIGNMENT_LEFT,-1,small,Color(palette[1],.8))
 if value.get("seal",false):
  draw_texture_rect(UIStyle.sprite("seal"),Rect2(size.x-26,2,24,24),false)

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

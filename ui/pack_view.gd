extends Control
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
const CARD: PackedScene = preload("res://scenes/ui/card.tscn")
const BUTTON: PackedScene = preload("res://scenes/ui/action_button.tscn")
signal picked(id: String)
signal item_inspected(id: String, source: Control)
signal skipped
var choices: Array = []
var available: Dictionary = {}
var motion_enabled := true
func _ready() -> void:
 var title: Label = UIStyle.label("SUPPLY PACK",30,UIStyle.GOLD,true)
 title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 UIStyle.place(title,self,Rect2(20,26,744,42))
 var note: Label = UIStyle.label("CHOOSE ONE",15,UIStyle.MUTED,true)
 note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 UIStyle.place(note,self,Rect2(20,80,744,38))
 for index in range(choices.size()):
  var id: String = choices[index]
  var x: float = 80+index*232
  var card: Control = CARD.instantiate()
  card.item_id=id
  card.motion_enabled=motion_enabled
  card.custom_minimum_size=Vector2.ZERO
  UIStyle.place(card,self,Rect2(x,158,164,192))
  card.inspected.connect(func(item: String): item_inspected.emit(item,card))
  var choose: Button = BUTTON.instantiate()
  choose.custom_minimum_size=Vector2.ZERO
  choose.text="TAKE"
  choose.base_color=Color("328a69")
  choose.edge_color=Color("82b999")
  choose.display_size=20
  choose.padding=6
  choose.motion_enabled=motion_enabled
  choose.disabled=not bool(available.get(id,false))
  choose.pressed.connect(func(item: String = id): picked.emit(item))
  UIStyle.place(choose,self,Rect2(x,382,164,46))
  if motion_enabled:
   card.position=Vector2(416,144)
   card.scale=Vector2(.8,.8)
   card.modulate.a=.4
   var reveal: Tween = card.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
   reveal.tween_property(card,"position",Vector2(x,158),.3).set_delay(index*.06)
   reveal.tween_property(card,"scale",Vector2.ONE,.3).set_delay(index*.06)
   reveal.tween_property(card,"modulate:a",1.0,.2).set_delay(index*.06)
 var skip: Button = BUTTON.instantiate()
 skip.custom_minimum_size=Vector2.ZERO
 skip.text="SKIP"
 skip.base_color=Color("685574")
 skip.display_size=20
 skip.padding=6
 skip.motion_enabled=motion_enabled
 skip.pressed.connect(func(): skipped.emit())
 UIStyle.place(skip,self,Rect2(596,500,168,48))

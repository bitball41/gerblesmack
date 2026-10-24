extends Control
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
const CARD: PackedScene = preload("res://scenes/ui/card.tscn")
const BUTTON: PackedScene = preload("res://scenes/ui/action_button.tscn")
signal picked(id: String)
signal skipped
var choices: Array = []
var available: Dictionary = {}
var motion_enabled := true

func _ready() -> void:
 var title: Label = UIStyle.label("SUPPLY PACK",34,UIStyle.GOLD,true)
 title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 UIStyle.place(title,self,Rect2(18,22,1102,44))
 var note: Label = UIStyle.label("CHOOSE ONE FOR YOUR ENGINE",14,UIStyle.MUTED,true)
 note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 UIStyle.place(note,self,Rect2(18,72,1102,22))
 for index in range(choices.size()):
  var id: String = choices[index]
  var x: float = 108+index*340
  var card: Control = CARD.instantiate()
  card.item_id=id
  card.motion_enabled=motion_enabled
  card.custom_minimum_size=Vector2.ZERO
  UIStyle.place(card,self,Rect2(x,110,210,280))
  card.inspected.connect(func(item: String): picked.emit(item))
  var description: Label = UIStyle.label(Cat.data_for(id).desc,14,UIStyle.CREAM,false,true)
  UIStyle.place(description,self,Rect2(x-26,404,264,56))
  var choose: Button = BUTTON.instantiate()
  choose.custom_minimum_size=Vector2.ZERO
  choose.text="TAKE CARD"
  choose.base_color=Color("488268")
  choose.edge_color=Color("9ebd8b")
  choose.display_size=20
  choose.padding=6
  choose.motion_enabled=motion_enabled
  choose.disabled=not bool(available.get(id,false))
  choose.pressed.connect(func(item: String = id): picked.emit(item))
  UIStyle.place(choose,self,Rect2(x,468,210,42))
  if motion_enabled:
   card.position=Vector2(464,165)
   card.scale=Vector2(.7,.7)
   card.modulate.a=.4
   var reveal: Tween = card.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
   reveal.tween_property(card,"position",Vector2(x,110),.34).set_delay(index*.07)
   reveal.tween_property(card,"scale",Vector2.ONE,.34).set_delay(index*.07)
   reveal.tween_property(card,"modulate:a",1.0,.2).set_delay(index*.07)
 var seal: TextureRect = UIStyle.texture("pack")
 UIStyle.place(seal,self,Rect2(30,527,40,40))
 UIStyle.place(UIStyle.label("ONE CARD. A DIFFERENT RUN.",13,UIStyle.MUTED,true),self,Rect2(84,540,690,25))
 var skip: Button = BUTTON.instantiate()
 skip.custom_minimum_size=Vector2.ZERO
 skip.text="SKIP PACK"
 skip.base_color=Color("685574")
 skip.display_size=18
 skip.padding=6
 skip.motion_enabled=motion_enabled
 skip.pressed.connect(func(): skipped.emit())
 UIStyle.place(skip,self,Rect2(878,530,220,40))

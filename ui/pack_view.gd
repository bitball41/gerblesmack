extends Control
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
var game
const CARD: PackedScene = preload("res://scenes/ui/card.tscn")
const BUTTON: PackedScene = preload("res://scenes/ui/action_button.tscn")
signal picked(id: String)
signal item_inspected(id: String, source: Control)
signal skipped
var choices: Array = []
var available: Dictionary = {}
var tags: Dictionary = {}
var type := "standard"
var pack_size := "Standard"
var remaining := 1
var motion_enabled := true
func _ready() -> void:
 var title: Label = UIStyle.label((pack_size+" "+str(Cat.PACKS[type].name)+" pack").to_upper(),36,UIStyle.GOLD,true)
 title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 UIStyle.place(title,self,Rect2(20,26,856,42))
 var note: Label = UIStyle.label("CHOOSE %d / %s" % [remaining,Cat.PACKS[type].desc],27,UIStyle.MUTED,true)
 note.add_theme_font_size_override("font_size",27)
 note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 UIStyle.place(note,self,Rect2(20,80,856,38))
 var spacing: float = minf(36,(856-choices.size()*164.0)/maxi(1,choices.size()-1))
 var start: float = 20+(856-choices.size()*164-(choices.size()-1)*spacing)/2
 for index in range(choices.size()):
  var id: String = choices[index]
  var x: float = start+index*(164+spacing)
  var card: Control = CARD.instantiate()
  card.item_id=id
  card.item_state=tags.get(id,{})
  if game!=null and Cat.RELICS.has(id):
   var preview: Dictionary = {"id":id,"growth":UIStyle.Num.new(1),"charge":0,"carry":0}
   preview.merge(card.item_state,true)
   card.live_note=game.Rules.status(game,preview)
  card.motion_enabled=motion_enabled
  card.custom_minimum_size=Vector2.ZERO
  UIStyle.place(card,self,Rect2(x,158,164,192))
  card.inspected.connect(func(item: String): item_inspected.emit(item,card))
  var choose: Button = BUTTON.instantiate()
  choose.custom_minimum_size=Vector2.ZERO
  choose.text="TAKE"
  choose.base_color=Color("328a69")
  choose.edge_color=Color("82b999")
  choose.display_size=32
  choose.padding=6
  choose.motion_enabled=motion_enabled
  choose.disabled=not bool(available.get(id,false))
  choose.pressed.connect(func(item: String = id): picked.emit(item))
  UIStyle.place(choose,self,Rect2(x,382,164,46))
  if motion_enabled:
   card.position=Vector2(366,144)
   card.scale=Vector2(.8,.8)
   card.modulate.a=.4
   var reveal: Tween = card.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
   reveal.tween_property(card,"position",Vector2(x,158),.3).set_delay(index*.04)
   reveal.tween_property(card,"scale",Vector2.ONE,.3).set_delay(index*.04)
   reveal.tween_property(card,"modulate:a",1.0,.2).set_delay(index*.04)
 var skip: Button = BUTTON.instantiate()
 skip.custom_minimum_size=Vector2.ZERO
 skip.text="SKIP REST" if remaining>1 else "SKIP"
 skip.base_color=Color("685574")
 skip.display_size=32
 skip.padding=6
 skip.motion_enabled=motion_enabled
 skip.pressed.connect(func(): skipped.emit())
 UIStyle.place(skip,self,Rect2(648,500,228,48))

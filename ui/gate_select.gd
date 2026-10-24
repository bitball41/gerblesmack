extends Control
const UIStyle = preload("res://ui/skin.gd")
const BUTTON: PackedScene = preload("res://scenes/ui/action_button.tscn")
signal enter_requested
var view_size := Vector2(1152,580)
var previews: Array[Dictionary] = []
var floor_num := 1
var retry := false
var motion_enabled := true
var cards: Array[Control] = []
var enter_buttons: Array[Button] = []
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_STOP
 _text("Floor %d  /  Choose your next gate" % floor_num,Rect2(22,8,1100,40),32,UIStyle.CREAM,self)
 for preview in previews:
  var index: int = preview.index
  var active: bool = preview.status=="Ready"
  var card := Control.new()
  UIStyle.place(card,self,Rect2(20+index*376,62,344,498))
  card.set_meta("gate_index",index)
  cards.append(card)
  var bg: PanelContainer = UIStyle.panel(Color("263b45") if active else Color("21323c"),UIStyle.GOLD if active else Color("637a80"),0)
  UIStyle.place(bg,card,Rect2(0,0,344,498))
  var status: String = "Retry this gate" if active and retry else "You are here" if active else preview.status
  _text(status,Rect2(18,14,308,36),32,UIStyle.GOLD if active else UIStyle.GREEN if preview.status=="Cleared" else UIStyle.MUTED,card)
  _text(preview.name,Rect2(18,58,308,72),32,UIStyle.CREAM,card,true)
  var art: TextureRect = UIStyle.texture(preview.art)
  UIStyle.place(art,card,Rect2(246,138,64,64))
  _text("Target",Rect2(18,134,204,34),32,UIStyle.MUTED,card)
  _text(preview.target,Rect2(18,166,228,72),64,UIStyle.GOLD,card)
  _text("%d moves" % preview.moves,Rect2(18,248,308,36),32,UIStyle.CREAM,card)
  _text(preview.rule,Rect2(18,292,308,100),32,UIStyle.CREAM,card,true)
  _text("Base reward  $%d" % preview.reward,Rect2(18,402,308,34),32,UIStyle.GOLD,card)
  var enter: Button = BUTTON.instantiate()
  enter.custom_minimum_size=Vector2.ZERO
  enter.text="Enter gate" if active else preview.status
  enter.display_size=32
  enter.padding=6
  enter.motion_enabled=motion_enabled
  enter.base_color=Color("bd594c") if active else Color("3c535b")
  enter.edge_color=Color("df9581") if active else Color("607981")
  enter.disabled=not active
  enter.pressed.connect(func(): enter_requested.emit())
  UIStyle.place(enter,card,Rect2(18,446,308,42))
  enter_buttons.append(enter)
  if preview.status=="Cleared": card.modulate=Color(.67,.77,.75)
 adapt_canvas(view_size)
func _text(value: String, rect: Rect2, font_size: int, color: Color, parent: Node, wrap: bool = false) -> Label:
 var label: Label = UIStyle.label(value,font_size,color,false,wrap)
 if font_size>=48: label.add_theme_font_override("font",UIStyle.DISPLAY)
 UIStyle.place(label,parent,rect)
 return label

func adapt_canvas(dimensions: Vector2) -> void:
 var width: float = floorf((dimensions.x-104)/3)
 var height: float = dimensions.y-82
 for index in range(cards.size()):
  var card: Control = cards[index]
  card.position.x=20+index*(width+32)
  card.size=Vector2(width,height)
  card.get_child(0).size=card.size
  var enter: Button = enter_buttons[index]
  enter.position.y=height-52
  enter.size.x=width-36
  var reward: Label = card.get_child(card.get_child_count()-2)
  reward.position.y=height-96

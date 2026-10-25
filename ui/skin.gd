extends RefCounted
const DISPLAY: Font = preload("res://assets/type/m6x11plus.ttf")
const BODY: Font = preload("res://assets/type/m6x11plus.ttf")
const BOLD: Font = DISPLAY
const Fracture = preload("res://scripts/fracture_catalog.gd")
const Visuals = preload("res://ui/visual_catalog.gd")
const Num = preload("res://scripts/num.gd")
const CREAM = Color("fff3ce")
const TEXT = Color("f4f4e9")
const MUTED = Color("afc2c8")
const GOLD = Color("f0bd51")
const GREEN = Color("67b38d")
const RED = Color("e86d53")
const BLUE = Color("54b3d8")
const PANEL = Color("263741")
const TILE_COLORS = [["f4e8c6","283948"],["ecc36c","353c3d"],["e89b51","293541"],["d76c47","fff2cf"],["b8506b","fff3d8"],["8761a1","fff3d5"],["527bac","fff1d3"],["3f9299","fff1ca"],["95b864","273e39"],["e3ad3a","30392f"],["f1cd67","313a35"]]

static func box(bg: Color, edge: Color = Color("526571"), radius: int = 9, depth: int = 4, padding: int = 12) -> StyleBoxFlat:
 var style := StyleBoxFlat.new()
 style.bg_color=bg
 style.border_color=edge
 style.set_border_width_all(2)
 style.set_corner_radius_all(radius)
 style.corner_detail=6
 style.anti_aliasing=false
 style.border_width_bottom=4 if depth>0 else 2
 style.shadow_color=Color("08151de6")
 style.shadow_size=0
 style.shadow_offset=Vector2(0,depth)
 style.content_margin_left=padding
 style.content_margin_right=padding
 style.content_margin_top=padding
 style.content_margin_bottom=padding
 return style

static func label(text: String, font_size: int = 16, color: Color = TEXT, display: bool = false, wrap: bool = false) -> Label:
 var result := Label.new()
 result.text=readable(text)
 result.add_theme_font_override("font",DISPLAY if display else BODY)
 result.add_theme_font_size_override("font_size",pixel_font_size(font_size))
 result.add_theme_color_override("font_color",color)
 result.mouse_filter=Control.MOUSE_FILTER_IGNORE
 result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
 return result

static func panel(bg: Color = PANEL, edge: Color = Color("526571"), padding: int = 12) -> PanelContainer:
 var result := PanelContainer.new()
 result.mouse_filter=Control.MOUSE_FILTER_IGNORE
 result.add_theme_stylebox_override("panel",box(bg,edge,14,5,padding))
 return result

static func column(gap: int = 10) -> VBoxContainer:
 var result := VBoxContainer.new()
 result.add_theme_constant_override("separation",gap)
 return result

static func row(gap: int = 10) -> HBoxContainer:
 var result := HBoxContainer.new()
 result.add_theme_constant_override("separation",gap)
 return result

static func texture(symbol: String, tint: Color = CREAM) -> TextureRect:
 var result := TextureRect.new()
 var path: String = "res://assets/pixel/"+symbol+".png"
 if ResourceLoader.exists(path): result.texture=sprite(symbol)
 result.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 # Illustrations carry their own palette. Only monochrome interface icons are tinted.
 if symbol.begins_with("ui_") and symbol!="ui_heart": result.modulate=tint
 result.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 result.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 result.mouse_filter=Control.MOUSE_FILTER_IGNORE
 return result

static func colors(id: String) -> Array:
 var pair: Array = Visuals.CARDS.get(id,{}).get("colors",Fracture.RELICS.get(id,Fracture.FRACTURES.get(id,{})).get("colors",["#46799e","#fff3ce"]))
 return [Color(pair[0]),Color(pair[1])]

static func tile_colors(exponent: int) -> Array:
 var pair: Array = TILE_COLORS[clampi(exponent-1,0,TILE_COLORS.size()-1)]
 return [Color(pair[0]),Color(pair[1])]

static func number(value) -> String:
 return Num.of(value).fmt()

static func tile_text(exponent: int) -> String:
 return str(1<<exponent) if exponent<20 else Num.power(2,exponent).fmt()

static func place(control: Control, parent: Node, rect: Rect2) -> void:
 parent.add_child(control)
 control.position=rect.position
 control.size=rect.size

static func set_rect(control: Control, rect: Rect2) -> void:
 control.position=rect.position
 control.size=rect.size

static func default_theme() -> Theme:
 var result := Theme.new()
 result.default_font=BODY
 result.default_font_size=36
 result.set_constant("outline_size","Label",0)
 result.set_color("font_shadow_color","Label",Color.TRANSPARENT)
 result.set_constant("shadow_offset_y","Label",0)
 result.set_constant("shadow_offset_x","Label",0)
 result.set_stylebox("panel","TooltipPanel",box(Color("152e3c"),Color("8caaa9"),8,4,12))
 result.set_font("font","TooltipLabel",BODY)
 result.set_font_size("font_size","TooltipLabel",18)
 result.set_color("font_color","TooltipLabel",CREAM)
 result.set_stylebox("normal","LineEdit",box(Color("152c3b"),Color("71929e"),7,3,12))
 result.set_stylebox("focus","LineEdit",box(Color("1d3542"),GOLD,7,3,12))
 result.set_font("font","LineEdit",DISPLAY)
 result.set_font_size("font_size","LineEdit",36)
 result.set_color("font_color","LineEdit",CREAM)
 result.set_stylebox("normal","TextEdit",box(Color("152c3b"),Color("71929e"),7,3,12))
 for control_type in ["VScrollBar","HScrollBar"]:
  result.set_stylebox("scroll",control_type,box(Color("172732"),Color("324a56"),0,0,0))
  result.set_stylebox("grabber",control_type,box(Color("547985"),Color("9bb6b7"),0,0,0))
  result.set_stylebox("grabber_highlight",control_type,box(Color("6b96a1"),GOLD,0,0,0))
  result.set_stylebox("grabber_pressed",control_type,box(Color("91b9b2"),GOLD,0,0,0))
 return result

static func sprite(symbol: String) -> Texture2D:
 if ResourceLoader.exists("res://assets/plates/"+symbol+".png"):
  return load("res://assets/plates/"+symbol+".png") as Texture2D
 return load("res://assets/pixel/"+symbol+".png") as Texture2D

static func pixel_font_size(requested: int) -> int:
 return 36 if requested<=36 else int(ceilf(requested/18.0))*18

static func precise(value) -> String:
 var n = Num.of(value)
 if n.e>=5: return n.fmt()
 var amount: float = snappedf(n.to_float(),.001)
 return str(int(amount)) if amount==floorf(amount) else str(amount)

static func item_tooltip(title_text: String, description: String, rarity: String, live: String = "", _native_popup: bool = false) -> PanelContainer:
 var result: PanelContainer = panel(Color("e9e3cf"),Color("fbf4de"),12)
 result.name="ItemTooltip"
 result.custom_minimum_size.x=288
 var body: VBoxContainer = column(8)
 result.add_child(body)
 var title_label: Label = label(title_text,36,Color("22343c"),true,true)
 title_label.custom_minimum_size.x=264
 body.add_child(title_label)
 var desc := RichTextLabel.new()
 desc.bbcode_enabled=true
 desc.fit_content=true
 desc.scroll_active=false
 desc.mouse_filter=Control.MOUSE_FILTER_IGNORE
 desc.custom_minimum_size.x=264
 desc.add_theme_font_override("normal_font",BODY)
 desc.add_theme_font_size_override("normal_font_size",27)
 desc.add_theme_color_override("default_color",Color("38464b"))
 desc.add_theme_constant_override("line_separation",2)
 var regex := RegEx.new()
 regex.compile("([×+^][0-9][0-9.,]*|\\$[0-9]+|[0-9]+%)")
 desc.text=regex.sub(readable(description),"[color=#a23c42]$1[/color]",true)
 body.add_child(desc)
 if not live.is_empty():
  var state: PanelContainer = panel(Color("243a43"),Color("49666b"),7)
  var text: Label = label(live,32,GOLD,false,true)
  text.custom_minimum_size.x=250
  text.add_theme_font_size_override("font_size",27)
  state.add_child(text)
  body.add_child(state)
 var badge: Label = label(rarity,32,Color("376a85") if rarity=="Common" else Color("467653") if rarity=="Uncommon" else Color("946c20") if rarity=="Legendary" else Color("795088") if rarity=="Fracture" else Color("986047"),true)
 badge.add_theme_font_size_override("font_size",27)
 body.add_child(badge)
 return result

static func fit(label_node: Label, largest: int, smallest: int = 12) -> void:
 var font: Font = label_node.get_theme_font("font")
 var font_size: int = pixel_font_size(largest)
 while font_size>maxi(36,smallest) and font.get_string_size(label_node.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>label_node.size.x: font_size-=18
 label_node.add_theme_font_size_override("font_size",pixel_font_size(font_size))

## Numeric displays keep six significant digits where space permits. Hover
## always exposes ten; narrow sidebars use five or four before reducing size.
static func paint_number(label_node: Label, value, prefix: String = "", largest: int = 64) -> void:
 var number = Num.of(value)
 var available: float = float(label_node.get_meta("numeric_width",label_node.size.x))
 label_node.set_meta("numeric_width",available)
 label_node.clip_text=true
 label_node.size.x=available
 var font: Font = label_node.get_theme_font("font")
 for digits in [6,5,4]:
  var text: String = prefix+number.fmt(digits)
  for font_size in [pixel_font_size(largest),54,36,27]:
   if font_size>pixel_font_size(largest): continue
   if font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=label_node.size.x:
    label_node.add_theme_font_size_override("font_size",font_size)
    label_node.text=text
    label_node.tooltip_text=prefix+number.fmt(10)+"\n"+number.explain(8)
    label_node.mouse_filter=Control.MOUSE_FILTER_PASS
    return
 label_node.text=prefix+number.fmt(4)
 fit_number(label_node,largest)
 label_node.tooltip_text=prefix+number.fmt(10)+"\n"+number.explain(8)
 label_node.mouse_filter=Control.MOUSE_FILTER_PASS

static func fit_number(label_node: Label, largest: int = 64) -> void:
 var font: Font = label_node.get_theme_font("font")
 for font_size in [pixel_font_size(largest),54,36,27,18]:
  if font_size>pixel_font_size(largest): continue
  label_node.add_theme_font_size_override("font_size",font_size)
  if font.get_string_size(label_node.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=label_node.size.x: return

static func summary(text: String, width: float, font_size: int, max_lines: int = 3) -> String:
 var lines: Array[String] = []
 var line := ""
 for word in text.split(" "):
  var next: String = word if line.is_empty() else line+" "+word
  if BODY.get_string_size(next,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=width:
   line=next
  else:
   lines.append(line)
   line=word
   if lines.size()==max_lines:
    var last: String = lines[-1]
    while not last.is_empty() and BODY.get_string_size(last+"...",HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>width: last=last.left(last.length()-1).strip_edges()
    lines[-1]=last+"..."
    return "\n".join(lines)
 if not line.is_empty(): lines.append(line)
 return "\n".join(lines)

static func pixel_rect(canvas: CanvasItem, rect: Rect2, fill: Color, light: Color, unit: float = 2.0, radius: int = 10) -> void:
 var r := Rect2(rect.position.snapped(Vector2(unit,unit)),rect.size.snapped(Vector2(unit,unit)))
 var shadow: StyleBoxFlat = box(Color("0b1721"),Color("0b1721"),radius,0,0)
 canvas.draw_style_box(shadow,Rect2(r.position+Vector2(0,unit*2),r.size))
 var body: StyleBoxFlat = box(fill,light,radius,0,0)
 body.set_border_width_all(int(unit))
 body.border_width_bottom=int(unit*2)
 canvas.draw_style_box(body,r)
 # Highlights stop before the curve instead of drawing square corners over it.
 canvas.draw_line(r.position+Vector2(radius,unit),r.position+Vector2(r.size.x-radius,unit),light.lightened(.1),unit)


static func readable(text: String, arrows: bool = true) -> String:
 var result: String = text.replace("’","'").replace("…","...").replace("·","/").replace("−","-")
 return result.replace("→",">") if arrows else result

extends RefCounted
const DISPLAY: Font = preload("res://assets/fonts/pixel.fnt")
const BODY: Font = DISPLAY
const BOLD: Font = DISPLAY
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
 style.set_corner_radius_all(0)
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
 result.text=text
 result.add_theme_font_override("font",DISPLAY if display else BODY)
 result.add_theme_font_size_override("font_size",font_size)
 result.add_theme_color_override("font_color",color)
 result.mouse_filter=Control.MOUSE_FILTER_IGNORE
 result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
 return result

static func panel(bg: Color = PANEL, edge: Color = Color("526571"), padding: int = 12) -> PanelContainer:
 var result := PanelContainer.new()
 result.mouse_filter=Control.MOUSE_FILTER_IGNORE
 result.add_theme_stylebox_override("panel",box(bg,edge,10,5,padding))
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
 if ResourceLoader.exists(path): result.texture=load(path)
 result.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 # Illustrations carry their own palette. Only monochrome interface icons are tinted.
 if symbol.begins_with("ui_") and symbol!="ui_heart": result.modulate=tint
 result.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 result.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 result.mouse_filter=Control.MOUSE_FILTER_IGNORE
 return result

static func colors(id: String) -> Array:
 var pair: Array = Visuals.CARDS.get(id,{}).get("colors",["#46799e","#fff3ce"])
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
 result.default_font_size=16
 result.set_constant("outline_size","Label",0)
 result.set_color("font_shadow_color","Label",Color("101f2b"))
 result.set_constant("shadow_offset_y","Label",1)
 result.set_constant("shadow_offset_x","Label",0)
 result.set_stylebox("panel","TooltipPanel",box(Color("152e3c"),Color("8caaa9"),8,4,12))
 result.set_font("font","TooltipLabel",BODY)
 result.set_font_size("font_size","TooltipLabel",18)
 result.set_color("font_color","TooltipLabel",CREAM)
 result.set_stylebox("normal","LineEdit",box(Color("152c3b"),Color("71929e"),7,3,12))
 result.set_stylebox("focus","LineEdit",box(Color("1d3542"),GOLD,7,3,12))
 result.set_font("font","LineEdit",DISPLAY)
 result.set_font_size("font_size","LineEdit",22)
 result.set_color("font_color","LineEdit",CREAM)
 result.set_stylebox("normal","TextEdit",box(Color("152c3b"),Color("71929e"),7,3,12))
 for control_type in ["VScrollBar","HScrollBar"]:
  result.set_stylebox("scroll",control_type,box(Color("172732"),Color("324a56"),0,0,0))
  result.set_stylebox("grabber",control_type,box(Color("547985"),Color("9bb6b7"),0,0,0))
  result.set_stylebox("grabber_highlight",control_type,box(Color("6b96a1"),GOLD,0,0,0))
  result.set_stylebox("grabber_pressed",control_type,box(Color("91b9b2"),GOLD,0,0,0))
 return result

static func sprite(symbol: String) -> Texture2D:
 return load("res://assets/pixel/"+symbol+".png") as Texture2D

static func fit(label_node: Label, largest: int, smallest: int = 12) -> void:
 var font: Font = label_node.get_theme_font("font")
 var font_size: int = largest
 while font_size>smallest and font.get_string_size(label_node.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>label_node.size.x: font_size-=2
 label_node.add_theme_font_size_override("font_size",font_size)

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

static func pixel_rect(canvas: CanvasItem, rect: Rect2, fill: Color, light: Color, unit: float = 2.0) -> void:
 var r := Rect2(rect.position.snapped(Vector2(unit,unit)),rect.size.snapped(Vector2(unit,unit)))
 canvas.draw_rect(Rect2(r.position+Vector2(0,unit*2),r.size),Color("0b1721"))
 canvas.draw_rect(r,Color("172833"))
 canvas.draw_rect(r.grow(-unit),fill)
 canvas.draw_rect(Rect2(r.position+Vector2(unit,unit),Vector2(r.size.x-unit*2,unit)),light)
 canvas.draw_rect(Rect2(r.position+Vector2(unit,unit),Vector2(unit,r.size.y-unit*2)),light.darkened(.15))
 canvas.draw_rect(Rect2(r.position+Vector2(unit,r.size.y-unit*2),Vector2(r.size.x-unit*2,unit)),fill.darkened(.32))

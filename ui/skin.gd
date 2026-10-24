extends RefCounted
const DISPLAY: Font = preload("res://assets/fonts/display.ttf")
const BODY: Font = preload("res://assets/fonts/body.ttf")
const BOLD: Font = preload("res://assets/fonts/body_bold.ttf")
const Visuals = preload("res://ui/visual_catalog.gd")
const Num = preload("res://scripts/num.gd")
const CREAM = Color("fff3ce")
const TEXT = Color("f4f4e9")
const MUTED = Color("afc2c8")
const GOLD = Color("f0bd51")
const GREEN = Color("67b38d")
const RED = Color("e86d53")
const BLUE = Color("54b3d8")
const PANEL = Color("253440")
const TILE_COLORS = [["f4e8c6","283948"],["ecc36c","353c3d"],["e89b51","293541"],["d76c47","fff2cf"],["b8506b","fff3d8"],["8761a1","fff3d5"],["527bac","fff1d3"],["3f9299","fff1ca"],["95b864","273e39"],["e3ad3a","30392f"],["f1cd67","313a35"]]

static func box(bg: Color, edge: Color = Color("526571"), radius: int = 9, depth: int = 4, padding: int = 12) -> StyleBoxFlat:
 var style := StyleBoxFlat.new()
 style.bg_color=bg
 style.border_color=edge
 style.set_border_width_all(2)
 style.set_corner_radius_all(radius)
 style.shadow_color=Color("091e2ac9")
 style.shadow_size=1
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
 var path: String = "res://assets/art/"+symbol+".svg"
 if ResourceLoader.exists(path): result.texture=load(path)
 result.modulate=tint
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
 result.set_stylebox("panel","TooltipPanel",box(Color("152e3c"),Color("8caaa9"),8,4,12))
 result.set_font("font","TooltipLabel",BODY)
 result.set_font_size("font_size","TooltipLabel",14)
 result.set_color("font_color","TooltipLabel",CREAM)
 result.set_stylebox("normal","LineEdit",box(Color("152c3b"),Color("71929e"),7,3,12))
 result.set_stylebox("focus","LineEdit",box(Color("1d3542"),GOLD,7,3,12))
 result.set_font("font","LineEdit",DISPLAY)
 result.set_font_size("font_size","LineEdit",22)
 result.set_color("font_color","LineEdit",CREAM)
 result.set_stylebox("normal","TextEdit",box(Color("152c3b"),Color("71929e"),7,3,12))
 return result

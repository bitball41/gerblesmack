extends "res://ui/juice_button.gd"
var selected := false
func _ready() -> void:
 super._ready()
 mouse_entered.connect(_preview)
 focus_entered.connect(_preview)
 mouse_exited.connect(_hide_preview)
 focus_exited.connect(_hide_preview)
func _preview() -> void:
 var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
 if host: host._show_item_preview(str(get_meta("item_id","")),"One offer per floor",self)
func _hide_preview() -> void:
 var host: Node = get_tree().get_first_node_in_group("card_inspection_host")
 if host: host._hide_item_preview(self)

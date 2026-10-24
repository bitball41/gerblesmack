extends "res://ui/juice_button.gd"
const Cat = preload("res://scripts/catalog.gd")
func _make_custom_tooltip(_for_text: String) -> Object:
 var data: Dictionary = Cat.data_for(str(get_meta("item_id","")))
 return UIStyle.item_tooltip(data.get("name","Upgrade"),data.get("desc",""),"Upgrade","ONE OFFER PER FLOOR",true)

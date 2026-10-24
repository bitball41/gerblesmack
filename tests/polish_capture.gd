extends "res://scripts/main.gd"
func _ready() -> void:
 super._ready()
 await get_tree().process_frame
 g.persist_enabled=false
 var scene: String = "shop"
 if OS.has_feature("web"): scene=str(JavaScriptBridge.eval("new URLSearchParams(location.search).get('qa') || 'shop'"))
 if scene=="home": return
 start_run("black","POLISH")
 effects.clear_transients()
 g.relics=[{"id":"carbon","growth":Num.new(1),"charge":0,"carry":0},{"id":"monolith","growth":Num.new(2.75),"charge":0,"carry":0},{"id":"compound","growth":Num.new(1.953),"charge":0,"carry":0}]
 g.inventory=["mercy","venus"]
 g.money=Num.new(29)
 run_view.wallet.reset(g.money)
 _refresh_run()
 if scene=="play": return
 g.finish_gate(true)
 g.open_shop()
 g.shop_offers=["echo","battery","prism","mercury"]
 g.shop_upgrade="moves1"
 g.floor_upgrade="moves1"
 g.money=Num.new(29)
 _refresh_run(false)
 _show_shop()
 if scene=="selected": _inspect_item("relic",1)
 if scene=="selector": _show_new_run()

func _process(_delta: float) -> void:
 if not OS.has_feature("web"): return
 var report: Dictionary = {"phase":g.phase,"money":g.money.fmt(),"relics":g.relics.map(func(r): return r.id),"inventory":g.inventory,"overlay":overlay.view_id,"context":is_instance_valid(context_panel),"pack":g.pack_choices,"upgrade":g.shop_upgrade,"gate":g.gate,"floor":g.floor_num}
 if is_instance_valid(shop_view) and shop_view.is_inside_tree(): report.selected_offer=shop_view.selected_offer
 if is_instance_valid(context_panel):
  var sell: Array = context_panel.find_children("SellSelected","Button",true,false)
  if not sell.is_empty():
   var bounds: Rect2 = sell[0].get_global_rect()
   report.sell_rect=[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]
 JavaScriptBridge.eval("window.gatefoldQA="+JSON.stringify(report))

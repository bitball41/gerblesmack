extends "res://scripts/main.gd"
var qa_last_action := ""
func _ready() -> void:
 super._ready()
 run_view.action_requested.connect(func(action: String): qa_last_action=action)
 await get_tree().process_frame
 g.persist_enabled=false
 var scene: String = "shop"
 if OS.has_feature("web"): scene=str(JavaScriptBridge.eval("new URLSearchParams(location.search).get('qa') || 'shop'"))
 if scene=="home": return
 start_run("black","POLISH")
 if scene=="gates": return
 _begin_gate()
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
 if scene in ["selector","selector2","selector_robot"]:
  _show_new_run()
  if scene=="selector2": run_selector._set_page(1); run_selector._select("archivist",false)
  if scene=="selector_robot": run_selector._select("robot",false)
 if scene=="board": _show_board()

func _process(_delta: float) -> void:
 super._process(_delta)
 if not OS.has_feature("web"): return
 var report: Dictionary = {"board_id":g.board_id,"run_seed":g.seed_text,"phase":g.phase,"money":g.money.fmt(),"relics":g.relics.map(func(r): return r.id),"inventory":g.inventory,"overlay":overlay.view_id,"context":is_instance_valid(context_panel),"pack":g.pack_choices,"upgrade":g.shop_upgrade,"gate":g.gate,"floor":g.floor_num}
 var hovered: Control = get_viewport().gui_get_hovered_control()
 report.hovered=str(hovered.get_path()) if hovered else ""
 report.hover_rect=_bounds(hovered) if hovered else []
 report.run_rect=_bounds(run_view)
 report.last_action=qa_last_action
 report.board_visible=run_view.board_button.is_visible_in_tree()
 report.board_disabled=run_view.board_button.disabled
 report.shade_rect=_bounds(overlay.get_child(0)) if overlay.visible else []
 report.panel_rect=_bounds(overlay.panel) if overlay.visible else []
 report.board_button_rect=_bounds(run_view.board_button)
 if is_instance_valid(run_selector) and run_selector.is_inside_tree():
  report.selected_board=run_selector.chosen_board
  report.page=run_selector.page
  report.seed=run_selector.seed_field.text
 if is_instance_valid(shop_view) and shop_view.is_inside_tree(): report.selected_offer=shop_view.selected_offer
 if is_instance_valid(context_panel):
  report.dock_rect=_bounds(context_panel)
  report.dock_buttons=[]
  for button in context_panel.find_children("*","Button",true,false): report.dock_buttons.append({"text":button.text,"rect":_bounds(button),"disabled":button.disabled})
 if overlay.view_id=="pack":
  report.pack_buttons=[]
  for button in overlay.find_children("*","Button",true,false):
   if button.text=="TAKE": report.pack_buttons.append({"rect":_bounds(button),"disabled":button.disabled})
 if is_instance_valid(context_panel):
  var sell: Array = context_panel.find_children("SellSelected","Button",true,false)
  if not sell.is_empty():
   var bounds: Rect2 = sell[0].get_global_rect()
   report.sell_rect=[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]
 JavaScriptBridge.eval("window.gatefoldQA="+JSON.stringify(report))

func _bounds(control: Control) -> Array:
 var bounds: Rect2 = control.get_global_rect()
 return [bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]

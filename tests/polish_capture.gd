extends "res://scripts/main.gd"
var qa_last_action := ""
var qa_scene := ""
func _ready() -> void:
 super._ready()
 run_view.action_requested.connect(func(action: String): qa_last_action=action)
 await get_tree().process_frame
 g.persist_enabled=false
 var scene: String = "shop"
 if OS.has_feature("web"): scene=str(JavaScriptBridge.eval("new URLSearchParams(location.search).get('qa') || 'shop'"))
 qa_scene=scene
 if scene=="home": return
 var board_id: String = "nomad" if scene=="fracture_nomad" else "labyrinth" if scene=="fracture_blocked" else "blue" if scene.begins_with("clarity") or scene.begins_with("scoring") else "classic" if scene.begins_with("fracture") else "black"
 start_run(board_id,"POLISH","cursed" if scene.begins_with("fracture") and scene!="fracture_nomad" else "normal")
 if scene=="fracture_nomad": return
 if scene=="gates": return
 _begin_gate()
 effects.clear_transients()
 if scene.begins_with("fracture"):
  _fracture_fixture(scene)
  return
 if scene.begins_with("scoring"):
  _scoring_fixture(scene)
  return
 g.relics=[{"id":"carbon","growth":Num.new(1),"charge":0,"carry":0},{"id":"monolith","growth":Num.new(2.75),"charge":0,"carry":0},{"id":"compound","growth":Num.new(1.953),"charge":0,"carry":0}]
 if scene.begins_with("clarity"):
  g.relics=[{"id":"carbon","growth":Num.new(1),"charge":0,"carry":0},{"id":"echo","growth":Num.new(1),"charge":0,"carry":0}]
  if scene=="clarity_full":
   for id in ["odd","avalanche"]: g.relics.append({"id":id,"growth":Num.new(1),"charge":0,"carry":0})
 g.inventory=["mercy","venus"]
 g.money=Num.new(29)
 run_view.wallet.reset(g.money)
 _refresh_run()
 if scene=="play": return
 g.finish_gate(true)
 g.open_shop()
 g.shop_offers=["corner","steelworks","feedback","mercury"] if scene.begins_with("clarity") else ["echo","battery","prism","mercury"]
 g.shop_upgrade="trade3" if scene=="clarity_full" else "moves1"
 g.floor_upgrade=g.shop_upgrade
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
 report.scenario=qa_scene
 report.state_hash=g.export_run().sha256_text()
 report.moving=moving
 report.scoring=scoring_sequence.active
 report.score=g.score.fmt()
 report.score_text=run_view._score_label.text
 report.receipt=run_view._receipt_points.text
 report.receipt_note=run_view._receipt_counts.text
 report.scoring_cursor=scoring_sequence.cursor
 report.scoring_count=g.last_score_steps.size()
 report.difficulty=g.f.difficulty
 report.curse=g.f.curse
 report.pack_remaining=g.f.pack_remaining
 report.pack_offers=g.f.pack_offers
 report.reserve=g.f.reserve.size()
 report.phantoms=g.f.phantoms.size()
 report.block=g.f.block
 report.cells=g.cells.map(func(t): return t.e if t!=null else 0)
 report.triggering=[]
 report.owned_cards=[]
 for index in range(run_view.relic_cards.size()):
  var card: Control = run_view.relic_cards[index]
  report.owned_cards.append({"id":card.item_id,"rect":_bounds(card),"index":index})
  if card.scoring_active: report.triggering.append(card.item_id)
 report.ui_buttons=[]
 for node in find_children("*","Button",true,false):
  if not node.is_visible_in_tree(): continue
  var center: Vector2 = node.get_global_rect().get_center()
  if not Rect2(Vector2.ZERO,size).has_point(center): continue
  var ancestor: Node = node.get_parent()
  var clipped := false
  while ancestor!=null:
   if ancestor is ScrollContainer and not ancestor.get_global_rect().has_point(center): clipped=true
   ancestor=ancestor.get_parent()
  if clipped: continue
  report.ui_buttons.append({"text":node.text,"name":node.name,"rect":_bounds(node),"disabled":node.disabled,"pack_slot":node.get_meta("pack_slot",-1)})
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

func _scoring_fixture(scene: String) -> void:
 auto_speed=8 if scene=="scoring_fast" else 1
 reduced_motion=false
 g.floor_num=1 if scene=="scoring_win" else 10
 g.moves=30
 g.cells.fill(null)
 g.cells[0]=g.tile(1,{},true); g.cells[1]=g.tile(1)
 g.cells[4]=g.tile(2); g.cells[5]=g.tile(2)
 g.relics=[]
 for id in ["carbon","echo","monolith","feedback","resonance"]: g._grant(id)
 g.relics[3].carry=3
 g.score=Num.new(20); g.total_score=Num.new(20)
 _refresh_run(); effects.clear_transients()

func _fracture_fixture(scene: String) -> void:
 if scene=="fracture_selector":
  _show_new_run(); run_selector._set_page(2); run_selector._select("rich_get_richer",false); run_selector._set_difficulty("cursed")
  return
 g.f.extra_slots=3
 g.relics=[]
 g._grant("carbon")
 g._grant("echo",{"edition":"oversaturated","cursed":true})
 g._grant("leech",{"edition":"unbound"})
 g._grant("crown_echoes")
 g.upgrades=["satchel1","satchel2","storefront1","storefront2","storefront3","fusion1","fusion2","fusion3","wagers1","wagers2","wagers3","shatterproof1"]
 g.inventory=["liberation","overexposure","genesis","venus"]
 g.money=Num.new(80);run_view.wallet.reset(g.money)
 g.cells.fill(null)
 for index in [0,1,4,5,8,9]: g.cells[index]=g.tile(2+index%3)
 g.next_tile=g.tile(1)
 if scene=="fracture_blocked":
  g.f.block=6
  _refresh_run();return
 g.gate=2
 g.finish_gate(true);g.open_shop()
 g.money=Num.new(80);run_view.wallet.reset(g.money)
 g.shop_offers=["ghostwriter","devourer","venus","liberation","mobius"]
 g.f.offer_tags={"ghostwriter":{"edition":"oversaturated"},"devourer":{"cursed":true}}
 g.shop_upgrade="shatterproof3";g.floor_upgrade="shatterproof3";g.floor_upgrade_bought=false
 g.f.floor_choices=["shatterproof3","wagers3"]
 g.f.pack_offers=[{"type":"fracture","size":"Mega","bought":false},{"type":"reliquary","size":"Jumbo","bought":false}]
 _refresh_run();_show_shop()
 if scene=="fracture_workshop": _show_workshop()
 if scene=="fracture_pack":
  g.pack_open(0)
  g.pack_choices=["liberation","erosion","genesis","sovereign","overexposure"]
  _show_pack()
 if scene=="fracture_target":
  g.inventory=["genesis","venus"]
  _refresh_run(false);_select_item(0)

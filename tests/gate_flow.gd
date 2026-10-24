extends SceneTree
const Game = preload("res://scripts/game.gd")
const Num = preload("res://scripts/num.gd")
const MAIN = preload("res://scenes/main.tscn")
var failures := 0
var assertions := 0
func _initialize() -> void:
 run.call_deferred()
func check(okay: bool, message: String) -> void:
 assertions+=1
 if not okay: failures+=1; printerr("FAIL: ",message)
func run() -> void:
 var game := Game.new()
 game.persist_enabled=false
 game.new_run("classic","GATES")
 game.queue_gate()
 var before: String = game.export_run()
 var rng_before: int = game.rng.state
 var previews: Array[Dictionary] = game.gate_previews()
 check(previews.size()==3 and previews[0].status=="Ready" and previews[1].status=="Upcoming","three gates identify the current route")
 check(previews[0].target==game.target().fmt() and previews[0].moves==game.moves,"active gate shows authoritative target and moves")
 check(previews[2].rule==game.guardian().desc,"guardian preview includes the actual floor rule")
 check(game.export_run()==before and game.rng.state==rng_before,"gate previews cannot change run state or RNG")
 check(not game.move("left") and game.export_run()==before,"waiting at the gates blocks moves")
 var loaded := Game.new()
 loaded.persist_enabled=false
 check(loaded.import_run(before) and loaded.phase=="gates","waiting gate state survives save import")
 check(loaded.begin_gate() and loaded.phase=="play" and not loaded.begin_gate(),"entry commits once")
 for index in range(3):
  loaded.finish_gate(true)
  loaded.open_shop()
  loaded.leave_shop()
  loaded.queue_gate()
  var active: Dictionary = loaded.gate_previews()[loaded.gate]
  check(active.target==loaded.target().fmt() and active.moves==loaded.moves,"preview stays accurate after gate %d" % index)
  if index<2:
   check(loaded.gate_previews()[index].status=="Cleared","completed gate remains marked cleared")
  else: check(loaded.floor_num==2 and loaded.gate==0,"new floor starts a fresh route")
  loaded.begin_gate()
 loaded.finish_gate(false)
 loaded.open_shop()
 var failed_gate: int = loaded.gate
 loaded.leave_shop()
 loaded.queue_gate()
 check(loaded.gate==failed_gate and not loaded.pending_outcome,"failure retries the same gate")
 loaded.upgrades.append("moves2")
 loaded.moves=loaded.budget()
 check(loaded.gate_previews()[loaded.gate].moves==loaded.moves,"move upgrade is reflected in the active preview")
 var ui: Control = MAIN.instantiate()
 root.add_child(ui)
 ui.g.persist_enabled=false
 ui.effects.sound_enabled=false
 ui.start_run("black","DOCK")
 await process_frame
 check(ui.g.phase=="gates" and ui.overlay.view_id=="gates" and not ui.run_view.board.visible,"new run waits on the gate selector")
 var buttons: Array = ui.gate_selector.enter_buttons
 check(not buttons[0].disabled and buttons[1].disabled and buttons[2].disabled,"only current gate can be entered")
 ui._show_settings()
 ui._close_overlay()
 check(ui.g.phase=="gates" and ui.overlay.view_id=="gates","Options returns to the gate selector without entering")
 ui._begin_gate()
 check(ui.g.phase=="play" and not ui.overlay.visible and ui.run_view.board.visible,"explicit entry reveals the board")
 var first: Control = ui.run_view.relic_cards[0]
 var second: Control = ui.run_view.relic_cards[1]
 ui._show_item_preview(first.item_id,first.live_note,first)
 check(first.tooltip_text.is_empty() and second.tooltip_text.is_empty(),"cards do not open native mouse-positioned tooltips")
 await process_frame
 await process_frame
 check(ui.context_panel.size.x<=300 and ui.context_panel.size.y<360,"hover details have a smaller footprint")
 var first_position: Vector2 = ui.context_panel.position
 check(first_position.x==first.get_global_rect().end.x+12,"details sit beside the inspected item")
 ui._show_item_preview(second.item_id,second.live_note,second)
 await process_frame
 await process_frame
 var second_position: Vector2 = ui.context_panel.position
 check(second_position.x==second.get_global_rect().end.x+12 and second_position.x>first_position.x,"details move with the item being inspected")
 second.position.x+=20
 await process_frame
 check(ui.context_panel.position.x==second_position.x+20,"details follow item movement")
 second.position.x-=20
 ui._show_item_preview(second.item_id,second.live_note,second)
 await process_frame
 await process_frame
 check(ui.context_panel.position==second_position,"recreating a preview on the same item preserves its anchor")
 ui._inspect_item("relic",1)
 await process_frame
 await process_frame
 check(ui.context_panel.position==second_position,"click details retain the item's anchor")
 ui._inspect_item("relic",1)
 check(ui.context_panel==null and not second.selected,"clicking a selected relic again closes details")
 ui.g.finish_gate(true)
 ui.g.open_shop()
 ui.g.money=Num.new(100)
 ui._refresh_run(false)
 ui._show_shop()
 await process_frame
 check(ui.run_view._sidebar_background.position==Vector2.ZERO and ui.run_view._sidebar_background.size.y==ui.size.y,"sidebar fills the left edge from top to bottom")
 check(ui.overlay.panel.position.y+ui.overlay.panel.size.y==ui.size.y,"shop reaches the bottom edge")
 check(ui.overlay.panel.get_global_rect().end.x+24<=ui.run_view.board_button.get_global_rect().position.x,"shop leaves a separate area for Board")
 check(ui.shop_view.get_global_rect().end.x<=ui.overlay.panel.get_global_rect().end.x and ui.shop_view.get_global_rect().end.y<=ui.overlay.panel.get_global_rect().end.y,"shop input area matches its visible frame")
 var shop_state: String = ui.g.export_run()
 ui._run_action("board")
 await process_frame
 var grids: Array = ui.overlay.find_children("CurrentBoardGrid","Control",true,false)
 check(ui.overlay.view_id=="board" and grids.size()==1,"Board opens the current grid")
 var preview_grid: Control = grids[0]
 check(preview_grid.decorative and preview_grid.cells==ui.g.cells,"board view displays a read-only copy of current tiles")
 for tile in preview_grid.cells:
  if tile!=null: tile.e+=10; break
 check(ui.g.export_run()==shop_state,"board preview cannot mutate tiles, money, offers or RNG")
 ui._close_overlay()
 check(ui.overlay.view_id=="shop" and ui.g.export_run()==shop_state,"closing Board restores the same shop")
 ui._open_shop_pack()
 var pack_state: String = ui.g.export_run()
 ui._show_board()
 ui._close_overlay()
 check(ui.overlay.view_id=="pack" and ui.g.export_run()==pack_state,"Board returns to a pending pack without another charge or reroll")
 ui.g.pack_choices=[]
 ui._show_shop()
 shop_state=ui.g.export_run()
 ui._show_new_run()
 var catalog_ids: Array[String] = []
 for page in range(2):
  ui.run_selector._set_page(page)
  check(ui.run_selector._page_label.text=="Page %d / 2" % (page+1),"board pages use plain numbered navigation")
  for option in ui.run_selector._thumbs.get_children(): catalog_ids.append(option.board_id)
 check(catalog_ids.size()==15 and catalog_ids==Game.Cat.BOARDS.map(func(board): return board.id),"both pages show every board once in catalog order")
 ui.run_selector._select("archivist",false)
 ui.run_selector.seed_field.text="PAGES"
 ui.run_selector.seed_field.text_changed.emit("PAGES")
 ui.run_selector._set_page(0)
 ui.run_selector._set_page(1)
 check(ui.run_selector.chosen_board=="archivist" and ui.run_selector.seed_field.text=="PAGES","page navigation retains selection and seed")
 check(ui.g.export_run()==shop_state,"browsing boards cannot alter the active run or its RNG")
 ui._close_overlay()
 ui.shop_view._select_offer(0)
 check(is_instance_valid(ui.context_panel) and ui.shop_view.offers[0].buy.visible,"clicking an offer reveals details and purchase")
 ui.shop_view._select_offer(0)
 check(ui.context_panel==null and not ui.shop_view.offers[0].buy.visible,"clicking a selected offer again closes details and purchase")
 ui._leave_shop()
 check(ui.g.phase=="gates" and ui.g.gate==1 and ui.overlay.view_id=="gates","Next round stops at the next gate")
 check(ui.gate_selector.enter_buttons[0].disabled and not ui.gate_selector.enter_buttons[1].disabled,"route progresses to the second gate")
 check(ui.scale==Vector2.ONE and ui.run_view._gate_name.get_theme_font_size("font_size")>=32,"reading text avoids the old two-thirds shrink")
 ui.queue_free()
 await process_frame
 await process_frame
 print("Gate flow and item detail checks: ",assertions,"; failures: ",failures)
 quit(0 if failures==0 else 1)

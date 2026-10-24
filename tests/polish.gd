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
 game.new_run("classic","FLOOR-TICKET")
 game.finish_gate(true)
 game.open_shop()
 var offer: String = game.shop_upgrade
 check(not offer.is_empty(),"floor begins with an upgrade offer")
 game.leave_shop()
 game.finish_gate(true)
 game.open_shop()
 check(game.shop_upgrade==offer,"unbought upgrade persists into the second shop")
 game.reroll()
 check(game.shop_upgrade==offer,"reroll does not replace the floor upgrade")
 game.money=Num.new(100)
 check(game.buy_item(offer),"floor upgrade can be redeemed")
 var saved: String = game.export_run()
 var restored := Game.new()
 restored.persist_enabled=false
 check(restored.import_run(saved),"floor ticket state survives save import")
 restored.leave_shop()
 restored.finish_gate(true)
 restored.open_shop()
 check(restored.shop_upgrade.is_empty(),"redeemed upgrade stays sold through the rest of the floor")
 restored.leave_shop()
 restored.finish_gate(true)
 restored.open_shop()
 check(restored.floor_num==2 and not restored.shop_upgrade.is_empty(),"next floor receives a fresh upgrade")
 game.new_run("classic","RESET")
 check(game.floor_upgrade_floor==0 and not game.floor_upgrade_bought,"new run clears previous floor ticket state")
 var malformed: Dictionary = restored.snapshot()
 malformed.floor_upgrade="not-an-upgrade"
 check(not game.restore(malformed),"invalid saved floor upgrade is rejected")
 var ui: Control = MAIN.instantiate()
 root.add_child(ui)
 ui.g.persist_enabled=false
 ui.effects.sound_enabled=false
 ui.start_run("black","TOOLTIPS")
 ui._begin_gate()
 await process_frame
 ui.g.relics[1].growth=Num.new(2.75)
 ui._refresh_run(false)
 var monolith: Control = ui.run_view.relic_cards[1]
 check(monolith.live_note.contains("2.75"),"live multiplier retains decimals instead of rounding to an integer")
 ui.g.relics[1].growth=Num.new(1.25,400)
 ui._refresh_run(false)
 check(monolith.live_note.contains("1.25e400"),"tooltip handles multipliers beyond float range")
 ui.g.finish_gate(true)
 ui.g.open_shop()
 ui._refresh_run(false)
 ui._show_shop()
 await process_frame
 var shop: int = ui.shop_view.get_instance_id()
 check(ui.context_panel==null,"sell actions are absent before selection")
 ui._inspect_item("relic",1)
 await process_frame
 check(is_instance_valid(ui.context_panel),"clicking a relic opens its contextual actions")
 check(ui.context_panel.find_children("SellSelected","Button",true,false).size()==1,"only the selected relic has a sell action")
 check(ui.overlay.view_id=="shop" and ui.shop_view.get_instance_id()==shop,"selection preserves the shop")
 ui._clear_context()
 check(ui.context_panel==null,"dismissing selection removes its actions")
 for slot in ui.shop_view.offers:
  if is_instance_valid(slot.buy):check(not slot.buy.visible,"buy actions are hidden until an offer is selected")
 ui.shop_view._select_offer(0)
 check(ui.shop_view.offers[0].buy.visible,"selecting an offer reveals its buy action")
 ui._run_action("menu")
 check(ui.overlay.view_id=="settings","Options opens options directly")
 ui._close_overlay()
 check(ui.overlay.view_id=="shop","closing Options returns to the active shop")
 ui.queue_free()
 await process_frame
 await process_frame
 print("Polish checks: ",assertions,"; failures: ",failures)
 quit(0 if failures==0 else 1)

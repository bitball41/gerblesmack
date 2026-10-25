extends SceneTree
const MAIN = preload("res://scenes/main.tscn")
const Cat = preload("res://scripts/catalog.gd")
const Num = preload("res://scripts/num.gd")
var assertions := 0
var failures := 0
var ui: Control
func _initialize() -> void: run.call_deferred()
func check(okay: bool, label: String) -> void:
 assertions+=1
 if not okay: failures+=1;printerr("FAIL: ",label)
func button(root_node: Node, text: String) -> Button:
 for node in root_node.find_children("*","Button",true,false):
  if node.text==text:return node
 return null
func shop() -> void:
 ui.start_run("classic","FRACTURE-UI","normal")
 ui._begin_gate()
 ui.g.finish_gate(true)
 ui.g.open_shop()
 ui.g.money=Num.new(200)
 ui._refresh_run(false)
 ui._show_shop()
func run() -> void:
 ui=MAIN.instantiate();root.add_child(ui)
 ui.g.persist_enabled=false;ui.effects.sound_enabled=false;ui.reduced_motion=false;ui.auto_speed=1
 ui.start_run("nomad","COMPANION","normal")
 await process_frame
 check(ui.overlay.view_id=="choice" and ui.g.phase=="gates","Nomad opens a real companion choice")
 var before: String=ui.g.export_run()
 var take: Button=button(ui.overlay,"Take")
 check(take!=null,"Nomad choice has usable Take control")
 take.pressed.emit()
 await process_frame
 check(ui.g.relics.size()==2 and ui.g.f.nomad_choices.is_empty() and ui.overlay.view_id=="gates","taking a companion returns to the actual gate selector")
 ui._show_new_run()
 ui.run_selector._set_page(2)
 ui.run_selector._select("rich_get_richer",false)
 ui.run_selector._set_difficulty("cursed")
 ui.run_selector.seed_field.text="THIRD-PAGE"
 ui.run_selector.seed_field.text_changed.emit("THIRD-PAGE")
 ui.run_selector._set_page(0);ui.run_selector._set_page(2)
 check(ui.run_selector.chosen_board=="rich_get_richer" and ui.run_selector.difficulty=="cursed" and ui.run_selector.seed_field.text=="THIRD-PAGE","paging retains new board, difficulty, and seed")
 var start: Button=button(ui.overlay,"Start run")
 start.pressed.emit()
 check(ui.g.board_id=="rich_get_richer" and ui.g.f.difficulty=="cursed" and ui.g.seed_text=="THIRD-PAGE","selector starts the chosen Cursed board")
 shop()
 ui.g.upgrades=["storefront1","storefront2","storefront3","satchel1","satchel2","fusion1","fusion2","fusion3"]
 ui.g.shop_offers=["handbrake","devourer","mercy","venus","mobius"]
 ui.g.f.offer_tags={"handbrake":{"edition":"oversaturated","cursed":true}}
 ui.g.shop_upgrade="shatterproof1";ui.g.floor_upgrade="shatterproof1";ui.g.f.floor_choices=["shatterproof1","wagers1"]
 ui.g.f.pack_offers=[{"type":"fracture","size":"Mega","bought":false},{"type":"reliquary","size":"Jumbo","bought":false}]
 ui._refresh_run(false);ui._show_shop()
 await process_frame
 check(ui.shop_view._sources.has("pack0") and ui.shop_view._sources.has("pack1"),"two actual pack controls appear in the shop")
 check(ui.shop_view.offers[0].card.item_state.get("edition","")=="oversaturated","offer displays its real edition metadata")
 ui.shop_view._more.pressed.emit()
 check(ui.shop_view.offers[0].id=="mobius","Storefront extra offer is reachable without shrinking cards")
 ui.shop_view._more.pressed.emit()
 check(ui.shop_view.offers[0].id=="handbrake","offer paging returns to original page")
 ui.shop_view._select_offer(0)
 var lock: Button=button(ui.context_panel,"Lock offer")
 check(lock!=null,"Storefront II exposes contextual locking")
 lock.pressed.emit()
 var locked_id: String=ui.g.f.locked_offer
 ui._reroll_shop()
 check(locked_id=="handbrake" and ui.g.shop_offers.has("handbrake"),"locking survives a paid reroll")
 ui._inspect_upgrade(ui.g.shop_upgrade,ui.shop_view._sources[ui.g.shop_upgrade])
 var other: Button=button(ui.context_panel,"Other upgrade")
 check(other!=null,"Storefront III exposes the floor upgrade choice")
 other.pressed.emit()
 var select: Button=button(ui.overlay,"Select")
 select.pressed.emit()
 check(ui.g.f.floor_choices.has(ui.g.shop_upgrade) and not ui.g.floor_upgrade_bought,"choosing the voucher does not buy or reroll it")
 ui._clear_context();ui._show_shop()
 ui._open_shop_pack(0)
 await process_frame
 check(ui.overlay.view_id=="pack" and ui.g.pack_choices.size()==5 and ui.g.f.pack_remaining==2,"Mega Fracture opens five choices and two picks")
 var first: String=ui.g.pack_choices[0]
 ui._pick_pack(first)
 await process_frame
 check(ui.overlay.view_id=="pack" and ui.g.pack_choices.size()==4 and ui.g.f.pack_remaining==1,"first Mega pick keeps the pack open")
 var pending: String=ui.g.export_run()
 ui._show_board();ui._close_overlay()
 check(ui.overlay.view_id=="pack" and ui.g.export_run()==pending,"Board preview returns to an unchanged pending Mega pack")
 ui._pick_pack(ui.g.pack_choices[0])
 check(ui.overlay.view_id=="shop" and ui.g.pack_choices.is_empty(),"second Mega pick returns to shop")
 ui.g.inventory=["liberation","venus"]
 ui.g.f.item_tags={}
 ui._refresh_run(false)
 ui._select_item(0)
 await process_frame
 check(ui.overlay.view_id=="choice","targeted Fracture opens a relic picker")
 var transform: Button=button(ui.overlay,"Transform")
 transform.pressed.emit()
 check(ui.g.relics[0].get("edition","")=="unbound" and ui.g.inventory==["venus"] and ui.overlay.view_id=="shop","relic transformation commits and consumes exactly its source card")
 ui.g.cells.fill(null);ui.g.cells[0]=ui.g.tile(2);ui.g.cells[1]=ui.g.tile(3);ui.g.cells[4]=ui.g.tile(4)
 ui.g.inventory=["genesis"]
 ui._refresh_run(false);ui._select_item(0)
 await process_frame
 var targets: Array=ui.overlay.find_children("TargetBoard","Control",true,false)
 check(targets.size()==1 and targets[0].targeting and targets[0].allowed_targets.has(0),"tile Fracture uses an interactive highlighted board")
 targets[0].cell_selected.emit(0)
 check(ui.g.inventory.is_empty() and ui.g.filled()==2 and ui.overlay.view_id=="shop","tile target commits the Fracture without entering the gate")
 ui.g.inventory=["venus","mars"]
 ui._refresh_run(false)
 ui._inspect_item("inventory",0)
 var store: Button=button(ui.context_panel,"Store in reserve")
 check(store!=null,"pocket context exposes reserve storage")
 store.pressed.emit()
 check(ui.g.f.reserve.size()==1 and ui.g.inventory.size()==1,"reserve action preserves a real card")
 ui._show_workshop()
 await process_frame
 var reserve_button: Button=button(ui.overlay,"Open reserve")
 reserve_button.pressed.emit()
 button(ui.overlay,"Retrieve").pressed.emit()
 check(ui.g.f.reserve.is_empty() and ui.g.inventory.size()==2,"reserve retrieval is connected to the model")
 ui.g.f.phantoms=[{"id":"venus","tags":{}}]
 ui._refresh_run(false);ui.overlay.close()
 ui._inspect_item("phantom",0)
 check(button(ui.context_panel,"Use")!=null and button(ui.context_panel,"SellSelected")==null,"phantom has Use without a sale loophole")
 var previous_level: int=ui.g.rune_levels.gold
 button(ui.context_panel,"Use").pressed.emit()
 check(ui.g.f.phantoms.is_empty() and ui.g.rune_levels.gold==previous_level+1,"phantom UI consumes the phantom, not an owned card")
 ui._run_action("upgrades")
 await process_frame
 check(ui.overlay.view_id=="choice" and button(ui.overlay,"Details")!=null,"upgrade artwork opens a readable owned-upgrade gallery")
 ui._close_overlay()
 ui.g.f.extra_slots=12
 for id in ["devourer","monolith","feedback","perpetuum","paradox","conductor","mobius"]: ui.g._grant(id)
 ui._refresh_run(false)
 await process_frame
 var visible_cards: Array=ui.run_view.relic_cards.filter(func(card): return card.visible)
 check(visible_cards.size()==5 and ui.run_view._relic_pager.visible,"large relic inventory uses five full-size cards per page")
 for index in range(1,visible_cards.size()):
  check(visible_cards[index-1].get_global_rect().end.x<visible_cards[index].get_global_rect().position.x,"full relic slots stay separated")
 ui.run_view._relic_pager.pressed.emit()
 check(not ui.run_view.relic_cards[0].visible and ui.run_view.relic_cards[5].visible,"relic inventory pager reaches later owned cards")
 ui.g.inventory=["venus","mars","mercy","hourglass","genesis"]
 ui.g.f.phantoms=[{"id":"venus","tags":{}},{"id":"mars","tags":{}},{"id":"mercy","tags":{}}]
 ui._refresh_run(false)
 check(ui.run_view.pocket_cards.filter(func(card): return card.visible).size()==6 and ui.run_view._pocket_pager.visible,"phantom overflow uses pocket pages")
 ui.run_view._pocket_pager.pressed.emit()
 check(ui.run_view.pocket_cards.filter(func(card): return card.visible).size()==2,"pocket pager exposes phantom cards without shrinking")
 ui.start_run("vortex","TURNING","normal");ui._begin_gate()
 ui.g.swipes=3;ui.g.floor_num=10;ui.g.cells.fill(null);ui.g.cells[0]=ui.g.tile(1);ui.g.cells[1]=ui.g.tile(1)
 ui._refresh_run()
 ui._request_move("left")
 await create_timer(.2).timeout
 check(ui.run_view.board.animating,"Vortex has a visible turn after the swipe")
 await create_timer(.35).timeout
 ui._settle_move()
 check(ui.run_view.board.cells==ui.g.cells and not ui.run_view.board.animating,"Vortex settles to authoritative cells without a stale callback")
 for pool in [Cat.RELICS,Cat.UPGRADES,Cat.FRACTURES]:
  for id in pool:
   var text: String=ui.UIStyle.readable(pool[id].name+" "+pool[id].desc)
   var okay:=true
   for char in text:
    if char!="\n" and not ui.UIStyle.BODY.has_char(char.unicode_at(0)):okay=false
   check(okay,"pixel font covers "+id)
 ui._go_home();ui.queue_free()
 await process_frame;await process_frame
 print("Fracture interface checks: ",assertions,"; failures: ",failures)
 quit(0 if failures==0 else 1)

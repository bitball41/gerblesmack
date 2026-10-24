extends SceneTree
const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const Game = preload("res://scripts/game.gd")
const Num = preload("res://scripts/num.gd")
var failures := 0
var assertions := 0
var ui: Control

func _initialize() -> void:
 call_deferred("run")

func check(okay: bool, label_text: String) -> void:
 assertions+=1
 if not okay:
  failures+=1
  printerr("FAIL: ",label_text)

func run() -> void:
 ui=MAIN_SCENE.instantiate()
 root.add_child(ui)
 # Inspect generated audio directly; the headless dummy mixer need not play voices.
 ui.effects.sound_enabled=false
 var chip: AudioStreamWAV = ui.effects._synthesize("buy",0)
 check(chip.mix_rate==22050 and chip.format==AudioStreamWAV.FORMAT_16_BITS,"purchase sound is valid uncompressed PCM")
 check(chip.data.size()>1000 and chip.data.count(0)<chip.data.size(),"purchase sound contains an audible waveform")
 chip=null
 ui.g.persist_enabled=false
 if ui.reduced_motion: ui._toggle_motion()
 await process_frame
 check(ui.home_active and ui.home.visible,"opens on composed title screen")
 check(ui.home.find_children("*","Button",true,false).size()>=6,"title artwork and menu built")
 var title: Label = ui.home.get_node("Title")
 check(title.get_theme_font("font").resource_path=="res://assets/fonts/pixel.fnt","native bitmap font throughout the game")
 check(title.size.x>=500,"title does not wrap into a column")
 for definition in Game.Cat.BOARDS:
  ui.start_run(definition.id,"UI-TEST")
  await process_frame
  check(ui.run_view.board.size.x==420,"board fits "+definition.id)
  check(ui.run_view.relic_cards.size()==ui.g.relics.size(),"illustrated rack "+definition.id)
  check(ui.run_view.pocket_cards.size()==ui.g.inventory.size(),"pocket view "+definition.id)
  for card in ui.run_view.relic_cards+ui.run_view.pocket_cards:
   check(card.title.position.y+card.title.size.y<=card.size.y+2,"card title stays inside artwork frame")
  ui.g.finish_gate(true)
  ui._refresh_run()
  ui._show_result()
  await process_frame
  check(ui.overlay.view_id=="result","reward overlay "+definition.id)
  ui.g.open_shop()
  ui._refresh_run(false)
  ui._show_shop()
  await process_frame
  check(ui.overlay.panel.position.y>=ui.run_view.rack.get_global_rect().end.y+35,"shop avoids owned rack "+definition.id)
  check(ui.overlay.panel.position.x+ui.overlay.panel.size.x<=1440,"shop fits width "+definition.id)
  ui.g.money=Num.new(100)
  ui.g.pack_open()
  ui._show_pack()
  await process_frame
  check(ui.overlay.view_id=="pack","illustrated pack "+definition.id)
  ui.overlay.close()
 ui.start_run("classic","INPUT")
 var rack_node: int = ui.run_view.rack.get_instance_id()
 var board_node: int = ui.run_view.board.get_instance_id()
 ui._request_move("left")
 ui._request_move("down")
 ui._request_move("right")
 await create_timer(.65).timeout
 check(ui.g.swipes==3,"input buffers through slide animation")
 check(not ui.moving,"animation releases movement lock")
 check(ui.run_view.rack.get_instance_id()==rack_node and ui.run_view.board.get_instance_id()==board_node,"movement keeps persistent interface nodes")
 for index in ui.run_view.board.tiles:
  var tile: Control = ui.run_view.board.tiles[index]
  check(tile.position.distance_to(ui.run_view.board._cell_position(index))<.1,"tile settles into its grid cell")
 ui.start_run("classic","TOUCH")
 var touch_down := InputEventScreenTouch.new()
 touch_down.pressed=true
 touch_down.position=Vector2(60,60)
 ui.run_view.board._gui_input(touch_down)
 var touch_up := InputEventScreenTouch.new()
 touch_up.pressed=false
 touch_up.position=Vector2(180,60)
 ui.run_view.board._gui_input(touch_up)
 await create_timer(.22).timeout
 check(ui.g.swipes==1,"touch swipe reaches the movement controller")
 ui.start_run("classic","CONTROLLER")
 var joy := InputEventJoypadButton.new()
 joy.button_index=JOY_BUTTON_DPAD_LEFT
 joy.pressed=true
 ui._input(joy)
 await create_timer(.22).timeout
 check(ui.g.swipes==1,"controller D-pad maps to a valid slide")
 ui._request_move("up")
 ui._go_home()
 await process_frame
 check(ui.home_active and not ui.moving,"menu safely cancels in-flight animation")
 ui._show_new_run()
 await process_frame
 check(ui.overlay.view_id=="new","board selection is separate from title screen")
 ui.board_page=1
 ui._show_new_run()
 await process_frame
 var board_choices: Array = ui.overlay.find_children("*","Button",true,false).filter(func(button): return button.get_script()!=null and button.get_script().resource_path=="res://ui/board_option.gd")
 check(board_choices.size()==5,"five additional boards have their own page")
 var active_rng: int = ui.g.rng.state
 var active_board: String = ui.g.board_id
 ui.run_selector._select("archivist")
 check(ui.run_selector.hero.texture.resource_path.ends_with("board_archivist.png"),"selection shows distinct pixel board artwork")
 check(ui.run_selector._stats[0].text=="2" and ui.run_selector._stats[3].text=="5","selection uses actual board starting rules")
 check(ui.run_selector._loadout.get_child_count()==12,"starting kit includes relics, upgrade, and three runes")
 check(ui.g.rng.state==active_rng and ui.g.board_id==active_board,"selection preview cannot change the active run or RNG")
 ui.run_selector.seed_field.text_changed.emit("KEPT-SEED")
 var selector_id: int = ui.run_selector.get_instance_id()
 ui.run_selector._set_page(0)
 check(ui.run_selector.get_instance_id()==selector_id and ui.seed_input=="KEPT-SEED","page browsing preserves the selector and seed")
 ui.run_selector._select("chronicle")
 check(ui.run_selector._stats[1].text=="21","move preview includes starting upgrades")
 for pool in [Game.Cat.RELICS,Game.Cat.SPELLS,Game.Cat.RUNES,Game.Cat.UPGRADES]:
  for id in pool:
   check(ResourceLoader.exists("res://assets/pixel/"+str(pool[id].art)+".png"),"pixel art covers "+id)
 ui.start_run("classic","TRANSACTIONS")
 ui.g.finish_gate(true)
 ui.g.open_shop()
 ui.g.shop_offers=["corner","mercy","venus","echo"]
 ui.g.shop_upgrade="moves1"
 ui.g.money=Num.new(100)
 ui.run_view.wallet.reset(ui.g.money)
 ui._refresh_run(false)
 ui._show_shop()
 await process_frame
 var shop_id: int = ui.shop_view.get_instance_id()
 var wallet_id: int = ui.shop_view.wallet.get_instance_id()
 var first_cost: int = ui.g.cost_for("corner")
 check(ui._buy("corner"),"purchase commits immediately")
 var after_first = ui.g.money
 check(after_first.cmp(100-first_cost)==0,"purchase charges the exact cost")
 check(not ui._buy("corner") and ui.g.money.cmp(after_first)==0,"repeat purchase cannot charge twice during an animation")
 check(ui.shop_view.get_instance_id()==shop_id and ui.shop_view.wallet.get_instance_id()==wallet_id,"purchase preserves the shop and money counter")
 var second_cost: int = ui.g.cost_for("mercy")
 check(ui._buy("mercy") and ui.g.money.cmp(after_first.minus(second_cost))==0,"another purchase works while earlier feedback is running")
 check(ui.run_view.card_for("mercy").modulate.a==0.0,"acquisition travels before appearing in its slot")
 await create_timer(.85).timeout
 check(ui.shop_view.wallet.value_label.text==ui.g.money.fmt() and ui.run_view.wallet.value_label.text==ui.g.money.fmt(),"both animated balances settle at the authoritative amount")
 check(ui.run_view.card_for("mercy").modulate.a==1.0,"acquisition reveals its destination after arrival")
 var stale_flights: Array = ui.effects.get_children().filter(func(node): return node is Button and node.has_meta("transient"))
 check(stale_flights.is_empty(),"card flights clean themselves up")
 ui._open_shop_pack()
 await process_frame
 check(ui.overlay.view_id=="pack" and not ui.overlay.closable,"pack reveal preserves the pending choice")
 var pick: String = ""
 for id in ui.g.pack_choices:
  if ui.g.can_grant(id): pick=id; break
 check(pick!="","pack provides a usable choice")
 ui._pick_pack(pick)
 check(ui.g.pack_choices.is_empty() and ui.overlay.view_id=="shop","taking a pack card returns to the shop")
 ui._go_home()
 await process_frame
 check(ui.effects.get_children().filter(func(node): return node.has_meta("transient")).is_empty(),"leaving a run cancels transient card and coin effects")
 ui._show_help()
 await process_frame
 ui._show_settings()
 await process_frame
 ui._show_collection()
 await process_frame
 ui._save_dialog(true)
 await process_frame
 ui._save_dialog(false)
 await process_frame
 ui.overlay.close()
 ui.start_run("purple","ORDER")
 var first_id: String = ui.g.relics[0].id
 ui._reorder_to(0,1)
 check(ui.g.relics[1].id==first_id,"card drop reorders scoring engine")
 ui.start_run("robot","AUTO")
 ui._toggle_auto()
 await create_timer(.9).timeout
 check(ui.g.swipes>0,"automatic input advances animated board")
 ui._show_settings()
 var paused_swipes: int = ui.g.swipes
 await create_timer(.4).timeout
 check(ui.g.swipes==paused_swipes and not ui.auto_on,"opening a menu stops autoplay")
 check(not ui.auto_thinking,"menu cancels pending autoplay search")
 ui.overlay.close()
 if not ui.reduced_motion: ui._toggle_motion()
 ui._request_move("left")
 await process_frame
 check(not ui.moving and not ui.run_view.board.animating,"reduced motion resolves without an animation lock")
 ui._go_home()
 while ui.auto_thinking: await process_frame
 await process_frame
 await process_frame
 ui.queue_free()
 ui=null
 joy=null
 touch_down=null
 touch_up=null
 await process_frame
 await process_frame
 await create_timer(.05).timeout
 print("UI integration checks: ",assertions,"; failures: ",failures)
 quit(0 if failures==0 else 1)

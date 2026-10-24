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
 ui.g.persist_enabled=false
 if ui.reduced_motion: ui._toggle_motion()
 await process_frame
 check(ui.home_active and ui.home.visible,"opens on composed title screen")
 check(ui.home.find_children("*","Button",true,false).size()>=8,"title artwork and menu built")
 var title: Label = ui.home.get_node("Title")
 check(title.get_theme_font("font").resource_path=="res://assets/fonts/display.ttf","original display font restored")
 check(title.size.x>=500,"title does not wrap into a column")
 for definition in Game.Cat.BOARDS:
  ui.start_run(definition.id,"UI-TEST")
  await process_frame
  check(ui.run_view.board.size.x==490,"board fits "+definition.id)
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

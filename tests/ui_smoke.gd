extends SceneTree
const Main = preload("res://scripts/main.gd")
var failures := 0
var ui
func _initialize():
 call_deferred("run")
func check(okay: bool, label_text: String):
 if not okay:
  failures+=1
  printerr("FAIL: ",label_text)
func run():
 ui=Main.new()
 root.add_child(ui)
 ui.g.persist_enabled=false
 ui.size=Vector2(1366,768)
 await process_frame
 check(ui.g.phase=="home","starts on home screen")
 for label in ui.find_children("*","Label",true,false):
  if label.text=="GATEFOLD": check(label.size.x>=200 and label.size.y<60,"title retains readable width")
 for board in Main.Cat.BOARDS:
  ui.g.new_run(board.id,"UI-TEST")
  ui._render()
  await process_frame
  check(ui.board_area.size.x>300,"board visible "+board.id)
  ui.g.finish_gate(true)
  ui._render()
  await process_frame
  ui.g.open_shop()
  ui._render()
  await process_frame
  ui.g.money=Main.Game.Num.new(100)
  ui.g.pack_open()
  ui._render()
  await process_frame
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
 ui.active_dialog.hide()
 ui.active_dialog.queue_free()
 ui.g.new_run("robot","AUTO")
 ui._toggle_auto()
 await create_timer(.7).timeout
 check(ui.g.swipes>0,"automatic moves advance run")
 ui._go_home()
 ui.board_page=1
 ui._render()
 await process_frame
 print("UI smoke failures: ",failures)
 ui.queue_free()
 await process_frame
 quit(0 if failures==0 else 1)

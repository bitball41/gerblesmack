extends SceneTree
const Game = preload("res://scripts/game.gd")
const Num = preload("res://scripts/num.gd")
const MAIN = preload("res://scenes/main.tscn")
var assertions := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(okay: bool, message: String) -> void:
 assertions+=1
 if not okay: failures+=1; printerr("FAIL: ",message)
func relic(id: String) -> Dictionary:
 return {"id":id,"growth":Num.new(1),"charge":24.0 if id=="battery" else 0.0,"carry":3 if id=="feedback" else 0}
func setup(game) -> void:
 game.persist_enabled=false
 game.new_run("blue","SCORING")
 game.floor_num=10
 game.moves=30
 game.cells.fill(null)
 game.cells[0]=game.tile(1,{},true)
 game.cells[1]=game.tile(1)
 game.cells[4]=game.tile(2)
 game.cells[5]=game.tile(2)
 game.relics=[relic("carbon"),relic("echo"),relic("mirror"),relic("feedback"),relic("resonance")]
 game.score=Num.new(20)
 game.total_score=Num.new(20)
func run() -> void:
 var traced := Game.new()
 setup(traced)
 var skipped := Game.new()
 skipped.persist_enabled=false
 skipped.restore(traced.snapshot())
 check(traced.move("left",true) and skipped.move("left",false),"both playback paths commit the same swipe")
 check(traced.export_run()==skipped.export_run(),"receipts do not alter scores, growth, income, saves, or RNG")
 check(not traced.last_score_steps.is_empty() and skipped.last_score_steps.is_empty(),"fast path builds no animation receipts")
 var receipts: Array = traced.last_score_steps
 var activations: Array = receipts.filter(func(step): return step.kind=="relic").map(func(step): return step.id)
 check(activations.slice(0,5)==["carbon","echo","mirror","feedback","resonance"],"actual left-to-right relic order is retained")
 check(activations.count("carbon")==3 and activations.count("echo")==3,"two merges and a seal preserve repeated activations")
 check(receipts.filter(func(step): return step.kind=="retrigger").size()>=6,"Echo, Mirror, and Feedback record retriggers")
 check(receipts.filter(func(step): return step.kind=="merge" and step.text=="Seal retrigger").size()==1,"seal explicitly starts a second pass")
 check(receipts[-1].kind=="bank" and receipts[-1].subtotal.cmp(traced.last_merge)==0,"final bank equals the authoritative scientific score")
 var restored := Game.new()
 restored.persist_enabled=false
 check(restored.restore(traced.snapshot()) and restored.last_score_steps.is_empty(),"save loading does not resume stale receipts")
 var preview := Game.new()
 setup(preview)
 var slid: Dictionary = preview.slide("left")
 preview.cells=slid.board
 check(preview.score_merges(slid.events,2,true,true).steps.is_empty(),"autoplay previews allocate no presentation queue")
 setup(preview)
 preview.relics=[relic("battery")]
 preview.cells.fill(null)
 preview.cells[1]=preview.tile(1)
 preview.move("left")
 check(preview.last_merge.m==0 and preview.last_score_steps.size()==1 and preview.last_score_steps[0].text=="+12 stored","battery charging creates no fabricated score")
 var ui: Control = MAIN.instantiate()
 root.add_child(ui)
 ui.effects.sound_enabled=false
 ui.auto_speed=1
 ui.reduced_motion=false
 ui.start_run("blue","UI-SCORING")
 ui._begin_gate()
 setup(ui.g)
 ui._refresh_run()
 await process_frame
 ui._request_move("left")
 var committed: String = ui.g.export_run()
 check(ui.moving and ui.run_view.scoring and ui.run_view._score_label.text=="20","committed points remain visually pending during slide")
 check(not ui.run_view._action.visible,"phase action waits until scoring ends")
 await create_timer(.22).timeout
 check(ui.scoring_sequence.active and ui.run_view._receipt_heading.text=="Scoring","settled board begins the scoring sequence")
 ui.scoring_sequence._process(.17)
 check(ui.run_view.relic_cards.any(func(card): return card.scoring_active and card.has_node("ScoreBadge")),"active relic gets an attached numeric badge")
 ui.scoring_sequence._process(10.0)
 check(not ui.moving and not ui.scoring_sequence.active and not ui.run_view.scoring,"sequence releases the input lock")
 check(ui.run_view._score_label.text==ui.g.score.fmt() and ui.run_view._receipt_points.text=="+"+ui.g.last_merge.fmt(),"final counters show exact committed totals")
 check(ui.g.export_run()==committed,"playback does not replay any model mutations")
 check(ui.run_view.relic_cards.all(func(card): return not card.scoring_active and card.scale==Vector2.ONE),"card highlights and scale return to rest")
 setup(ui.g)
 ui._refresh_run()
 ui._request_move("left")
 await create_timer(.2).timeout
 ui._show_settings()
 var paused: String = ui.g.export_run()
 check(ui.overlay.view_id=="settings" and not ui.moving and not ui.scoring_sequence.active,"Options immediately settles scoring")
 await create_timer(.25).timeout
 check(ui.g.export_run()==paused and ui.overlay.view_id=="settings","stale callbacks do not replace menus")
 ui.overlay.close()
 setup(ui.g)
 ui._refresh_run()
 ui._request_move("left")
 await create_timer(.2).timeout
 ui.start_run("classic","CANCEL-CHAIN")
 await create_timer(.2).timeout
 check(ui.g.phase=="gates" and ui.g.score.m==0 and not ui.scoring_sequence.active and not ui.run_view.scoring,"new run cancels every scoring callback")
 ui._begin_gate()
 setup(ui.g)
 ui.auto_speed=8
 ui._refresh_run()
 ui._request_move("left")
 await create_timer(.2).timeout
 check(not ui.moving and not ui.scoring_sequence.active and ui.g.last_score_steps.is_empty(),"8x bypasses playback and queue allocation")
 check(ui.run_view._score_label.text==ui.g.score.fmt() and ui.run_view.relic_cards.all(func(card): return not card.scoring_active),"8x retains exact totals without stale feedback")
 setup(ui.g)
 ui.auto_speed=1
 ui._refresh_run()
 ui._request_move("left")
 await create_timer(.2).timeout
 ui.auto_speed=4
 ui._cycle_speed()
 check(ui.auto_speed==8 and not ui.moving and not ui.scoring_sequence.active,"switching to 8x settles an in-flight sequence")
 setup(ui.g)
 ui.auto_speed=1
 ui.g.floor_num=1
 ui._refresh_run()
 ui._request_move("left")
 check(ui.g.phase=="reward" and ui.moving and not ui.overlay.visible,"winning move waits for its visible chain")
 await create_timer(.2).timeout
 ui.scoring_sequence._process(10.0)
 check(ui.overlay.view_id=="result" and not ui.moving,"winning chain opens results after the final tally")
 ui.overlay.close()
 setup(ui.g)
 ui.reduced_motion=true
 ui._refresh_run()
 ui._request_move("left")
 check(not ui.moving and not ui.run_view.scoring and ui.g.last_score_steps.is_empty(),"reduced motion resolves directly")
 ui._go_home()
 ui.queue_free()
 await process_frame
 await process_frame
 print("Scoring playback checks: ",assertions,"; failures: ",failures)
 quit(0 if failures==0 else 1)

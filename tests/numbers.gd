extends SceneTree
const Game = preload("res://scripts/game.gd")
const Num = preload("res://scripts/num.gd")
const Rules = preload("res://scripts/fracture_rules.gd")
const Cat = preload("res://scripts/catalog.gd")
const UIStyle = preload("res://ui/skin.gd")
const MAIN = preload("res://scenes/main.tscn")
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(okay: bool, label: String) -> void:
 checks+=1
 if not okay: failures+=1;printerr("FAIL: ",label)
func game(board: String = "classic"):
 var g = Game.new();g.persist_enabled=false;g.new_run(board,"HUGE-NUMBERS")
 return g
func near(a,b) -> bool:
 return a.cmp(b)==0 or (a.layer==0 and b.layer==0 and absf(a.log10_value()-b.log10_value())<1e-9)
func finite(value) -> bool:
 return value.m>0 and is_finite(value.m) and is_finite(value.e) and value.layer>=0
func run() -> void:
 var n = Num.new(1.23456789,87)
 var encoding: Dictionary = n.encode()
 check(n.fmt()=="1.23457e87" and n.fmt(10)=="1.23456789e87","six visible significant digits and ten detailed digits")
 check(n.encode()==encoding,"formatting never mutates stored precision")
 check(Num.new(1.23,45600000).fmt()=="1.23e4.56e7","double scientific notation has the requested meaning")
 check(Num.new(9.9999999,999999).fmt()=="1e1e6","rounded mantissa carries into a nested exponent")
 check(Num.new(1,248.05,1).fmt()=="1e1.12202e248" and Num.new(1,248.05,1).explain().begins_with("10^("),"the reported ee248.05 value has an explicit readable exponent")
 check(Num.new(1,15.5,1).fmt()=="1e3.16228e15","layered magnitudes display their exponent's coefficient")
 check(Num.new().fmt()=="0" and Num.new(999999).fmt()=="999999","ordinary values retain familiar integer formatting")
 var huge = Num.power(2,4096).raised(Num.power(1.2,1000000))
 check(finite(huge) and huge.layer>0 and not "inf" in huge.fmt().to_lower(),"million-pass powers stay finite and meaningful")
 var larger = huge.raised(huge)
 check(finite(larger) and larger.cmp(huge)>0 and larger.layer>huge.layer,"additional layers preserve increasing magnitude")
 check(near(huge.div(huge),Num.new(1)) and huge.ratio_to(larger)==0 and larger.ratio_to(huge)==1,"huge arithmetic and progress avoid invalid Infinity differences")
 for value in [n,Num.new(1.23,45600000),huge,larger,Num.new(1,1e308)]:
  var g=game();g.score=value;g.total_score=value;g.last_merge=value
  var h=game()
  check(h.import_run(g.export_run()) and h.score.cmp(value)==0 and h.total_score.cmp(value)==0,"huge magnitude survives native save reload "+value.fmt())
 # Actual sales, including both relics' numerical editions.
 for sold_tags in [{},{"edition":"oversaturated"},{"cursed":true}]:
  for writer_tags in [{},{"edition":"oversaturated"},{"cursed":true}]:
   var g=game();g.relics=[];g._grant("ghostwriter",writer_tags);g._grant("singularity",sold_tags)
   var writer: Dictionary = g.relics[0];writer.growth=Num.new(1,5)
   var exponent: float = 1.2*Rules.power(g.relics[1])*Rules.power(writer)
   g.phase="shop"
   check(g.sell_relic(1) and near(writer.growth,Num.power(10,5*exponent)),"Singularity sale permanently exponentiates Ghostwriter "+str([sold_tags,writer_tags]))
   var h=game()
   check(h.import_run(g.export_run()) and near(Rules.actor(h,"ghostwriter").growth,writer.growth),"sale exponent survives save reload")
 var g=game();g.relics=[];g._grant("ghostwriter");g._grant("echo");g.relics[0].growth=Num.new(100);g.phase="shop"
 check(g.sell_relic(1) and near(g.relics[0].growth,Num.new(200)),"ordinary multiplier sales keep their existing behavior")
 g._grant("singularity");g.phase="play"
 var before: String = g.export_run()
 check(not g.sell_relic(1) and g.export_run()==before,"invalid sales cannot grant a power or change state")
 check(Cat.RELICS.ghostwriter.rarity=="Rare","Ghostwriter keeps its current rarity")
 # Hollow gets the temporary boost only when starting a new run.
 g=game("hollow")
 check(g.relics.size()==1 and g.relics[0].id=="avalanche" and g.relics[0].perishable_clears==3 and g.max_relics()==7 and g.money.cmp(4)==0,"Hollow starts Perishable Avalanche without changing its other rules")
 check("3 successful clears" in Rules.status(g,g.relics[0]),"live tooltip explains the expiration condition")
 var events: Array = []
 for index in [0,4,8]:
  var tile: Dictionary = g.tile(2);g.cells[index]=tile;events.append({"index":index,"tile":tile})
 check(g.score_merges(events,3).score.cmp(28)==0,"starting Avalanche has its full ordinary scoring ability")
 g.phase="play";g.finish_gate(true)
 check(g.relics[0].perishable_clears==2,"a successful gate consumes one clear")
 g.finish_gate(true)
 check(g.relics[0].perishable_clears==2,"duplicate result callbacks never consume another clear")
 g.phase="play";g.finish_gate(false)
 check(g.relics[0].perishable_clears==2,"a failed gate does not consume the timer")
 var h=game()
 check(h.import_run(g.export_run()) and h.relics[0].perishable_clears==2,"remaining lifetime persists through saves")
 h.phase="play";h.finish_gate(true)
 check(h.has_relic("avalanche") and h.relics[0].perishable_clears==1,"Avalanche remains available for the third successful gate")
 h.phase="play";h.finish_gate(true)
 check(not h.has_relic("avalanche") and "Avalanche expired" in h.result_text and Rules.bound_count(h)==0,"the third clear expires Avalanche and frees its slot")
 h.phase="shop";h._grant("avalanche");h.phase="play";h.finish_gate(true)
 check(h.has_relic("avalanche") and not h.relics[0].has("perishable_clears"),"a later ordinary Avalanche is permanent")
 # Absorbing the temporary relic does not accidentally make its ability eternal.
 g=game("hollow");g._grant("devourer");g.phase="shop";g.f.pending.devourer=1
 check(g.workshop_action("devour",0) and g.relics[0].abilities[0].perishable_clears==3,"Devourer inherits the existing timer with the ability")
 for index in range(3):g.phase="play";g.finish_gate(true)
 check(g.has_relic("devourer") and g.relics[0].abilities.is_empty(),"only the inherited temporary ability expires")
 g=game("hollow");g.inventory=["rebirth"];g.phase="play"
 check(g.use_item(0,0) and g.relics[0].perishable_clears==3,"trait-preserving transformations retain the existing lifetime")
 var old: Dictionary = game("hollow").snapshot();old.relics=[]
 h=game()
 check(h.restore(old) and h.relics.is_empty(),"loading an existing Hollow run never grants a new starting relic")
 for timer in [0,-1,1.5,4,"3"]:
  var malformed: Dictionary = game("hollow").snapshot();malformed.relics[0].perishable_clears=timer
  check(not h.restore(malformed),"invalid lifetime is rejected before mutation "+str(timer))
 # Narrow and wide real labels retain useful precision and hover detail.
 var ui: Control = MAIN.instantiate();root.add_child(ui);ui.effects.sound_enabled=false;ui.start_run("hollow","NUMERIC-UI");ui._begin_gate()
 await process_frame
 for value in [n,Num.new(1.23,45600000),Num.new(1,248.05,1),huge,larger]:
  UIStyle.paint_number(ui.run_view._score_label,value)
  var label: Label = ui.run_view._score_label
  var font: Font = label.get_theme_font("font")
  check(label.size.x<=188 and font.get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,label.get_theme_font_size("font_size")).x<=label.size.x,"huge score fits its actual sidebar "+label.text)
  check(label.tooltip_text.begins_with(value.fmt(10)+"\n") and value.explain(8) in label.tooltip_text,"hover preserves greater numerical detail")
 check(ui.run_view.relic_cards[0].item_state.perishable_clears==3,"Hollow's starting card exposes its lifetime")
 ui._go_home();ui.queue_free();await process_frame
 print("Huge number, sale and Hollow checks: ",checks,"; failures: ",failures)
 quit(0 if failures==0 else 1)

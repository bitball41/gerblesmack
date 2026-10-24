extends SceneTree
const Game = preload("res://scripts/game.gd")
const Num = preload("res://scripts/num.gd")
var failures := 0
var checks := 0

func expect(okay: bool, context: String) -> void:
 checks+=1
 if not okay:
  failures+=1
  if failures<=20: printerr("FAIL: "+context)

func same(actual, expected, path: String = "") -> bool:
 if expected is Dictionary:
  if actual is not Dictionary: return false
  for key in expected:
   if not actual.has(key) or not same(actual[key],expected[key],path+"."+key):
    if failures<5: printerr("Mismatch ",path+"."+key," got ",actual.get(key)," expected ",expected[key])
    return false
  return true
 if expected is Array:
  if actual is not Array or actual.size()!=expected.size(): return false
  for index in range(expected.size()):
   if not same(actual[index],expected[index],path+"[%d]"%index): return false
  return true
 if (actual is int or actual is float) and (expected is int or expected is float):
  return absf(float(actual)-float(expected))<=1e-9*maxf(1,absf(float(expected)))
 return actual==expected

func game():
 var g=Game.new()
 g.persist_enabled=false
 return g

func _initialize() -> void:
 call_deferred("run")

func run() -> void:
 var fixture_file := FileAccess.open("res://tests/fixtures/legacy.json",FileAccess.READ)
 var data: Dictionary = JSON.parse_string(fixture_file.get_as_text())
 for case in data.fixtures:
  var g=game()
  if case.op=="new": g.new_run(case.board,case.seed)
  else:
   expect(g.restore(case.input),case.name+" restore")
   if case.op=="move":
    expect(g.move(case.dir)==case.ok,case.name+" valid move")
    if case.has("gain"):
     expect(same(g.last_merge.encode(),case.gain),case.name+" merge gain")
     expect(g.last_triggers==case.triggers,case.name+" triggers")
   elif case.op=="shop":
    g.finish_gate(case.success)
    g.open_shop()
  expect(same(g.snapshot(),case.expected),case.name+" state")
  var copy=game()
  expect(copy.import_run(g.export_run()),case.name+" reload")
  expect(same(copy.snapshot(),g.snapshot()),case.name+" save round trip")
 for case in data.slides:
  var g=game()
  var slid: Dictionary = g.slide(case.dir,case.board)
  expect(slid.changed==case.changed and same(slid.board,case.expected) and same(slid.events,case.events),"pure slide "+case.dir)
 for case in data.autoplay:
  var g=game()
  expect(g.restore(case.input),case.name+" auto restore")
  var before: String = g.export_run()
  var start: int = Time.get_ticks_msec()
  expect(g.choose_auto_move(false)==case.basic,case.name+" Auto I")
  expect(g.choose_auto_move(true)==case.advanced,case.name+" Auto II")
  var Autoplayer=load("res://scripts/autoplayer.gd")
  expect(await Autoplayer.choose_async(g,true,self)==case.advanced,case.name+" asynchronous Auto II parity")
  expect(g.export_run()==before,case.name+" search leaves RNG and live run untouched")
  print("Autoplay ",case.name," both tiers: ",Time.get_ticks_msec()-start,"ms")
 _native_regressions()
 print("Regression checks: ",checks,"; failures: ",failures)
 quit(0 if failures==0 else 1)

func _native_regressions() -> void:
 var huge=Num.power(2,4096)
 expect(is_finite(huge.m) and huge.e>1000,"uncapped tile score")
 expect(huge.times(huge).e>2000,"uncapped multiplication")
 expect(huge.plus(huge).div(2).cmp(huge)==0,"large arithmetic round trip")
 var g=game()
 g.new_run("classic","SAVE-TEST")
 var prior: String = g.export_run()
 expect(not g.import_run('{"version":2,"cells":[]}'),"reject incomplete save")
 expect(g.export_run()==prior,"rejected save preserves current run")
 for id in ["auto1","auto2"]:
  expect(g.cost_for(id)==18,"non-Robot automation price")
  expect(not g.upgrade_allowed(id),"automation locked on floors 1 and 2")
 g.floor_num=3
 expect(g.upgrade_allowed("auto1"),"automation unlocks on floor 3")
 g.new_run("robot","ROBOT")
 expect(g.cost_for("auto2")==12,"Robot upgrade price")
 g.new_run("classic","ITEMS")
 g.inventory=["seed","twins","void","seal","emperor","mercy"]
 expect(g.use_item(0,0),"spawn Spell")
 expect(g.cells[0].e==4,"Seed value")
 expect(g.use_item(0,0,1),"Duplicate source/destination")
 expect(g.cells[0]==g.cells[1],"Duplicate enhancements preserved")
 expect(g.use_item(0,0),"erase Spell")
 expect(g.cells[0]==null,"Shatter frees a cell")
 expect(g.use_item(0,1),"Echo mark")
 g.inventory.insert(0,"seal")
 expect(not g.use_item(0,1),"duplicate enhancement does not consume card")
 g.inventory.remove_at(0)
 expect(g.use_item(0,1),"Gold enhancement")
 expect(not g.use_item(0),"full-health Mend retained")
 g.hp-=1
 expect(g.use_item(0),"Mend heals")
 g.phase="shop"
 g.inventory=["hourglass"]
 expect(not g.use_item(0),"time Spell restricted to play")
 var initial_money=g.money
 expect(g.sell_item(0),"sell consumable")
 expect(g.money.cmp(initial_money)>0,"consumable sale income")
 g.new_run("chronicle","CHRONICLE")
 g.moves=10
 g.finish_gate(true)
 expect(g.result_summary.efficiency==0,"Chronicle banks moves without cash efficiency")
 g.open_shop()
 var voucher: String = g.shop_upgrade
 g.money=Num.new(100)
 expect(g.reroll(),"shop reroll")
 expect(g.shop_upgrade==voucher,"reroll preserves upgrade offer")
 g.leave_shop()
 expect(g.moves==30,"Chronicle carries ten moves into next gate")
 g.new_run("archivist","ARCHIVE")
 expect(g.hp==2 and g.inventory.size()==3,"Archivist downside and pocket")
 g.new_run("bazaar","BAZAAR")
 expect(g.money.cmp(8)==0,"Bazaar starts with $8")
 # Legacy JSON with Num tags imports and preserves deterministic continuation.
 var legacy={"version":1,"seed":"IMPORT","boardId":"classic","rng":12345,"board":g.cells,"jokers":Game.encode(g.relics),"inventory":[{"uid":1,"id":"seed"}],"vouchers":[],"planets":g.rune_levels,"planetUses":0,"floor":1,"gate":0,"hp":3,"maxHp":3,"moves":18,"money":{"__num":[1.23,600]},"score":{"__num":[0,0]},"totalScore":{"__num":[1,800]},"next":g.next_tile,"phase":"play"}
 expect(g.import_run(JSON.stringify(legacy)),"legacy HTML save import")
 expect(g.money.e==600 and g.total_score.e==800 and g.inventory==["seed"] and g.rng.state==12345,"legacy large scores and RNG preserved")

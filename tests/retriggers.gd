extends SceneTree
## Independent, deliberately unbatched reference checks for the corrected rules.
const Game = preload("res://scripts/game.gd")
const Num = preload("res://scripts/num.gd")
const Rules = preload("res://scripts/fracture_rules.gd")
const Count = preload("res://scripts/trigger_count.gd")
const Clock = preload("res://ui/scoring_sequence.gd")
var checks := 0
var failures := 0

func _initialize() -> void: run.call_deferred()
func check(okay: bool, message: String) -> void:
 checks+=1
 if not okay:
  failures+=1
  if failures<=20: printerr("FAIL: ",message)
func close(a, b) -> bool:
 if a.m==0 or b.m==0: return a.cmp(b)==0
 return a.layer==b.layer and (absf(a.log10_value()-b.log10_value())<1e-8 if a.layer==0 else absf(a.e-b.e)<1e-8)
func relic(id: String, tags: Dictionary = {}) -> Dictionary:
 return {"id":id,"growth":Num.new(2),"charge":24.0 if id=="battery" else 0.0,"carry":0}.merged(tags,true)
func game(ids: Array = []):
 var g = Game.new()
 g.persist_enabled=false
 g.new_run("classic","ACTUAL-TRIGGERS")
 g.floor_num=20; g.moves=30
 g.cells.fill(null); g.relics=[]
 for id in ids: g.relics.append(relic(id))
 return g
func event(g, exponent: int = 11, seal: bool = false) -> Dictionary:
 var tile: Dictionary = g.tile(exponent,{},seal)
 g.cells[0]=tile
 return {"index":0,"tile":tile}

func reference(ids: Array, exponent: int, seal: bool) -> Dictionary:
 var full = Num.new()
 var total: int = 0
 var resonance_pos: int = 0
 var carries: Dictionary = {}
 for pass_index in range(2 if seal else 1):
  var value = Num.power(2,exponent)
  var count: int = 1
  for slot in range(ids.size()):
   var id: String = ids[slot]
   var arriving: int = count
   if id=="feedback":
    # Simulate the trigger stream, including the extra triggers it creates.
    var carry: int = int(carries.get(slot,0))
    var pending: int = count
    var extra: int = 0
    while pending>0:
     pending-=1; carry+=1
     if carry==5: carry=0; extra+=1; pending+=1
    carries[slot]=carry
    value=value.plus(value.div(arriving).times(extra))
    count+=extra
    continue
   for activation in range(arriving):
    match id:
     "carbon": value=value.plus(8)
     "battery": value=value.plus(24)
     "corner","odd","compound","ghostwriter": value=value.times(2)
     "echo": value=value.times(2)
     "mirror","ascension": value=value.times(3)
     "singularity": value=value.raised(1.2)
     "resonance":
      resonance_pos+=1
      value=value.times(Num.power(1.12,resonance_pos))
   if id=="echo": count*=2
   if id in ["mirror","ascension"]: count*=3
  full=full.plus(value)
  total+=count
 return {"score":full.floored(),"triggers":total}

func run() -> void:
 # Small chains compare algebraic batching against actual repeated operations.
 var pool: Array = ["carbon","battery","corner","odd","compound","echo","mirror","ascension","singularity","resonance","feedback"]
 for first in pool:
  for second in pool:
   for third in ["carbon","corner","singularity","resonance","feedback"]:
    for sealed in [false,true]:
     var ids: Array = [first,second,third]
     var g = game(ids)
     var expected: Dictionary = reference(ids,11,sealed)
     var actual: Dictionary = g.score_merges([event(g,11,sealed)],12)
     check(close(actual.score,expected.score),"batched score equals individual activations "+str(ids)+str(sealed))
     check(actual.triggers==expected.triggers,"trigger stream equals reference "+str(ids)+str(sealed))
 check(close(Num.power(2,-3),Num.new(.125)),"ordinary negative powers retain the original arithmetic API")
 var g = game(["echo","carbon"])
 check(g.score_merges([event(g,2)],3).score.cmp(24)==0,"two Carbon activations add sixteen actual points")
 g=game(["echo","corner"])
 check(g.score_merges([event(g,2)],3).score.cmp(32)==0,"two Cornerstone activations multiply twice")
 g=game(["echo","echo","singularity"])
 var singular = g.score_merges([event(g,2)],3)
 check(close(singular.score,Num.power(32,pow(1.2,4)).floored()),"Singularity raises points four times")
 # Echo metadata survives the real Workshop sacrifice and a save/load.
 g=game(["echo","devourer"])
 g.relics[0].echoed=true; g.relics[0].echo_passes=2
 g.phase="shop"; g.f.pending.devourer=1
 check(g.workshop_action("devour",0),"Workshop accepts Echoed Echo Chamber")
 var h = game()
 check(h.import_run(g.export_run()) and h.relics[0].abilities[0].echoed,"absorbed Echo survives save reload")
 var inherited = h.score_merges([event(h,2)],3)
 check(inherited.triggers==4 and inherited.score.cmp(32)==0,"inherited Echo resolves twice without a physical-host duplicate")
 h.relics[0].echoed=true; h.relics[0].echo_passes=2
 var both = h.score_merges([event(h,2)],3)
 check(both.triggers==16 and both.score.cmp(131072)==0,"host and absorbed Echo passes multiply independently")
 g=game(["devourer"])
 g.relics[0].echoed=true
 g.relics[0].abilities=[relic("monolith",{"echoed":true})]
 var growth = g.relics[0].abilities[0].growth
 g.score_merges([event(g,11,true)],11)
 check(close(g.relics[0].abilities[0].growth,growth.times(1.15)),"inherited growth occurs once per actual merge, including seal/reverse/Echo passes")
 g=game(["business","echo","monolith","mobius"])
 g.relics[0].echoed=true;g.relics[2].echoed=true
 var payout = g.score_merges([event(g,2,true)],2)
 check(payout.money.cmp(1)==0 and close(g.relics[2].growth,Num.new(2).times(1.15)),"Echoes and Mobius never duplicate payouts or permanent growth")
 # The agreed run: 288 forward x 288 reverse x 2 seals x 4 merges.
 g=game(["echo","devourer","conductor","ghostwriter","ascension","mobius"])
 g.relics[1].echoed=true
 g.relics[1].abilities=[relic("echo"),relic("echo")]
 g.relics[3].growth=Num.new(1,5)
 g.relics[4].echoed=true
 var events: Array = []
 for index in [0,4,8,12]:
  var tile: Dictionary = g.tile(12,{},true)
  g.cells[index]=tile; events.append({"index":index,"tile":tile})
 var saved: String = g.export_run()
 var started: int = Time.get_ticks_usec()
 var result: Dictionary = g.score_merges(events,13,false,true)
 var elapsed: int = Time.get_ticks_usec()-started
 check(result.triggers==663552 and result.entries.all(func(e):return e.triggers==165888),"all 663,552 intended triggers reach scoring")
 var log_points: float = 12*log(2.0)/log(10.0)
 var count: int = 1
 var forward: Array = [2,2,2,2,2,100000,100000,3,3]
 var reverse: Array = forward.duplicate(); reverse.reverse()
 for factor in forward+reverse:
  log_points+=count*log(float(factor))/log(10.0)
  if factor in [2,3]: count*=factor
 log_points+=log(8.0)/log(10.0)
 check(count==82944 and absf(result.score.log10_value()-log_points)<1e-7,"663,552-trigger score matches an independent analytic exponent")
 check(result.steps.size()<400 and elapsed<1000000,"huge run uses bounded batches and completes in under a second")
 var restored = game()
 restored.import_run(saved)
 var skipped: Dictionary = restored.score_merges(events,13,false,false)
 check(close(skipped.score,result.score) and skipped.triggers==result.triggers and skipped.steps.is_empty(),"animation capture cannot change huge score, counts, or state")
 check(restored.export_run()==g.export_run(),"captured and skipped huge chains persist identical model state")
 var next: Dictionary = g.score_merges(events,13)
 check(next.triggers==2304,"Mobius reverse is consumed once per scoring swipe, not once per merge")
 # Repeat powers exceed even the old scientific exponent's float range.
 g=game()
 for index in range(14): g.relics.append(relic("echo"))
 g.relics.append(relic("singularity"))
 var layered: Dictionary = g.score_merges([event(g,12)],13)
 check(layered.score.layer>0 and is_finite(layered.score.e) and is_finite(layered.score.m),"repeated powers promote to finite layered exponents")
 check(layered.score.fmt().begins_with("1e") and layered.score.cmp(Num.new(1,1e14))>0,"layered formatting and ordering remain meaningful")
 g.score=layered.score;g.total_score=layered.score;g.last_merge=layered.score
 h=game()
 check(h.import_run(g.export_run()) and h.score.cmp(g.score)==0,"layered scores save and reload without Infinity or lost magnitude")
 check(g.score.ratio_to(h.score)==1.0 and Num.new(1).ratio_to(g.score)==0.0,"huge UI and autoplay ratios avoid Infinity minus Infinity")
 check(g.score.div(g.score).cmp(1)==0 and Num.power(10,g.score.log10_num()).cmp(g.score)==0,"layered division and log/power round trips")
 # Counters also exceed native 64-bit integers without wrapping or capping.
 var exact = Count.new(1)
 g=game()
 for index in range(80): exact=exact.times(2); g.relics.append(relic("echo"))
 var overflow: Dictionary = g.score_merges([event(g,2)],3)
 check(close(Num.of(overflow.triggers),Num.power(2,80)) and exact.mod_small(5)==1,"2^80 triggers retain magnitude and exact carry arithmetic")
 g.score=overflow.score;g.total_score=overflow.score;g.last_triggers=overflow.triggers
 h=game()
 check(h.import_run(g.export_run()) and h.export_run()==g.export_run(),"huge counters and scores round trip together")
 # Adaptive clock remains presentation-only, with bounded small expansions.
 var clock = Clock.new()
 root.add_child(clock)
 var small: Array = [{"kind":"relic","id":"corner","slot":0,"text":"x2","value":Num.new(32),"before":Num.new(8),"operand":Num.new(2),"operation":"multiply","activations":2}]
 clock.play(small)
 check(clock.steps.size()==2 and clock.steps[0].value.cmp(16)==0 and clock.steps[1].value.cmp(32)==0,"small scoring batches animate their actual intermediate values")
 var small_beat: float = clock._beat
 var large: Array = small.duplicate(true)
 large[0].activations=663552
 clock.play(large)
 check(clock.steps.size()==1 and clock._beat<small_beat and "663552" in clock.steps[0].text,"enormous batches compress and accelerate according to trigger count")
 var first_beat: float = clock._beat
 clock.play(large,4)
 check(is_equal_approx(clock._beat,first_beat/4),"manual speed multiplies the adaptive presentation speed")
 clock.play(result.steps)
 check(clock.steps.size()<=Clock.MAX_STEPS+16,"huge complete chain keeps bounded visual groups")
 var seen: Array = []
 clock.step_started.connect(func(step):seen.append(step))
 clock._process(10.0)
 check(not clock.active and seen[-1].kind=="bank" and seen[-1].subtotal.cmp(result.score)==0,"compressed animation banks the authoritative huge total")
 clock.play(result.steps,8)
 check(not clock.active and clock.steps.is_empty(),"8x instantly skips enormous chains")
 clock.queue_free()
 print("Retrigger mathematics checks: ",checks,"; failures: ",failures,"; 663,552-trigger calculation: ",elapsed,"us; score: ",result.score.fmt())
 quit(0 if failures==0 else 1)

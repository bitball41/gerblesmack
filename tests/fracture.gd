extends SceneTree
const Game = preload("res://scripts/game.gd")
const Num = preload("res://scripts/num.gd")
const Cat = preload("res://scripts/catalog.gd")
const Rules = preload("res://scripts/fracture_rules.gd")
const Actions = preload("res://scripts/fracture_actions.gd")
const Market = preload("res://scripts/fracture_market.gd")
var assertions := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(okay: bool, label: String) -> void:
 assertions+=1
 if not okay: failures+=1; printerr("FAIL: ",label)
func game(board: String = "classic", mode: String = "normal"):
 var g=Game.new()
 g.persist_enabled=false
 g.new_run(board,"FRACTURE-TEST",mode)
 return g
func only(g, ids: Array) -> void:
 g.relics=[]
 for id in ids: g._grant(id)
func plain(g, exponent: int = 1) -> void:
 g.cells.fill(null)
 g.cells[0]=g.tile(exponent)
 g.cells[1]=g.tile(exponent)
 g.floor_num=10
 g.moves=30
 g.score=Num.new()
func use(g, id: String, target: int = -1) -> bool:
 g.inventory=[id]
 g.f.item_tags={}
 return g.use_item(0,target)
func roundtrip(g, label: String) -> void:
 var h=Game.new()
 h.persist_enabled=false
 check(h.import_run(g.export_run()) and h.export_run()==g.export_run(),label+" save round trip")
func run() -> void:
 check(Cat.BOARDS.size()==25 and Cat.RELICS.size()==54 and Cat.UPGRADES.size()==30 and Cat.FRACTURES.size()==15,"complete Fracture content counts")
 check(Cat.RELICS.compound.rarity=="Legendary" and Cat.BASE_RELICS.compound.rarity=="Rare","Legendary classification preserves original baseline catalog")
 for board in Cat.BOARDS:
  for mode in ["normal","cursed"]:
   var g=game(board.id,mode)
   check(g.cells.size()==16 and g.moves>0 and g.hp>0 and g.hp<=g.max_hp,"valid start "+board.id+" "+mode)
   roundtrip(g,board.id+" "+mode)
 var g=game("hollow")
 check(g.relics.is_empty() and g.max_relics()==7 and g.money.cmp(4)==0,"Hollow kit and seven empty slots")
 g.upgrades=["moves1"]
 check(g.budget(0)==16 and g.budget(1)==16 and g.budget(2)==15,"Hollow penalty applies to every upgraded gate budget")
 g=game("treasury")
 check(g.money.cmp(50)==0 and g.has_relic("charity"),"Treasury starts with Deep Pockets and $50")
 g.finish_gate(true)
 check(g.money.cmp(50)==0 and g.result_summary.interest.m==0 and g.result_summary.efficiency==0,"Treasury receives no clear, efficiency, or interest cash")
 g=game("eclipse")
 check(g.max_hp==1 and not g.can_grant("heart1") and g.next_tile.fx.get("gold",false),"Eclipse has exactly one maximum Life and starts Gold")
 g.finish_gate(true);g.open_shop();g.leave_shop()
 check(g.next_tile.fx.get("glass",false) and g.max_hp==1,"Eclipse switches to Glass next gate")
 g=game("rich_get_richer")
 var compound: Dictionary = Rules.actor(g,"compound")
 check(Rules.current_factor(g,compound).cmp(2)==0 and g.price(10)==17,"Rich Get Richer starts x2 and has 65% markup")
 g.finish_gate(true)
 check(Rules.current_factor(g,compound).cmp(5)==0,"Oversaturated Compound Growth grows by x2.5")
 g=game("labyrinth")
 g.f.block=1;g.cells.fill(null);g.cells[0]=g.tile(2);g.cells[2]=g.tile(2)
 check(not g.slide("left").changed and g.slide("right").board[0].e==2,"blocked cell prevents sliding and merging across itself")
 g=game("reactor");only(g,[]);plain(g);g.f.merges=7
 g.move("left")
 check(g.cells[0].e==3 and g.last_merge.cmp(4)==0,"eighth merge doubles smallest tile without adding score")
 g=game("twinfall");g.f.spawns=5;g.cells.fill(null);g.next_tile=g.tile(5,{"gold":true},true);g.spawn()
 check(g.filled()==2 and g.f.spawns==6 and g.cells.filter(func(t):return t!=null and t.e==5 and t.seal and t.fx.gold).size()==2,"sixth natural spawn duplicates once with its properties")
 g=game("nomad");g.queue_gate()
 check(g.f.nomad_choices.size()==3 and not g.begin_gate(),"Nomad waits for its starting companion")
 check(Actions.choose_nomad(g,g.f.nomad_choices[0]) and g.begin_gate() and g.relics.size()==2,"Nomad choice grants exactly one starting relic")
 g=game();g.floor_num=10
 check(g.target().cmp(Num.power(3,9).times(96).times(8))==0,"endless adds super-exponential scaling after floor eight")
 g=game("classic","cursed")
 var initial=g.target()
 only(g,[]);g._grant("carbon",{"cursed":true,"edition":"oversaturated"})
 check(g.f.curse==4 and Rules.power(g.relics[0])==3 and g.target().cmp(initial)>0,"Cursed stacks independently with Oversaturated and increases gate danger")
 var preview: Dictionary = g.gate_previews()[0]
 check(preview.target==g.target().fmt() and preview.moves==g.moves,"gate previews use authoritative Cursed targets")
 g=game();only(g,["carbon","echo","corner","odd","compound"])
 check(Rules.bound_count(g)==5 and not g.can_grant("monolith"),"normal slot limit enforced")
 check(use(g,"liberation",0) and Rules.bound_count(g)==4 and g.can_grant("monolith") and g.f.move_penalty==2,"Liberation frees a slot with permanent move cost")
 check(use(g,"overexposure",1) and g.max_hp==2 and Rules.power(g.relics[1])==2,"Overexposure doubles a relic and costs maximum Life")
 roundtrip(g,"editions")
 g=game("eclipse")
 var before: String = g.export_run()
 g.inventory=["overexposure"]
 check(not g.use_item(0,0) and g.max_hp==1 and g.inventory==["overexposure"],"invalid Overexposure is not consumed")
 g=game();only(g,["carbon","echo","compound"])
 check(use(g,"schism",1) and g.relics.size()==2 and g.relics.all(func(r):return r.id=="echo") and g.relics[0].uid!=g.relics[1].uid,"Schism duplicates target and destroys two other relics")
 roundtrip(g,"duplicate relics")
 g=game();only(g,["carbon","echo","compound"])
 check(use(g,"erosion") and g.relics.size()==2 and g.f.extra_slots==1,"Erosion destroys a random relic for one slot")
 g=game();only(g,["carbon","echo","compound"])
 check(use(g,"rebirth",1) and g.relics.size()==3 and Cat.RELICS[g.relics[-1].id].rarity=="Uncommon","Rebirth supplies one same-rarity replacement")
 g=game();plain(g);g.cells[4]=g.tile(3);g.cells[8]=g.tile(4)
 check(use(g,"genesis",4) and g.filled()==3 and g.cells.filter(func(t):return t!=null and t.e==3).size()==2,"Genesis preserves source and clone while destroying two others")
 check(use(g,"collapse") and g.filled()==3 and g.cells.all(func(t):return t==null or t.seal),"Collapse seals three highest surviving tiles")
 g=game();plain(g);g.cells[0].fx.gold=true;g.cells[1].fx.steel=true;g.cells[1].seal=true
 check(use(g,"transference",0) and g.cells[0].fx.size()==2 and g.cells[0].seal and g.cells[1].fx.is_empty() and not g.cells[1].seal,"Transference concentrates properties without changing tile values")
 g=game();plain(g,4);g.cells[4]=g.tile(2)
 check(use(g,"monoculture") and g.cells.all(func(t):return t==null or(t.e==2 and t.fx.glass and t.seal)),"Monoculture makes a uniform Glass/sealed engine")
 g=game();g.money=Num.new(100)
 check(use(g,"overdraft") and g.money.m==0 and g.f.extra_slots==2 and g.f.no_interest==3,"Overdraft has explicit slots, cash, and interest costs")
 for turn in range(3):g.phase="play";g.finish_gate(true)
 check(g.f.no_interest==0 and g.interest().m>0,"Overdraft interest restriction expires after three clears")
 g=game();g.cells[0]=g.tile(4,{"gold":true});g.cells[1]=g.tile(2,{},true)
 check(use(g,"asceticism") and g.rune_uses==5 and g.rune_levels.values().all(func(v):return v==1) and g.cells.all(func(t):return t==null or (t.fx.is_empty() and not t.seal)),"Asceticism trades enhanced tiles for all five Rune upgrades")
 g=game();var old_count: int = g.relics.size()
 check(use(g,"sovereign") and g.relics.size()==old_count+1 and Cat.RELICS[g.relics[-1].id].rarity=="Legendary","Sovereign creates a Legendary with no downside")
 var sovereign_count := 0
 for draw in range(10000):
  if Market.draw_fracture(g,Cat.FRACTURES.keys())=="sovereign":sovereign_count+=1
 check(sovereign_count>200 and sovereign_count<400,"Sovereign generation tracks the specified three percent")
 for type in Cat.PACKS:
  for size in ["Standard","Jumbo","Mega"]:
   g=game();g.money=Num.new(100)
   g.f.pack_offers=[{"type":type,"size":size,"bought":false},{"type":type,"size":size,"bought":false}]
   g.phase="shop"
   check(g.pack_open(0) and g.pack_choices.size()==(3 if size=="Standard" else 5),type+" "+size+" opens with correct choice count")
   var held: Array = g.pack_choices.duplicate()
   check(g.pack_choose(held[0]),type+" "+size+" accepts first pick")
   if size=="Mega":
    check(g.pack_choices.size()==4 and g.f.pack_remaining==1,type+" Mega retains its second choice")
    roundtrip(g,type+" pending Mega")
    check(g.pack_choose(held[1]) and g.pack_choices.is_empty(),type+" Mega consumes exactly two picks")
   else:check(g.pack_choices.is_empty(),type+" "+size+" consumes one pick")
   check(not g.pack_open(0),"bought pack cannot charge twice")
 g=game();only(g,["carbon","echo","conductor"]);plain(g)
 var forward=g.score_merges(g.slide("left").events,1,false,true).score
 only(g,["conductor","carbon","echo"])
 var copied=g.score_merges(g.slide("left").events,1,false,true).score
 check(copied.cmp(forward)>0,"Conductor copies only its physical right neighbor")
 g=game();only(g,["carbon","mobius"]);plain(g)
 var first=g.score_merges(g.slide("left").events,1).score
 var second=g.score_merges(g.slide("left").events,1).score
 check(first.cmp(20)==0 and second.cmp(12)==0,"Mobius reverses the first scoring swipe only")
 g=game();only(g,["carbon","paradox"]);plain(g);g.money=Num.new(30)
 var old_cells: Array=g.cells.duplicate(true);var old_moves: int=g.moves
 g.move("left")
 check(Actions.rewind(g) and g.cells==old_cells and g.moves==old_moves and g.score.m==0 and g.money.cmp(30)==0 and not Actions.rewind(g),"Paradox restores model state exactly once per gate")
 g=game();only(g,["carbon","crown_echoes"]);plain(g);g.f.pending.crown_echoes=1;g.phase="shop"
 check(g.workshop_action("echo",0),"Crown can permanently Echo a selected scoring relic")
 g.phase="play"
 check(g.score_merges(g.slide("left").events,1).score.cmp(20)==0,"Echoed Carbon scores twice")
 g=game();only(g,["carbon","devourer"]);g.f.pending.devourer=1;g.phase="shop"
 check(g.workshop_action("devour",0) and g.relics.size()==1 and g.relics[0].abilities.size()==1,"Devourer inherits a sacrificed ability")
 plain(g);g.phase="play"
 check(g.score_merges(g.slide("left").events,1).score.cmp(12)==0,"inherited Carbon still scores")
 roundtrip(g,"inherited ability")
 g=game();g.upgrades=["satchel1","satchel2","fusion1","fusion2","fusion3"]
 g.inventory=["venus","mars","mercy","hourglass"]
 check(g.max_pocket()==5 and Market.put_in_reserve(g,0) and g.inventory.size()==3 and game().f.reserve.is_empty(),"reserve is separate from pocket and other runs")
 check(Market.take_from_reserve(g,0) and g.inventory.size()==4,"reserve card returns without losing identity")
 g.phase="shop"
 check(g.workshop_action("fusion_spell",1,2) and g.inventory.size()==3,"two Spells fuse into one")
 g.inventory=["venus","mars"]
 check(g.workshop_action("fusion_double",0,1,"venus") and g.inventory==["venus"] and g.f.item_tags["0"].double,"Fusion Lab III creates a double-use Rune")
 check(g.use_item(0) and g.rune_levels.gold==2 and g.rune_uses==2,"double-use Rune applies its track twice")
 g=game();only(g,["perpetuum"]);g.inventory=["venus"];g.use_item(0);g.phase="shop";g.pending_outcome=true;g.leave_shop()
 check(g.f.phantoms.size()==1 and g.inventory.is_empty() and g.use_item(0,-1,-1,"phantom") and g.rune_levels.gold==2,"Perpetuum supplies a usable slot-free phantom")
 g=game();only(g,["loan_shark","risky_investment"]);g.phase="gates";g.gate=2;g.money=Num.new(100);g.upgrades=["wagers1","wagers2","wagers3"]
 check(g.workshop_action("borrow",-1,-1,"",50) and g.f.debt.cmp(50)==0 and g.money.cmp(150)==0,"loan adds principal and records debt")
 check(g.workshop_action("invest") and g.f.investment.cmp(75)==0,"investment deposits half before Guardian")
 check(g.workshop_action("wager",-1,-1,"",30) and not g.workshop_action("wager",-1,-1,"",10),"wager validates cap and prevents duplicate staking")
 roundtrip(g,"financial contracts")
 g=game();var safe: String=g.export_run();var bad:Dictionary=g.snapshot();bad.f.curse=-2
 check(not g.restore(bad) and g.export_run()==safe,"invalid expansion save cannot mutate the live run")
 print("Fracture model checks: ",assertions,"; failures: ",failures)
 quit(0 if failures==0 else 1)

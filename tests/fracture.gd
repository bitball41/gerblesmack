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
 edge_checks()
 trigger_checks()
 duplicate_checks()
 result_checks()
 final_power_checks()
 print("Fracture model checks: ",assertions,"; failures: ",failures)
 quit(0 if failures==0 else 1)

func edge_checks() -> void:
 var g=game()
 # Production Fracture mode must preserve original scoring as well as frozen legacy mode.
 for id in Cat.BASE_RELICS:
  for direction in ["left","right","up","down"]:
   g=game();only(g,[id]);plain(g,4);g.floor_num=1
   g.relics[0].charge=24.0;g.relics[0].carry=3
   g.cells[0].fx.steel=true;g.cells[1].seal=true;g.cells[4]=g.tile(3);g.cells[5]=g.tile(3)
   var old=Game.new();old.persist_enabled=false;old.legacy_compat=true
   check(old.restore(g.snapshot()),"baseline parity state "+id)
   var a=g.slide(direction);var b=old.slide(direction)
   g.cells=a.board;old.cells=b.board
   var actual=g.score_merges(a.events,4);var expected=old.score_merges(b.events,4)
   check(actual.score.cmp(expected.score)==0 and actual.money.cmp(expected.money)==0 and g.rng.state==old.rng.state and Game.encode(g.relics)==Game.encode(old.relics),"production retains original effect "+id+" "+direction)
 for board in Cat.BASE_BOARDS:
  check(Cat.board(board.id)==board,"original board statistics preserved "+board.id)
 for pending in [false,true]:
  g=game();g.phase="shop";g.shop_offers=["carbon","echo","venus","mercy"];g.shop_pack_bought=pending
  g.pack_choices=["monolith","mars","hourglass"] if pending else []
  var state: Dictionary = g.snapshot();state.version=2;state.erase("f")
  var restored=game()
  check(restored.restore(state) and restored.shop_offers==g.shop_offers and restored.pack_choices==g.pack_choices and restored.f.pack_offers.size()==2,"version-two shop migration preserves choices")
  check(not pending or(restored.f.pack_offers[0].bought and restored.f.pack_remaining==1),"pending old pack is already paid")
  roundtrip(restored,"migrated shop")
 g=game();plain(g)
 for id in ["genesis","transference","collapse","monoculture"]:
  if id=="collapse" or id=="monoculture":
   for tile in g.cells:
    if tile!=null: tile.seal=true;tile.fx.glass=true
  g.inventory=[id]
  var before: String = g.export_run()
  check(not g.use_item(0,0) and g.export_run()==before,"no-op Fracture retains card and RNG "+id)
 g=game();only(g,["paradox"]);g.relics[0].edition="oversaturated";plain(g)
 for index in range(2):
  check(g.move("left") and Actions.rewind(g),"Oversaturated Paradox grants rewind "+str(index+1))
 check(not Actions.rewind(g),"Paradox quota cannot be reset by its own snapshot")
 roundtrip(g,"spent multiple rewinds")
 g=game();only(g,["steelworks"]);g.relics[0].edition="oversaturated";plain(g);g.cells[4]=g.tile(3,{"steel":true});g.cells[5]=g.tile(4,{"steel":true})
 check(is_equal_approx(Rules.current_factor(g,g.relics[0]).to_float(),5.76),"Oversaturated Steelworks doubles each printed per-Steel factor")
 g=game();only(g,["risky_investment"]);g.relics[0].edition="oversaturated";g.f.investment=Num.new(10);g.money=Num.new();g.gate=2
 Rules.after_result(g,true)
 check(g.money.cmp(60)==0,"Oversaturated investment pays six times principal")
 g=game();only(g,["shipping_crate"]);g.relics[0].edition="oversaturated";g.inventory=[];plain(g);g.cells[4]=g.tile(2);g.cells[5]=g.tile(3);g.cells[6]=g.tile(4)
 Rules.after_arrival(g)
 check(g.inventory.size()==2 and g.inventory.all(func(id): return Cat.SPELLS.has(id)),"Oversaturated Shipping Crate supplies two Spells")
 g=game();only(g,["crown_echoes"]);g.relics[0].edition="oversaturated";g.gate=2;g.cleared=3
 Rules.after_result(g,true)
 check(g.f.pending.crown_echoes==2,"Oversaturated Crown earns two permanent Echo choices")
 g=game();only(g,["devourer"]);g.relics[0].edition="oversaturated";g.f.pending.devourer=4;g.f.extra_slots=4
 for id in ["carbon","echo","corner","odd"]: g._grant(id)
 g.phase="shop"
 for index in range(4): check(g.workshop_action("devour",1),"Oversaturated Devourer capacity "+str(index+1))
 check(g.relics[0].abilities.size()==4,"Devourer retains four distinct inherited effects")
 roundtrip(g,"expanded Devourer")
 g=game();only(g,["stowaway"]);g.relics[0].edition="oversaturated";g.phase="shop";g.shop_offers=["carbon","echo","venus","mars"]
 check(Market.stow_offer(g,"carbon") and Market.stow_offer(g,"echo"),"Oversaturated Stowaway accepts two offers")
 g.shop_offers=["corner","odd","mercy","mars"];Market.tag_offers(g)
 check(g.shop_offers.has("carbon") and g.shop_offers.has("echo"),"both carried offers survive reroll")
 roundtrip(g,"multiple carried offers")
 g=game();only(g,["pandora"]);g.relics[0].edition="oversaturated";g.f.extra_slots=5;g.phase="shop";g.money=Num.new(100);g.f.pack_offers=[{"type":"standard","size":"Standard","bought":false}]
 var count: int = g.relics.size()+g.inventory.size()
 check(g.pack_open(0) and g.pack_choose(g.pack_choices[0]) and g.relics.size()+g.inventory.size()==count+3,"Oversaturated Pandora gives two additional random rewards")
 g=game("labyrinth")
 var safe: String = g.export_run()
 for field in ["last_used","paradox_used","rewind","item_tags"]:
  var malformed: Dictionary = g.snapshot()
  if field=="last_used": malformed.f[field]=42
  elif field=="paradox_used": malformed.f[field]=-1
  elif field=="rewind": malformed.f[field]={"json":42}
  else: malformed.f[field]={"0":{"double":42}}
  check(not g.restore(malformed) and g.export_run()==safe,"malformed expansion fields reject atomically "+field)
 var sampler=preload("res://scripts/autoplayer.gd")
 check(not sampler._spaces(g.cells,int(g.f.block)).has(int(g.f.block)),"autoplay never samples blocked Labyrinth space")
 var prior: String = g.export_run()
 check(sampler.choose(g)!="" and g.export_run()==prior,"Fracture autoplay is isolated from live state and RNG")
 var legendaries := 0
 for count_draw in range(10000):
  if Cat.RELICS[Market.draw_item(g,Cat.RELICS.keys())].rarity=="Legendary": legendaries+=1
 check(legendaries>50 and legendaries<160,"Reliquary Legendary generation remains about one percent")

func trigger_checks() -> void:
 var g=game();only(g,["handbrake"]);g.cells.fill(null);g.cells[1]=g.tile(2);g.moves=10;g.floor_num=10
 g.move("left")
 check(g.moves==10,"Handbrake refunds one valid nonmerge swipe")
 g.move("right")
 check(g.moves==9,"Handbrake does not refund repeatedly")
 g=game();only(g,["matchbox","spare_change","seedling","morgue","chain_reaction"]);plain(g)
 g.cells[4]=g.tile(3);g.cells[5]=g.tile(4)
 var event: Dictionary = {"index":0,"tile":g.tile(3,{"glass":true,"gold":true},true)}
 var balance=g.money
 var next: int = g.next_tile.e
 Rules.on_shatter(g,event)
 check(g.next_tile.fx.get("gold",false) and g.next_tile.fx.get("glass",false),"Matchbox enchants next natural tile")
 check(g.money.cmp(balance.plus(5))==0,"Spare Change pays only actual Gold/Glass shatters")
 check(g.next_tile.e==next+1,"Seedling improves next natural spawn")
 check(g.cells.any(func(t): return t!=null and t.seal),"Morgue transfers a shattered seal")
 check(g.cells[1].e==2 or g.cells[4].e==4,"Chain Reaction improves an adjacent tile")
 g=game();only(g,["copper_coil","red_thread","clone_vat"]);plain(g);g.cells[4]=g.tile(3)
 event={"index":0,"tile":g.tile(10,{"steel":true},true)}
 Rules.on_merge(g,event)
 check(g.cells[1].fx.get("steel",false) or g.cells[4].fx.get("steel",false),"Copper Coil spreads Steel to an adjacent tile")
 check(g.next_tile.seal,"Red Thread seals the next natural tile")
 check(g.cells.filter(func(t): return t!=null and t.e==10).size()==1,"Clone Vat creates exactly one plain copy")
 g=game();only(g,["leech"]);plain(g)
 var tile=g.tile(3,{"glass":true,"steel":true})
 Rules.on_merge(g,{"index":0,"tile":tile})
 check(tile.fx.size()==1 and is_equal_approx(g.relics[0].growth.to_float(),1.15),"Leech consumes one enhancement for permanent growth")
 g=game();only(g,["spore_cloud"]);g.relics[0].edition="oversaturated";g.relics[0].cursed=true;plain(g);g.cells[4]=g.tile(3)
 var copies := 0
 for index in range(1000):
  g.cells[1].fx={};g.cells[4].fx={}
  Rules.on_merge(g,{"index":0,"tile":g.tile(3,{"gold":true})})
  if g.cells[1].fx.has("gold"): copies+=1
 check(copies>500 and copies<700,"Spore Cloud probability honors combined x3 power")
 g=game();only(g,["cuckoo_clock"]);g.moves=0
 for index in range(21): Rules.on_merge(g,{"index":0,"tile":g.tile(2)})
 check(g.moves==2 and g.relics[0].carry==21,"Cuckoo Clock caps refunds at two per gate")
 g=game();only(g,["spare_parts"]);g.relics[0].edition="oversaturated";g.relics[0].cursed=true
 var retained := 0
 for index in range(1000):
  g.inventory=["venus"];g.use_item(0)
  if not g.inventory.is_empty(): retained+=1
 check(retained>500 and retained<700,"Spare Parts refund probability honors effective power")
 g=game();only(g,["body_double"]);plain(g,2);g.inventory=["goldleaf"]
 # Use the catalog's targeted enhancement spell rather than relying on display text.
 var spell: String = ""
 for id in Cat.SPELLS:
  if Cat.SPELLS[id].action=="gold": spell=id
 if spell!="":
  g.inventory=[spell]
  check(g.use_item(0,0) and g.cells[0].fx.get("gold",false) and g.cells[1].fx.get("gold",false),"Body Double also enchants a matching tile")
 g=game();only(g,["carbon","recycling_bin","ghostwriter","echo"]);g.phase="shop"
 check(g.sell_relic(3) and g.inventory.size()==1 and Cat.RUNES.has(g.inventory[0]) and Rules.actor(g,"ghostwriter").growth.cmp(2)==0,"relic sale resolves Recycling Bin and Ghostwriter once")
 g=game();only(g,["double_exposure"]);g.cells.fill(null);g.cells[0]=g.tile(4,{"gold":true,"steel":true});Rules.after_spawn(g,0)
 check(g.filled()==2 and g.cells.any(func(t): return t!=null and t.e==3 and t.fx.is_empty()),"Double Exposure creates a plain half-value copy")
 g=game();only(g,["guillotine"]);plain(g,5);g.cells[4]=g.tile(10);g.phase="shop";g.f.pending.guillotine=1
 check(g.workshop_action("guillotine") and g.cells[4]==null and is_equal_approx(g.relics[0].growth.to_float(),1.8),"Guillotine sacrifices the highest tile for x1.8 growth")
 g=game();only(g,["chrysalis"]);plain(g)
 check(g.workshop_action("chrysalis",0),"Chrysalis marks an eligible plain tile")
 var marked: Dictionary = g.cells[0]
 for index in range(3):
  var merged: Dictionary = g.tile(int(marked.e)+1)
  Rules.inherit_mark(merged,marked,g.tile(int(marked.e)))
  marked=merged
 check(marked.seal and marked.fx.size()==3 and not marked.has("chrysalis"),"Chrysalis completes after exactly three inherited merges")

func duplicate_checks() -> void:
 var g=game();only(g,["handbrake","carbon","echo"])
 check(use(g,"schism",0) and g.relics.size()==2,"Schism can create duplicate passive relics")
 g.phase="play";g.cells.fill(null);g.cells[1]=g.tile(2);g.moves=10;g.floor_num=10
 g.move("left")
 check(g.moves==11,"each copied Handbrake refunds its own first nonmerge swipe")
 g=game();only(g,["devourer"]);g.relics[0].edition="oversaturated";g.f.pending.devourer=4;g.f.extra_slots=4;g.phase="shop"
 for id in ["carbon","echo","odd","corner"]: g._grant(id)
 for index in range(4): g.workshop_action("devour",1)
 check(use(g,"liberation",0) and g.relics[0].abilities.size()==4,"changing edition retains already inherited abilities")
 roundtrip(g,"Devourer changed edition")

func result_checks() -> void:
 var g=game("classic","cursed");g.gate=2
 var played_target=g.target()
 g.finish_gate(true)
 check(g.f.curse==3 and g.target().cmp(played_target)==0,"Guardian result retains the target actually played")
 check(g.target(2).cmp(played_target)>0,"next attempt preview includes the new Curse")
 roundtrip(g,"Cursed completed target")

func final_power_checks() -> void:
 var g=game();only(g,["domino"]);g.relics[0].edition="oversaturated";plain(g)
 g.cells[4]=g.tile(1);g.cells[5]=g.tile(1);g.cells[8]=g.tile(1);g.cells[9]=g.tile(1)
 var slid=g.slide("left");g.cells=slid.board
 var score=g.score_merges(slid.events,1)
 check(score.entries[2].points.cmp(64)==0 and score.entries[2].triggers==16,"Oversaturated Domino doubles each earlier-merge factor")
 g=game();only(g,["body_double"]);g.relics[0].edition="oversaturated";plain(g,2);g.cells[4]=g.tile(2)
 var spell: String = ""
 for id in Cat.SPELLS:
  if Cat.SPELLS[id].action=="gold": spell=id
 g.inventory=[spell]
 check(spell!="" and g.use_item(0,0) and [0,1,4].all(func(i): return g.cells[i].fx.get("gold",false)),"Oversaturated Body Double affects two extra matching tiles")

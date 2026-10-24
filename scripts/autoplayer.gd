extends RefCounted
## Lookahead uses visible information and its own sampler; it never consumes run RNG.
const Num = preload("res://scripts/num.gd")
const RunRng = preload("res://scripts/run_rng.gd")
const DIRECTIONS = ["down","left","right","up"]

class Sampler:
 var state: int
 func _init(seed_value: int): state=seed_value if seed_value!=0 else 1
 func randf() -> float:
  state=(state^(state<<13))&0xffffffff
  state=(state^(state>>17))&0xffffffff
  state=(state^(state<<5))&0xffffffff
  return float(state)/4294967296.0

static func _copy(g):
 var q = g.get_script().new()
 q.persist_enabled=false
 for key in ["board_id","floor_num","gate","moves","gate_swipes","last_dir","rune_uses","phase","jammed"]: q.set(key,g.get(key))
 q.rune_levels=g.rune_levels
 q.upgrades=g.upgrades
 q.cells=g.cells.duplicate()
 q.relics=g.relics.duplicate(true)
 q.money=g.money
 q.score=g.score
 q.next_tile=g.next_tile
 return q

static func corner(board: Array) -> int:
 var max_e := 0
 for cell in board:
  if cell!=null: max_e=maxi(max_e,int(cell.e))
 for index in [12,15,0,3]:
  if board[index]!=null and board[index].e==max_e: return index
 var pos := 0
 for index in range(16):
  if board[index]!=null and board[index].e==max_e: pos=index; break
 var best := 12
 for index in [12,15,0,3]:
  if _distance(index,pos)<_distance(best,pos): best=index
 return best

static func _distance(a: int, b: int) -> int:
 return absi(a%4-b%4)+absi(int(a/4.0)-int(b/4.0))

static func evaluate(g, anchor: int) -> float:
 var raw: Array = g.cells.map(func(t): return int(t.e) if t!=null else 0)
 var max_e: int = raw.max()
 var scale: float = 16.0/maxf(16,max_e)
 var values: Array = raw.map(func(value): return value*scale)
 var empty: int = raw.count(0)
 var smooth := 0.0
 var mono := 0.0
 var pairs := 0
 for row in range(4):
  for col in range(4):
   var index: int = row*4+col
   if raw[index]==0: continue
   for neighbor in [index+1 if col<3 else -1,index+4 if row<3 else -1]:
    if neighbor>=0 and raw[neighbor]!=0:
     smooth+=absf(values[index]-values[neighbor])
     if raw[index]==raw[neighbor]: pairs+=1
 for line in range(4):
  for indices in [[line*4,line*4+1,line*4+2,line*4+3],[line,line+4,line+8,line+12]]:
   var occupied: Array = []
   for index in indices:
    if values[index]!=0: occupied.append(values[index])
   var up := 0.0
   var down := 0.0
   for k in range(1,occupied.size()):
    var diff: float = occupied[k]-occupied[k-1]
    if diff>0: up+=diff
    else: down-=diff
   mono-=minf(up,down)
 var highest: int = raw.find(max_e)
 var held: float = max_e*scale*20 if raw[anchor]==max_e else 0.0
 var corner_score: float = held-_distance(highest,anchor)*18
 if empty==0 and not g.can_slide(): return -1000000
 return empty*120+pairs*28-smooth*4+mono*16+corner_score

static func preview(g, direction: String, anchor: int) -> Dictionary:
 var slid: Dictionary = g.slide(direction)
 if not slid.changed: return {}
 var q = _copy(g)
 q.cells=slid.board
 q.gate_swipes=g.gate_swipes+1
 q.last_dir=direction
 var cost := 1
 if g.gate==2:
  if g.guardian().id=="repeat" and g.last_dir==direction: cost+=1
  if g.guardian().id=="toll" and q.gate_swipes%4==0: cost+=1
 q.moves=maxi(0,g.moves-cost)
 var scored: Dictionary = q.score_merges(slid.events,g.highest(),true)
 q.score=g.score.plus(scored.score)
 var target = g.target()
 var shape: float = evaluate(q,anchor)
 var terminal = 1000000+shape if q.score.cmp(target)>=0 else -1000000+shape if q.moves<=0 else null
 var remaining = target.minus(g.score)
 var fraction: float = minf(1,pow(10,minf(0,scored.score.log10_value()-remaining.log10_value()))) if scored.score.m>0 else 0.0
 var reward: float = fraction*(1500+1800.0/(g.moves+1))+minf(80,maxf(0,scored.score.log10_value()))*2+minf(20,scored.money.to_float())*2
 return {"g":q,"dir":direction,"order":DIRECTIONS.find(direction),"shape":shape,"reward":reward,"terminal":terminal,"events":slid.events,"value":terminal if terminal!=null else reward+shape}

static func _sort(items: Array, key: String) -> void:
 items.sort_custom(func(a,b): return a[key]>b[key] or (a[key]==b[key] and a.order<b.order))

static func _moves(g, anchor: int) -> Array:
 var moves: Array = []
 for direction in DIRECTIONS:
  var step: Dictionary = preview(g,direction,anchor)
  if not step.is_empty(): moves.append(step)
 _sort(moves,"value")
 return moves

static func _spaces(board: Array) -> Array:
 var empty: Array = []
 for index in range(16):
  if board[index]==null: empty.append(index)
 return empty

static func _place(g, index: int, value: Dictionary):
 var q = _copy(g)
 q.cells[index]=value.duplicate(true)
 return q

static func expected(step: Dictionary, anchor: int) -> float:
 if step.terminal!=null: return float(step.terminal)
 var empty: Array = _spaces(step.g.cells)
 if empty.is_empty(): return -1000000
 var total := 0.0
 var worst := INF
 for index in empty:
  var q = _place(step.g,index,step.g.next_tile)
  var moves: Array = _moves(q,anchor)
  var best: float = moves[0].value if not moves.is_empty() else -1000000.0
  total+=best
  worst=minf(worst,best)
 return step.reward+.88*(.9*total/empty.size()+.1*worst)

static func _sample_tile(g, sampler: Sampler) -> Dictionary:
 var exponent: int = g.spawn_min()+int(sampler.randf()<(.10+.35*(int(g.rune_levels.spawn)%2)))
 if g.has_relic("alchemy") and sampler.randf()<.25: exponent+=1
 var fx := {}
 for key in ["gold","glass","steel"]:
  if sampler.randf()<1.0-pow(.92,g.rune_levels[key]): fx[key]=true
 return g.tile(exponent,fx,sampler.randf()<1.0-pow(.94,g.rune_levels.seal))

static func _shatter(q, events: Array, sampler: Sampler) -> void:
 for event in events:
  if event.tile.fx.get("glass",false) and sampler.randf()<.25 and q.cells[event.index]==event.tile: q.cells[event.index]=null

static func rollout(step: Dictionary, anchor: int, seed_value: int, explore: bool) -> float:
 var sampler := Sampler.new(seed_value)
 var q = _copy(step.g)
 var value: float = step.reward
 _shatter(q,step.events,sampler)
 for depth in range(1,6):
  var empty: Array = _spaces(q.cells)
  if empty.is_empty(): return value-1000000*pow(.96,depth)
  q=_place(q,empty[int(floorf(sampler.randf()*empty.size()))],q.next_tile)
  q.next_tile=_sample_tile(q,sampler)
  var moves: Array = _moves(q,anchor)
  if moves.is_empty(): return value-1000000*pow(.96,depth)
  var chosen: Dictionary = moves[0]
  if explore and moves.size()>1 and moves[0].terminal==null and sampler.randf()<.18: chosen=moves[1]
  if chosen.terminal!=null: return value+pow(.96,depth)*chosen.terminal
  value+=pow(.96,depth)*chosen.reward
  q=chosen.g
  _shatter(q,chosen.events,sampler)
 return value+pow(.96,6)*evaluate(q,anchor)

static func choose(g, advanced: bool = false) -> String:
 if g.phase!="play" or g.jammed: return ""
 var anchor: int = corner(g.cells)
 var moves: Array = _moves(g,anchor)
 if moves.is_empty(): return ""
 var wins: Array = moves.filter(func(step): return step.terminal!=null and step.terminal>0)
 if not wins.is_empty():
  _sort(wins,"terminal")
  return wins[0].dir
 for step in moves: step.search_value=expected(step,anchor)
 _sort(moves,"search_value")
 if not advanced: return moves[0].dir
 var parts: Array = []
 for cell in g.cells:
  if cell==null: parts.append("0")
  else:
   var keys: Array = cell.fx.keys()
   keys.sort()
   parts.append("%d:%d:%s" % [cell.e,int(cell.seal),",".join(keys)])
 var seed_value: int = RunRng.seed_hash("|".join(parts)+"|"+str(g.moves))
 for step in moves:
  if step.terminal!=null:
   step.deep_value=step.terminal
   continue
  var total := 0.0
  var worst := INF
  for index in range(16):
   var value: float = rollout(step,anchor,(seed_value+(index+1)*0x9e3779b9)&RunRng.MASK,index%4==3)
   total+=value
   worst=minf(worst,value)
  step.deep_value=step.search_value*.3+(.9*total/16+.1*worst)*.7
 _sort(moves,"deep_value")
 return moves[0].dir

static func choose_async(g, advanced: bool, tree: SceneTree, cancelled: Callable = Callable()) -> String:
 # The same search as choose(), divided across frames so Stop and menus respond.
 if _is_cancelled(cancelled) or g.phase!="play" or g.jammed: return ""
 var anchor: int = corner(g.cells)
 var moves: Array = _moves(g,anchor)
 if moves.is_empty(): return ""
 var wins: Array = moves.filter(func(step): return step.terminal!=null and step.terminal>0)
 if not wins.is_empty():
  _sort(wins,"terminal")
  return wins[0].dir
 for step in moves:
  if _is_cancelled(cancelled): return ""
  step.search_value=expected(step,anchor)
  await tree.process_frame
  if _is_cancelled(cancelled): return ""
 _sort(moves,"search_value")
 if not advanced: return moves[0].dir
 var parts: Array = []
 for cell in g.cells:
  if cell==null: parts.append("0")
  else:
   var keys: Array = cell.fx.keys()
   keys.sort()
   parts.append("%d:%d:%s" % [cell.e,int(cell.seal),",".join(keys)])
 var seed_value: int = RunRng.seed_hash("|".join(parts)+"|"+str(g.moves))
 for step in moves:
  if step.terminal!=null:
   step.deep_value=step.terminal
   continue
  var total := 0.0
  var worst := INF
  var slice_start: int = Time.get_ticks_msec()
  for index in range(16):
   if _is_cancelled(cancelled): return ""
   var value: float = rollout(step,anchor,(seed_value+(index+1)*0x9e3779b9)&RunRng.MASK,index%4==3)
   total+=value
   worst=minf(worst,value)
   if Time.get_ticks_msec()-slice_start>=6:
    await tree.process_frame
    if _is_cancelled(cancelled): return ""
    slice_start=Time.get_ticks_msec()
  step.deep_value=step.search_value*.3+(.9*total/16+.1*worst)*.7
 _sort(moves,"deep_value")
 return moves[0].dir

static func _is_cancelled(callback: Callable) -> bool:
 return callback.is_valid() and bool(callback.call())

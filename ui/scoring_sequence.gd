extends Node
## Presentation-only clock. The game has already committed and saved the move.
## A receipt represents a mathematical batch, never a command to the model.
const Num = preload("res://scripts/num.gd")
const MAX_STEPS: int = 96
signal step_started(step: Dictionary)
signal finished
var active := false
var cursor := 0
var steps: Array = []
var _wait := 0.0
var _beat := .16
var _ramp := 0.0

func play(receipts: Array, speed: int = 1) -> void:
 cancel()
 if speed>=8 or receipts.is_empty():
  finished.emit()
  return
 var pressure := 1.0
 for receipt in receipts:
  pressure=maxf(pressure,Num.of(receipt.get("activations",1)).log10_value())
 # Small batches get individual beats. Huge batches retain a single receipt,
 # the original row order, their activation count, and the exact bank totals.
 var expanded: Array = []
 for receipt in receipts:
  var count = Num.of(receipt.get("activations",1))
  var operation: String = receipt.get("operation","")
  if receipt.kind=="relic" and operation!="" and count.cmp(1)>0 and count.cmp(4)<=0:
   var value = receipt.before
   var total: int = int(count.to_float())
   for index in range(total):
    var step: Dictionary = receipt.duplicate()
    match operation:
     "add": value=value.plus(receipt.operand)
     "multiply": value=value.times(receipt.operand)
     "power": value=value.raised(receipt.operand)
    step.value=receipt.value if index==total-1 else value
    step.text="%s (%d/%d)" % [receipt.text,index+1,total]
    expanded.append(step)
  else:
   var step: Dictionary = receipt.duplicate()
   if step.kind in ["relic","retrigger"] and count.cmp(1)>0: step.badge_text="x"+count.fmt()
   if step.kind=="relic" and count.cmp(1)>0:
    step.text="%s / %s activations" % [receipt.text,receipt.get("activation_text",count.fmt())]
   expanded.append(step)
 steps=_compress(expanded)
 var weight := 0.0
 for step in steps: weight+=_weight(step)
 var acceleration: float = 1.0+maxf(0.0,pressure-1.0)*.65
 _ramp=minf(.75,maxf(0.0,pressure-1.0)*.15)
 _beat=minf(.16/acceleration,3.2/maxf(1,weight))/maxi(1,speed)
 active=true
 _advance()

func _compress(receipts: Array) -> Array:
 if receipts.size()<=MAX_STEPS: return receipts
 var result: Array = []
 var stride: int = int(ceil(receipts.size()/float(MAX_STEPS)))
 var pending: Array = []
 for receipt in receipts:
  pending.append(receipt)
  # Merge/bank boundaries must remain visible. A compressed group displays
  # its final authoritative subtotal without allocating per-trigger objects.
  if pending.size()>=stride or receipt.kind in ["merge","bank"]:
   var step: Dictionary = receipt.duplicate()
   if pending.size()>1:
    step.text="%s / %d scoring steps" % [step.text,pending.size()]
    if step.kind in ["relic","retrigger"]: step.badge_text="x"+Num.of(step.get("activations",1)).fmt()
   result.append(step)
   pending.clear()
 if not pending.is_empty(): result.append(pending[-1])
 return result

func _process(delta: float) -> void:
 if not active: return
 _wait-=delta
 while active and _wait<=0: _advance()

func _advance() -> void:
 if cursor>=steps.size():
  cancel()
  finished.emit()
  return
 var step: Dictionary = steps[cursor]
 cursor+=1
 # Later beats accelerate gently within the same chain as well.
 var progress: float = (cursor-1)/float(maxi(1,steps.size()-1))
 _wait+=_beat*_weight(step)/(1.0+progress*_ramp)
 step_started.emit(step)

func _weight(step: Dictionary) -> float:
 return 1.4 if step.kind=="bank" else 1.25 if step.kind=="retrigger" else 1.0

func cancel() -> void:
 active=false
 steps=[]
 cursor=0
 _wait=0.0

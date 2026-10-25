extends Node
## Presentation-only clock. The game has already committed and saved the move.
signal step_started(step: Dictionary)
signal finished
var active := false
var cursor := 0
var steps: Array = []
var _wait := 0.0
var _beat := .16

func play(receipts: Array, speed: int = 1) -> void:
 cancel()
 if speed>=8 or receipts.is_empty():
  finished.emit()
  return
 steps=receipts.duplicate(true)
 # Large engines accelerate as a group instead of stalling each swipe.
 var weight := 0.0
 for step in steps: weight+=_weight(step)
 _beat=minf(.16,3.2/maxf(1,weight))/maxi(1,speed)
 active=true
 _advance()

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
 _wait+=_beat*_weight(step)
 step_started.emit(step)

func _weight(step: Dictionary) -> float:
 return 1.4 if step.kind=="bank" else 1.25 if step.kind=="retrigger" else 1.0

func cancel() -> void:
 active=false
 steps=[]
 cursor=0
 _wait=0.0

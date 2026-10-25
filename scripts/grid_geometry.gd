extends RefCounted
static func lines(direction: String, blocked: int = -1) -> Array:
 var segments: Array = []
 for line in range(4):
  var positions: Array = []
  for p in range(4):
   var index: int = line*4+p if direction=="left" else line*4+3-p if direction=="right" else p*4+line if direction=="up" else (3-p)*4+line
   if index==blocked:
    if not positions.is_empty(): segments.append(positions)
    positions=[]
   else: positions.append(index)
  if not positions.is_empty(): segments.append(positions)
 return segments

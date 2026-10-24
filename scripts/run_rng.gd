extends RefCounted
## Mulberry32 and FNV-1a from the HTML build. No engine-specific random sequence.
var state: int = 1
const MASK = 0xffffffff

static func seed_hash(text: String) -> int:
 var h: int = 2166136261
 for character in text:
  var code: int = character.unicode_at(0)
  if code > 0xffff: code = 0xd800 + ((code-0x10000) >> 10)
  h = ((h ^ code) * 16777619) & MASK
 return h if h != 0 else 1

func randomize() -> void:
 state = seed_hash(str(Time.get_unix_time_from_system())+str(Time.get_ticks_usec()))

func randf() -> float:
 state = (state + 0x6d2b79f5) & MASK
 var t: int = state
 t = ((t ^ (t >> 15)) * (t | 1)) & MASK
 t = (t ^ ((t + (((t ^ (t >> 7)) * (t | 61)) & MASK)) & MASK)) & MASK
 return float((t ^ (t >> 14)) & MASK) / 4294967296.0

func pick(items: Array):
 # JS pick advances the generator even for an empty pool.
 var value: float = self.randf()
 return items[int(floorf(value*items.size()))] if not items.is_empty() else null

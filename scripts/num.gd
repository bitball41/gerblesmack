extends RefCounted
## Non-negative scientific arithmetic, matching the original HTML game's Num.
## Values stay finite past float overflow; only the mantissa uses a float.
var m: float = 0.0
var e: float = 0.0

func _init(mantissa: float = 0.0, exponent: float = 0.0) -> void:
 m = mantissa
 e = exponent
 _normalize()

func _normalize() -> void:
 assert(is_finite(m) and is_finite(e), "Invalid scientific arithmetic")
 if m <= 0.0:
  m = 0.0
  e = 0.0
  return
 var shift: float = floorf(log(m) / log(10.0))
 m /= pow(10.0, shift)
 e += shift
 if m >= 9.999999999999998:
  m = 1.0
  e += 1.0

static func of(value):
 var Script = load("res://scripts/num.gd")
 if value is RefCounted and value.get_script() == Script: return value
 if value is Dictionary:
  if value.has("__num"): return Script.new(float(value.__num[0]), float(value.__num[1]))
  if value.has("m"): return Script.new(float(value.m), float(value.get("e",0)))
 return Script.new(float(value) if value != null else 0.0)

static func power(base: float, exponent: float):
 var Script = load("res://scripts/num.gd")
 if base == 0.0: return Script.new()
 var value_log: float = log(base) / log(10.0) * exponent
 var exp_part: float = floorf(value_log)
 return Script.new(pow(10.0, value_log - exp_part), exp_part)

func plus(value):
 var b = of(value)
 var Script = get_script()
 if m == 0.0: return Script.new(b.m, b.e)
 if b.m == 0.0: return Script.new(m, e)
 var exp_part: float = maxf(e, b.e)
 return Script.new(m * pow(10.0, e-exp_part) + b.m * pow(10.0, b.e-exp_part), exp_part)

func minus(value):
 var b = of(value)
 if cmp(b) <= 0: return get_script().new()
 return get_script().new(m - b.m * pow(10.0, b.e-e), e)

func times(value):
 var b = of(value)
 return get_script().new(m*b.m, e+b.e)

func div(value):
 var b = of(value)
 assert(b.m != 0.0, "Division by zero")
 return get_script().new(m/b.m, e-b.e)

func cmp(value) -> int:
 var b = of(value)
 if m == 0.0 or b.m == 0.0: return int(signf(m-b.m))
 if e != b.e: return int(signf(e-b.e))
 return 0 if absf(m-b.m)<1e-12 else int(signf(m-b.m))

func floored():
 if e < 14: return get_script().new(floorf(to_float()+1e-9))
 return get_script().new(m,e)

func log10_value() -> float:
 return log(m)/log(10.0)+e if m > 0.0 else -INF

func to_float() -> float:
 return m * pow(10.0,e)

func fmt() -> String:
 if m == 0.0: return "0"
 if e < 6: return str(int(roundf(to_float())))
 var mantissa: float = snappedf(m,0.01)
 var exponent: float = e
 if mantissa >= 10.0:
  mantissa = 1.0
  exponent += 1.0
 return "%se%s" % [str(mantissa),str(int(exponent)) if absf(exponent)<9e18 else str(exponent)]

func encode() -> Dictionary:
 return {"__num":[m,e]}

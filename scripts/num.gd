extends RefCounted
## Non-negative scientific arithmetic. Ordinary values retain the original m/e
## encoding. Layered exponents keep repeated powers finite beyond 10^(1e308).
## layer=1 means 10^(10^e); each additional layer adds another outer 10^.
const LAYER_LIMIT: float = 1e15
var m: float = 0.0
var e: float = 0.0
var layer: int = 0

func _init(mantissa: float = 0.0, exponent: float = 0.0, exponent_layer: int = 0) -> void:
 m = mantissa
 e = exponent
 layer = exponent_layer
 _normalize()

func _normalize() -> void:
 assert(is_finite(m) and is_finite(e) and layer>=0, "Invalid scientific arithmetic")
 if m <= 0.0:
  m=0.0; e=0.0; layer=0
  return
 if layer>0:
  m=1.0
  while e<15.0 and layer>0:
   e=pow(10.0,e)
   layer-=1
  while e>=LAYER_LIMIT:
   e=log(e)/log(10.0)
   layer+=1
  return
 var shift: float = floorf(log(m) / log(10.0))
 m /= pow(10.0,shift)
 e += shift
 if m >= 9.999999999999998:
  m=1.0; e+=1.0
 if e>=LAYER_LIMIT:
  e=log(e)/log(10.0); m=1.0; layer=1

static func of(value):
 var Script = load("res://scripts/num.gd")
 if value is RefCounted and value.get_script()==Script: return value
 if value is Dictionary:
  if value.has("__num"):
   var data: Array = value.__num
   return Script.new(float(data[0]),float(data[1]),int(data[2]) if data.size()==3 else 0)
  if value.has("m"): return Script.new(float(value.m),float(value.get("e",0)),int(value.get("layer",0)))
 return Script.new(float(value) if value!=null else 0.0)

func copy():
 return get_script().new(m,e,layer)

static func power(base: float, exponent):
 return of(base).raised(exponent)

static func from_log10(value):
 var n = of(value)
 var Script = load("res://scripts/num.gd")
 if n.layer>0: return Script.new(1,n.e,n.layer+1)
 if n.e>=15: return Script.new(1,n.log10_value(),1)
 var logarithm: float = n.to_float()
 var exp_part: float = floorf(logarithm)
 return Script.new(pow(10.0,logarithm-exp_part),exp_part)

func raised(exponent):
 if (exponent is int or exponent is float) and exponent<0:
  return get_script().new(1).div(raised(-float(exponent)))
 var n = of(exponent)
 if n.m==0.0: return get_script().new(1)
 if m==0.0: return get_script().new()
 if n.layer==0 and n.e<10:
  var ordinary: float = n.to_float()
  if ordinary==floorf(ordinary):
   # Integer powers avoid logarithmic rounding near exact scoring integers.
   var remaining: int = int(ordinary)
   var result = get_script().new(1)
   var base = copy()
   while remaining>0:
    if remaining%2==1: result=result.times(base)
    remaining=remaining/2
    if remaining>0: base=base.times(base)
   return result
 if layer==0 and cmp(1)<0:
  # Only ordinary fractional bases need a signed logarithm.
  var logarithm: float = log10_value()*n.to_float()
  if not is_finite(logarithm): return get_script().new()
  var whole: float = floorf(logarithm)
  return get_script().new(pow(10.0,logarithm-whole),whole)
 return from_log10(log10_num().times(n))

func plus(value):
 var b = of(value)
 if m==0.0: return b.copy()
 if b.m==0.0: return copy()
 if layer>0 or b.layer>0:
  # At this scale, a factor of two is below mantissa precision.
  return copy() if cmp(b)>=0 else b.copy()
 var exp_part: float = maxf(e,b.e)
 return get_script().new(m*pow(10.0,e-exp_part)+b.m*pow(10.0,b.e-exp_part),exp_part)

func minus(value):
 var b = of(value)
 if cmp(b)<=0: return get_script().new()
 if layer>0 or b.layer>0: return copy()
 return get_script().new(m-b.m*pow(10.0,b.e-e),e)

func times(value):
 var b = of(value)
 if m==0.0 or b.m==0.0: return get_script().new()
 if layer==0 and b.layer==0: return get_script().new(m*b.m,e+b.e)
 return from_log10(log10_num().plus(b.log10_num()))

func div(value):
 var b = of(value)
 assert(b.m!=0.0,"Division by zero")
 if layer==0 and b.layer==0: return get_script().new(m/b.m,e-b.e)
 var comparison: int = cmp(b)
 if comparison==0: return get_script().new(1)
 if comparison<0: return get_script().new()
 return from_log10(log10_num().minus(b.log10_num()))

func cmp(value) -> int:
 var b = of(value)
 if m==0.0 or b.m==0.0: return int(signf(m-b.m))
 if layer!=b.layer: return int(signi(layer-b.layer))
 if layer>0 and absf(e-b.e)<=1e-12*maxf(1.0,absf(e)): return 0
 if e!=b.e: return int(signf(e-b.e))
 return 0 if absf(m-b.m)<1e-12 else int(signf(m-b.m))

func floored():
 if layer==0 and e<14:
  var value: float = to_float()
  var nearest: float = roundf(value)
  # Undo a few float ULPs of drift at integer boundaries before flooring.
  if absf(value-nearest)<=maxf(1e-9,absf(value)*2e-15): value=nearest
  return get_script().new(floorf(value))
 return copy()

func log10_num():
 if layer==0: return of(log10_value())
 if layer==1: return power(10.0,e)
 return get_script().new(1,e,layer-1)

func log10_value() -> float:
 if layer>0: return INF
 return log(m)/log(10.0)+e if m>0.0 else -INF

func to_float() -> float:
 return INF if layer>0 else m*pow(10.0,e)

func ratio_to(value) -> float:
 var b = of(value)
 if m==0.0: return 0.0
 if cmp(b)>=0: return 1.0
 if layer>0 or b.layer>0: return 0.0
 return clampf(pow(10.0,log10_value()-b.log10_value()),0.0,1.0)

## Display precision only: stored mantissas/exponents are never rounded here.
func fmt(significant_digits: int = 6) -> String:
 var digits: int = clampi(significant_digits,3,10)
 if m==0.0: return "0"
 if layer>=4: return "e^%d %s" % [layer+1,of(e).fmt(digits)]
 if layer>0: return "1e"+log10_num().fmt(digits)
 if e<6: return str(int(roundf(to_float())))
 var places: int = digits-1
 var mantissa: float = snappedf(m,pow(10.0,-places))
 var exponent: float = e
 if mantissa>=10.0: mantissa=1.0; exponent+=1.0
 var power_text: String = of(exponent).fmt(digits) if exponent>=1e6 else str(int(exponent))
 return _decimal(mantissa,places)+"e"+power_text

func explain(significant_digits: int = 6) -> String:
 if m==0.0 or (layer==0 and e<6): return fmt(significant_digits)
 if layer>=4: return "Repeated powers of ten / height %d" % (layer+1)
 if layer>0: return "10^("+log10_num().explain(significant_digits)+")" if layer>1 else "10^("+log10_num().fmt(significant_digits)+")"
 return _decimal(m,clampi(significant_digits-1,2,9))+" x 10^("+of(e).fmt(significant_digits)+")"

static func _decimal(value: float, places: int) -> String:
 var pattern: String = "%.$pf".replace("$p",str(places))
 var result: String = pattern % value
 if "." in result:
  while result.ends_with("0"): result=result.left(-1)
  result=result.trim_suffix(".")
 return result

func encode() -> Dictionary:
 return {"__num":[m,e,layer]} if layer>0 else {"__num":[m,e]}

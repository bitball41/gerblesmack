extends RefCounted
## Exact non-negative counters. Scoring never loops once per trigger or wraps
## a 64-bit int; conversion to Num happens only for score arithmetic/display.
const Num = preload("res://scripts/num.gd")
const BASE: int = 1000000
var digits: Array[int] = []

func _init(value: int = 0) -> void:
 while value>0:
  digits.append(value%BASE)
  value=value/BASE

func copy():
 var result = get_script().new()
 result.digits.assign(digits)
 return result

func plus(value):
 var result = copy()
 var carry: int = 0
 for index in range(maxi(digits.size(),value.digits.size())):
  if index>=result.digits.size(): result.digits.append(0)
  var sum: int = result.digits[index]+(value.digits[index] if index<value.digits.size() else 0)+carry
  result.digits[index]=sum%BASE
  carry=sum/BASE
 if carry>0: result.digits.append(carry)
 return result

func times(factor: int):
 var result = get_script().new()
 var carry: int = 0
 for digit in digits:
  var product: int = digit*factor+carry
  result.digits.append(product%BASE)
  carry=product/BASE
 while carry>0:
  result.digits.append(carry%BASE)
  carry=carry/BASE
 result._trim()
 return result

func div_small(divisor: int):
 var result = copy()
 var remainder: int = 0
 for index in range(digits.size()-1,-1,-1):
  var part: int = remainder*BASE+digits[index]
  result.digits[index]=part/divisor
  remainder=part%divisor
 result._trim()
 return result

func mod_small(divisor: int) -> int:
 var remainder: int = 0
 for index in range(digits.size()-1,-1,-1): remainder=(remainder*BASE+digits[index])%divisor
 return remainder

func minus_one():
 var result = copy()
 for index in range(result.digits.size()):
  if result.digits[index]>0:
   result.digits[index]-=1
   break
  result.digits[index]=BASE-1
 result._trim()
 return result

func _trim() -> void:
 while not digits.is_empty() and digits[-1]==0: digits.pop_back()

func number():
 var value = Num.new()
 for index in range(digits.size()-1,-1,-1): value=value.times(BASE).plus(digits[index])
 return value

func scalar():
 if digits.size()<4:
  var value: int = 0
  for index in range(digits.size()-1,-1,-1): value=value*BASE+digits[index]
  return value
 return number()

func text() -> String:
 return str(scalar()) if digits.size()<4 else number().fmt()

extends RefCounted
const Cat = preload("res://scripts/catalog.gd")
const Num = preload("res://scripts/num.gd")
const Rules = preload("res://scripts/fracture_rules.gd")

static func tags_for(game, id: String) -> Dictionary:
 if game.f.pack_tags.has(id) and game.pack_choices.has(id): return game.f.pack_tags[id]
 return game.f.offer_tags.get(id,{})

static func roll_tags(game) -> Dictionary:
 var tags: Dictionary = {}
 var edition: float = game.rng.randf()
 if edition<.02: tags.edition="unbound"
 elif edition<.05: tags.edition="oversaturated"
 if game.f.difficulty=="cursed" and game.rng.randf()<.3: tags.cursed=true
 return tags

static func tag_offers(game) -> void:
 var old: Dictionary = game.f.offer_tags
 game.f.offer_tags={}
 for id in game.shop_offers:
  if Cat.RELICS.has(id): game.f.offer_tags[id]=old[id] if old.has(id) else roll_tags(game)
 var locked: String = game.f.locked_offer
 if locked!="" and not game.has_relic(locked) and not game.shop_offers.has(locked): game.shop_offers[0]=locked
 if game.f.stowed.has("id"):
  game.f.stowed={game.f.stowed.id:game.f.stowed.get("tags",{})}
 var carried: Dictionary = game.f.stowed.duplicate(true)
 for id in carried:
  if game.has_relic(id): game.f.stowed.erase(id)
  else:
   if not game.shop_offers.has(id): game.shop_offers.append(id)
   game.f.offer_tags[id]=carried[id]

 if locked!="" and Cat.RELICS.has(locked): game.f.offer_tags[locked]=old.get(locked,{})

static func make_packs(game) -> void:
 game.f.pack_offers=[]
 for slot in range(2):
  var type: String = game.rng.pick(Cat.PACKS.keys())
  var size_roll: float = game.rng.randf()
  var size: String = "Standard" if size_roll<.6 else "Jumbo" if size_roll<.88 else "Mega"
  game.f.pack_offers.append({"type":type,"size":size,"bought":false})

static func pack_cost(game, slot: int) -> int:
 if game.b().get("free_packs",false): return 0
 if slot<0 or slot>=game.f.pack_offers.size(): return 0
 return game.price({"Standard":5,"Jumbo":8,"Mega":10}[game.f.pack_offers[slot].size])

static func pool(game, type: String) -> Array:
 match type:
  "reliquary": return game._eligible_relics()
  "grimoire": return Cat.SPELLS.keys()
  "sigil": return Cat.RUNES.keys()
  "fracture": return Cat.FRACTURES.keys()
 return game._eligible_relics()+Cat.SPELLS.keys()+Cat.RUNES.keys()

static func draw_fracture(game, choices: Array) -> String:
 if choices.has("sovereign") and game.rng.randf()<.03: return "sovereign"
 var normal: Array = choices.filter(func(id): return id!="sovereign")
 return str(game.rng.pick(normal if not normal.is_empty() else choices))

static func draw_item(game, choices: Array) -> String:
 var relics: Array = choices.filter(func(id): return Cat.RELICS.has(id))
 var consumables: Array = choices.filter(func(id): return not Cat.RELICS.has(id))
 if relics.is_empty(): return str(game.rng.pick(consumables))
 if not consumables.is_empty() and game.rng.randf()>=float(relics.size())/choices.size(): return str(game.rng.pick(consumables))
 var roll: float = game.rng.randf()
 var rarity: String = "Legendary" if roll<.01 else "Rare" if roll<.13 else "Uncommon" if roll<.45 else "Common"
 var eligible: Array = relics.filter(func(id): return Cat.RELICS[id].rarity==rarity)
 return str(game.rng.pick(eligible if not eligible.is_empty() else relics))

static func open_pack(game, slot: int = 0) -> bool:
 if game.phase!="shop" or not game.pack_choices.is_empty() or slot<0 or slot>=game.f.pack_offers.size(): return false
 var offer: Dictionary = game.f.pack_offers[slot]
 var cost: int = pack_cost(game,slot)
 var available: Array = pool(game,offer.type).filter(func(id): return pack_item_fits(game,id))
 if offer.bought or available.is_empty() or game.money.cmp(cost)<0: return false
 game.money=game.money.minus(cost)
 offer.bought=true
 game.shop_pack_bought=game.f.pack_offers.all(func(p): return p.bought)
 game.f.pack_type=offer.type
 game.f.pack_size=offer.size
 game.f.pack_remaining=2 if offer.size=="Mega" else 1
 game.f.pack_tags={}
 game.pack_choices=[]
 var count: int = 3 if offer.size=="Standard" else 5
 while game.pack_choices.size()<count and not available.is_empty():
  var id: String = draw_fracture(game,available) if offer.type=="fracture" else draw_item(game,available)
  game.pack_choices.append(id)
  available.erase(id)
  if Cat.RELICS.has(id): game.f.pack_tags[id]=roll_tags(game)
 if game.has_relic("pandora") and offer.type=="standard" and not game.f.floor.get("pandora",false):
  game.f.floor.pandora=true
  game.f.floor.pandora_bonus=int(ceil(Rules.amount(game,"pandora")))
 game.save_run()
 return true

static func choose_pack(game, id: String) -> bool:
 if game.phase!="shop" or not game.pack_choices.has(id) or not game._grant(id,game.f.pack_tags.get(id,{})): return false
 game.pack_choices.erase(id)
 game.f.pack_remaining=maxi(0,int(game.f.pack_remaining)-1)
 if game.f.pack_remaining==0 or game.pack_choices.is_empty():
  game.pack_choices=[]
  var bonus_count: int = int(game.f.floor.get("pandora_bonus",0))
  game.f.floor.pandora_bonus=0
  for count in range(bonus_count):
   var available: Array = pool(game,"standard").filter(func(item): return game.can_grant(item))
   if not available.is_empty():
    var bonus: String = draw_item(game,available)
    game._grant(bonus,roll_tags(game) if Cat.RELICS.has(bonus) else {})
    game.f.notice="Pandora's Box / "+Cat.name_for(bonus)
 game.save_run()
 return true

static func skip_pack(game) -> void:
 game.pack_choices=[]
 game.f.pack_remaining=0
 game.f.floor.pandora_bonus=false
 game.save_run()

static func item_id(game, index: int, source: String = "pocket") -> String:
 if source=="phantom":
  return str(game.f.phantoms[index].id) if index>=0 and index<game.f.phantoms.size() else ""
 return str(game.inventory[index]) if index>=0 and index<game.inventory.size() else ""

static func item_tags(game, index: int, source: String = "pocket") -> Dictionary:
 if source=="phantom": return game.f.phantoms[index].get("tags",{}) if index>=0 and index<game.f.phantoms.size() else {}
 return game.f.item_tags.get(str(index),{})

static func remove_item(game, index: int, source: String = "pocket") -> void:
 if source=="phantom":
  game.f.phantoms.remove_at(index)
  return
 game.inventory.remove_at(index)
 var tags: Dictionary = {}
 for key in game.f.item_tags:
  var position: int = int(key)
  if position!=index: tags[str(position-1 if position>index else position)]=game.f.item_tags[key]
 game.f.item_tags=tags

static func add_item(game, id: String, tags: Dictionary = {}) -> bool:
 if game.inventory.size()>=game.max_pocket(): return false
 game.inventory.append(id)
 if not tags.is_empty(): game.f.item_tags[str(game.inventory.size()-1)]=tags.duplicate(true)
 return true

static func put_in_reserve(game, index: int) -> bool:
 if not game.has_upgrade("satchel2") or game.f.reserve.size()>=2 or item_id(game,index)=="": return false
 game.f.reserve.append({"id":item_id(game,index),"tags":item_tags(game,index).duplicate(true)})
 remove_item(game,index)
 game.save_run()
 return true

static func take_from_reserve(game, index: int) -> bool:
 if index<0 or index>=game.f.reserve.size() or game.inventory.size()>=game.max_pocket(): return false
 var held: Dictionary = game.f.reserve[index]
 add_item(game,held.id,held.tags)
 game.f.reserve.remove_at(index)
 game.save_run()
 return true

static func lock_offer(game, id: String) -> bool:
 if game.phase!="shop" or not game.has_upgrade("storefront2") or not game.shop_offers.has(id): return false
 game.f.locked_offer="" if game.f.locked_offer==id else id
 game.save_run()
 return true

static func stow_offer(game, id: String) -> bool:
 if game.phase!="shop" or not game.has_relic("stowaway") or not game.shop_offers.has(id): return false
 if game.f.stowed.has("id"): game.f.stowed={game.f.stowed.id:game.f.stowed.get("tags",{})}
 if game.f.stowed.has(id): game.f.stowed.erase(id)
 else:
  var limit: int = maxi(1,int(ceil(Rules.amount(game,"stowaway"))))
  if game.f.stowed.size()>=limit: game.f.stowed.erase(game.f.stowed.keys()[0])
  game.f.stowed[id]=tags_for(game,id).duplicate(true)
 game.save_run()
 return true

static func has_pack_room(game, slot: int) -> bool:
 if slot<0 or slot>=game.f.pack_offers.size(): return false
 var offer: Dictionary = game.f.pack_offers[slot]
 if offer.bought: return false
 return pool(game,offer.type).any(func(id): return pack_item_fits(game,id))

static func pack_item_fits(game, id: String) -> bool:
 if Cat.RELICS.has(id): return not game.has_relic(id) and game.Rules.bound_count(game)<game.max_relics()
 return game.inventory.size()<game.max_pocket()

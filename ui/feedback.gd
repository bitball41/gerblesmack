extends Node2D
const UIStyle = preload("res://ui/skin.gd")
const Cat = preload("res://scripts/catalog.gd")
const CARD_SCENE: PackedScene = preload("res://scenes/ui/card.tscn")
@export var sound_enabled := true
@export var motion_enabled := true
var _players: Array[AudioStreamPlayer] = []
var _sounds: Dictionary = {}
var _particles: Array = []
var _player_cursor := 0
var _visual_rng := RandomNumberGenerator.new()

func _ready() -> void:
 _visual_rng.randomize()
 for index in range(8):
  var player := AudioStreamPlayer.new()
  player.volume_db=-14
  add_child(player)
  _players.append(player)

func play(event: String, tier: int = 0) -> void:
 if not sound_enabled or _players.is_empty(): return
 var key: String = event+str(clampi(tier,0,5)) if event=="merge" else event
 if not _sounds.has(key): _sounds[key]=_synthesize(event,tier)
 var player: AudioStreamPlayer = _players[_player_cursor%_players.size()]
 _player_cursor+=1
 player.stream=_sounds[key]
 player.pitch_scale=_visual_rng.randf_range(.98,1.02)
 player.play()

func _synthesize(event: String, tier: int) -> AudioStreamWAV:
 var duration: float = .07
 var frequencies: Array = [360.0]
 var volume: float = .3
 match event:
  "merge":
   duration=.16
   frequencies=[[261.63,293.66,329.63,392.0,440.0,523.25][clampi(tier,0,5)]]
   volume=.5
  "win": duration=.6; frequencies=[392.0,493.88,587.33]; volume=.36
  "fail": duration=.32; frequencies=[146.83,155.56]; volume=.32
  "buy": duration=.22; frequencies=[783.99,1046.5]; volume=.27
  "coin": duration=.036; frequencies=[1318.5]; volume=.1
  "cash": duration=.3; frequencies=[659.25,880.0,1318.5]; volume=.28
  "select": duration=.065; frequencies=[440.0,659.25]; volume=.17
  "shuffle": duration=.15; frequencies=[196.0,293.66]; volume=.22
  "pack": duration=.26; frequencies=[329.63,493.88,659.25]; volume=.28
  "start": duration=.38; frequencies=[261.63,392.0,523.25]; volume=.26
  "hover": duration=.025; frequencies=[500.0]; volume=.08
  "slide": duration=.045; frequencies=[180.0,250.0]; volume=.16
 var pcm := PackedByteArray()
 var samples: int = int(duration*22050)
 pcm.resize(samples*2)
 for index in range(samples):
  var t: float = float(index)/22050.0
  var envelope: float = minf(1,t*500)*exp(-t*(8 if event=="win" else 22))
  var value := 0.0
  if event in ["buy","cash","pack","start"]:
   var step: int = mini(frequencies.size()-1,int(t/duration*frequencies.size()))
   value=sin(TAU*float(frequencies[step])*t)
  else:
   for frequency in frequencies: value+=sin(TAU*float(frequency)*t)
   value/=frequencies.size()
  # Soft square oscillator and a four-bit amplitude ladder make a short chip voice.
  value=snappedf(value*.6+signf(value)*.22,.125)*volume*envelope
  var sample: int = clampi(int(value*23000),-32768,32767)
  pcm[index*2]=sample&255
  pcm[index*2+1]=(sample>>8)&255
 var stream := AudioStreamWAV.new()
 stream.format=AudioStreamWAV.FORMAT_16_BITS
 stream.mix_rate=22050
 stream.data=pcm
 return stream

func number_popup(at: Vector2, text: String, color: Color = UIStyle.GOLD, large: bool = false) -> void:
 if not motion_enabled: return
 var label: Label = UIStyle.label(text,37 if large else 27,color,true)
 label.position=at-Vector2(40,22)
 label.z_index=20
 label.add_theme_color_override("font_shadow_color",Color("09222a"))
 label.add_theme_constant_override("shadow_offset_y",3)
 add_child(label)
 label.set_meta("transient",true)
 label.pivot_offset=Vector2(40,20)
 label.scale=Vector2(1.15,1.15)
 var tween: Tween = label.create_tween().set_parallel(true)
 tween.tween_property(label,"position:y",label.position.y-48,.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 tween.tween_property(label,"scale",Vector2.ONE,.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
 tween.tween_property(label,"modulate:a",0.0,.3).set_delay(.35)
 tween.chain().tween_callback(label.queue_free)

func burst(at: Vector2, color: Color, count: int = 12) -> void:
 if not motion_enabled: return
 for index in range(count):
  var angle: float = _visual_rng.randf_range(-PI,0)
  var velocity: Vector2 = Vector2(cos(angle),sin(angle))*_visual_rng.randf_range(75,180)
  _particles.append({"pos":at,"vel":velocity,"life":.65,"max_life":.65,"color":color.lightened(_visual_rng.randf_range(0,.3)),"size":_visual_rng.randf_range(2,5)})

func _process(delta: float) -> void:
 if _particles.is_empty(): return
 for particle in _particles:
  particle.life-=delta
  particle.pos+=particle.vel*delta
  particle.vel.y+=280*delta
 _particles=_particles.filter(func(p): return p.life>0)
 queue_redraw()

func _draw() -> void:
 for particle in _particles:
  var color: Color = particle.color
  color.a=clampf(particle.life/particle.max_life,0,1)
  draw_rect(Rect2(Vector2(particle.pos).snapped(Vector2(2,2)),Vector2(4,4)),color)

func coin_stream(from: Vector2, to: Vector2, count: int = 6) -> void:
 if not motion_enabled: return
 for index in range(clampi(count,0,10)):
  var coin: TextureRect = UIStyle.texture("coin")
  coin.set_meta("transient",true)
  coin.size=Vector2(22,22)
  coin.position=from-Vector2(11,11)
  add_child(coin)
  var midpoint: Vector2 = (from+to)*.5+Vector2(_visual_rng.randf_range(-25,25),-65-index*7)
  var flight: Tween = coin.create_tween()
  flight.tween_interval(index*.035)
  flight.tween_property(coin,"position",midpoint,.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
  flight.tween_property(coin,"position",to-Vector2(11,11),.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
  flight.tween_callback(coin.queue_free)

func acquire_card(id: String, source: Rect2, destination: Rect2, receiver: Control = null) -> void:
 if not motion_enabled: return
 var ghost: Control
 if Cat.UPGRADES.has(id):
  ghost=UIStyle.texture(Cat.UPGRADES[id].art)
 else:
  var card: Control = CARD_SCENE.instantiate()
  card.item_id=id
  card.motion_enabled=false
  card.custom_minimum_size=Vector2.ZERO
  ghost=card
 ghost.set_meta("transient",true)
 add_child(ghost)
 ghost.mouse_filter=Control.MOUSE_FILTER_IGNORE
 ghost.focus_mode=Control.FOCUS_NONE
 ghost.position=source.position
 ghost.size=source.size
 if is_instance_valid(receiver):
  receiver.modulate.a=0.0
  var receiver_weak: WeakRef = weakref(receiver)
  ghost.tree_exiting.connect(func():
   var current: Control = receiver_weak.get_ref() as Control
   if is_instance_valid(current): current.modulate.a=1.0
  )
 var midpoint: Vector2 = (source.position+destination.position)*.5-Vector2(0,70)
 var flight: Tween = ghost.create_tween()
 flight.set_parallel(true)
 flight.tween_property(ghost,"position",midpoint,.17).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 flight.tween_property(ghost,"self_modulate",Color(1.3,1.18,.9),.1)
 flight.chain().set_parallel(true)
 flight.tween_property(ghost,"position",destination.position,.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
 flight.tween_property(ghost,"size",destination.size,.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
 flight.tween_property(ghost,"self_modulate",Color.WHITE,.22)
 flight.chain().tween_callback(func(): burst(destination.get_center(),UIStyle.GOLD,8); ghost.queue_free())
 number_popup(source.get_center(),"BOUGHT",UIStyle.CREAM)

func banner(title: String, subtitle: String) -> void:
 if not motion_enabled: return
 var panel: PanelContainer = UIStyle.panel(Color("1c303b"),UIStyle.GOLD,8)
 panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
 panel.set_meta("transient",true)
 panel.position=Vector2(440,251)
 panel.size=Vector2(510,68)
 var column: VBoxContainer = UIStyle.column(4)
 panel.add_child(column)
 var heading: Label = UIStyle.label(title,12,UIStyle.GOLD,true)
 heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 column.add_child(heading)
 var sub: Label = UIStyle.label(subtitle,24,UIStyle.CREAM,true)
 sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 column.add_child(sub)
 add_child(panel)
 panel.modulate.a=0.0
 var tween: Tween = panel.create_tween()
 tween.tween_property(panel,"modulate:a",1.0,.12)
 tween.tween_interval(.8)
 tween.tween_property(panel,"modulate:a",0.0,.15)
 tween.tween_callback(panel.queue_free)

func clear_transients(stop_sounds: bool = false) -> void:
 if stop_sounds: stop_audio()
 _particles.clear()
 queue_redraw()
 for child in get_children():
  if child.has_meta("transient"): child.queue_free()

func stop_audio() -> void:
 for player in _players:
  if is_instance_valid(player):
   player.stop()
   player.stream=null

func _exit_tree() -> void:
 sound_enabled=false
 stop_audio()
 _sounds.clear()

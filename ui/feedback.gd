extends Node2D
const UIStyle = preload("res://ui/skin.gd")
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
  "hover": duration=.025; frequencies=[500.0]; volume=.08
  "slide": duration=.045; frequencies=[180.0,250.0]; volume=.16
 var pcm := PackedByteArray()
 var samples: int = int(duration*22050)
 pcm.resize(samples*2)
 for index in range(samples):
  var t: float = float(index)/22050.0
  var envelope: float = minf(1,t*500)*exp(-t*(8 if event=="win" else 22))
  var value := 0.0
  for frequency in frequencies:
   value+=sin(TAU*float(frequency)*t)+.20*sin(TAU*float(frequency)*2*t)
  value=value/frequencies.size()*volume*envelope
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
 label.pivot_offset=Vector2(40,20)
 label.scale=Vector2(1.15,1.15)
 var tween: Tween = create_tween().set_parallel(true)
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
  draw_rect(Rect2(particle.pos,Vector2(particle.size,particle.size)),color)

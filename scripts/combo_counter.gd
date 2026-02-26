extends Control

@onready var text: Label = $Text
@onready var fire: AnimatedSprite2D = $Fire
@onready var timer: Timer = $Timer
## the magnitude of the scale at a time
@export var bounce_size : Curve = Curve.new()
## how long the bounce animation will last
@export var lifetime : float = 0.3
var _bounce_call_count : int
var og_scale : Vector2
var fire_og_scale: Vector2

var combo: int = 0

func _ready() -> void:
	og_scale = text.scale
	fire.play()
	fire_og_scale = fire.scale
	combo_reset()
	timer.timeout.connect(combo_reset)
	

func _process(_delta: float) -> void:
	text.text = "x%02d" % combo

func combo_inc():
	combo += 1
	fire.scale = fire_og_scale * min(floor(combo/10)/5.0, 1)
	timer.start()
	bounce()
	
func combo_reset():
	combo += 0
	fire.scale = fire_og_scale


func bounce():
	var time = 0
	
	_bounce_call_count += 1
	var cur_bounce_id = _bounce_call_count
	while(time < lifetime):
		text.scale = og_scale * bounce_size.sample(time / lifetime)
		await get_tree().process_frame
		if (cur_bounce_id != _bounce_call_count): break
		time += get_process_delta_time()
	_bounce_call_count -= 1

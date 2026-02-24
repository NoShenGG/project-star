extends Control

## the magnitude of the scale at a time
@export var bounce_size : Curve = Curve.new()
## how long the bounce animation will last
@export var lifetime : float = 1
var _bounce_call_count : int
var og_scale : Vector2

func _ready() -> void:
	og_scale = scale

func bounce():
	print("bouncing!")
	var time = 0
	
	_bounce_call_count += 1
	var cur_bounce_id = _bounce_call_count
	while(time < lifetime):
		scale = og_scale * bounce_size.sample(time / lifetime)
		await get_tree().process_frame
		if (cur_bounce_id != _bounce_call_count): break
		time += get_process_delta_time()
	_bounce_call_count -= 1

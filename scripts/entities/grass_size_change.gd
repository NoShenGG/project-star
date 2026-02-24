class_name GrassSizeChange extends Node

## if disabled, the grass size will go to zero when finished
@export var return_to_default : bool = true
## the delay after start() before the grass size changes
@export_range(0, 3) var delay : float = 0

@export var grass_displacement_size : float = 0.5

@export_category("tweening")
@export var tween : bool = true
@export var tween_transition : Tween.TransitionType

@export_category("timer")
@export var timer : bool = false
@export_range(0.1, 3) var duration : float = 1 :
	set(value):
		if (timer):
			duration = value
		else:
			duration = 0


var _entity : Entity
var _default_grass_size : float = 0
var _running : bool = false
func _ready() -> void:
	_entity = owner as Entity
	_default_grass_size = _entity.grass_displacement_size

func start():
	print("starting")
	_running = true
	if (delay > 0):
		await get_tree().create_timer(delay).timeout
	_entity.grass_displacement_size = grass_displacement_size
	
	if (timer):
		if (tween):
			var tween = _entity.create_tween()
			tween.set_trans(tween_transition)
			var end_size : float = _default_grass_size if return_to_default else 0.0
			tween.tween_property(_entity, "grass_displacement_size", end_size, duration)
			tween.tween_callback(stop)
		else:
			await get_tree().create_timer(duration).timeout
			stop()

func stop():
	if (!_running): return
	_entity.grass_displacement_size = _default_grass_size
	_running = false

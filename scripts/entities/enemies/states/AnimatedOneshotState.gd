@tool
@abstract
class_name AnimatedOneshotState extends State


@export_category("Animation")
@export var animation : AnimationState :
	set(value):
		animation = value
		if (animation):
			## animation is bugged ;-;
			pass
			#duration = -1
@export var duration : float = 0.4 : 
	set(value):
		if (animation):
			#duration = -1
			duration = value
		elif (value >= 0):
			duration = value
		else:
			duration = 0

signal animation_finished

func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()
	
	if (animation):
		animation.enter()
	animation_wait()

var wait_timer : SceneTreeTimer

func animation_wait():
	## animation api still not working ;-;
	if (animation and false):
		await animation.stop
	elif (duration > 0):
		wait_timer = get_tree().create_timer(duration)
		await wait_timer.timeout
		
	
	animation_finished.emit()

func end() -> void:
	wait_timer = null
	finished.emit()

extends ProgressBar

@export var increment = 20;

func _ready()-> void:
	value = 0

func _process(delta):
	if Input.is_action_just_pressed("basic_attack"):
		value += increment
		if value > max_value:
			value = max_value
	

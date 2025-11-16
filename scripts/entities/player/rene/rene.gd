class_name Rene extends Player

signal update_counters(num: int)


var counters: int:
	set(val):
		val = clampi(val, 0, 4)
		update_counters.emit(val)
		counters = val

'''
This class mostly holds configuration for Rene.
It may eventually hold some signal binding or wtv.
'''

func _ready() -> void:
	super()
	_has_special = false
	
func _process(_delta: float) -> void:
	super(_delta)
	if Input.is_action_just_pressed("dodge"):
		var bullet: ReneShot = load("res://scenes/final/rene/rene_shot.tscn").instantiate()
		bullet.global_position = global_position + Vector3.UP * 2
		bullet.target = Vector3(5, 5, 5)
		get_tree().root.add_child(bullet)

# Override these functions to prevent special attack functionality
func use_special() -> void:
	pass

func set_special_cd() -> void:
	pass

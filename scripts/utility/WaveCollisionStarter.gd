@tool
extends Area3D

@export var wave : Wave

func _enter_tree() -> void:
	collision_layer = 0
	collision_mask = 2
	
	body_entered.connect(start_wave)


func start_wave(body : Node3D):
	
	if (wave):
		wave.validate_condition(body)

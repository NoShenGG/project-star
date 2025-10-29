extends Node3D

@export var enemy: PackedScene
@export var num: int = 4
@export var max_radius: float = 8

var count: int = 0

func _ready() -> void:
	await owner.ready
	spawn()
	
	
func spawn() -> void:
	for i in range(num):
		var temp: Enemy = enemy.instantiate()
		temp.global_position = owner.global_position \
			+ Vector3.FORWARD.rotated(Vector3.UP, randf() * 360) \
			* randf() * max_radius
		add_child(temp)
		count += 1
		temp.killed.connect(decrement)
		
func decrement() -> void:
	count -= 1
	if count == 0:
		spawn()

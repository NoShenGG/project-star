extends Node3D
class_name  CameraTarget

# connect to player with relative path
@onready var player = get_node("../PlayerManager")
@export_range(0.0, 1.0, 0.01) var follow_speed: float = 0.1

func _physics_process(delta: float) -> void:
	position = lerp(position, player.position, follow_speed)

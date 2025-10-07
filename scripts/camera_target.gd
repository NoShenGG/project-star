extends Node3D
class_name CameraTarget

# connect to player with relative path
@onready var player : PlayerManager = (func get_player_manager() -> PlayerManager:

		var player_manager : PlayerManager = get_parent() as PlayerManager
		if (player_manager):
			return player_manager
		player_manager = get_node("../PlayerManager") as PlayerManager
		
		assert(player_manager != null, "camera_target could not find player, make sure its name is PlayerManager and has a PlayerManager script \n" + get_tree_string_pretty())
		return player_manager).call()

@export_range(0.0, 1.0, 0.01) var follow_speed: float = 0.1

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, player.position, follow_speed)

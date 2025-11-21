class_name FortifierMove extends EnemyState

@export var rotate_speed : float = 10

## Goal distance for movement
@export var target_dist: float = 5
## Error Distance for goal
@export var error_dist: float = 0.5

@export var reached_enemy_state : State


func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()

func end() -> void:
	finished.emit()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	if (enemy.death): return
	
	var player_distance = enemy.global_position.distance_to(GameManager.curr_player.global_position)

	if abs(player_distance - target_dist) > error_dist:
		var pos : Vector3 = GameManager.curr_player.global_position
		var dir : Vector3 = (enemy.global_position - pos).normalized().slide(Vector3.UP)
		pos += dir * target_dist

		enemy.set_movement_target(pos)
		enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP) * _delta * rotate_speed)
		
		return
	trigger_finished.emit(reached_enemy_state.get_path())
	
	## code for attacking player / directly looking at player
	#rotate_y(global_basis.z.signed_angle_to(global_position - GameManager.curr_player.global_position, Vector3.UP) * delta * 10)

class_name MergerMove extends EnemyState

@export var rotate_speed : float = 10
@export var drift_amount : float  = 0.6

## Max distance to track player
@export var max_dist: float = 15
## Goal distance for movement
@export var target_dist: float = 3.5
## Error Distance for goal
@export var error_dist: float = 0.5

@export var enemy_far_state : State


func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()

func end() -> void:
	finished.emit()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if (enemy.death): return
	
	var player_distance = enemy.global_position.distance_to(GameManager.curr_player.global_position)

	if player_distance > max_dist:
		trigger_finished.emit(enemy_far_state.get_path())
		return
		
	var pos : Vector3 = GameManager.curr_player.global_position
	var dir : Vector3 = (enemy.global_position - pos).normalized().slide(Vector3.UP)
	pos += dir * target_dist
	if abs(player_distance - target_dist) < error_dist: 
		var drift_dir = (-dir).cross(Vector3.UP)
		pos += drift_dir.normalized() * drift_amount
	enemy.set_movement_target(pos)
	enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP) * delta * rotate_speed)

	
	## code for attacking player / directly looking at player
	#rotate_y(global_basis.z.signed_angle_to(global_position - GameManager.curr_player.global_position, Vector3.UP) * delta * 10)

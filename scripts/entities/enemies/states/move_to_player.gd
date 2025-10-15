class_name MoveToPlayerState extends EnemyState


## distance from player before stopping
@export var attack_distance : float = 1

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
	if (player_distance > attack_distance and enemy.moving) or (player_distance > attack_distance + 3):
		var pos : Vector3 = GameManager.curr_player.global_position
		var dir : Vector3 = (enemy.global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP) * attack_distance
		pos = GameManager.curr_player.global_position + dir
		
		enemy.set_movement_target(pos)
		enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP) * _delta * 10)
		
		return
	
	trigger_finished.emit(reached_enemy_state.get_path())
	
	## code for attacking player / directly looking at player
	#rotate_y(global_basis.z.signed_angle_to(global_position - GameManager.curr_player.global_position, Vector3.UP) * delta * 10)

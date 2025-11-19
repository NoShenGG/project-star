class_name MossyPedeAttack extends EnemyState

@export var reached_state: State

var target: Vector3

func enter(_prev_state: String, _data := {}) -> void:
	enemy.can_damage = true
	target = GameManager.curr_player.global_position
	enemy.set_movement_target(target)
	var dir : Vector3 = (enemy.global_position - target).normalized().slide(Vector3.UP)
	enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP))
	entered.emit()

func end() -> void:
	finished.emit()

func exit() -> void:
	enemy.set_movement_target(enemy.global_position)

func update(_delta: float) -> void:
	if (enemy.death): return
	if enemy.navigation_agent.is_target_reached():
		trigger_finished.emit(reached_state.get_path())

func physics_update(_delta: float) -> void:
	pass

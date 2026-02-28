class_name MergerFleeState extends EnemyState

@export var rotate_speed : float = 10

func enter(_prev_state: String, _data := {}) -> void:
	# Cut speed since its injured
	enemy._base_speed /= 1.5
	# Cut to 10% hp
	if enemy._hp > 0.1 * enemy._max_hp:
		enemy._hp = 0.1 * enemy._max_hp
	entered.emit()

func end() -> void:
	finished.emit()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	if (enemy.death): return
	
	var pos : Vector3 = enemy.global_position
	var dir : Vector3 = (pos - GameManager.curr_player.global_position).normalized().slide(Vector3.UP)
	pos += dir * 3
	
	enemy.set_movement_target(pos)
	enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP) * _delta * rotate_speed)

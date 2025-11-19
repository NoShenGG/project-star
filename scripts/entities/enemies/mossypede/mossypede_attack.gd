class_name MossyPedeAttack extends EnemyState

@export var reached_state: State

var target_dist: float
var orig: Vector3

func enter(_prev_state: String, _data := {}) -> void:
	enemy = enemy as Mossypede
	enemy.can_damage = true
	var dir : Vector3 = (GameManager.curr_player.global_position - enemy.global_position) \
			.normalized().slide(Vector3.UP)
	var cast =  enemy.cast as ShapeCast3D
	cast.force_shapecast_update()
	target_dist = enemy.global_position.distance_to(cast.get_collision_point(0)) - 1.5 if cast.is_colliding() else cast.target_position.length()
	orig = enemy.global_position
	enemy.velocity = dir * enemy.speed
	enemy.look_at(enemy.global_position + dir)
	entered.emit()

func end() -> void:
	finished.emit()

func exit() -> void:
	enemy.set_movement_target(enemy.global_position)

func update(_delta: float) -> void:
	if (enemy.death): return
	enemy.move_and_slide()
	if orig.distance_to(enemy.global_position) >= target_dist:
		trigger_finished.emit(reached_state.get_path())

func physics_update(_delta: float) -> void:
	pass

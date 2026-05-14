extends EnemyState

@export var rotate_speed : float = 5

## called when firing with aiming direction
signal firing(direction:Vector3)

@export var fire_time : float = 0.6

func update(_delta: float) -> void:
	var dir : Vector3 = (enemy.global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP)
	enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP) * _delta * rotate_speed)
	
func physics_update(_delta: float) -> void:
	pass

func enter(_prev_state: String, _data := {}) -> void:
	shoot()
	entered.emit()

func shoot() -> void:
	if not enemy.death:
		var projectile_instance = enemy.projectile_scene.instantiate()
		projectile_instance.global_transform = enemy.global_transform
		var dir : Vector3 = enemy.global_position.direction_to(GameManager.curr_player.global_position)
		dir.y = 0
		projectile_instance.direction = dir
		firing.emit(dir)
		
		enemy.add_child(projectile_instance)
	end()

func end() -> void:
	trigger_finished.emit("idle")

func exit() -> void:
	pass

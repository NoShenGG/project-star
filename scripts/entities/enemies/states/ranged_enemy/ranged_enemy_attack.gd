extends State

var parent_enemy : RangedEnemy

## called when firing with aiming direction
signal firing(direction:Vector3)

@export var fire_time : float = 0.6

func update(_delta: float) -> void:
	if (parent_enemy.target_node) and not parent_enemy.death:
		parent_enemy.set_movement_target(parent_enemy.target_node.global_position)

func physics_update(_delta: float) -> void:
	pass

func enter(_prev_state: String, _data := {}) -> void:
	parent_enemy = owner as RangedEnemy
	parent_enemy.cooldown.timeout.connect(_on_cooldown_timeout.bind())
	shoot(parent_enemy.Projectile)
	entered.emit()

func shoot(projectile: PackedScene) -> void:
	if not parent_enemy.death:
		var projectile_instance = projectile.instantiate()
		var dir : Vector3 = parent_enemy.global_position.direction_to(parent_enemy.target_node.global_position)
		dir.y = 0
		projectile_instance.direction = dir
		firing.emit(dir)
		
		parent_enemy.add_child(projectile_instance)
		parent_enemy.cooldown.start()
		
		var time : float = 0
		while time < fire_time:
			owner.global_basis = (owner.global_basis as Basis).looking_at(parent_enemy.global_position)
			
			time += get_process_delta_time()
			await get_tree().process_frame
		
		end()

func _on_cooldown_timeout() -> void:
	shoot(parent_enemy.Projectile)

func end() -> void:
	trigger_finished.emit("idle")

func exit() -> void:
	pass

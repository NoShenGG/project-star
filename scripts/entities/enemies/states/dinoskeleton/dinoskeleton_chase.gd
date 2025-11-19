extends State

var parent_enemy : DinoSkeleton

func update(_delta: float) -> void:
	if parent_enemy.death:
		return
	
	var target := parent_enemy.target_node
	if target == null:
		trigger_finished.emit("idle")
	
	var distanceToPlayer := parent_enemy.global_position.distance_to(target.global_position)
	
	var direction = parent_enemy.target_node.global_position - parent_enemy.global_position;
	direction.y = 0
	parent_enemy.look_at(parent_enemy.global_position + direction, Vector3.UP)
	
	if distanceToPlayer <= parent_enemy.fire_distance && parent_enemy.fire_cd.is_stopped():
		trigger_finished.emit("fire_attack_prepare")
		return
	
	if distanceToPlayer <= parent_enemy.spit_distance && parent_enemy.spit_cd.is_stopped():
		trigger_finished.emit("spit_attack_commit")
		return
	
	parent_enemy.set_movement_target(target.global_position)

func physics_update(_delta: float) -> void:
	pass

func enter(_prev_state: String, _data := {}) -> void:
	parent_enemy = owner as DinoSkeleton
	entered.emit()

func shoot(projectile: PackedScene) -> void:
	var projectile_instance = projectile.instantiate()
	var dir : Vector3 = parent_enemy.global_position.direction_to(parent_enemy.target_node.global_position)
	dir.y = 0
	projectile_instance.direction = dir
	parent_enemy.add_child(projectile_instance)
	parent_enemy.cooldown.start()

func _on_cooldown_timeout() -> void:
	shoot(parent_enemy.Projectile)

func end() -> void:
	trigger_finished.emit("idle")

func exit() -> void:
	pass

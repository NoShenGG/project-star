#Refactored by Zifeng

extends State

var parent_enemy : RangedEnemy

func update(_delta: float) -> void:
	if (parent_enemy.target_node):
		parent_enemy.set_movement_target(parent_enemy.target_node.global_position)

func physics_update(_delta: float) -> void:
	pass

func enter(_prev_state: String, _data := {}) -> void:
	parent_enemy = owner as RangedEnemy
	parent_enemy.target_node = GameManager.curr_player#this line used to be with ranged_enemy_idle.gd
	parent_enemy.cooldown.timeout.connect(_on_cooldown_timeout.bind())
	shoot(parent_enemy.Projectile)
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

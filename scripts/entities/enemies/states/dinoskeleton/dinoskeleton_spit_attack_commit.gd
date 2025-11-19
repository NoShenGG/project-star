extends State

var parent_enemy : DinoSkeleton

@onready var spit_timer: Timer = $SpitAnimationTimer

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_prev_state: String, _data := {}) -> void:
	parent_enemy = owner as DinoSkeleton
	
	print("tried to spit")
	
	if not parent_enemy.target_node:
		trigger_finished.emit("chase")
		return
	
	var projectile = parent_enemy.spit_projectile_scene.instantiate() as SpitProjectileController
	parent_enemy.get_tree().current_scene.add_child(projectile)

	projectile.setup(parent_enemy.spit_source_node.global_position, parent_enemy.target_node.global_position)

	parent_enemy.spit_commit.emit()
	
	if not spit_timer.timeout.is_connected(_on_spit_done):
		spit_timer.timeout.connect(_on_spit_done)
	spit_timer.start()
	
	if parent_enemy.spit_cd.is_stopped():
		parent_enemy.spit_cd.start()
	
	entered.emit()

func _on_spit_done() -> void:
	trigger_finished.emit("chase")

func end() -> void:
	if spit_timer and not spit_timer.is_stopped():
		spit_timer.stop();
	trigger_finished.emit("chase")

func exit() -> void:
	if spit_timer and spit_timer.timeout.is_connected(_on_spit_done):
		spit_timer.timeout.disconnect(_on_spit_done)

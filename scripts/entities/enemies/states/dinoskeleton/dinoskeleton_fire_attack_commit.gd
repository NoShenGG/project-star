extends State

var parent_enemy : DinoSkeleton

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_prev_state: String, _data := {}) -> void:
	parent_enemy = owner as DinoSkeleton
	
	if parent_enemy.death:
		trigger_finished.emit("idle")
		return
	
	if parent_enemy.fire_effect_scene:
		var effect = parent_enemy.fire_effect_scene.instantiate()
		effect.global_position = parent_enemy.global_position
		parent_enemy.get_tree().current_scene.add_child(effect)
	
	parent_enemy.fire_commit.emit()
	
	if parent_enemy.fire_cd:
		parent_enemy.fire_cd.start()

	trigger_finished.emit("chase")
	entered.emit()

func end() -> void:
	trigger_finished.emit("chase")

func exit() -> void:
	pass

extends NovaState

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit(name, _previous_state_path)
	nova.sweep_box.monitoring = true
	

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.move_and_slide()
		
func do_damage() -> void:
	for node in nova.sweep_box.get_overlapping_bodies():
		if not node is Enemy:
			continue
		(node as Enemy).try_damage(nova.charged_attack_dmg)
		
func end() -> void:
	finished.emit(MOVING if player.velocity else IDLE)

func exit() -> void:
	nova.sweep_box.monitoring = false

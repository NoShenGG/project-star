extends PlayerState


func enter(_previous_state_path: String, _data := {}) -> void:
	player.get_node("CollisionShape3D").disabled = false
	player.visible = true
	entered.emit()
	get_tree().create_timer(0.25).timeout.connect(
		trigger_finished.emit.bind(MOVING if player.velocity else IDLE))

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.move_and_slide()
		
func end() -> void:
	pass
		
func exit() -> void:
	pass

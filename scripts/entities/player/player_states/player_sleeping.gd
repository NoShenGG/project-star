extends PlayerState


func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	player.velocity = Vector3.ZERO

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
		
func end() -> void:
	trigger_finished.emit(SWAP_IN)
		
func exit() -> void:
	pass

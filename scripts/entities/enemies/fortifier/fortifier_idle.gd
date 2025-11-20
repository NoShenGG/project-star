class_name Idle extends FortifierState


func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	fortifier.velocity = Vector3.ZERO

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func end() -> void:
	pass
		
func exit() -> void:
	pass

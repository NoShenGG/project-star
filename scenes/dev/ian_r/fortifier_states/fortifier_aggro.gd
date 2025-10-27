class_name Aggro extends FortifierState

var target: Player = null

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	fortifier.velocity = Vector3.ZERO

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	## goal: have the fortifier face the player while in this state
	pass

func end() -> void:
	pass
		
func exit() -> void:
	pass

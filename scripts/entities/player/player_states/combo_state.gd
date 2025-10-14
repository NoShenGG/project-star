@abstract
class_name ComboState extends PlayerState

@export var combo_num: int = 0

var _attacking_state: PlayerState

func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()

func end() -> void:
	finished.emit()
	_attacking_state.end()

@abstract
class_name ComboState extends PlayerState

@export var combo_num: int = 0

func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()

func end() -> void:
	finished.emit()

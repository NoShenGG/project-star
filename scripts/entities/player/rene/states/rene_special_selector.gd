@icon("uid://btv30atgumepn")
extends PlayerState

@export var regular: State
@export var charged: State

var current_state: State = null

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	player.use_special()
	if _data.get("charges", 1) == 1:
		current_state = regular
	else:
		current_state = charged
	start_state(_previous_state_path, _data)

func start_state(_prev_state: String, _data := {}) -> void:
	current_state.finished.connect(state_done)
	current_state.enter(_prev_state, _data)
	
func state_done() -> void:
	current_state.finished.disconnect(state_done)
	current_state.exit()
	end()

func update(_delta: float) -> void:
	current_state.update(_delta)

func physics_update(_delta: float) -> void:
	current_state.physics_update(_delta)

func end() -> void:
	trigger_finished.emit(MOVING if player.velocity else IDLE)

func exit() -> void:
	player.set_special_cd()
	current_state.finished.disconnect(state_done)
	current_state.exit()

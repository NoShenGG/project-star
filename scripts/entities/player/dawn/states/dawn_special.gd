@icon("uid://k8c74qb6yai2")
extends PlayerState

@export var regular: State
@export var charged: State

var current_state: State = null

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	if _data.get("charges", 1) > 1:
		current_state = charged
	elif player._has_special:
		current_state = regular
		player.use_special()
	else:
		current_state = null
		end()
		return
	current_state.finished.connect(state_done)
	current_state.enter(_previous_state_path, _data)
	
func state_done() -> void:
	current_state.finished.disconnect(state_done)
	current_state.exit()
	current_state = null
	end()

func update(_delta: float) -> void:
	current_state.update(_delta)

func physics_update(_delta: float) -> void:
	current_state.physics_update(_delta)

func end() -> void:
	trigger_finished.emit(MOVING if player.velocity else IDLE)

func exit() -> void:
	if current_state == regular:
		player.set_special_cd()
	if current_state != null:
		current_state.finished.disconnect(state_done)
		current_state.exit()

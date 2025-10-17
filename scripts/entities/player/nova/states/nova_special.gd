@icon("uid://btv30atgumepn")
extends PlayerState

@export var special_state: State
@export var wait_state: State

var current_state: State = null
var _state_queue: Array = []

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	_state_queue.clear()
	player.has_special = false
	for i in range(2 * _data.get("charges", 1) - 1):
		_state_queue.push_back(special_state if i % 2 == 0 else wait_state)
	print(_state_queue)
	start_state(_previous_state_path, _data)

func start_state(_prev_state: String, _data := {}) -> void:
	current_state = _state_queue.pop_front()
	current_state.finished.connect(state_done)
	current_state.enter(_prev_state, _data)
	
func state_done() -> void:
	current_state.finished.disconnect(state_done)
	current_state.exit()
	
	if _state_queue.is_empty():
		end()
	else:
		## doing deferred instead of waiting a frame so we arent skipping a frame, theres a difference between deferred and a skipped frame
		start_state.call_deferred(SPECIAL)

func update(_delta: float) -> void:
	current_state.update(_delta)

func physics_update(_delta: float) -> void:
	current_state.physics_update(_delta)

func end() -> void:
	trigger_finished.emit(MOVING if player.velocity else IDLE)

func exit() -> void:
	current_state.finished.disconnect(state_done)
	current_state.exit()
	get_tree().create_timer(player.special_cd).timeout.connect(func(): player.has_special = true)

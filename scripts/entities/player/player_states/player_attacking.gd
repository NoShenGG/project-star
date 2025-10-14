extends PlayerState

signal update_combo(count: int)

var _states: Array[ComboState] = []
var current_state: ComboState = null
var combo_timer: SceneTreeTimer = null
var combo_counter: int = 0

func _ready() -> void:
	for child in get_children():
		if not child is ComboState:
			continue
		child = child as ComboState
		_states.append(child)
		child._attacking_state = self
	_states.sort_custom(func(a: ComboState, b: ComboState): return a.combo_num < b.combo_num)
	for state in _states:
		if _states[state.combo_num] != state:
			assert(false, "Cannot Have duplicate Combo States")
		if state.combo_num >= _states.size():
			assert(false, "Combo Number cannot exceed the number of ComboStates")
		
	
func enter(_previous_state_path: String, _data := {}) -> void:
	if combo_timer != null and combo_timer.time_left > 0:
		combo_timer.timeout.disconnect(reset_combo)
		combo_timer = null
	entered.emit()
	current_state = _states[combo_counter]
	current_state.enter(_previous_state_path, _data)
	
func reset_combo() -> void:
	combo_counter = 0
	update_combo.emit(0)

func update(_delta: float) -> void:
	current_state.update(_delta)

func physics_update(_delta: float) -> void:
	current_state.physics_update(_delta)

func end() -> void:
	trigger_finished.emit(MOVING if player.velocity else IDLE)
		
func exit() -> void:
	current_state.exit()
	combo_counter = (combo_counter + 1) % len(_states.size())
	update_combo.emit(combo_counter)
	combo_timer = get_tree().create_timer(player.combo_reset_time)
	combo_timer.timeout.connect(reset_combo)

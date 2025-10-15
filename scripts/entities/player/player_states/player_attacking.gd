extends PlayerState

signal update_combo(count: int)
signal attack_started(count :int)

var _states: Array[ComboState] = []
var current_state: ComboState = null
var combo_timer: SceneTreeTimer = null
var combo_counter: int = 0

var combo_queue : int = 0

const ATTACK_INPUTS : Array[String]= ["basic_attack", "special_attack", "synergy_burst"]
@export_enum(ATTACK_INPUTS[0],ATTACK_INPUTS[1],ATTACK_INPUTS[2]) var Combo_Attack_input : int


func _ready() -> void:
	super()
	for child in get_children():
		if not child is ComboState:
			continue
		child = child as ComboState
		_states.append(child)
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
	current_state.finished.connect(attack_done)
	current_state.enter(_previous_state_path, _data)
	attack_started.emit(combo_counter)
	combo_queue = 0

func attack_done():
	
	if (combo_queue <= 0):
		end()
		print("returning")
		return
	
	print("continuing")
	
	
	current_state.finished.disconnect(attack_done)
	increase_combo_count()
	
	current_state = _states[combo_counter]
	current_state.finished.connect(attack_done)
	current_state.enter(ATTACKING, {})
	
	attack_started.emit(combo_counter)
	
	combo_queue -= 1 if combo_queue > 0 else 0

func reset_combo() -> void:
	combo_counter = 0
	update_combo.emit(0)

## when clicking attack mid combo, it will set the amount of clicks to be a queue of attacks. if false you have to spam click to continue combo
@export var queue_combo : bool = true
func update(_delta: float) -> void:
	if Input.is_action_just_pressed(ATTACK_INPUTS[Combo_Attack_input]):
		combo_queue = combo_queue + 1 if queue_combo else 1
	current_state.update(_delta)
	

func physics_update(_delta: float) -> void:
	current_state.physics_update(_delta)

func end() -> void:
	current_state.finished.disconnect(attack_done)
	print("ending end")
	trigger_finished.emit(MOVING if player.velocity else IDLE)
	combo_queue = 0
func exit() -> void:
	current_state.finished.disconnect(attack_done)
	current_state.exit()
	increase_combo_count()
	combo_queue = 0

func increase_combo_count():
	combo_counter = (combo_counter + 1) % _states.size()
	update_combo.emit(combo_counter)
	combo_timer = get_tree().create_timer(player.combo_reset_time)
	combo_timer.timeout.connect(reset_combo)

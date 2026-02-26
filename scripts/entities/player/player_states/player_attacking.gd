@icon("uid://btv30atgumepn")
extends PlayerState

signal update_combo(count: int)
signal attack_started(count :int)

var _states: Array[State] = []
var current_state: State = null
var combo_timer: SceneTreeTimer = null
var charge_timer: SceneTreeTimer = null
var combo_counter: int = 0
var combo_queue: int = 0
var charge_queued: bool = false

## when clicking attack mid combo, it will set the amount of clicks to be a queue of attacks. if false you have to spam click to continue combo
@export var queue_combo : bool = true
## if false, the combo will be exited before it loops
@export var loop_combo : bool = true

func _ready() -> void:
	super()
	for child in get_children():
		if not child is State:
			continue
		child = child as State
		_states.append(child)

func enter(_previous_state_path: String, _data := {}) -> void:
	if combo_timer != null and combo_timer.time_left > 0:
		combo_timer.timeout.disconnect(reset_combo)
		combo_timer = null
	entered.emit()
	start_attack(_previous_state_path, _data)

func start_attack(_prev_state: String, _data := {}) -> void:
	current_state = _states[combo_counter]
	attack_started.emit(combo_counter)
	current_state.finished.connect(attack_done)
	current_state.enter(_prev_state, _data)
	
func attack_done():
	if charge_queued:
		combo_queue = 0
		trigger_finished.emit(CHARGING, {"time": player.max_click_time})
		return
	if combo_queue <= 0 or (loop_combo and (_states.size() - 1) - combo_counter == 0):
		await get_tree().create_timer(0.08).timeout
		if (combo_queue <= 0):
			end()
			return
	current_state.finished.disconnect(attack_done)
	current_state.exit()
	
	increase_combo_count()
	## doing deferred instead of waiting a frame so we arent skipping a frame, theres a difference between deferred and a skipped frame
	start_attack.call_deferred(ATTACKING)
	combo_queue -= 1 if combo_queue > 0 else 0

func reset_combo() -> void:
	combo_counter = 0
	update_combo.emit(0)
	
func increase_combo_count():
	if combo_timer != null and combo_timer.time_left > 0:
		combo_timer.timeout.disconnect(reset_combo)
		combo_timer = null
	combo_counter = (combo_counter + 1) % _states.size()
	update_combo.emit(combo_counter)
	combo_timer = get_tree().create_timer(player.combo_reset_time)
	combo_timer.timeout.connect(reset_combo)
	
func start_charge_timer():
	if charge_timer != null and not charge_queued:
		charge_timer.timeout.disconnect(attack_held)
	charge_timer = get_tree().create_timer(player.max_click_time)
	charge_timer.timeout.connect(attack_held)
	
func attack_held():
	charge_queued = true
	charge_timer = null
	

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("basic_attack"):
		start_charge_timer()
		combo_queue = min(combo_queue + 1, (_states.size()) - (combo_counter + 1)) if queue_combo else 1
	if Input.is_action_just_released("basic_attack") and charge_timer != null:
		charge_timer.timeout.disconnect(attack_held)
		charge_timer = null
	current_state.update(_delta)

func physics_update(_delta: float) -> void:
	current_state.physics_update(_delta)

func end() -> void:
	trigger_finished.emit(MOVING if player.velocity else IDLE)
	combo_queue = 0

func exit() -> void:
	current_state.finished.disconnect(attack_done)
	current_state.exit()
	charge_queued = false
	increase_combo_count()
	combo_queue = 0

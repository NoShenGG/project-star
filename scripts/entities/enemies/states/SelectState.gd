@icon("uid://btv30atgumepn")
class_name SelectState extends EnemyState

@export_category("Playing")
@export_enum("Sequential", "Random") var play_order : int = 0

## play only one substate
@export var oneshot : bool = false

## endlessly loop instead of playing the size of attacks
@export var loop : bool = false

@export_category("Exiting")
## transitioned to when SelectState is done with its state(s)
@export var exit_state : State

@export_subgroup("Damage")
## If we get damaged, well stop going through substates, and automatically exit to damage_state
@export var damage_interrupt : bool = true
@export var damage_state : State
@export_subgroup("Distance")
## If the player gets too far, well stop going through substates, and automatically exit to player_far_state
@export var player_lost_interrupt : bool = true
@export var max_player_distance : float = 1
## the euler angle before we exit through player lost. 
@export var sight_angle : float = 180
@export var player_lost_state : State


var _states_played : int = 0
var _cur_substate_index : int = -1
var cur_substate : State = null :
	get():
		assert(_cur_substate_index != -1, "Must call get_next_state() before getting cur_substate")
		return cur_substate

var _states: Array[State] = []

var _entered_state : String

func _ready() -> void:
	await super()
	for child in get_children():
		if not child is State:
			continue
		child = child as State
		_states.append(child)
	enemy.hurt.connect(hurt)

func hurt(damage : float):
	if (player_lost_interrupt and damage_state):
		trigger_finished.connect(damage_state.get_path)

func enter(_prev_state: String, _data := {}) -> void:
	_entered_state = _prev_state
	entered.emit()
	get_next_state()
	cur_substate.enter(_entered_state)
	cur_substate.finished.connect.call_deferred(substate_ended)
	print("connected")

func get_next_state() -> State:
	match (play_order):
		0:
			_cur_substate_index = (_cur_substate_index + 1) % _states.size()
		1:
			_cur_substate_index = randi_range(0, _states.size() - 1)
	
	cur_substate = _states[_cur_substate_index]
	_states_played += 1
	return cur_substate

func substate_ended():
	print("next state 1")
	if (enemy.death): return
	
	if (oneshot or (!loop and _states_played >= _states.size())):
		end()
		return
	
	var player_distance : float = enemy.global_position.distance_to(GameManager.curr_player.global_position)
	## yeah i can use angle_to(), but thats in radians and i dont wanna do five operations to get a result with floating-point error
	var player_angle : float = (1 - enemy.global_basis.z.normalized().dot((enemy.global_position - GameManager.curr_player.global_position).normalized())) * 90
	var player_lost : bool = player_distance > max_player_distance or player_angle > sight_angle
	if (player_lost_interrupt and player_lost_state and player_lost):
		trigger_finished.emit(player_lost_state.get_path())
		return
	
	print("next state 3")
	cur_substate.finished.disconnect(substate_ended)
	get_next_state()
	cur_substate.enter(_entered_state)
	cur_substate.finished.connect.call_deferred(substate_ended)

func end() -> void:
	_states_played = 0
	finished.emit()
	trigger_finished.emit(exit_state.get_path())

func exit() -> void:
	_states_played = 0

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

@icon("uid://btv30atgumepn")
class_name BurstState extends PlayerState

signal burst_done

@export var burst_player_1: PlayerManager.Players
@export var burst_1: State
@export var burst_player_2: PlayerManager.Players
@export var burst_2: State
var bursts := {}

var current_state: State

func _ready() -> void:
	super()
	assert(burst_player_1 != burst_player_2, "Players should have two unique bursts")
	bursts[burst_player_1] = burst_1
	bursts[burst_player_2] = burst_2
	
	

func enter(_previous_state_path: String, _data := {}) -> void:
	## DISABLE/SLOW EVERYTHING IN THE BACKGROUND
	entered.emit()
	var with = _data.get("player", null)
	assert(with != null)
	current_state = bursts.get(with)
	current_state.finished.connect(attack_done)
	current_state.enter(_previous_state_path, _data)
	
func attack_done():
	current_state.finished.disconnect(attack_done)
	current_state.exit()
	burst_done.emit()

func update(_delta: float) -> void:
	current_state.update(_delta)

func physics_update(_delta: float) -> void:
	current_state.physics_update(_delta)

func end() -> void:
	trigger_finished.emit(MOVING if player.velocity else IDLE)
	
func end_sleep() -> void:
	trigger_finished.emit(SLEEPING)

func exit() -> void:
	current_state.finished.disconnect(attack_done)
	current_state.exit()

@icon("uid://btv30atgumepn")
class_name BurstState extends PlayerState

signal burst_done

@export var burst_player_1: PlayerManager.Players
@export var burst_1: State
@export var burst_player_2: PlayerManager.Players
@export var burst_2: State

var current_state: State
var was_sleeping: bool

func _ready() -> void:
	super()
	assert(burst_player_1 != burst_player_2, "Players should have two unique bursts")


func enter(_previous_state_path: String, _data := {}) -> void:
	## DISABLE/SLOW EVERYTHING IN THE BACKGROUND
	entered.emit()
	was_sleeping = _data.get("sleep", false)
	var with = _data.get("player", null)
	assert(with != null)
	current_state = burst_1 if with == burst_player_1 else \
			burst_2 if with == burst_player_2 else null
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
	trigger_finished.emit(SLEEPING if was_sleeping else MOVING if player.velocity else IDLE)

func exit() -> void:
	current_state.finished.disconnect(attack_done)
	current_state.exit()

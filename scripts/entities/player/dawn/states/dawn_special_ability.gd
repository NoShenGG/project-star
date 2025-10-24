@icon("uid://k8c74qb6yai2")
extends PlayerState

@export var wave: State
@export var forte: State
@export var stun_wave: State
@export var vortex: State
@export var ice: State
@export var fish_shield: State

@export var notes: DawnNotes

var current_state: State = null

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	var p = notes.Patterns
	match notes.use_notes():
		p.BASS:
			current_state = wave
		p.FORTE:
			current_state = forte
		p.HIGH_TIDE:
			current_state = stun_wave
		p.SIREN_SONG:
			current_state = vortex
		p.CHILLING_TUNE:
			current_state = ice
		p.ACCELERANDO:
			current_state = fish_shield
		_:
			end()
			return
		
	current_state.finished.connect(state_done)
	current_state.enter(_previous_state_path, _data)
	
func state_done() -> void:
	current_state.finished.disconnect(state_done)
	current_state.exit()
	end()

func update(_delta: float) -> void:
	current_state.update(_delta)

func physics_update(_delta: float) -> void:
	current_state.physics_update(_delta)

func end() -> void:
	finished.emit()

func exit() -> void:
	if current_state != null:
		current_state.finished.disconnect(state_done)
		current_state.exit()

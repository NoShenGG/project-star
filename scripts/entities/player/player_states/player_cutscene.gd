extends PlayerState

var time_active: float = 0

var exit_state : State

## how long the player is invisible before starting the cutscene
@export var invisible_duration : float
@export var cutscene_duration : float

@export var animation : AnimationState

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	var coll = player.collision_layer
	player.collision_layer = 0
	player.hide()
	await get_tree().create_timer(invisible_duration).timeout
	animation.enter()
	await get_tree().process_frame
	await get_tree().process_frame
	player.show.call_deferred()
	
	await get_tree().create_timer(cutscene_duration).timeout
	player.collision_layer = coll
	trigger_finished.emit.call_deferred(IDLE)

func physics_update(_delta: float) -> void:
	pass
## Called on state enter. Make sure to emit entered.:

func update(_delta: float) -> void:
	pass

func end() -> void:
	pass
		
func exit() -> void:
	pass

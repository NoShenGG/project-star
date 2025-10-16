@icon("uid://fui6kut2l6b1")
class_name PlayerStateMachine extends StateMachine


var player: Player

func _ready() -> void:
	player = owner as Player
	super()
	
func swap_out() -> void:
	assert(state.name in [PlayerState.IDLE, PlayerState.MOVING], "Bad Call to Swap Out")
	state.trigger_finished.emit(PlayerState.SWAP_OUT)
	
func swap_in() -> void:
	assert(state.name in [PlayerState.SLEEPING], "Bad Call to Swap In")
	state.trigger_finished.emit(PlayerState.SWAP_IN)

func _physics_process(delta: float) -> void:
	super(delta)
	
	if (!player.is_on_floor()):
		player.velocity += Vector3.DOWN * (9.81 * 10)* delta
	

class_name PlayerStateMachine extends StateMachine


var player: Player

func _ready() -> void:
	super()
	player = owner as Player
	
func swap_out() -> void:
	state.trigger_finished.emit(PlayerState.SWAP_OUT)
	
func swap_in() -> void:
	state.trigger_finished.emit(PlayerState.SWAP_IN)

func _physics_process(delta: float) -> void:
	super(delta)
	
	if (!player.is_on_floor()):
		player.velocity += Vector3.DOWN * (9.81 * 10)* delta
	

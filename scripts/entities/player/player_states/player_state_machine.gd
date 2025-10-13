@icon("uid://fui6kut2l6b1")
class_name PlayerStateMachine extends StateMachine

'''
PlayerStateMachine Class enforces PlayerStates for all states in the machine.
It also enforces that each state conforms to the valid PlayerStates across all characters.

Some states like attacks are character specific and should be named:
	"[player]_[state].gd"
Others that can be applied to any player like movement should be named:
	"player_[state].gd"
'''

var player: Player

func _ready() -> void:
	player = owner as Player
	
	for state_node in get_children():
		assert(state_node is PlayerState)
		assert(state_node.name in PlayerState.VALID_STATES)
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
	

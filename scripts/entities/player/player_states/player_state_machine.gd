class_name PlayerStateMachine extends StateMachine

'''
PlayerStateMachine Class enforces PlayerStates for all states in the machine.
It also enforces that each state conforms to the valid PlayerStates across all characters.

Some states like attacks are character specific and should be named:
	"[player]_[state].gd"
Others that can be applied to any player like movement should be named:
	"player_[state].gd"
'''


func _ready() -> void:
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

class_name PlayerStateMachine extends StateMachine

'''
PlayerStateMachine Class enforces PlayerStates for all states in the machine.
It also enforces that each state conforms to the valid PlayerStates across all characters.

Some states like attacks are character specific and should be named:
	"[player]_[state].gd"
Others that can be applied to any player like movement should be named:
	"player_[state].gd"
'''

signal idle
signal moving
signal charging
signal attacking
signal attacking_charged
signal charging_special
signal attacking_special
signal attacking_charged_special
signal bursting
signal swap_in
signal swap_out

func _ready() -> void:
	for state_node in find_children("*"):
		assert(state_node is PlayerState)
		assert(state_node.name in PlayerState.VALID_STATES)
	super()
	state_changed.connect(func(_state):
		match (_state):
			PlayerState.IDLE:
				idle.emit()
			PlayerState.MOVING:
				moving.emit()
			PlayerState.CHARGING:
				charging.emit()
			PlayerState.ATTACKING:
				attacking.emit()
			PlayerState.ATTACKING_CHARGED:
				attacking_charged.emit()
			PlayerState.CHARGING_SPECIAL:
				charging_special.emit()
			PlayerState.ATTACKING_SPECIAL:
				attacking_special.emit()
			PlayerState.ATTACKING_CHARGED_SPECIAL:
				attacking_charged_special.emit()
			PlayerState.BURSTING:
				bursting.emit()
			PlayerState.SWAP_IN:
				swap_in.emit()
			PlayerState.SWAP_OUT:
				swap_out.emit()
		)

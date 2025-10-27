@abstract 
class_name PlayerState extends State

const IDLE = "Idle"
const MOVING = "Moving"
const CHARGING = "Charging"
const ATTACKING = "Attacking"
const ATTACKING_CHARGED = "AttackingCharged"
const CHARGING_SPECIAL = "ChargingSpecial"
const SPECIAL = "Special"
const BURSTING = "Bursting"
const SWAP_IN = "SwapIn"
const SWAP_OUT = "SwapOut"
const SLEEPING = "Sleeping"
const HIT_STUN = "HitStun"

const VALID_STATES := [IDLE, MOVING, CHARGING, ATTACKING, ATTACKING_CHARGED, CHARGING_SPECIAL, \
		SPECIAL, BURSTING, SWAP_IN, SWAP_OUT, SLEEPING, HIT_STUN]

var player: Player


## Saves instance of player as variable for all states.
func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state node must only be used with Player.")

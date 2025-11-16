@abstract 
class_name PlayerState extends State

const IDLE = "Idle"
const MOVING = "Moving"
const DASH = "Dash"
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
const ALT_ATTACK = "AltAttack"

const VALID_STATES := [IDLE, MOVING, DASH, CHARGING, ATTACKING, ATTACKING_CHARGED, CHARGING_SPECIAL, \
		SPECIAL, BURSTING, SWAP_IN, SWAP_OUT, SLEEPING, HIT_STUN, ALT_ATTACK]

var player: Player

## Saves instance of player as variable for all states.
func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state node must only be used with Player.")

func get_player_manager() -> PlayerManager:
	return player.player_manager
	
func get_players() -> Array[Player]:
	return player.player_manager.players

func team_hurt(damage: float):
	for x in get_players():
		if x is Player:
			# hurts all players
			x.try_damage(damage)

func team_effect(e: EntityEffect):
	for x in get_players():
		if x is Player:
			e.try_apply(x)

func team_heal(amount: float):
	for x in get_players():
		if x is Player:
			x.try_heal(amount)

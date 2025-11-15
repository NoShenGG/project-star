@abstract
class_name FortifierState extends EnemyState

const IDLE = "Idle"
const AGGRO = "Aggro"
const SHIELDING = "Shielding"
const DEAD = "DeadState"

const VALID_STATES := [IDLE, AGGRO, SHIELDING, DEAD]

var fortifier: Fortifier


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	fortifier = owner as Fortifier
	assert(fortifier != null, "The FortifierState state node must only be used with Fortifier.")

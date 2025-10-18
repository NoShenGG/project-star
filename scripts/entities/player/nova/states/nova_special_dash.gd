@tool
@icon("uid://cqoaj0qflq6xg")
class_name NovaSpecialDash extends MeleeAttackState

var nova: Nova


## Saves instance of Nova as variable
func _ready() -> void:
	nova = owner as Nova
	assert(nova != null, "Must only be used with Nova")

func enter(_prev_state: String, data := {}) -> void:
	damage_on_enter = false
	super(_prev_state, data)
	nova.give_dash()
	nova.dash(nova.special_dash_dist, false)
	await_frame()


func await_frame() -> void:
	# Wait two frames to allow hitbox to refresh
	await get_tree().physics_frame
	await get_tree().physics_frame
	do_damage()

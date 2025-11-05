@tool
class_name NovaComboState extends MeleeAttackState

var nova: Nova
@export var speed_scale_factor: float = 0.2


## Saves instance of Nova as variable
func _ready() -> void:
	nova = owner as Nova
	assert(nova != null, "Must only be used with Nova")
	
func physics_update(delta: float) -> void:
	if nova.closest_enemy != null \
			and Input.get_vector("move_up", "move_down", "move_right", "move_left") == Vector2.ZERO:
		nova.move_to(nova.closest_enemy.global_position, delta, 1.0)
	else:
		nova.move(delta, speed_scale_factor)
	nova.move_and_slide()

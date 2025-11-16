@tool
class_name ReneComboState extends MeleeAttackState

var rene: Rene
@export var speed_scale_factor: float = 0.2


## Saves instance of Rene as variable
func _ready() -> void:
	rene = owner as Rene
	assert(rene != null, "Must only be used with Rene")

func physics_update(delta: float) -> void:
	if rene.closest_enemy != null \
			and Input.get_vector("move_up", "move_down", "move_right", "move_left") == Vector2.ZERO:
		rene.move_to(rene.closest_enemy.global_position, delta, 1.0)
	else:
		rene.move(delta, speed_scale_factor)
	rene.move_and_slide()

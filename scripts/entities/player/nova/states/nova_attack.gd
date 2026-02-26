@tool
class_name NovaComboState extends MeleeAttackState

var nova: Nova
@export var speed_scale_factor: float = 0.2

func enter(_prev_state: String, _data := {}) -> void:
	super(_prev_state, _data)
	nova.invincible = true

## Saves instance of Nova as variable
func _ready() -> void:
	nova = owner as Nova
	assert(nova != null, "Must only be used with Nova")
	
func do_damage() -> void:
	if not hitbox.monitoring or not active or entity.death:
		return
	var hit = false
	for node in hitbox.get_overlapping_bodies():
		if node is Entity and (node as Entity).faction != entity.faction:
			if (node as Entity).try_damage(damage * entity.damage_mult):
				hit = true
	if hit:
		nova.enemy_hit.emit()
	
func physics_update(delta: float) -> void:
	if nova.closest_enemy != null \
			and Input.get_vector("move_up", "move_down", "move_right", "move_left") == Vector2.ZERO:
		nova.move_to(nova.closest_enemy.global_position, delta, 1.0)
	else:
		nova.move(delta, speed_scale_factor)
	nova.move_and_slide()
	
func exit() -> void:
	super()
	nova.invincible = false

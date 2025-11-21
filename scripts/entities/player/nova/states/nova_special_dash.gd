@tool
@icon("uid://cqoaj0qflq6xg")
class_name NovaSpecialDash extends MeleeAttackState

var nova: Nova
var time: float
var direction: Vector3
var anim_done: bool = false


## Saves instance of Nova as variable
func _ready() -> void:
	nova = owner as Nova
	assert(nova != null, "Must only be used with Nova")

func enter(_prev_state: String, data := {}) -> void:
	damage_on_enter = false
	super(_prev_state, data)
	direction = -nova.basis.z.normalized()
	anim_done = false
	animation.stop.connect(anim_stop)
	time = duration
	nova.collision_mask = 1
	
func anim_stop() -> void:
	anim_done = true

func update(_delta: float) -> void:
	if time <= 0 and anim_done:
		end()

func physics_update(delta: float) -> void:
	delta = min(delta, time)
	time -= delta
	nova.velocity = direction * nova.special_dash_dist / duration
	nova.move_and_slide()
			
func end() -> void:
	finished.emit()
		
func exit() -> void:
	do_damage()
	nova.collision_mask = 3
	active = false
	hitbox.monitoring = false
	animation.stop.disconnect(anim_stop)

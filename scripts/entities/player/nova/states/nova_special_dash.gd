@tool
@icon("uid://cqoaj0qflq6xg")
class_name NovaSpecialDash extends MeleeAttackState

var nova: Nova
var anim_dur: float
var time: float
var dash_target_dist: float
var anim_done: bool = false


## Saves instance of Nova as variable
func _ready() -> void:
	nova = owner as Nova
	assert(nova != null, "Must only be used with Nova")

func enter(_prev_state: String, data := {}) -> void:
	damage_on_enter = false
	super(_prev_state, data)
	var ray = nova.ray
	ray.force_shapecast_update()
	dash_target_dist = min(nova.global_position.distance_to(ray.get_collision_point(0))-0.5, nova.dash_distance) \
			if ray.is_colliding() else nova.special_dash_dist
	anim_dur = animation.playback.get_current_length()
	time = anim_dur
	anim_done = false
	animation.stop.connect(anim_stop)
	
func anim_stop() -> void:
	anim_done = true

func update(_delta: float) -> void:
	if time <= 0 and anim_done:
		end()

func physics_update(delta: float) -> void:
	delta = min(delta, time)
	time -= delta
	nova.global_position += Vector3.FORWARD.rotated(Vector3.UP, nova.rotation.y) \
		* dash_target_dist * delta / anim_dur
			
func end() -> void:
	finished.emit()
		
func exit() -> void:
	do_damage()
	active = false
	hitbox.monitoring = false
	animation.stop.disconnect(anim_stop)

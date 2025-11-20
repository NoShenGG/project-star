@tool
extends AnimatedOneshotState

var player: Player
var anim_dur: float
var time: float
var dash_target_dist: float
var anim_done: bool = false

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "Must be used with a player")

func enter(_prev_state: String, _data := {}):
	player._can_dash = false
	player.invincible = true
	super(_prev_state, _data)
	var ray = player.ray
	ray.force_shapecast_update()
	dash_target_dist = min(player.global_position.distance_to(ray.get_collision_point(0))-0.5, player.dash_distance) \
			if ray.is_colliding() else player.dash_distance

	anim_dur = duration
	if animation != null:
		anim_dur = animation.playback.get_current_length()
		animation.stop.connect(anim_stop)
		anim_done = false
	else:
		anim_done = true
	time = anim_dur
	
func anim_stop() -> void:
	anim_done = true

func update(_delta: float) -> void:
	if time <= 0 and anim_done:
		trigger_finished.emit("Moving")

func physics_update(delta: float) -> void:
	delta = min(delta, time)
	time -= delta
	player.global_position += Vector3.FORWARD.rotated(Vector3.UP, player.rotation.y) * 1.5 \
		* dash_target_dist * delta / anim_dur
			
func end() -> void:
	pass
		
func exit() -> void:
	player.invincible = false
	if animation != null:
		animation.stop.disconnect(anim_stop)
	get_tree().create_timer(player.dash_cd).timeout.connect(player.give_dash)

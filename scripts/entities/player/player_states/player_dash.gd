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
	if not player._can_dash:
		trigger_finished.emit("Moving")
		return
	player._can_dash = false
	super(_prev_state, _data)
	var ray = player.ray
	ray.force_shapecast_update()
	dash_target_dist = min(player.global_position.distance_to(ray.get_collision_point(0))-0.5, player.dash_distance) \
			if ray.is_colliding() else player.dash_distance
	anim_dur = 0.2 #animation.playback.get_current_length() <- Current anim too long lol
	time = anim_dur
	anim_done = false
	animation.stop.connect(anim_stop)
	
func anim_stop() -> void:
	anim_done = true

func update(_delta: float) -> void:
	if time <= 0: #and anim_done <- Current anim too long lol:
		trigger_finished.emit("Moving")

func physics_update(delta: float) -> void:
	delta = min(delta, time)
	time -= delta
	player.global_position += Vector3.FORWARD.rotated(Vector3.UP, player.rotation.y) \
		* dash_target_dist * delta / anim_dur
			
func end() -> void:
	pass
		
func exit() -> void:
	animation.stop.disconnect(anim_stop)
	get_tree().create_timer(player.dash_cd).timeout.connect(player.give_dash)

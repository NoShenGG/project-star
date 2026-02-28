@tool
extends AnimatedOneshotState

var player: Player
var time: float
var direction: Vector3
var anim_done: bool = false

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "Must be used with a player")

func enter(_prev_state: String, _data := {}):
	player._can_dash = false
	player.invincible = true
	super(_prev_state, _data)
	direction = -player.basis.z.normalized()
	if animation != null:
		animation.stop.connect(anim_stop)
		anim_done = false
	else:
		anim_done = true
	time = duration
	
func anim_stop() -> void:
	anim_done = true

func update(_delta: float) -> void:
	if time <= 0 and anim_done:
		trigger_finished.emit("Moving")

func physics_update(delta: float) -> void:
	delta = min(delta, time)
	time -= delta
	player.velocity = direction * player.dash_distance / duration
	player.move_and_slide()
			
func end() -> void:
	pass
		
func exit() -> void:
	player.invincible = false
	if animation != null:
		animation.stop.disconnect(anim_stop)
	get_tree().create_timer(player.dash_cd).timeout.connect(player.give_dash)

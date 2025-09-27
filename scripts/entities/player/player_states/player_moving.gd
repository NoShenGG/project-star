extends PlayerState

var target_velocity := Vector3.ZERO
var old_velocity := Vector3.ZERO
var velocity_smoothing_counter: float = 0

func enter(_previous_state_path: String, data := {}) -> void:
	player.velocity = Vector3.ZERO
	target_velocity = data.get("taget_velocity", Vector3.ZERO);
	old_velocity = data.get("old_velocity", Vector3.ZERO);
	velocity_smoothing_counter = data.get("velocity_smoothing_counter", 0)
	

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction = Input.get_vector("move_up", "move_down", "move_right", "move_left")
	
	direction = Vector3(direction.x, 0, direction.y)
	direction = direction.normalized()
	direction = direction.rotated(Vector3.UP, deg_to_rad(-45))
	direction = direction * player._movement_speed
	
	if direction != target_velocity:
		velocity_smoothing_counter = 0
		old_velocity = player.velocity
	if velocity_smoothing_counter < 1:
		velocity_smoothing_counter += delta / player.input_smoothing_time
	target_velocity = direction
	
	if Input.is_action_just_pressed("dodge"):
		player.dash()
	player.velocity = old_velocity.lerp(target_velocity, clamp(velocity_smoothing_counter, 0, 1))
	if player.velocity:
		player.look_at(player.global_position + player.velocity)
	player.move_and_slide()

	if Input.is_action_just_pressed("synergy_burst"):
		finished.emit(BURSTING)
	elif Input.is_action_just_pressed("special_attack") and player.has_special:
		finished.emit(CHARGING_SPECIAL)
	elif Input.is_action_just_pressed("basic_attack"):
		finished.emit(CHARGING)
	elif not Input.get_vector("move_down", "move_up", "move_left", "move_right"):
		finished.emit(IDLE)
			
func end() -> void:
	pass
		
func exit() -> void:
	pass

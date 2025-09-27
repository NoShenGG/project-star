extends PlayerState

var target_velocity := Vector3.ZERO
var old_velocity := Vector3.ZERO
var velocity_smoothing_counter: float = 0
var time_active: float = 0

func enter(_previous_state_path: String, _data := {}) -> void:
	time_active = 0;
	

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction = Input.get_vector("move_up", "move_down", "move_right", "move_left")
	
	direction = Vector3(direction.x, 0, direction.y)	
	direction = direction.normalized()
	direction = direction.rotated(Vector3.UP, deg_to_rad(-45))
	direction = direction * player._movement_speed * \
			(0.25 if time_active > player.max_click_time else 1.0)
	
	if direction != target_velocity:
		velocity_smoothing_counter = 0
		old_velocity = player.velocity
	if velocity_smoothing_counter < 1:
		velocity_smoothing_counter += delta / player.input_smoothing_time
	target_velocity = direction
	
	player.velocity = old_velocity.lerp(target_velocity, clamp(velocity_smoothing_counter, 0, 1))
	if player.velocity:
		player.look_at(player.global_position + player.velocity)
	player.move_and_slide()

	time_active += delta

	if Input.is_action_just_pressed("synergy_burst"):
		finished.emit(BURSTING)
	if Input.is_action_just_pressed("dodge"):
		player.dash()
		finished.emit(MOVING if player.velocity else IDLE, {"target_velocity": target_velocity, \
				"old_velocity":old_velocity, "velocity_smoothing_counter":velocity_smoothing_counter})
	elif  Input.is_action_just_released("basic_attack"):
		if time_active > player.attack_charge_time:
			finished.emit(ATTACKING_CHARGED, {"charge_time": time_active})
		else:
			finished.emit(ATTACKING)
		
func end() -> void:
	pass
	

func exit() -> void:
	pass

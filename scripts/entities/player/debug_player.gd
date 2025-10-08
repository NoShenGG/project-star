## Debug Player Implementation
class_name DebugPlayer extends Player


func _physics_process(delta):
	super(delta)
	var direction := Input.get_vector("move_up", "move_down", "move_right", "move_left")
	
	direction = direction.rotated(deg_to_rad(45))
	direction = direction * _movement_speed
	
	target_velocity.x = direction.x
	target_velocity.z = direction.y
	
	velocity = target_velocity.lerp(velocity, clamp(pow(0.1, input_smoothing_speed * delta), 0, 1))
	if velocity:
		look_at(global_position + velocity)
	move_and_slide()
	
	if Input.is_action_just_pressed("dodge"):
		dash()

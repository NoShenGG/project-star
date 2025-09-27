## Debug Player Implementation
class_name DebugPlayer extends Player

var target_velocity := Vector3.ZERO
var old_velocity := Vector3.ZERO
var velocity_smoothing_counter: float = 0

func _physics_process(delta):
	super(delta)
	var direction = Input.get_vector("move_up", "move_down", "move_right", "move_left")
	
	direction = Vector3(direction.x, 0, direction.y)
	direction = direction.normalized()
	direction = direction.rotated(Vector3.UP, deg_to_rad(-45))
	direction = direction * _movement_speed
	
	if direction != target_velocity:
		velocity_smoothing_counter = 0
		old_velocity = velocity
	if velocity_smoothing_counter < 1:
		velocity_smoothing_counter += delta / input_smoothing_time
	target_velocity = direction
	
	if Input.is_action_just_pressed("dodge"):
		dash()
	velocity = old_velocity.lerp(target_velocity, clamp(velocity_smoothing_counter, 0, 1))
	if velocity:
		look_at(global_position + velocity)
	move_and_slide()

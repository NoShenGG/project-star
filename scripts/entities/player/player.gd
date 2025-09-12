class_name Player extends Entity

var target_velocity = Vector3.ZERO
var pos: Vector3

func _ready() -> void:
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)

func _physics_process(delta):
	# TODO Track player location via GameManager instead
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_left"):
		direction.x += 1
	if Input.is_action_pressed("move_right"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		direction.z += 1
	if Input.is_action_pressed("move_down"):
		direction.z -= 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		
	if Input.is_action_just_pressed("dodge"):
		direction *= 7
	
	target_velocity.x = direction.x * _movement_speed
	target_velocity.z = direction.z * _movement_speed
	
	velocity = target_velocity
	move_and_slide()

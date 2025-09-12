class_name Player extends Entity

var target_velocity = Vector3.ZERO
var pos: Vector3

func _ready() -> void:
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)

func _physics_process(delta):
	# TODO Track player location via GameManager instead
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)
	var direction : Vector2 = Vector2.ZERO
	direction = Input.get_vector("move_right", "move_left", "move_down", "move_up")
	
	if direction.length() > 1:
		direction = direction.normalized()
		
	if Input.is_action_just_pressed("dodge"):
		direction *= 7
	
	target_velocity.x = direction.x * _movement_speed
	target_velocity.z = direction.y * _movement_speed
	
	velocity = target_velocity
	move_and_slide()

extends CharacterBody3D
class_name PlayerButLeftClick
# Should Really Be Renamed to Enemy 
# and Get Rid of All Input Checking Except for
# Player Attack ("Left Click") on Update
# and then Ideally you see if Enemy is Within Range of Player
# Through Like a Position Vector (Making Sure It Faces the Enemy)
var speed = 14
var target_velocity = Vector3.ZERO
var stunnable = true
var decrease_rate = 100.0
var stun_time = 5.0
const PLAYER_RUN_SPEED = 14

func _physics_process(delta):
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
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	velocity = target_velocity
	move_and_slide()
		
func _process(delta):
	if Input.is_action_just_pressed("basic_attack"):
		get_stun_points(5)
		
	if (is_stunned() && stunnable):
		get_stunned()
	
	if (!stunnable):
		reset_stun_meter(delta)

# My Deepest Thanks to Some YouTuber named 
# Robin Lamb for No Reason in Particular
# (Definitely Did Not Ctrl+C Ctrl+V from 
# Their Video, "3D Health Bar in Godot 4")

func get_stun_points(stun_points):
	if (!stunnable):
		return
		
	if ($SubViewport/StunMeter.max_value - $SubViewport/StunMeter.value) < stun_points:
		stun_points = $SubViewport/StunMeter.value 
	$SubViewport/StunMeter.value += stun_points

func is_stunned():
	return $SubViewport/StunMeter.value >= $SubViewport/StunMeter.max_value

func get_stunned():
	stunnable = false
	speed = 0
	$StunTimer.start(stun_time)
	
func reset_stun_meter(delta):
	if $SubViewport/StunMeter.value > 0:
		$SubViewport/StunMeter.value -= decrease_rate * delta
		
	if $SubViewport/StunMeter.value < 0:
		$SubViewport/StunMeter.value = 0	

func _on_stun_timer_timeout() -> void:
	stunnable = true
	speed = PLAYER_RUN_SPEED
	

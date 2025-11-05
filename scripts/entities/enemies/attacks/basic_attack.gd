extends MeshInstance3D

var can_attack: bool = true
var attack_speed: Timer

func _ready() -> void:
	#Create imer to for attack speed
	attack_speed = Timer.new()
	add_child(attack_speed)
	attack_speed.wait_time = 1.0
	attack_speed.connect('timeout', Callable(self, 'attack_reset'))

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("basic_attack") and can_attack:
		#play animation here
		attack_speed.start()
		can_attack = false
		#print("attack")
		$".".visible = true
		
	if Input.is_action_just_pressed("move_left"):
		$".".position.x += 0.5
		$".".position.x = clamp(position.x, -0.5,0.5)
	if Input.is_action_just_pressed("move_right"):
		$".".position.x -= 0.5 
		$".".position.x = clamp(position.x, -0.5,0.5)
	if Input.is_action_just_pressed("move_up"):
		$".".position.z += 0.5
		$".".position.z = clamp(position.z, -0.5,0.5)
	if Input.is_action_just_pressed("move_down"):
		$".".position.z -= 0.5
		$".".position.z = clamp(position.z, -0.5,0.5)

func attack_reset():
	attack_speed.stop()
	$".".visible = false
	can_attack = true
	$".".position.x = 0
	$".".position.z = 0

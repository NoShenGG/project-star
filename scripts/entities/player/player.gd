@abstract
@icon("uid://br5yk4evttuoq")
class_name Player extends Entity

signal player_dashed
signal special_cooldown_update(percent: float)
signal special_available

@onready var ray: ShapeCast3D = $ForwardRay
@onready var player_manager: PlayerManager = owner as PlayerManager

@export var targetting_box: Area3D
@export_category("Input Thresholds")
@export var max_click_time: float = 0.25
@export_category("Attack")
@export var attack_charge_time: float = 0.5
@export var max_attack_charges: int = 1
@export var combo_reset_time: float = 0.6
@export_category("Special")
@export var special_charge_time: float = 0.5
@export var max_special_charges: int = 3
@export var special_cd: float = 5
@export_category("Movement Parameters")
@export var input_smoothing_speed: float = 8
@export var dash_cd: float = 1
@export var dash_distance: float = 5

var _can_dash := true
var _has_special := true
var closest_enemy: Enemy = null
var special_cd_timer: SceneTreeTimer

var target_velocity := Vector3.ZERO

func _ready() -> void:
	super()
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)

func _process(_delta: float) -> void:
	super(_delta)
	if special_cd_timer != null:
		special_cooldown_update.emit((special_cd - special_cd_timer.time_left)/special_cd)
		if special_cd_timer.time_left == 0:
			special_cd_timer = null
	if closest_enemy != null:
		if closest_enemy.death or targetting_box.get_overlapping_bodies().size() == 0:
			closest_enemy = null
	for body in targetting_box.get_overlapping_bodies():
		if body is Enemy:
			if body.death:
				continue
			if closest_enemy == null:
				closest_enemy = body as Enemy
			elif body.global_position.distance_to(global_position) < closest_enemy.global_position.distance_to(global_position):
				closest_enemy = body as Enemy 

func _physics_process(_delta):
	# TODO Track player location via GameManager instead
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)

	
## Used for player manager to handle check if Player is in valid state to swap
func can_swap() -> bool:
	return ($StateMachine.state as State).name in ["Idle", "Moving"];
	
func move(delta: float, speed_scale := 1.0) -> void:
	var direction := Input.get_vector("move_up", "move_down", "move_right", "move_left")
	
	direction = direction.rotated(deg_to_rad(45))
	direction = direction * speed * speed_scale
	
	target_velocity.x = direction.x
	target_velocity.z = direction.y
	
	velocity = target_velocity.lerp(velocity, clamp(pow(0.1, input_smoothing_speed * delta), 0, 1))
	if velocity:
		look_at(global_position + velocity)
	move_and_slide()
	
func move_translate(delta: float, speed_scale := 1.0) -> void:
	var direction := Input.get_vector("move_up", "move_down", "move_right", "move_left")
	
	direction = direction.rotated(deg_to_rad(45))
	direction = direction * speed * speed_scale
	
	target_velocity.x = direction.x
	target_velocity.z = direction.y
	
	velocity = target_velocity.lerp(velocity, clamp(pow(0.1, input_smoothing_speed * delta), 0, 1))
	move_and_slide()	
	
func move_to(target: Vector3, delta: float, speed_scale := 0.5):
	look_at(Vector3(target.x, global_position.y, target.z))
	var pos_delta = target - global_position
	if pos_delta.length() > 1.0:
		pos_delta = pos_delta.normalized() * speed * speed_scale
		target_velocity.x = pos_delta.x
		target_velocity.z = pos_delta.z
		velocity = target_velocity.lerp(velocity, clamp(pow(0.1, input_smoothing_speed * delta), 0, 1))
	else:
		velocity = Vector3.ZERO
	move_and_slide()
	
func use_special():
	if _has_special:
		_has_special = false
		special_cooldown_update.emit(0)
		
func set_special_cd():
	special_cd_timer = get_tree().create_timer(special_cd)
	special_cd_timer.timeout.connect(func special_cd_timeout(): 
		special_available.emit()
		_has_special = true)
	
func give_dash():
	_can_dash = true
	
func trigger_death() -> void:
	death = true
	killed.emit()
	push_error("Player has Died")

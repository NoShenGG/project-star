@abstract
@icon("uid://br5yk4evttuoq")
class_name Player extends Entity

signal player_dashed

@onready var ray: ShapeCast3D = $ForwardRay

@export var targetting_box: Area3D
@export_category("Input Thresholds")
@export var max_click_time: float = 0.25
@export_category("Attack")
@export var charged_attack_dmg: int = 10
@export var attack_charge_time: float = 0.5
@export var max_attack_charges: int = 1
@export var combo_reset_time: float = 0.6
@export_category("Special")
@export var special_dmg: int = 25
@export var charged_special_dmg: int = 25
@export var special_charge_time: float = 0.5
@export var max_special_charges: int = 3
@export var special_cd: float = 5
@export_category("Movement Parameters")
@export var input_smoothing_speed: float = 8
@export var dash_cd: float = 1
@export var dash_distance: float = 5

var can_dash := true
var has_special := true
var closest_enemy: Enemy = null

var target_velocity := Vector3.ZERO

func _ready() -> void:
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)

func _physics_process(_delta):
	# TODO Track player location via GameManager instead
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)

	
## Used for player manager to handle check if Player is in valid state to swap
func can_swap() -> bool:
	return ($StateMachine.state as State).name in ["Idle", "Moving"];
	
func move(delta: float, speed_scale := 1.0) -> void:
	var direction := Input.get_vector("move_up", "move_down", "move_right", "move_left")
	
	direction = direction.rotated(deg_to_rad(45))
	direction = direction * _movement_speed * speed_scale
	
	target_velocity.x = direction.x
	target_velocity.z = direction.y
	
	velocity = target_velocity.lerp(velocity, clamp(pow(0.1, input_smoothing_speed * delta), 0, 1))
	if velocity:
		look_at(global_position + velocity)
	move_and_slide()
	
func move_to(target: Vector3, delta: float, speed_scale := 1.0):
	var direction = global_position.direction_to(target)
	
	direction = direction * _movement_speed * speed_scale
	
	target_velocity.x = direction.x
	target_velocity.z = direction.y
	
	look_at(global_position + target_velocity)
	velocity = target_velocity.lerp(velocity, clamp(pow(0.1, input_smoothing_speed * delta), 0, 1))
	move_and_slide()
	

## Dash function, uses raycast to prevent clipping world but ignores entities
func dash(dist := dash_distance, emit : bool = true) -> void:
	if not can_dash:
		return
	if (emit): player_dashed.emit()
	can_dash = false
	ray.force_shapecast_update()
	var dash_target_dist = min(position.distance_to(ray.get_collision_point(0))-0.5, dash_distance) \
			if ray.is_colliding() else dist
	position += Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * dash_target_dist
	get_tree().create_timer(dash_cd).timeout.connect(func(): can_dash = true)
	
func _entered_vision(body: Node3D) -> void:
	if body is Enemy:
		if closest_enemy == null:
			closest_enemy = body as Enemy
		elif body.global_position.distance_to(self.global_position) < closest_enemy.global_position.distance_to(self.global_position):
			closest_enemy = body as Enemy 
	
func _exited_vision(body: Node3D) -> void:
	if body as Enemy == closest_enemy:
		closest_enemy = null
	
func trigger_death() -> void:
	push_error("Player has Died")

@abstract
class_name Player extends Entity

@onready var ray: RayCast3D = $ForwardRay

@export_category("Input Thresholds")
@export var max_click_time: float = 0.25
@export var attack_charge_time: float = 0.5
@export var special_charge_time: float = 0.75
@export_category("Movement Parameters")
@export var input_smoothing_time: float = 0.1
@export var dash_distance: float = 5
@export_category("Cooldowns")
@export var special_cd: float = 5
@export var dash_cd: float = 1

var can_dash := true
var has_special := true

func _ready() -> void:
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)

func _physics_process(_delta):
	# TODO Track player location via GameManager instead
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)

	
## Used for player manager to handle check if Player is in valid state to swap
func can_swap() -> bool:
	return ($StateMachine.state as State).name in ["Idle", "Moving"];

## Dash function, uses raycast to prevent clipping world but ignores entities
func dash(dist := dash_distance) -> void:
	if not can_dash:
		return
	can_dash = false
	ray.force_raycast_update()
	var dash_target_dist = min(position.distance_to(ray.get_collision_point())-0.5, dash_distance) \
			if ray.is_colliding() else dist
	position += Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * dash_target_dist
	get_tree().create_timer(dash_cd).timeout.connect(func(): can_dash = true)

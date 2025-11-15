@icon("uid://cgy1hfljlnsj3")
class_name Enemy extends Entity

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@export var vision_radius: float = 1
@export var attack_radius: float = 1

var ai_override: bool = false
var ai_override_target
var ai_override_speed: float = 1.0

signal move
signal idle

var moving : bool : 
	set(value):
		if (moving != value):
			if (value):
				move.emit()
			else:
				idle.emit()
		moving = value

func _init() -> void:
	faction = Faction.HOSTILE

func _ready() -> void:
	super()
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector3):
	var move_distance : float = global_position.slide(Vector3.UP).distance_to(movement_target.slide(Vector3.UP))
	if (!moving and move_distance > 1):
		moving = true
	navigation_agent.target_position = movement_target

func _process(delta: float) -> void:
	super(delta)

func _physics_process(_delta: float) -> void:
	if (death): return
	
	if ai_override and ai_override_target != null:
		navigation_agent.target_position = ai_override_target
	
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		moving = false
		return
	
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position)
	if navigation_agent.avoidance_enabled:
		navigation_agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity * (ai_override_speed if ai_override else speed)
	move_and_slide()
	
func set_ai_override(enable: bool, target = null, target_speed := 10):
	ai_override = enable
	if enable:
		ai_override_target = target
		ai_override_speed = target_speed
	else:
		ai_override_target = null

class_name TendrilEnemy
extends Enemy

@export var grab_range: float = 7.0
@export var grab_cooldown_sec: float = 3.5

@export var pull_strength: float = 12.0
@export var max_pull_distance: float = 20.0
@export var stun_trigger_distance: float = 1.0

@export var grab_duration_ms: int = 2000

@onready var cooldown: Timer = $GrabCooldown
@onready var aggro_area: Area3D = $AggroArea
@onready var nav: NavigationAgent3D = $NavigationAgent3D

var target_node: Node3D = null

func _ready() -> void:
	nav.velocity_computed.connect(Callable(_on_velocity_computed))
	cooldown.wait_time = grab_cooldown_sec
	cooldown.one_shot = true

	aggro_area.body_entered.connect(_on_aggro_area_body_entered)
	aggro_area.body_exited.connect(_on_aggro_area_body_exited)

	nav.avoidance_enabled = false
	nav.path_desired_distance = 0.2
	nav.target_desired_distance = 0.2

func _process(delta: float) -> void:
	super._process(delta)

	if target_node:
		for child in target_node.get_children():
			if child is GrabbedEffect:
				(child as GrabbedEffect).pull_anchor = global_position
				break

		set_movement_target(target_node.global_position)
		_try_grab(target_node)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not target_node:
		return

	var dir := Vector3.ZERO
	if NavigationServer3D.map_get_iteration_id(nav.get_navigation_map()) != 0 and not nav.is_navigation_finished():
		dir = (nav.get_next_path_position() - global_position).normalized()
	else:
		dir = (target_node.global_position - global_position).normalized()

	if dir.length() > 0.001:
		velocity = dir * _movement_speed
		move_and_slide()

func _try_grab(target: Node3D) -> void:
	if cooldown.time_left > 0.0:
		return
	if not is_instance_valid(target):
		return
	if global_position.distance_to(target.global_position) > grab_range:
		return
	if not (target is Entity):
		return

	for child in target.get_children():
		if child is EntityEffect and (child as EntityEffect).id == EntityEffect.EffectID.GRABBED:
			return

	var effect := GrabbedEffect.new()
	effect.pull_strength = pull_strength
	effect.max_pull_distance = max_pull_distance
	effect.stun_trigger_distance = stun_trigger_distance
	effect.stun_duration_ms = grab_duration_ms
	effect.pull_anchor = global_position

	(target as Entity).apply_effect(effect)
	cooldown.start()

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity * _movement_speed
	move_and_slide()

func _on_aggro_area_body_entered(body: Node3D) -> void:
	if body is Player:
		target_node = body

func _on_aggro_area_body_exited(body: Node3D) -> void:
	if body == target_node:
		target_node = null

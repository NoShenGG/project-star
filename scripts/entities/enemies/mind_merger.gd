class_name MindMerger extends Enemy

signal unmerge

@export var flee_state: State
@export_category("Rotation")
@export var ROTATION_SPEED_DEG_PER_SEC: float = 60
@export var MIN_ROTATION_WAIT:float = 3
@export var MAX_ROTATION_WAIT: float = 8
@export_category("Expansion")
@export var MINION_OFFSET: float = 3
@export var MAX_EXPANSION: float = 2
@export var EXPANSION_SPEED: float = 0.5
@export var EXPANSION_CURVE: Curve

@onready var vision = $Vision
@onready var damage = $Damage
@onready var laser_scene = load("res://scenes/dev/christian_d/merger_laser.tscn")

# Merger Vars
var minions: Array[Merged] = []
var lasers: Array = []
var rotation_offset: float = 0
var rotation_flip_wait: float = 0
var rotation_flip_mult: int = 1
var expansion_time: float = 0
var expansion_mult: int = 1
var hit_cooldown: Array[Node3D] = []

var col_shape_frames: int = 0:
	get():
		col_shape_frames = (col_shape_frames + 1) % 3
		return col_shape_frames


func _enter_tree() -> void:
	# Waits 2 frames for area3d to update
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# Gets the closest enemies to the merger sorted by distance 
	var closest: Array = vision.get_overlapping_bodies() \
		.filter(func(e): return e is Enemy and not e is MindMerger)
	vision.monitoring = false
	if closest.size() < 3:
		return
	closest.sort_custom(func(a: Enemy,b: Enemy): \
			return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position))
	
	# Attempts to merge with at most 6 enemies
	for body in closest:
		if minions.size() >= 6:
			break
		body = body as Enemy
		var effect = Merged.new(self)
		if body.apply_effect(effect):
			minions.append(effect)
			effect.enemy_killed.connect(remove_minion)
			
	# Generates laser vfx for each merged
	for minion in minions:
		var laser = laser_scene.instantiate() as MergerLaser
		laser.node_a = minion._entity
		laser.node_b = minions.get(
			(minions.find(minion) + 1) % minions.size())._entity
		add_child(laser)
		lasers.append(laser)


func _process(delta: float) -> void:
	super(delta)
	
	## Calculates Minion Rotation
	if (rotation_flip_wait <= 0):
		rotation_flip_wait = lerp(MIN_ROTATION_WAIT, MAX_ROTATION_WAIT, randf())
		rotation_flip_mult *= -1
	rotation_offset += ROTATION_SPEED_DEG_PER_SEC * delta * rotation_flip_mult
	if (abs(rotation_offset) >= 360): # Float Modulus for Offset Wrapping
		rotation_offset -= sign(rotation_offset)*360
	rotation_flip_wait -= delta # Reduce cooldown Timer	
	
	## Calculates Minion Expansion
	expansion_time += EXPANSION_SPEED * delta * expansion_mult
	if (expansion_time >= 1 or expansion_time <= 0):
		expansion_mult *= -1
		expansion_time += EXPANSION_SPEED * delta * expansion_mult
	
	## Calculates Minion Positions and sends to Minions
	for i in range(minions.size()):
		minions[i].set_target( \
			global_position + (Vector3.RIGHT * (MINION_OFFSET + MAX_EXPANSION * EXPANSION_CURVE.sample(expansion_time))) \
			.rotated(Vector3.UP, deg_to_rad(i * 360.0 / minions.size() + rotation_offset)))
	if damage.monitoring:
		for body in damage.get_overlapping_bodies():
			if body is Player and not hit_cooldown.has(body):
				hit_cooldown.append(body)
				get_tree().create_timer(1.0).timeout.connect(func(): hit_cooldown.erase(body))
				body = body as Player
				body.try_damage(0.1)


func _physics_process(_delta: float) -> void:
	super(_delta)
	if col_shape_frames == 0:
		update_collision_shape()


func update_collision_shape():
	if minions.size() < 3:
		return
	var prism_points: PackedVector3Array = PackedVector3Array()
	
	for effect in minions:
		prism_points.append(effect._entity.global_position - global_position)
		
	for i in range(minions.size() - 1, -1, -1):
		prism_points.append(minions[i]._entity.global_position - global_position + Vector3.UP * 2)
		
	var shape = ConvexPolygonShape3D.new()
	shape.points = prism_points
	
	damage.get_child(0).free()
	var obj = CollisionShape3D.new()
	obj.shape = shape
	damage.add_child(obj)
	damage.global_position = global_position


## Unmerges a Minion, Reconnects VFX. Removes all minions if <3 
func remove_minion(effect: Merged) -> void:
	if minions.has(effect):
		var idx := minions.find(effect)
		lasers[(idx - 1) % lasers.size()].node_b = \
			minions.get((idx + 1) % minions.size())._entity
		lasers.pop_at(idx).queue_free()
		minions.erase(effect)
		effect.active = false
		if minions.size() <= 2:
			for temp in minions:
				temp.active = false
			for laser in lasers:
				laser.queue_free()
			minions.clear()
			lasers.clear()
			damage.monitoring = false
			state_machine.state.trigger_finished.emit(flee_state.get_path())

func trigger_death():
	super()
	for temp in minions:
		temp.active = false
	for laser in lasers:
		laser.queue_free.call_deferred()
	minions.clear.call_deferred()
	lasers.clear.call_deferred()
	damage.monitoring = false
	

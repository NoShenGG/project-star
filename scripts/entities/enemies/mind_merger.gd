class_name MindMerger extends Enemy

signal update(pos: Array[Vector3])
signal reindex(arr: Array[int])
signal unmerge

@export_category("Rotation")
@export var ROTATION_SPEED_DEG_PER_SEC: float = 60
@export var MIN_ROTATION_WAIT:float = 3
@export var MAX_ROTATION_WAIT: float = 8
@export_category("Expansion")
@export var MINION_OFFSET: float = 7
@export var MAX_EXPANSION: float = 2
@export var EXPANSION_SPEED: float = 0.5
@export var EXPANSION_CURVE: Curve
@export_category("Movement")
@export var FOLLOW_MIN_DIST: float = 5

# Merger Vars
var minion_pos: Array[Vector3] = []
var rotation_offset: float = 0
var rotation_flip_wait: float = 0
var rotation_flip_mult: int = 1
var expansion_time: float = 0
var expansion_mult: int = 1

# Player Reference to compute target
var player: Player

	
func setup(_player: Player, num: int):
	player = _player
	minion_pos.resize(num)
	
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
	for i in range(minion_pos.size()):
		minion_pos[i] = global_position + (Vector3.RIGHT * (MINION_OFFSET + MAX_EXPANSION * EXPANSION_CURVE.sample(expansion_time))).rotated(Vector3.UP, deg_to_rad(i * 360 / minion_pos.size() + rotation_offset))
	update.emit(minion_pos)

	## Sets Movement Target to be FOLLOW_MIN_DIST from Player. If has no Minions, Follow Twice as far.
	set_movement_target(player.global_position-(player.global_position-global_position).normalized()*FOLLOW_MIN_DIST*(2 if minion_pos.size() == 0 else 1))


## Unregisteres Minion from Merger, Reduces Shape to one less Vertex
func remove_minion(n: int) -> void:
	if minion_pos.size() == 3:
		unmerge.emit()
		minion_pos.clear()
		return
	minion_pos.remove_at(n)
	var new_index = PackedByteArray()
	new_index.resize(minion_pos.size()+1)
	var j = 0
	for i in range(minion_pos.size()+1):
		if i == n:
			j -= 1
		new_index[i] = j
		j += 1
	reindex.emit(new_index)
		
func trigger_death():
	unmerge.emit()
	super()

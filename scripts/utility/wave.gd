@icon("res://addons/fmod/icons/bank_icon.svg")
@tool
extends Node3D

class_name Wave

@export var enemies: Array[PackedScene]

# Elimination-based wave progression, could also implement time-based
# @export_category("Wave Type")
# @export var isEliminationBased = true
## how many enemys that are still alive before we consider the wave ended (ie. Stragglers)
@export var enemiesLeftUntilNextWave = 0

signal started
signal ended

@export_category("Which areas will this wave spawn in?")
@export var spawn_areas: Array[SpawnArea]

@export_category("Set or Random Spawn Areas for enemy spawning?")
@export var setSpawnAreas := false


@export_category("If you said yes, type the spawn area index for each enemy.")
@export var spawnAreaIndices : Array[int] : 
	set(value):
		var safe : bool = setSpawnAreas
		for i in value:
			if (i >= spawn_areas.size() and i >= 0):
				safe = false
				break
		if (safe):
			spawnAreaIndices = value

@onready var active = false

func _ready():
	if (Engine.is_editor_hint()):
		return
	
	ended.connect(get_parent()._on_wave_end)

func start():
	assert(not setSpawnAreas || enemies.size() == spawnAreaIndices.size(), "ERROR: Each enemy must have a set spawn area! The Enemies list and Spawn Area Indices list must have the same length.")
	assert(not setSpawnAreas || spawnAreaIndices.all(valid_area_ind), "ERROR: Spawn Area Indices must be a valid index of the Spawn Areas list!")
	
	active = true
	for i in range(0, enemies.size()):
		var n = enemies[i]
		var area = spawn_areas[randi_range(0, spawn_areas.size() - 1)] if not setSpawnAreas else spawn_areas[spawnAreaIndices[i]]
		
		var instance = n.instantiate()
		add_child(instance)
		
		if instance.get_node("CollisionShape3D"):
			# temp because enemies' height midpoints are centered at origin, not bottom
			instance.global_position = area.get_rand_point() + Vector3.UP * instance.get_node("CollisionShape3D").shape.size/2
		else:
			instance.global_position = area.get_rand_point() + Vector3(0.0, 1.0, 0.0)
	started.emit()
	
# TODO: func start_staggered()
# an option to not have enemies all spawn at once for a wave
# utilizes a linear timer, maybe could do an exponential sometime

func check():
	# TODO: Could poll every once in a while for efficiency utilizing a timer,
	# or could count how many enemies have died via signals and automatically end
	if get_children().size() <= enemiesLeftUntilNextWave:
		active = false
		ended.emit()
		print("ended")

func is_active():
	return active
	
func valid_area_ind(x: int):
	return x >= 0 and x < spawn_areas.size()

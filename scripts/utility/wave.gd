@icon("uid://btkf3nim3pnsa")
@tool
extends Node3D

class_name Wave

@export var enemies: Array[PackedScene]

var summonFX: PackedScene = preload("res://VFX/enemySummonFX.tscn")

# Elimination-based wave progression, could also implement time-based
# @export_category("Wave Type")
# @export var isEliminationBased = true
## how many enemys that are still alive before we consider the wave ended (ie. Stragglers)
@export var enemiesLeftUntilNextWave = 0
@export var startDelay := 0

signal started
signal ended

@export_category("Which areas will this wave spawn in?")
@export var spawn_areas: Array[SpawnArea]

@export_category("Set or Random Spawn Areas for enemy spawning?")
@export var setSpawnAreas := false

@export_group("If yes, type the spawn area index for each enemy")
@export var spawnAreaIndices : Array[int]
	#set(value):
		#var safe : bool = setSpawnAreas
		#for i in value:
			#if (i >= spawn_areas.size() and i >= 0):
				#safe = false
				#break
		#if (safe):
			#spawnAreaIndices = value

# can expand to general conditions if necessary
@export_category("Start Condition? (ignore for first wave)")
@export_group("If yes, check and connect signal to validate_condition")
@export var conditionalStart : bool = false
@onready var conditionMet := false	
signal condition

@onready var active = false

func _ready():
	if (Engine.is_editor_hint()):
		return
	ended.connect(get_parent()._on_wave_end)

func start():
	if active:
		return
		
	assert(not setSpawnAreas || enemies.size() == spawnAreaIndices.size(), "ERROR: Each enemy must have a set spawn area! The Enemies list and Spawn Area Indices list must have the same length.")
	assert(not setSpawnAreas || spawnAreaIndices.all(valid_area_ind), "ERROR: Spawn Area Indices must be a valid index of the Spawn Areas list!")
	
	active = true
	if conditionalStart and not conditionMet:
		await condition # uses a signal and flag just in case condition is met before start is called
	if startDelay != 0:
		await get_tree().create_timer(startDelay).timeout
		
	for i in range(0, enemies.size()):
		var n = enemies[i]
		var area = spawn_areas[randi_range(0, spawn_areas.size() - 1)] if not setSpawnAreas else spawn_areas[spawnAreaIndices[i]]
		
		var instance = n.instantiate()
		add_child(instance)
		
		if instance.get_node("CollisionShape3D"):
			# temp because enemies' height midpoints are centered at origin, not bottom
			## not offsetting by collision since if we did, those with origin at the bottom will be too high. also origin should be at bottom in every casea
			instance.global_position = area.get_rand_point()
		else:
			instance.global_position = area.get_rand_point()
			
		var instanceFX : Node3D = summonFX.instantiate()
		add_child(instanceFX)
		instanceFX.global_position = instance.global_position
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
	
func validate_condition(body: Node3D = null):
	if body:
		if body is Player:
			# for area 3D condition
			# connet Area3D.body_entered to this function
			conditionMet = true
			condition.emit()
	else:
		# assumes that condition has been met for all other types of signals
		conditionMet = true
		condition.emit()

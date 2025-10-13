extends Node3D

class_name WaveManager
 
@onready var current_wave = -1

# has both spawn areas and waves as children
var spawn_areas: Array[Node]
var waves: Array[Node]

## if enabled, we can recall the wave to be started
@export var replayable : bool

signal fight_started
signal fight_ended

signal wave_ended

func _ready():
	var children = get_children()
	spawn_areas = children.filter(is_spawn_area)
	waves = children.filter(is_wave)

func wave_process():
	fight_started.emit()
	while (current_wave >= 0 and current_wave < waves.size()):
		if not waves[current_wave].is_active():
			waves[current_wave].start()
		waves[current_wave].check()
		await get_tree().process_frame
	fight_ended.emit()
	if (replayable): current_wave = -1

# signal received from GameManager
func _on_start():
	if (current_wave != -1): return
	current_wave = 0
	wave_process()

func _on_wave_end():
	current_wave += 1
	wave_ended.emit()
	
func is_spawn_area(n: Node) -> bool:
	return n is SpawnArea

func is_wave(n: Node) -> bool:
	return n is Wave
	

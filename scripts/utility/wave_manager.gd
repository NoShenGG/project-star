extends Node3D

class_name WaveManager
 
@onready var current_wave = -1

# has both spawn areas and waves as children
var spawn_areas: Array[Node]
var waves: Array[Node]

func _ready():
	var children = get_children()
	spawn_areas = children.filter(is_spawn_area)
	waves = children.filter(is_wave)
	
	# testing
	#_on_start()
	
func _process(_delta: float):
	if current_wave >= 0 and current_wave < waves.size():
		# active
		if not waves[current_wave].is_active():
			waves[current_wave].start()
		waves[current_wave].check()
	
	if Input.is_action_just_pressed("test_wave"):
		get_tree().call_group("Enemies", "queue_free")

# signal received from GameManager
func _on_start():
	current_wave = 0
	
func _on_wave_end():
	current_wave += 1
	
func is_spawn_area(n: Node) -> bool:
	return n is SpawnArea

func is_wave(n: Node) -> bool:
	return n is Wave
	

extends Node

@export var area : Area3D
@export_file() var next_level : String = "end_screen"
@export var trigger_end: bool = true

signal area_entered

func _enter_tree() -> void:
	if (next_level.begins_with(GameManager.LEVEL_PATH)): 
		print("shortening")
		next_level = next_level.substr(GameManager.LEVEL_PATH.length() - 1)
	assert(area != null, "Area is null")
	assert(next_level != null, "Next Level is null")
	
	area.collision_layer = 0
	area.collision_mask = 2
	
	area.body_entered.connect(ping_signal)
	if trigger_end:
		area.body_entered.connect(end_level)


func end_level(body):
	GameManager.load_level(next_level)
	
func end_level_man():
	GameManager.load_level(next_level)

func ping_signal(body):
	print("HERHERHRHEAH")
	area_entered.emit()

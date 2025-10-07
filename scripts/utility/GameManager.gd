extends Node

const LEVEL_PATH := "res://austin_newby/levels/%s.tscn"
const LOADING_SCREEN = preload("uid://c41j5ds1pfvyx")

var player_manager : Node3D
var player_pos : Vector3:
	get: return player_manager.position
var current_level
var main_scene : MainScene

func _init() -> void:
	print_rich("[color=dark_gray]GameManager initalized.")

# unloads current level and calls loading functions inside of loading_scene
func load_level(level_name: String):
	unload_level()
	var loading_scene = LOADING_SCREEN.instantiate()
	main_scene.add_child(loading_scene)
	loading_scene.change_scene(LEVEL_PATH % level_name)

# destroys current level
func unload_level():
	if (is_instance_valid(current_level)):
		current_level.queue_free()
		print_rich("[color=dark_gray]Unloaded level: %s" % [LEVEL_PATH % current_level.name])
	current_level = null

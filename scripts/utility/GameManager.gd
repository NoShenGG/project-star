extends Node

const LEVEL_PATH := "res://scenes/final/%s.tscn"
const LOADING_SCREEN = preload("uid://c41j5ds1pfvyx")

var player_manager : PlayerManager
var curr_player : Player:
	get: return player_manager.current_char
var current_level
var current_level_name : String
var main_scene : MainScene
func _init() -> void:
	print_rich("[color=dark_gray]GameManager initalized.")

func exit_to_main_menu():
	load_level("main_menu")

func exit_game():
	get_tree().quit()

func reload_level():
	load_level(current_level_name)

# unloads current level and calls loading functions inside of loading_scene
func load_level(level_name: String):
	unload_level()
	var loading_scene = LOADING_SCREEN.instantiate()
	main_scene.add_child(loading_scene)
	loading_scene.change_scene(LEVEL_PATH % level_name)
	current_level_name = level_name


# destroys current level
func unload_level():
	if (is_instance_valid(current_level)):
		current_level.queue_free()
		print_rich("[color=dark_gray]Unloaded level: %s" % [LEVEL_PATH % current_level.name])
	current_level = null

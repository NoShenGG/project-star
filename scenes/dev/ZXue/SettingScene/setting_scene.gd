extends Node

signal done_reading

@export_category("Previous Page")
@export var previous_page : Node
@export_category("Settings")
@export_category("Window Settings")
@export var _window_mode : int = 0
@export var _resolution : int = 0
@export var _brightness : float = 0.5
@export_category("Graphics Settings")
@export var _is_fps_lock : int = 0
@export var _fps_limit : int = 0
@export_category("Gameplay Settings")
@export var _is_rookie_hat : bool = false
@export var _is_reverse_input : bool = false
@export_category("Audio Settings")
@export var _master_volume : float = 1.0
@export var _music_volume : float = 1.0
@export var _sfx_volume : float = 1.0
@export_category("Reference Dictionaries")
@export var _resolution_dict : Dictionary = {
	"1980*1080" = [1980, 1080],
	"1280*720" = [1280, 720]
}

func _ready() -> void:
	#save_setting()
	#THE FOLLOWING IS ACTUAL CODE, CODE ABOVE IS FOR TESTING PURPOSES
	var content = load_setting()
	read_setting(content)
	done_reading.emit(content)
	
func save_setting():
	var save_file = FileAccess.open("user://gamesetting.save", FileAccess.WRITE)
	var save_dict = {
		"window_mode" : _window_mode,
		"resolution" : _resolution,
		"brightness" : _brightness,
		"is_fps_lock" : _is_fps_lock,
		"fps_limit" : _fps_limit,
		"is_rookie_hat" : _is_rookie_hat,
		"is_reverse_input" : _is_reverse_input,
		"master_volume" : _master_volume,
		"music_volume" : _music_volume,
		"sfx_volume" : _sfx_volume
	}
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)
	
func load_setting() -> Dictionary:
	if not FileAccess.file_exists("user://gamesetting.save"):
		print("[SettingMenu]gamesetting.save not found. Creating new save")
		save_setting()
		
	var save_file = FileAccess.open("user://gamesetting.save", FileAccess.READ)
	var json_string = save_file.get_line()
	
	var json_helper = JSON.new()
	
	var parse_result = json_helper.parse(json_string)
	if not parse_result == OK:
		print("SettingScene failed to load with error: " + json_helper.get_error_message())
		return {}
	
	var this_data = json_helper.data
	return this_data

func read_setting(this_data : Dictionary):
	_window_mode = this_data["window_mode"]
	_resolution = this_data["resolution"]
	_brightness = this_data["brightness"]
	_is_fps_lock = this_data["is_fps_lock"]
	_fps_limit = this_data["fps_limit"]
	_is_rookie_hat = this_data["is_rookie_hat"]
	_master_volume = this_data["master_volume"]
	_music_volume = this_data["music_volume"]
	_sfx_volume = this_data["sfx_volume"]


'''
MENU LEVEL 1 SIGNAL CONNECTIONS
'''
func _on_op_1_button_pressed() -> void:
	$Level1Control.visible = false
	$WindowSettings.visible = true


func _on_op_2_button_pressed() -> void:
	$Level1Control.visible = false
	$GraphicsSettings.visible = true


func _on_op_3_button_pressed() -> void:
	$Level1Control.visible = false
	$GameplaySettings.visible = true


func _on_op_4_button_pressed() -> void:
	$Level1Control.visible = false
	$AudioSettings.visible = true

#To return to previous page by hiding self
#also saves setting back to saved file
func _on_return_button_pressed() -> void:
	save_setting()
	$Level1Control.visible = false
	$GeneralBacklay.visible = false


func _window_setting_return() -> void:
	$WindowSettings.visible = false
	$Level1Control.visible = true


func _graphics_setting_return() -> void:
	$GraphicsSettings.visible = false
	$Level1Control.visible = true


func _gameplay_setting_return() -> void:
	$GameplaySettings.visible = false
	$Level1Control.visible = true


func _audio_setting_return() -> void:
	$AudioSettings.visible = false
	$Level1Control.visible = true
	
'''
WINDOW SETTING SIGNAL CONNECTIONS
'''
func _on_windowed_option_button_item_selected(index: int) -> void:
	_window_mode = index


func _on_resolution_option_button_item_selected(index: int) -> void:
	_resolution = index
	

func _on_brightness_bar_value_changed(value: float) -> void:
	_brightness = value/100
	
'''
GRAPHICS SETTING SIGNAL CONNECTIONS
'''
func _on_fps_limit_button_item_selected(index: int) -> void:
	_is_fps_lock = index
	
func _on_fps_limit_slider_value_changed(value: float) -> void:
	_fps_limit = value
	
'''
GAMEPLAY SETTING SIGNAL CONNECTIONS
'''
func _on_rookie_hat_button_pressed() -> void:
	_is_rookie_hat = !_is_rookie_hat


func _on_reverse_control_button_pressed() -> void:
	_is_reverse_input = !_is_reverse_input

'''
AUDIO SETTING SIGNAL CONNECTIONS
'''
func _on_master_volume_bar_value_changed(value: float) -> void:
	_master_volume = value/100


func _on_music_volume_bar_value_changed(value: float) -> void:
	_music_volume = value/100


func _on_sfx_volume_bar_value_changed(value: float) -> void:
	_sfx_volume = value/100

'''
FOR GAME TO RETRIEVE SETTINGS
'''

func get_window_mode() -> bool:
	if _window_mode == 0:
		return false
	else:
		return true

func get_resolution():
	if _resolution == 0:
		return _resolution_dict["1980*1080"]
	elif _resolution == 1:
		return _resolution_dict["1280*720"]
	else:
		return null

func get_brightness():
	return _brightness

func get_fps_limit():
	if _is_fps_lock == 1:
		return _fps_limit
	else:
		return false

func get_is_rookie_hat():
	return _is_rookie_hat
	
func get_is_reverse_input():
	return _is_reverse_input
	
func get_master_volume():
	return _master_volume
	
func get_music_volume():
	return _music_volume
	
func get_sfx_volume():
	return _sfx_volume

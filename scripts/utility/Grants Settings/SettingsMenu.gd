@tool
class_name Settings extends Node

var data : SettingsData = SettingsData.new()

func _enter_tree() -> void:
	unique_name_in_owner = true
	name = "Settings"

func set_window(index : int):
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	data.screen_mode = DisplayServer.window_get_mode()

func set_bus_volume(index : int, volume_percent : float):
	var bus_name : String = "SFX"
	match index:
		0:
			bus_name = "bus:/SFX"
		1:
			bus_name = "bus:/Music"
		2:
			bus_name = "bus:/UI"
		3:
			bus_name = "bus:/Ambiance"
	print(bus_name)
	for bus in FmodServer.get_all_buses():
		print("pathhh  " + bus.get_path())
	print("path i s   " + (FmodServer.get_all_buses()[1] as FmodBus).get_path())
	var bus : FmodBus = FmodServer.get_bus(bus_name)
	if (bus):
		print("setting volume!!!")
		bus.volume = linear_to_db(volume_percent)
	else:
		print("no bus found :/")

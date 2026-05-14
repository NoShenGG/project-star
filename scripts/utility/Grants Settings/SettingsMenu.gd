@tool
class_name Settings extends Node

static var data : SettingsData = SettingsData.new()

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
			bus_name = "{c56923f2-facf-4234-8503-244eee038ce3}"
		1:
			bus_name = "{91e7148e-3e78-4553-a738-7b82edaae1a0}"
		2:
			bus_name = "{613f8ce6-2727-4ecf-a9c2-159cb4caf311}"
		3:
			bus_name = "{2533f5e6-3755-4921-850d-695a7c7f6a3f}"
		4:
			bus_name = "{40cf6196-4f6a-475c-bd2b-3207375401d5}"
	
	## because paths for fmod are ridiuclously bugged for some reason
	for bus in FmodServer.get_all_buses():
		if ((bus as FmodBus).get_guid() == bus_name):
			print(volume_percent)
			bus.volume = volume_percent#linear_to_db(1 - volume_percent)
	for bus in FmodServer.get_all_vca():
		if ((bus as FmodVCA).get_guid() != bus_name):
			pass#bus.volume = linear_to_db(volume_percent)
	
	return
	## WHY IS EVERYTHING BULLSHIT
	#print("path i s   " + (FmodServer.get_all_buses()[1] as FmodVCA).get_path())
	var bus : FmodBus = FmodServer.get_bus(bus_name)
	FmodServer.get_vca("vca:/Ambiance").volume = 5
	FmodServer.get_bus("bus:/Ambiance").volume = 5
	if (bus):
		print("setting volume!!!")
		bus.volume = linear_to_db(volume_percent)
	else:
		print("no bus found :/")

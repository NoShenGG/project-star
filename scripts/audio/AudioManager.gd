extends Node
# This script belongs to the Global 'audio_manager.tscn'
# Example Usage: AudioManager.play_sound("SOUNDNAME.mp3")

const AUDIO_DIRECTORY := "res://austin_newby/sounds" # !!! this must be changed to main audio directory

@onready var playing : Dictionary = {} ## Dictionary of currently active sounds
var sound_dict : Dictionary  ## Dictionary of all sounds within [member AUDIO_DIRECTORY]

func _init() -> void:
	sound_dict = scan_and_load_sounds(AUDIO_DIRECTORY)

## parses [member AUDIO_DIRECTORY] and adds any .mp3 .wav or .ogg to [member sound_dict]
## initializes each sound file with default values
func scan_and_load_sounds(directory):
	var dir = DirAccess.open(directory)
	if !dir:
		push_error("Error opening Audio Directory.")
		return {}
	var dic := {}
	dir.list_dir_begin()
	var sound_file_name := "temp" # prevents loop ending early
	var parsed_directories : Array # stores parsed dirs
	while sound_file_name != "":
		sound_file_name = dir.get_next()
		if dir.current_is_dir() and !parsed_directories.has(dir.get_current_dir() + "/" + sound_file_name):
			dir.change_dir(sound_file_name)
			dir.list_dir_begin()
		# ignores the file unless its of proper type
		elif (sound_file_name.ends_with(".wav") or sound_file_name.ends_with(".mp3") or sound_file_name.ends_with(".ogg")) and !sound_file_name.ends_with(".import") and !dic.has(sound_file_name):
			var new_sound = Sound.new()
			new_sound.name = sound_file_name
			new_sound.loop = false
			new_sound.stream = load(dir.get_current_dir(false) + "/" + sound_file_name)
			new_sound.volume = 0
			new_sound.pitch = 1
			new_sound.bus = "sfx"
			dic[sound_file_name] = new_sound
		if sound_file_name == "" and dir.get_current_dir() != AUDIO_DIRECTORY:
			print_rich("[color=aqua]Completed parsing of %s " % [dir.get_current_dir()])
			parsed_directories.append(dir.get_current_dir())
			dir.change_dir("..")
			dir.list_dir_begin()
			sound_file_name = "temp" 
	print_rich("[color=aqua]Completed parsing of %s " % [dir.get_current_dir()])
	return dic

func play_sound(sound_name: String, bus: String):
	if !(sound_name in sound_dict): 
		push_error("\"%s\" is not a key in the sound dictionary of AudioManager." % [sound_name])
		return
	var sound = sound_dict[sound_name]
	var a = AudioStreamPlayer.new()
	a.name = sound_name
	a.stream = sound.stream
	a.volume_db = sound.volume
	a.pitch_scale = sound.pitch
	a.set_bus(bus)
	
	if sound_name in playing: # this code checks for duplicate names in 'playing' and adds trailing numbers to differentiate
		for n in range(1, playing.size()+1):
			if !(sound_name + str(n) in playing):
				sound_name = sound_name + str(n)
				break
	
	a.finished.connect(a.queue_free) # when sound finished, frees player
	a.finished.connect(func(): playing.erase(sound_name)) # when sound finished, remove sound from playing dictionary
	a.finished.connect(loop_sound.bind(sound))
	# /\ this lambda function passes playing.erase(sound_name) as a Callable, which is necessary because playing.erase by itself indicates a key value
	
	playing.get_or_add(sound_name, a)
	get_tree().get_root().add_child.call_deferred(a)
	a.play.call_deferred()

func play_sound_2d(sound_name: String, bus: String, parent: Node2D):
	if !(sound_name in sound_dict): 
		push_error("\"%s\" is not a key in the sound dictionary of AudioManager." % [sound_name])
		return
	var sound = sound_dict[sound_name]
	var a = AudioStreamPlayer2D.new()
	a.name = sound_name
	a.stream = sound.stream
	a.volume_db = sound.volume
	a.pitch_scale = sound.pitch
	a.set_bus(bus)
	
	if sound_name in playing: # this code checks for duplicate names in 'playing' and adds trailing numbers to differentiate
		for n in range(1, playing.size()+1):
			if !(sound_name + str(n) in playing):
				sound_name = sound_name + str(n)
				break
	
	a.finished.connect(a.queue_free) # when sound finished, frees player
	a.finished.connect(func(): playing.erase(sound_name)) # when sound finished, remove sound from playing dictionary
	a.finished.connect(loop_sound.bind(sound))
	# /\ this lambda function passes playing.erase(sound_name) as a Callable, which is necessary because playing.erase by itself indicates a key value
	
	playing.get_or_add(sound_name, a)
	parent.add_child.call_deferred(a)
	a.global_position = parent.global_position
	a.play.call_deferred()
	

func loop_sound(s: Sound):
	if s.loop == true:
		play_sound(s.name, s.bus)

func edit_sound(sound_name: String, vol_adj:int, pitch:float, loop:bool):
	var new_sound = Sound.new()
	new_sound.name = sound_name
	new_sound.stream = sound_dict[sound_name].stream
	new_sound.volume = vol_adj
	new_sound.pitch = pitch
	new_sound.loop = loop
	if !(sound_name in sound_dict): 
		push_error("\"%s\" is not a key in the sound dictionary of AudioManager." % [sound_name])
		return
	sound_dict[sound_name] = new_sound

func print_sound_properties(sound_name: String):
	var s = sound_dict[sound_name]
	print_rich("[color=aqua]PROPERTIES OF SOUND: %s\n\tstream: %s\n\tvolume: %s\n\tpitch: %s\n\tbus: %s\n\tloop: %s" % [s.name, s.stream, s.volume, s.pitch, s.bus, s.loop])

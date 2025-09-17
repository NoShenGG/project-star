extends Node2D

@onready var r_marker_2d: Marker2D = $RMarker2D
@onready var u_marker_2d: Marker2D = $UMarker2D
@onready var l_marker_2d: Marker2D = $LMarker2D
@onready var d_marker_2d: Marker2D = $DMarker2D


func _ready() -> void:
	print_rich("[color=aqua]Loaded sounds: ", AudioManager.sound_dict.keys())
	AudioManager.edit_sound("audio_test_music_awesome.mp3", -10, 1, true)
	AudioManager.play_sound("audio_test_music_awesome.mp3", "music")

func _process(_delta: float) -> void:
	%PlayingLabel.text = "\n".join(AudioManager.playing.keys())

func _input(_event: InputEvent):
	if Input.is_action_just_pressed("move_left"):
		AudioManager.play_sound_2d("example_sound.mp3", "sfx", l_marker_2d)
	if Input.is_action_just_pressed("move_right"):
		AudioManager.play_sound_2d("example_sound.mp3", "sfx", r_marker_2d)
	if Input.is_action_just_pressed("move_up"):
		AudioManager.play_sound_2d("example_sound.mp3", "sfx", u_marker_2d)
	if Input.is_action_just_pressed("move_down"):
		AudioManager.play_sound_2d("example_sound.mp3", "sfx", d_marker_2d)
	if Input.is_action_just_pressed("dodge"):
		AudioManager.play_sound_2d("slidewhist.wav", "sfx", d_marker_2d)

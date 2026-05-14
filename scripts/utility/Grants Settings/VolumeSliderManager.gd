extends Node

@export var master_slider : Slider
@export var SFX_slider : Slider
@export var music_slider : Slider
@export var UI_slider : Slider
@export var ambiance_slider : Slider

func _ready() -> void:
	master_slider.value_changed.connect(func(value : float): set_volume(0, value))
	SFX_slider.value_changed.connect(func(value : float): set_volume(1, value))
	music_slider.value_changed.connect(func(value : float): set_volume(2, value))
	UI_slider.value_changed.connect(func(value : float): set_volume(3, value))
	ambiance_slider.value_changed.connect(func(value : float): set_volume(4, value))

func set_volume(index : int, value : float):
	(%Settings as Settings).set_bus_volume(index, value)

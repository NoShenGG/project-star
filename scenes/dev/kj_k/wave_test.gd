extends Node3D

@onready var wave_manager: WaveManager = $WaveManager

func _ready() -> void:
	wave_manager._on_start()

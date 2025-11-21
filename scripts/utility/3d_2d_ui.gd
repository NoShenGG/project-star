extends Node3D


@onready var camera : Camera3D = get_tree().root.get_camera_3d()
@export var ui : Control

@onready var offset : Vector3 = position

func _ready() -> void:
	top_level = true

func _process(delta: float) -> void:
	global_position = owner.global_position + offset
	ui.global_position = camera.unproject_position(global_position)

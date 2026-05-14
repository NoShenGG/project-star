extends Control

func _ready() -> void:
	(get_parent() as Node3D).visibility_changed.connect(vis_changed)

func vis_changed():
	visible = get_parent().visible

extends Node3D

@export var mesh : MeshInstance3D

@export_range(0,3) var duration : float = 1

@export var fade_in_on_start : bool

func _enter_tree() -> void:
	mesh.get_surface_override_material(0).set("shader_parameter/transparency",1.0)
	if (fade_in_on_start):
		fade_in()
	else:
		visibility_changed.connect(fade_in)

func fade_in():
	if (visible):
		var tween = create_tween()
		tween.tween_property(mesh.get_surface_override_material(0), "shader_parameter/transparency", 0, duration)

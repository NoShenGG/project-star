@tool
extends Node3D

@export var mesh: Mesh:
	set(value):
		mesh = value
		recreate_meshes()

@export var shader: Shader:
	set(value):
		shader = value
		recreate_meshes()

@export var albedo: Texture2D:
	set(value):
		albedo = value
		recreate_meshes()

@export var height_map: Texture2D:
	set(value):
		height_map = value
		recreate_meshes()

@export_range(1, 5, 0.1, "or_greater") var texture_scale: float = 1.0:
	set(value):
		texture_scale = value
		recreate_meshes()

@export_color_no_alpha var tint: Color = Color(1.0, 1.0, 1.0):
	set(value):
		tint = value
		recreate_meshes()
 
@export_range(2, 64, 1, "or_greater") var shell_count: int = 10:
	set(value):
		shell_count = value
		recreate_meshes()

@export_range(0, 0.5, 0.01, "or_greater") var shell_displacement: float = 0.05:
	set(value):
		shell_displacement = value
		recreate_meshes()

@export_range(0, 1, 0.01) var min_ambient_occlusion: float = 0.5:
	set(value):
		min_ambient_occlusion = value
		recreate_meshes()

func recreate_meshes():
	if not Engine.is_editor_hint():
		return
	
	if not is_inside_tree():
		return
	
	if not mesh:
		print("Warning: 'mesh' must be assigned in editor!")
		return
	
	if not shader:
		print("Warning: 'shader' must be assigned in editor!")
		return
	
	if not albedo:
		print("Warning: 'albedo' must be assigned in editor!")
		return
	
	if not height_map:
		print("Warning: 'height_map' must be assigned in editor!")
		return
	
	for child in get_children():
		if child is MeshInstance3D:
			child.free()
	
	for i in range(shell_count):
		var shell = MeshInstance3D.new()
		shell.mesh = mesh
		
		var material = ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter("albedo", albedo)
		material.set_shader_parameter("height_map", height_map)
		material.set_shader_parameter("texture_scale", texture_scale)
		material.set_shader_parameter("tint", tint)
		material.set_shader_parameter("shell_count", shell_count)
		material.set_shader_parameter("shell_idx", i)
		material.set_shader_parameter("shell_displacement", shell_displacement)
		material.set_shader_parameter("min_ambient_occlusion", min_ambient_occlusion)
		shell.set_surface_override_material(0, material)
		
		add_child(shell)
		shell.owner = get_tree().edited_scene_root

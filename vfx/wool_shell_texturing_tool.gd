@tool
extends Node3D

## OVERVIEW
## Translucent meshes (called shells) are layered to give the illusion of wool.
## Technique has a very low performance cost, but can run into issues of
## overdraw if too many shells are used.
## 
## HOW TO USE
## - Attach 'wool_shell_texturing_manager' (located in 'scenes/tool/' directory)
##   to a Node.
## - Assign Mesh, Shader (located in 'shaders' directory), Albedo & Height Map
##   Textures, and Shader Parameters (see tooltips for more info).
## - Press the 'Recreate Meshes' button to (re)generate the meshes.

## Base mesh that is duplicated 'shell_count' number of times. Ensure UV mapping
## is resonable to avoid major artifacts.
@export var mesh: Mesh

## Wool shell texturing shader located in 'shaders' directory.
@export var shader: Shader

## Base albedo texture for the wool. Ensure texture is seamless to avoid
## artifacts when scaling.
@export var albedo: Texture2D

## Albedo texture's associated height map. Most modern image editing software
## can generate a height map from an albedo texture. Ensure albedo texture is
## seamless before generating the height map.
@export var height_map: Texture2D

## Albedo/height map texture scale.
@export_range(1, 5, 0.1, "or_greater") var texture_scale: float = 1.0

## Albedo texture tint.
@export_color_no_alpha var tint: Color = Color(1.0, 1.0, 1.0)

## Number of mesh layers (shells). Note that each shell will duplicate the mesh.
## Therefore, high-polycount meshes or a high shell count will cause performance
## issues.
@export_range(2, 32, 1, "or_greater") var shell_count: int = 10

## Shells are displaced along mesh normals. Increase shell_count to avoid shell
## layering artifacts. Note that this artifact cannot be completely eliminated.
@export_range(0, 0.3, 0.01, "or_greater") var shell_displacement: float = 0.05

## Ambient occlusion darkens the lower shells, adding depth to the wool.
@export_range(0, 1, 0.01) var min_ambient_occlusion: float = 0.5

@export_tool_button("Recreate Meshes", "Callable") var recreate_button = recreate_meshes

func _ready():
	recreate_meshes()

func recreate_meshes():
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
	
	print("Recreating wool shell textures...")
	
	# delete current shells
	for child in get_children():
		if child is MeshInstance3D:
			child.free()
	
	# regenerate shells
	for i in range(shell_count):
		var shell = MeshInstance3D.new()
		shell.name = "Shell_" + str(i)
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
	
	print("Shell texture generation complete!")

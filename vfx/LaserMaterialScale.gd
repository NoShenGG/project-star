@tool
extends MeshInstance3D

@export var vfx_material : ShaderMaterial : 
	get():
		return get_surface_override_material(0) as ShaderMaterial
@export var vfx_scale : float = 1
@export var vfx_move_speed : float = 1

## if enabled, force duplicate on material, allowing per-instance variation. disables batching, small performance decrease
@export var instanced : bool :
	set(value):
		vfx_material.resource_local_to_scene = value
		instanced = value

func _process(delta: float) -> void:
	
	vfx_material.set_shader_parameter("uv1_scale", Vector3(vfx_material.get_shader_parameter("uv1_scale").x, global_basis.z.length() * vfx_scale, 0))
	var offset : Vector3 = vfx_material.get_shader_parameter("uv1_offset")
	vfx_material.set_shader_parameter("uv1_offset", Vector3(offset.x, offset.y + vfx_move_speed * delta, 0))

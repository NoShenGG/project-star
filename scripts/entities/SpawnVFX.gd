@tool
extends Node

@export var vfx : AutoStartVFX

@export var meshes_root : Node3D
@export var _meshes : Array[MeshInstance3D]
@export var hurt_overlay : BaseMaterial3D
@export_range(0.01,5, 0.01) var flash_duration : float = 0.1

var flash_count : int = 0

@export_tool_button("Play") var play : Callable = spawned

func _enter_tree() -> void:
	_meshes = find_meshs(meshes_root, [])
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	## used so that each enemy can flash on their own
	## i dont thinkk this should require a shader compilation?
	hurt_overlay = hurt_overlay.duplicate()
	
	(get_parent() as Entity).spawned.connect(spawned)

func _exit_tree() -> void:
	(get_parent() as Entity).spawned.disconnect(spawned)

func find_meshs(parent : Node, list : Array[MeshInstance3D]) -> Array[MeshInstance3D]:
	
	for child in parent.get_children():
		if child is MeshInstance3D:
			list.append(child)
		find_meshs(child, list)
	return list

func spawned():
	print("spawned!")
	flash(flash_duration, 1)
	var vfx_transform : Transform3D = vfx.transform
	vfx.top_level = true
	#get_parent().set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	#meshes_root.set_deferred("process_mode", Node.PROCESS_MODE_ALWAYS)
	vfx.restart_particles()
	
	scale_mesh()
	await vfx.finished
	vfx.top_level = false
	vfx.transform = vfx_transform
	#get_parent().process_mode = Node.PROCESS_MODE_INHERIT
	#meshes_root.process_mode = Node.PROCESS_MODE_INHERIT

func scale_mesh():
	var normal_scale : Vector3 = meshes_root.scale
	var tween = meshes_root.create_tween()
	meshes_root.scale = (Vector3.BACK + Vector3.RIGHT) * 0.0001 + Vector3.UP
	tween.tween_property(meshes_root, "scale", normal_scale, flash_duration)

func flash(duration : float, intensity : float):
	print("hurt overlay call!!")
	flash_count += 1
	var flash_size : int = flash_count
	for mesh in _meshes:
		mesh.material_overlay = hurt_overlay
	
	hurt_overlay.albedo_color.a = 1
	await get_tree().create_timer(duration).timeout
	## a new flash was called, we dont want to continue since the new one will handle it.
	## disabling this will cause jittery flash during fast attacks
	if (flash_count > flash_size): return
	hurt_overlay.albedo_color.a = 0
	flash_count -= 1

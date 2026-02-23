extends Node

@export var vfx : AutoStartVFX

@export var meshes_root : Node3D
var _meshes : Array[MeshInstance3D]
@export var hurt_overlay : BaseMaterial3D
@export_range(0.01,1, 0.01) var flash_duration : float = 0.1

var flash_count : int = 0

func _enter_tree() -> void:
	(get_parent() as Entity).hurt.connect(hurt)
	
	_meshes = find_meshs(meshes_root, [])
	

func _exit_tree() -> void:
	(get_parent() as Entity).hurt.disconnect(hurt)

func find_meshs(parent : Node, list : Array[MeshInstance3D]) -> Array[MeshInstance3D]:
	
	for child in parent.get_children():
		if child is MeshInstance3D:
			list.append(child)
		find_meshs(child, list)
	return list

func hurt(damage : float):
	print("hurt!")
	flash(flash_duration, 1)
	vfx.restart_particles()

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

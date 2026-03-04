extends Node

@export var vfx : AutoStartVFX

@export var meshes_root : Array[Node3D]
var _meshes : Array[MeshInstance3D]
@export var swap_overlay : BaseMaterial3D
@export_range(0.01,2, 0.01) var flash_duration : float = 0.3
@export var tween : bool = true
var _overlay_tween : Tween
@onready var original_a : float = swap_overlay.albedo_color.a
@export var albedo_curve : Curve
var flash_count : int = 0

func _enter_tree() -> void:
	(get_parent() as PlayerManager).new_player.connect(swap)
	
	_meshes.clear()
	for mesh_root in meshes_root:
		_meshes.append_array(find_meshs(mesh_root, []))
	
	
	## used so that each enemy can flash on their own
	## i dont thinkk this should require a shader compilation?
	swap_overlay = swap_overlay.duplicate()

func _exit_tree() -> void:
	(get_parent() as PlayerManager).new_player.disconnect(swap)

func find_meshs(parent : Node, list : Array[MeshInstance3D]) -> Array[MeshInstance3D]:
	
	for child in parent.get_children():
		if child is MeshInstance3D:
			list.append(child)
		find_meshs(child, list)
	return list

func swap(value : Player):
	print("hurt!")
	flash(flash_duration, 1)
	vfx.restart_particles()

func flash(duration : float, intensity : float):
	print("hurt overlay call!!")
	flash_count += 1
	var flash_size : int = flash_count
	for mesh in _meshes:
		mesh.material_overlay = swap_overlay
	
	swap_overlay.albedo_color.a = original_a
	if (tween):
		if (_overlay_tween): _overlay_tween.stop()
		_overlay_tween = create_tween()
		_overlay_tween.set_trans(_overlay_tween.TRANS_EXPO)
		var new_albedo = swap_overlay.albedo_color
		new_albedo.a = 0
		_overlay_tween.tween_property(swap_overlay, "albedo_color", new_albedo, flash_duration)
	await get_tree().create_timer(duration).timeout
	## a new flash was called, we dont want to continue since the new one will handle it.
	## disabling this will cause jittery flash during fast attacks
	if (flash_count > flash_size): return
	swap_overlay.albedo_color.a = 0
	flash_count -= 1

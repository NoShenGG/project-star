extends Node

@export var vfx : AutoStartVFX

@export var meshes_root : Node3D
var _meshes : Array[MeshInstance3D]
@export var hurt_overlay : BaseMaterial3D
@export_range(0.01,5, 0.01) var flash_duration : float = 1
@export var tween : bool = true
var _overlay_tween : Tween
@onready var original_a : float = hurt_overlay.albedo_color.a if hurt_overlay else 1
var flash_count : int = 0

@export_category("Death")
@export var death_delay : float = 1
@export var death_time : float = 1
@export var fade_out : bool = true

@export_category("Death scaling")
@export var flash_scale_mesh : bool = true

@export_category("Sink")
@export var sink : bool = true
@export var sink_depth : float = 2

func _enter_tree() -> void:
	(get_parent() as Entity).killed.connect(death)
	_meshes = find_meshs(meshes_root, [])
	
	## used so that each enemy can flash on their own
	## i dont thinkk this should require a shader compilation?
	if (hurt_overlay): hurt_overlay = hurt_overlay.duplicate()

func _exit_tree() -> void:
	(get_parent() as Entity).killed.disconnect(death)

func find_meshs(parent : Node, list : Array[MeshInstance3D]) -> Array[MeshInstance3D]:
	
	for child in parent.get_children():
		if child is MeshInstance3D:
			list.append(child)
		find_meshs(child, list)
	return list

func death():
	print("hurt!")
	flash(flash_duration, 1)
	if (flash_scale_mesh): scale_mesh()
	vfx.restart_particles()
	
	await get_tree().create_timer(death_delay).timeout
	if (!meshes_root): return
	if (fade_out):
		for mesh in _meshes:
			var transparency_tween = meshes_root.create_tween()
			transparency_tween.set_trans(Tween.TRANS_QUAD)
			transparency_tween.tween_property(mesh, "transparency", 1, death_time * 0.9)
	if (sink):
		var sink_tween = meshes_root.create_tween()
		var sink_pos = meshes_root.position + (Vector3.DOWN * sink_depth)
		sink_tween.tween_property(meshes_root, "position", sink_pos, death_time)



func scale_mesh():
	await get_tree().create_timer(death_delay).timeout
	## may get despawned after this time
	if (!meshes_root): return
	var normal_scale : Vector3 = meshes_root.scale
	var tween = meshes_root.create_tween()
	var target : Vector3 = meshes_root.scale * ((Vector3.UP * 0.0001) + (Vector3.BACK + Vector3.RIGHT))
	tween.tween_property(meshes_root, "scale", target, death_time)


func flash(duration : float, intensity : float):
	if (!hurt_overlay): return
	print("hurt overlay call!!")
	flash_count += 1
	var flash_size : int = flash_count
	for mesh in _meshes:
		mesh.material_overlay = hurt_overlay
	
	hurt_overlay.albedo_color.a = original_a
	if (tween):
		if (_overlay_tween): _overlay_tween.stop()
		_overlay_tween = create_tween()
		_overlay_tween.set_trans(_overlay_tween.TRANS_EXPO)
		var new_albedo = hurt_overlay.albedo_color
		new_albedo.a = 0
		_overlay_tween.tween_property(hurt_overlay, "albedo_color", new_albedo, flash_duration)
	await get_tree().create_timer(duration).timeout
	## a new flash was called, we dont want to continue since the new one will handle it.
	## disabling this will cause jittery flash during fast attacks
	if (flash_count > flash_size): return
	hurt_overlay.albedo_color.a = 0
	flash_count -= 1

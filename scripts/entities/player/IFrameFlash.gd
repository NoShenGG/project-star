extends Node

@export var meshes_root : Node3D
var _meshes : Array[MeshInstance3D]
@export var flash_overlay : BaseMaterial3D
@export var flash_speed : float = 20
@onready var original_a : float = flash_overlay.albedo_color.a
@export_range(0,255) var min_a : int = 0

var _flashing : bool = true
var _time : float = 0

func _enter_tree() -> void:
	(get_parent() as Entity).invincibility_gained.connect(flash_start)
	(get_parent() as Entity).invincibility_lost.connect(flash_stop)
	_meshes = find_meshs(meshes_root, [])
	
	## used so that each enemy can flash on their own
	## i dont thinkk this should require a shader compilation?
	flash_overlay = flash_overlay.duplicate()

func _exit_tree() -> void:
	(get_parent() as Entity).invincibility_gained.disconnect(flash_start)
	(get_parent() as Entity).invincibility_gained.disconnect(flash_stop)

func find_meshs(parent : Node, list : Array[MeshInstance3D]) -> Array[MeshInstance3D]:
	
	for child in parent.get_children():
		if child is MeshInstance3D:
			list.append(child)
		find_meshs(child, list)
	return list

func flash_start():
	flash_visuals_start()

func flash_stop():
	flash_visuals_stop()
	

func flash_visuals_start():
	if (_flashing): return
	for mesh in _meshes:
		mesh.material_overlay = flash_overlay
	
	_flashing = true
	_time = 0
	flash_overlay.albedo_color.a = original_a

func _process(delta: float) -> void:
	if (_flashing):
		_time += delta
		
		flash_overlay.albedo_color.a = (min_a / 255) + cos(_time * flash_speed) * (original_a - (min_a / 255))

func flash_visuals_stop():
	_flashing = false
	flash_overlay.albedo_color.a = 0

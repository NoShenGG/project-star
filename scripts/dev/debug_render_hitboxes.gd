## Attach to any node that holds Area3D hitboxes

extends Node

var meshes := {}

func _ready() -> void:
	for i in range(len(get_children())):
		var area = get_child(i) as Area3D
		var m = MeshInstance3D.new()
		var box = area.get_child(0) as CollisionShape3D
		if box == null:
			return
		m.mesh = box.shape.get_debug_mesh()
		box.add_child(m)
		meshes[area] = m
	
func _process(_delta: float) -> void:
	for area in meshes.keys():
		if (area as Area3D).monitoring:
			meshes[area].show()
		else:
			meshes[area].hide()

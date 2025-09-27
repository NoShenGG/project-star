## Attach to any node that holds Area3D hitboxes

extends Node

var meshes: Array[MeshInstance3D] = []

func _ready() -> void:
	for i in range(len(get_children())):
		var box = get_child(i).get_child(0) as CollisionShape3D
		var m = MeshInstance3D.new()
		m.mesh = box.shape.get_debug_mesh()
		box.add_child(m)
		meshes.append(m)
	
func _process(_delta: float) -> void:
	for i in range(len(get_children())):
		if (get_child(i) as Area3D).monitoring:
			meshes[i].show()
		else:
			meshes[i].hide()

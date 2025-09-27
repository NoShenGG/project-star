## Attach to any Area3D node

extends Area3D

var mesh: MeshInstance3D

func _ready() -> void:
	var box = get_child(0) as CollisionShape3D
	mesh = MeshInstance3D.new()
	mesh.mesh = box.shape.get_debug_mesh()
	box.add_child(mesh)
	
func _process(_delta: float) -> void:
	if monitoring:
		mesh.show()
	else:
		mesh.hide()

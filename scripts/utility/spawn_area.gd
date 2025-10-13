@tool
extends Node3D

class_name SpawnArea

func _process(_delta: float):
	if not Engine.is_editor_hint():
		# hide if not in editor
		visible = false 
	

# returns a random point within shape
func get_rand_point() -> Vector3:
	## using global basis so what you see is what you get (scale from basis same as global basis)
	var half : Vector3 = global_basis.get_scale() * 0.5
	
	if (half.y < 0.05):
		# no random vertical component, so just a 2D bounding box
		half.y = 0
		
	var local = Vector3(
		randf_range(-half.x, half.x),
		0,#randf_range(-half.y, half.y),
		randf_range(-half.z, half.z)
	)
	return global_transform.origin + local

# post_import.gd
extends EditorScenePostImport

func _post_import_scene(scene):
	# This script will be executed after the scene is imported from Blender
	# You can add more complex logic here as needed
	scene.call_on_children(func(child):
		if child is MeshInstance3D:
			if child.get_child_count() == 0: # Check if it has no children
				var static_body = StaticBody3D.new()
				var collision_shape = CollisionShape3D.new()
				collision_shape.shape = child.mesh.create_trimesh_shape() # Create trimesh shape
				static_body.add_child(collision_shape)
				child.add_child(static_body) # Add the static body to the mesh instance
	)
	return scene

class_name MergerLaser extends MeshInstance3D

var width: float = 0.6

var node_a: Node3D
var node_b: Node3D

var CAMERA_VIEW_VECTOR: Vector3 = Vector3(0.573576, 0.613437, 0.542289)

func _ready():
	mesh = ImmediateMesh.new()

func _process(_delta):
	if mesh and is_instance_valid(node_a) and is_instance_valid(node_b):
		update_laser_mesh()

func update_laser_mesh():
	mesh.clear_surfaces()
	
	var start_pos: Vector3 = node_a.global_transform.origin + Vector3.UP
	var end_pos: Vector3 = node_b.global_transform.origin + Vector3.UP

	global_transform.origin = start_pos
	
	var direction: Vector3 = end_pos - start_pos
	var length: float = direction.length()
	
	if length < 0.001:
		return

	var forward: Vector3 = direction.normalized()
	
	var right_vector: Vector3 = CAMERA_VIEW_VECTOR.cross(forward).normalized() * width / 2.0
	if right_vector.length_squared() < 0.0001:
		right_vector = Vector3.UP.cross(forward).normalized() * width / 2.0
		# Fallback check: if the laser is also pointing straight up/down, skip drawing
		if right_vector.length_squared() < 0.0001:
			return
			
	# Define the 4 corner points of the quad
	var p1 = Vector3.ZERO - right_vector # Start point, left side (relative to laser node)
	var p2 = Vector3.ZERO + right_vector # Start point, right side
	var p3 = length * forward + right_vector # End point, right side
	var p4 = length * forward - right_vector # End point, left side

	# Draw the surface (Quad/Triangle Strip)
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	var normal: Vector3 = right_vector.cross(forward).normalized()
	
	# Correct order for a quad with TRIANGLE_STRIP: P1, P2, P4, P3
	
	mesh.surface_set_normal(normal)
	mesh.surface_set_uv(Vector2(0, 0))
	mesh.surface_add_vertex(p1)
	
	mesh.surface_set_normal(normal)
	mesh.surface_set_uv(Vector2(1, 0))
	mesh.surface_add_vertex(p2)

	mesh.surface_set_normal(normal)
	mesh.surface_set_uv(Vector2(0, 1))
	mesh.surface_add_vertex(p4)
	
	mesh.surface_set_normal(normal)
	mesh.surface_set_uv(Vector2(1, 1))
	mesh.surface_add_vertex(p3)

	mesh.surface_end()

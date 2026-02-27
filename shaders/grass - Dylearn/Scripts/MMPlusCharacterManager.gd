# MIT License. 
# Made by Dylearn

# Takes all locations of characters and passes them to shader for grass displacement

@tool
extends Node

@export var mm_plus : MmPlus3D :
	set(value):
		mm_plus = value
		if (value):
			setup_meshes()
@export var meshes : Array[Mesh]
@export var debug_meshes : Array[Mesh]
var character_positions: Array = []
const MAX_CHARACTERS = 64
@export var grass_framerate = 10.0
var grass_timer = 0.0

var hidden_location = Vector4.ZERO

func _ready():
	# Initialize the array with zeros
	character_positions.resize(MAX_CHARACTERS)
	for i in range(MAX_CHARACTERS):
		character_positions[i] = hidden_location
	
	if mm_plus:
		setup_meshes()

func setup_meshes():
	if !mm_plus.is_node_ready():
		await mm_plus.ready
	
	meshes.clear()
	debug_meshes.clear()
	for data in mm_plus.data:
		#data.mesh_data.mesh
		debug_meshes.append(data.mesh_data.mesh)
		if !data.mesh_data.mesh or !data.mesh_data.mesh.surface_get_material(0):
			continue
		meshes.append(data.mesh_data.mesh)

func _process(delta):
	var grass_frametime = 1.0 / grass_framerate
	grass_timer += delta
	if grass_timer >= grass_frametime: # update grass
		grass_timer -= grass_frametime
		
		# Clear the array each frametime
		for i in range(MAX_CHARACTERS):
			character_positions[i] = hidden_location
		
		# Get all nodes in the "characters" group
		var characters = get_tree().get_nodes_in_group("characters")
		
		# Store their positions (up to MAX_CHARACTERS)
		for i in range(min(characters.size(), MAX_CHARACTERS)):
			var character = characters[i]
			var size: float = character.grass_displacement_size
			var position: Vector3 = character.global_transform.origin
			character_positions[i] = Vector4(position.x, position.y, position.z, size)
			
		
		# Pass info to the shader
		for mesh in meshes:
			mesh.surface_get_material(0).set(
					"shader_parameter/character_positions",
					character_positions
				)
		

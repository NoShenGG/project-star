# MIT License. 
# Made by Dylearn

# Takes all locations of characters and passes them to shader for grass displacement

@tool
extends Node

@export var grass: MultiMeshInstance3D
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
		grass.material_override.set(
				"shader_parameter/character_positions",
				character_positions
			)
		

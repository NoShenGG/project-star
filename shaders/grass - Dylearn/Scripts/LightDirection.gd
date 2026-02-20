# MIT License. 
# Made by Dylearn

# Pass light direction to global shaders

@tool
extends DirectionalLight3D

@onready var directional_light: DirectionalLight3D = $"."

# Function to send directional light information to the shader
func _process(_delta):
	if directional_light:
		# Get the world direction of the directional light
		var light_direction = directional_light.global_transform.basis.z.normalized()
		#print("light dir", light_direction)
		
		# Pass the light direction to the shader
		RenderingServer.global_shader_parameter_set("light_direction", light_direction)

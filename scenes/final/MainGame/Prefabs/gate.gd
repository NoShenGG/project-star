@tool
class_name Gate extends StaticBody3D

@export_tool_button("Open", "Unlock") var open_gate = open
@export_tool_button("Close", "Lock") var close_gate = close

@onready var shader: ShaderMaterial = $MeshInstance3D.get_surface_override_material(0)
	

func _ready() -> void:
	shader.set_shader_parameter("emission_color", Color("8200ff"))
	
func open() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	shader.set_shader_parameter("emission_color", Color("7eff00"))


func close() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	shader.set_shader_parameter("emission_color", Color("8200ff"))
	

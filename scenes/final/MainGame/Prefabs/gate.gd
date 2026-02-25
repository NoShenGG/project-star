@tool
class_name Gate extends StaticBody3D

@export_tool_button("Open", "Unlock") var open_gate = open
@export_tool_button("Close", "Lock") var close_gate = close
@onready var collision_shape = $CollisionShape3D

@onready var shader: ShaderMaterial = $MeshInstance3D.get_surface_override_material(0)

## called when gate opens
signal opened
## called when gate closes
signal closed


func _ready() -> void:
	shader.set_shader_parameter("emission_color", Color("8200ff"))
	close()
	
func open() -> void:
	opened.emit()
	process_mode = Node.PROCESS_MODE_DISABLED
	collision_shape.disabled = true	
	shader.set_shader_parameter("emission_color", Color("7eff00"))


func close() -> void:
	closed.emit()
	process_mode = Node.PROCESS_MODE_INHERIT
	collision_shape.disabled = false
	shader.set_shader_parameter("emission_color", Color("8200ff"))
	

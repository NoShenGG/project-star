@tool
class_name Gate extends StaticBody3D

@export_tool_button("Open", "Unlock") var open_gate = open
@export_tool_button("Close", "Lock") var close_gate = close
@onready var collision_shape = $CollisionShape3D

@onready var shader1: ShaderMaterial = $GateModel.get_surface_override_material(2)
@onready var shader2: ShaderMaterial = $Plane.get_surface_override_material(0)

## called when gate opens
signal opened
## called when gate closes
signal closed


func _ready() -> void:
	shader1.set_shader_parameter("Locked", true)
	shader2.set_shader_parameter("Locked", true)
	close()
	
func open() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	collision_shape.disabled = true	
	shader1.set_shader_parameter("Locked", false)
	shader2.set_shader_parameter("Locked", false)


func close() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	collision_shape.disabled = false
	shader1.set_shader_parameter("Locked", true)
	shader2.set_shader_parameter("Locked", true)
	

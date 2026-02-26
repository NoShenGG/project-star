extends Node3D
class_name HapticCaller

@export_category("haptics")
## considered small motor magnitude by gamepad
@export_range(0,1) var small_motor: float = 0.1
## considered large motor magnitude by gamepad
@export_range(0,1) var large_motor: float = 0.1
@export var duration_sec: float = 0.3
@export var delay_sec: float

func call_haptic():
	HapticHandler.global_haptic(global_position,small_motor, large_motor, duration_sec, delay_sec)

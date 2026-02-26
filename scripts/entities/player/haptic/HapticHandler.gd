extends Node3D
class_name HapticHandler

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	haptic_listeners.append(self)

func haptic(frequency: float, amplitude: float, duration_sec: float, delay_sec: float):
	push_warning("no override on haptic. called by " + name)


static var haptic_listeners : Array[HapticHandler]
static func global_haptic(position : Vector3, frequency: float, amplitude: float, duration_sec: float, delay_sec: float, radius : float = 100):
	for listener in haptic_listeners:
		if (listener.global_position.distance_to(position) <= radius):
			print("listener haptic")
			listener.haptic(frequency, amplitude, duration_sec, delay_sec)

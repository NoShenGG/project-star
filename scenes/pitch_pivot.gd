extends Node3D
class_name CameraPivot

@export var shake_reduction_rate := 1.0
@export var noise : FastNoiseLite

const noise_speed := 50.0

var intensity := 0.0
var time := 0.0
@onready var camera := $Camera3D
@onready var initial_rotation := camera.rotation_degrees as Vector3
@export var max_rotation := Vector3(10.0, 10.0, 5.0)

func _process(delta):
	intensity = max(intensity - delta * shake_reduction_rate, 0.0)
	time += delta
	
	camera.rotation_degrees.x = initial_rotation.x + max_rotation.x * shake_intensity() * get_noise_from_seed(0)
	camera.rotation_degrees.y = initial_rotation.y + max_rotation.y * shake_intensity() * get_noise_from_seed(1)
	camera.rotation_degrees.z = initial_rotation.z + max_rotation.z * shake_intensity() * get_noise_from_seed(2)

# function called from outside
func shake(impact: float) -> void:
	intensity += impact;
	intensity = clamp(intensity, 0.0, 1.0)

# squared to get a better function
func shake_intensity() -> float:
	return intensity * intensity

func get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)

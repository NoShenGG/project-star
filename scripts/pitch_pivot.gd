extends Node
class_name CameraPivot

@export var shakeStrength: float = 0.5
@export var shakeFadeDuration: float = 1.0

var rng = RandomNumberGenerator.new()
var initial_camera_pos: Vector3
var shake_strength: float = 0.0
var shake_duration: float = 0.0

@onready var camera: Camera3D = (func get_camera() -> Camera3D:
	var camera3D: Camera3D = get_parent() as Camera3D
	if (camera3D):
		initial_camera_pos = camera3D.position
		return camera3D
	assert(camera != null, "pitch_pivot could not find Camera3D, make sure its parent is a Camera3D.")
	return null
	).call()

func _process(delta):
	if shake_strength > 0.0:
		camera.position = initial_camera_pos + random_offset()
		shake_duration += delta
		
		# linear
		#shake_strength = lerpf(shakeStrength, 0.0, clampf(shake_duration / shakeFadeDuration, 0.0, 1.0))
		
		# exponential
		shake_strength = lerpf(shake_strength, 0.0, clampf(shake_duration / shakeFadeDuration, 0.0, 1.0))

func shake():
	shake_strength = shakeStrength
	Input.get_joy_vibration_strength(shake_strength)
	Input.get_joy_vibration_duration(shake_duration)
	shake_duration = 0.0

func random_offset():	
	return camera.global_transform.basis.x * rng.randf_range(-shake_strength, shake_strength) + camera.global_transform.basis.y * rng.randf_range(-shake_strength, shake_strength)

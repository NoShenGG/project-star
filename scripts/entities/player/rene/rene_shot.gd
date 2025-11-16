class_name ReneShot extends RigidBody3D

var target: Vector3
var force_scale: float = 6.0
var slow_dist: float = 2.0
var home: bool = false

func _ready() -> void:
	var diff = (target - global_position).normalized()
	var push = diff.cross(Vector3.UP) * (1 if randf() < 0.5 else -1)
	push = push.rotated(diff, deg_to_rad(randi_range(-30, 30)))
	push = (push + diff * 0.5).normalized()
	apply_impulse(push * 15)
	get_tree().create_timer(0.25).timeout.connect(func(): home = true)

func _physics_process(_delta: float) -> void:
	if not home:
		return
	linear_velocity = (target - global_position).clamp(Vector3.ONE*-slow_dist, Vector3.ONE*slow_dist) * force_scale

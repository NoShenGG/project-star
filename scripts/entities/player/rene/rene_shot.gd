class_name ReneShot extends RigidBody3D

signal hit

var target: Enemy
var force_scale: float = 6.0
var slow_dist: float = 2.0
var damage: float = 1.0
var home: bool = false

func _ready() -> void:
	if target != null:
		var diff = (target.global_position - global_position).normalized()
		var push = diff.cross(Vector3.UP) * (1 if randf() < 0.5 else -1)
		push = (push + diff * 0.5 + Vector3.UP).normalized()
		apply_impulse(push * 15)
		get_tree().create_timer(0.25).timeout.connect(func(): home = true)
	else:
		home = true
		global_position += Vector3.UP
		global_position += Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y) * 2

func _physics_process(_delta: float) -> void:
	for body in get_colliding_bodies():
		print(body)
		if body is Enemy:
			body = body as Enemy
			body.try_damage(damage)
			hit.emit()
			self.queue_free()
	if not home:
		return
	linear_velocity = (target.global_position - global_position
		if target != null
		else Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y) * slow_dist) \
			.clamp(Vector3.ONE*-slow_dist, Vector3.ONE*slow_dist) * force_scale
	look_at(global_position + linear_velocity)

extends Tone


@export var persist_time: float = 4.0
@export var attraction: float = 0.1
@export var projectile_mesh: MeshInstance3D
@export var effect_hitbox: Area3D
@export var particles: GPUParticles3D
@export var ring_mesh: MeshInstance3D

var timer
var move: bool = true
	
func start() -> void:
	timer = get_tree().create_timer(max_duration)
	timer.timeout.connect(stop_moving)
	hitbox.monitoring = true
	spawn.emit()
	dawn.note_manager.add_red()
	
func _process(delta: float) -> void:
	if move:
		global_position += direction * speed * delta
	elif effect_hitbox.has_overlapping_bodies():
		for body in effect_hitbox.get_overlapping_bodies():
			body.global_position += \
				body.global_position.direction_to(global_position) \
				* attraction \
				* Vector3(1, 0, 1)
				


func hitbox_entered(body: Node3D) -> void:
	if not body is Player:
		stop_moving()

	
func stop_moving() -> void:
	move = false
	hitbox.monitoring = false
	projectile_mesh.visible = false
	effect_hitbox.monitoring = true
	particles.emitting = true
	ring_mesh.visible = true
	timer = get_tree().create_timer(persist_time)
	timer.timeout.connect(destroy)

func destroy() -> void:
	if timer.time_left > 0:
		timer.timeout.disconnect(destroy)
	timer = null
	destroyed.emit()
	queue_free()

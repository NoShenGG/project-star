class_name ReneConstruct extends Area3D

@export var heal_amount: float = 2.0
@export var tick_time: float = 2.0
@export var duration: float = 8.0

@onready var parts: GPUParticles3D = $GPUParticles3D

signal pulse

var time: float = 0
var hide_timer: SceneTreeTimer

func _ready() -> void:
	(func():
		reparent(get_tree().root)
	).call_deferred();

func spawn(caller: Player) -> void:
	global_position = caller.global_position
	global_position += Vector3.UP
	visible = true
	monitoring = true
	time = 0
	hide_timer = get_tree().create_timer(duration)

func despawn() -> void:
	visible = false
	monitoring = false

func _process(delta: float) -> void:
	if hide_timer != null:
		if hide_timer.time_left <= 0:
			hide_timer = null
			despawn()
	if not visible:
		return
	time += delta
	if time < tick_time:
		return
	pulse.emit()
	parts.emitting = true
	for body in get_overlapping_bodies():
		if body is Player:
			(body as Player).try_heal(heal_amount)
	time = 0

extends Tone

@export var effect_duration := 3.0

@onready var bullet = $MeshInstance3D

var timer
var move: bool = true
var in_zone = {}
	
func start() -> void:
	timer = get_tree().create_timer(max_duration)
	timer.timeout.connect(stop_moving)
	hitbox.body_exited.connect(hitbox_exited)
	dawn.note_manager.add_blue()
	hitbox.monitoring = true
	spawn.emit()
	
func _process(delta: float) -> void:
	if not move:
		return
	var diff = speed * delta
	global_position += direction * diff
	hitbox.position.z += diff / 2
	hitbox.scale.z += diff/1.6
	

func hitbox_entered(body: Node3D) -> void:
	if timer == null:
		return
	if body is Player:
		body = body as Player
		var effect := Speed.new()
		in_zone[body] = effect
		body.apply_effect(effect)
		hit_enemy.emit()

func hitbox_exited(body: Node3D) -> void:
	if timer == null:
		return
	if body is Player:
		body = body as Player
		(in_zone[body] as Speed).end_effect()
		in_zone.erase(body)
		
	
func stop_moving() -> void:
	move = false
	timer = get_tree().create_timer(effect_duration)
	timer.timeout.connect(destroy)
	
	
func destroy() -> void:
	timer = null
	for effect in in_zone.values():
		(effect as Speed).end_effect()
	destroyed.emit()
	queue_free()

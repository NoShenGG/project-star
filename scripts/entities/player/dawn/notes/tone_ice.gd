extends Tone

@export var freeze_time = 5.0

var timer
var in_zone = {}
	
func start() -> void:
	timer = get_tree().create_timer(max_duration)
	timer.timeout.connect(destroy)
	hitbox.body_exited.connect(hitbox_exited)
	dawn.note_manager.add_blue()
	hitbox.monitoring = true
	spawn.emit()
	freeze()
	
func freeze():
	await get_tree().physics_frame
	await get_tree().physics_frame
	for body in hitbox.get_overlapping_bodies():
		if body is Enemy:
			body = body as Enemy
			hit_enemy.emit()
			body.apply_effect(Broken.new(EntityEffect.EffectID.BROKEN, freeze_time))
	
	
func _process(_delta: float) -> void:
	pass
	

func hitbox_entered(body: Node3D) -> void:
	if body is Player:
		body = body as Player
		var effect := Speed.new()
		in_zone[body] = effect
		body.apply_effect(effect)
		hit_enemy.emit()

func hitbox_exited(body: Node3D) -> void:
	if body is Player:
		body = body as Player
		(in_zone[body] as Speed).end_effect()
		in_zone.erase(body)
	
	
func destroy() -> void:
	timer = null
	for effect in in_zone.values():
		(effect as Speed).end_effect()
	destroyed.emit()
	queue_free()

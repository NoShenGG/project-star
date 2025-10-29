extends Tone

var timer
	
func start() -> void:
	timer = get_tree().create_timer(max_duration)
	timer.timeout.connect(destroy)
	hitbox.monitoring = true
	spawn.emit()
	dawn.note_manager.add_red()

func hitbox_entered(body: Node3D) -> void:
	if body is Enemy:
		body = body as Enemy
		hit_enemy.emit()
		body.apply_effect(Broken.new(EntityEffect.EffectID.BROKEN, 2))
	
func destroy() -> void:
	if timer.time_left > 0:
		timer.timeout.disconnect(destroy)
	timer = null
	destroyed.emit()
	queue_free()

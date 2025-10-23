extends NoteProjectile

var timer
	
func start() -> void:
	timer = get_tree().create_timer(max_duration)
	timer.timeout.connect(destroy)
	hitbox.monitoring = true
	spawn.emit()

func hitbox_entered(body: Node3D) -> void:
	if body is Enemy:
		body = body as Enemy
		hit_enemy.emit(body)
		body.try_damage(damage)
		destroy()
	
func destroy() -> void:
	if timer.time_left > 0:
		timer.timeout.disconnect(destroy)
	timer = null
	destroyed.emit()
	print("ded")
	queue_free()

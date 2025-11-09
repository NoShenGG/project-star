extends Tone

@export var rehit_time: float = 0.1

var timer
var hit: Array[Enemy] = []
	
func start() -> void:
	timer = get_tree().create_timer(max_duration)
	timer.timeout.connect(destroy)
	hitbox.monitoring = true
	spawn.emit()
	
func _process(_delta: float) -> void:
	super(_delta)
	for body in hitbox.get_overlapping_bodies():
		if body is Enemy and not body in hit:
			body = body as Enemy
			hit_enemy.emit()
			body.try_damage(damage)
			hit.push_back(body)
			get_tree().create_timer(rehit_time).timeout.connect( \
					func(): hit.pop_front())
	

func hitbox_entered(_body: Node3D) -> void:
	pass

func destroy() -> void:
	if timer.time_left > 0:
		timer.timeout.disconnect(destroy)
	timer = null
	destroyed.emit()
	queue_free()

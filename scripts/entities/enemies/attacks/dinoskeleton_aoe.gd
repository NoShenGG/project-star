class_name CorruptionAOE extends Node3D

@export_category("damage")
@export var damage : float = 2

@onready var timer: Timer = $Timer
@onready var hitbox: Hitbox = $Hitbox

func _ready():
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	if not hitbox.body_entered.is_connected(_on_hitbox_body_entered):
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	timer.start()

func _on_timer_timeout() -> void:
	queue_free()
	
	var parent := get_parent()
	if parent != null and parent is SpitProjectileController:
		parent.queue_free()

func _on_hitbox_body_entered(body: Node3D) -> void:
	if (body is Player):
		(body as Player).try_damage(damage)

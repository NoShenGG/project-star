class_name CorruptionAOEAnticipation extends Node3D

@onready var timer: Timer = $Timer

func _ready():
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	queue_free()

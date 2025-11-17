extends Area3D

@export var slow_duration: float = 3.0
@export var slow_factor: float = 0.5

func _ready() -> void:
	# Connect to collision signals
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Entity:
		var slow = SlowStatusEffect.new(slow_duration, slow_factor)
		body.apply_effect(slow)

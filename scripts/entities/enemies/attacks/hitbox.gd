class_name Hitbox extends Area3D

@export var damangeAmount := 10

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func set_disabled(is_disabled: bool) -> void:
	collision_shape.set_deferred("disabled", is_disabled)

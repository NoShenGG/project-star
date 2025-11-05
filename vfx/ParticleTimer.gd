extends Node3D

@export var destroy_cooldown : float = 1



# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().create_timer(destroy_cooldown).timeout.connect(destroy)

func destroy():
	queue_free()

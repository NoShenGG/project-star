
extends Node3D

## how long this node will be visible after being hurt
@export_range(0.01,4, 0.01) var duration : float = 1
var hurt_count : int = 0

func _enter_tree() -> void:
	(get_parent() as Entity).hurt.connect(hurt)
	hide()
	

func _exit_tree() -> void:
	(get_parent() as Entity).hurt.disconnect(hurt)

func hurt(damage : float):
	hurt_count += 1
	var hurt_size : int = hurt_count
	show()
	await get_tree().create_timer(duration).timeout
	## means a new hurt was called, dont want to interrupt the new hurt
	if (hurt_count > hurt_size): return
	hide()
	hurt_count -= 1

extends Node3D

class_name TrailTimer

@export var destroy_cooldown : float = 1
@onready var trail_owner : Node3D = get_parent_node_3d()
@onready var local_offset : Vector3 = position
@onready var local_basis : Basis = basis
@onready var children : Array = (get_all_children(self).filter(func(x): return x is AutoStartVFX))

func _ready() -> void:
	trail_owner.spawned.connect(restart)

func restart():
	for child in children:
		(child as AutoStartVFX).restart_particles()

func deparent_and_timer():
	## sometimes when limbs are destroyed, trails come back to see their village burnt down (limb is gone but trail remains) 
	if (!get_tree()): return
	reparent(get_tree().current_scene)
	get_tree().create_timer(destroy_cooldown).timeout.connect(destroy)
	
	for child in children:
		(child as AutoStartVFX).stop_particles()


func destroy():
	if (trail_owner):
		reparent(trail_owner, false)
		position = local_offset
		basis = local_basis
	else:
		queue_free()

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

class_name PooledOwner3D
extends Node3D

## uses the position and y-basis to spawn pooled objects
@export var spawn_node : Node3D

@export var scene : PackedScene

@export var pooled_starting_size : int = 12
var pooled_array : Array[Pooled3D]

## similar behaviour to packedscene.instantiate. current parent is the spawn_node
func get_spawned_instance() -> Pooled3D:
	## probably faster to calculate than find
	var pooled : Pooled3D = null
	if (pooled_array.size() == 0):
		add_pooled()
		pooled = pooled_array.pop_at(0)
		#print(name + " + NEW POOLED INSTANCE INSTANTIATED")
	else:
		pooled = pooled_array.pop_at(0)
		#print(name + " + norm spawn")
	
	pooled.in_use = true
	pooled.spawn()
	pooled.pooling.connect(pool_instance)
	pooled.show()
	return pooled

func _ready() -> void:
	for i in pooled_starting_size:
		add_pooled()

func _exit_tree() -> void:
	for pooled in pooled_array:
		## yes, children would be freed before this, 
		## but were worried about active unparented pooled items
		if (pooled and pooled.in_use):
			destroy_pooled(pooled)

func destroy_pooled(pooled :Pooled3D):
	await pooled.pooling
	pooled.queue_free()

func add_pooled() -> Pooled3D:
	var instance : Pooled3D = scene.instantiate()
	add_child(instance, true)
	instance.global_position = spawn_node.global_position
	instance.global_basis = spawn_node.global_basis.orthonormalized().scaled(instance.scale)
	pooled_array.append(instance)
	instance.pool()
	instance.hide()
	instance.in_use = false
	return instance

func pool_pooled(pooled : Pooled3D):
	## this is called because our pooled was pooled. (say pooled one more time)
	#pooled.pool()
	pooled.global_position = spawn_node.global_position
	pooled.global_basis = spawn_node.global_basis.orthonormalized().scaled(pooled.scale)
	pooled.reparent.call_deferred(self, true)
	pooled_array.append(pooled)
	pooled.hide()
	pooled.in_use = false

func pool_instance(pooled : Pooled3D):
	pooled.pooling.disconnect(pool_instance)
	pool_pooled(pooled)

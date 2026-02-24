class_name StateGrassSizeChange extends GrassSizeChange


func _ready() -> void:
	super()
	assert(get_parent() is State, "StateGrassSizeChange must be a child of an State")


func _enter_tree() -> void:
	(get_parent() as State).entered.connect(start)
	(get_parent() as State).finished.connect(stop)
func _exit_tree() -> void:
	(get_parent() as State).entered.disconnect(start)
	(get_parent() as State).finished.disconnect(stop)
	

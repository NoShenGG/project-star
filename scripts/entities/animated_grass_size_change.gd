class_name AnimatedStateGrassSizeChange extends GrassSizeChange


func _ready() -> void:
	super()
	assert(get_parent() is AnimationState, "AnimatedStateGrassSizeChange must be a child of an AnimatedState")

func _enter_tree() -> void:
	(get_parent() as AnimationState).start.connect(start)
	(get_parent() as AnimationState).stop.connect(stop)
func _exit_tree() -> void:
	(get_parent() as AnimationState).start.disconnect(start)
	(get_parent() as AnimationState).stop.disconnect(stop)

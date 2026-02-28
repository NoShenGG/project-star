extends HapticCaller
class_name StateHapticCaller

func _enter_tree() -> void:
	assert(get_parent() is State, "Ensure StateHapticCaller is child of State")
	(get_parent() as State).entered.connect(call_haptic)

func _exit_tree() -> void:
	(get_parent() as State).entered.disconnect(call_haptic)

func call_haptic():
	global_position = owner.global_position
	super()

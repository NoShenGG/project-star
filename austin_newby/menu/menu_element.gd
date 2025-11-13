extends Control
class_name MenuElements

# When parent menu closes or opens, play animations and allow itself to be focused/selected

@export var animation_delay : float

func opened() -> void:
	focus_mode = Control.FOCUS_ALL #makes focusable/selectable
	mouse_filter = Control.MOUSE_FILTER_STOP
	show()
	modulate = Color.TRANSPARENT
	await get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, animation_delay).finished # ANIMATION IN FUTURE

func closed() -> void:
	focus_mode = Control.FOCUS_NONE #makes unfocusable/unselectable
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate = Color.WHITE
	await get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, animation_delay).finished # ANIMATION IN FUTURE
	hide()

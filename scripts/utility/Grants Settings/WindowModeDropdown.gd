extends OptionButton

func _ready() -> void:
	item_selected.connect(set_window_mode)
	var mode : DisplayServer.WindowMode = DisplayServer.window_get_mode()
	match mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			selected = 0
		DisplayServer.WINDOW_MODE_WINDOWED:
			selected = 1

func set_window_mode(index : int):
	(%Settings as Settings).set_window(index)

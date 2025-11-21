extends Menu

func _on_setting_scene_done_reading(content : Dictionary) -> void:
	$HBoxContainer/VBoxContainer/WindowedOptionButton.selected = content["window_mode"]
	$HBoxContainer/VBoxContainer/ResolutionOptionButton.selected = content["resolution"]
	$HBoxContainer/VBoxContainer/BrightnessBar.ratio = content["brightness"]

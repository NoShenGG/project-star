extends Control


func _on_setting_scene_done_reading(content : Dictionary) -> void:
	$VBoxContainer/WindowedOptionButton.selected = content["window_mode"]
	$VBoxContainer/ResolutionOptionButton.selected = content["resolution"]
	$VBoxContainer/BrightnessBar.ratio = content["brightness"]

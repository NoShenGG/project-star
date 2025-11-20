extends Menu

func _on_setting_scene_done_reading(content : Dictionary) -> void:
	$VBoxContainer/ReverseControlButton.button_pressed = content["is_reverse_input"]

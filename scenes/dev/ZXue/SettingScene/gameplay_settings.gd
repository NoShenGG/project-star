extends Control


func _on_setting_scene_done_reading(content : Dictionary) -> void:
	$VBoxContainer/RookieHatButton.button_pressed = content["is_rookie_hat"]
	$VBoxContainer/ReverseControlButton.button_pressed = content["is_reverse_input"]

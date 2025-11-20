extends Menu

func _on_setting_scene_done_reading(content : Dictionary) -> void:
	$VBoxContainer/FPSLimitButton.selected = content["is_fps_lock"]
	$VBoxContainer/FPSLimitSlider.value = content["fps_limit"]
	if content["is_fps_lock"]:
		$VBoxContainer/FPSLimitSlider.visible = true
		$VBoxContainer/FPSLimitManifest.visible = true
		$VBoxContainer2/FPSSliderLabel.visible = true


func _on_fps_limit_button_item_selected(index: int) -> void:
	if index == 0:
		$VBoxContainer/FPSLimitSlider.visible = false
		$VBoxContainer/FPSLimitManifest.visible = false
		$VBoxContainer2/FPSSliderLabel.visible = false
	else:
		$VBoxContainer/FPSLimitSlider.visible = true
		$VBoxContainer/FPSLimitManifest.visible = true
		$VBoxContainer2/FPSSliderLabel.visible = true


func _on_fps_limit_slider_value_changed(value: float) -> void:
	$VBoxContainer/FPSLimitManifest.text = str(value)

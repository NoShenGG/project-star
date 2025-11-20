extends Menu

func _on_setting_scene_done_reading(content : Dictionary) -> void:
	$VBoxContainer/MasterVolumeBar.ratio = content["master_volume"]
	$VBoxContainer/MusicVolumeBar.ratio = content["music_volume"]
	$VBoxContainer/SFXVolumeBar.ratio = content["sfx_volume"]

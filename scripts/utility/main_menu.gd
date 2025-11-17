extends Control

func _on_start_button_pressed() -> void:
	GameManager.load_level("MainGame/Biome 1/Biome1_Level1")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

extends Control

func _on_start_button_pressed() -> void:
	GameManager.load_level("demo_level_environment")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

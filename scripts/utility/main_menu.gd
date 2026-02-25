extends Control

@export_range(0,2,0.01) var load_delay : float = 0
@export_range(0,2,0.01) var quit_delay : float = 0

func _on_start_button_pressed() -> void:
	if (load_delay > 0):
		await get_tree().create_timer(load_delay).timeout
		if (!get_tree()): return
	GameManager.load_level("MainGame/Biome 1/Biome1_Level1")

func _on_quit_button_pressed() -> void:
	if (quit_delay > 0):
		await get_tree().create_timer(quit_delay).timeout
		if (!get_tree()): return
	get_tree().quit()

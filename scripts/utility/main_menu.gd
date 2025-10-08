extends Control

func _ready():
	#$VBoxContainer/StartButton.grab_focus()
	pass

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/COPY_THIS.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

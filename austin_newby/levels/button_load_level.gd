extends Button
#this is a button that loads a level for testing purposes
@export var level_name : String

func _on_button_down() -> void:
	GameManager.load_level(level_name)

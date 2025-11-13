extends Control

# this is for testing purposes
# i know this code sucks, please ignore it

func _on_button_pressed() -> void:
	MenuManager.menus["SecondMenu"].open()


func _on_button_pressed2() -> void:
	MenuManager.menus["ThirdMenu"].open()


func _on_button_pressed3() -> void:
	MenuManager.menus["InitialMenu"].open()

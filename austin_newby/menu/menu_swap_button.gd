@tool
@icon("uid://df4e6fvogrt7v")
class_name MenuSwapButton
extends Node

@export var button : Button : 
	get():
		if (button == null and get_parent() is Button):
			await get_tree().create_timer(0.2).timeout
			button = get_parent() as Button
		return button
@export var next_menu : Menu


func _ready() -> void:
	if (Engine.is_editor_hint()):
		if (button == null and get_parent() is Button):
			button = get_parent() as Button
		return
	
	assert(button != null, name + " does not have its Button variable set!")
	assert(next_menu != null, name + " does not have its Menu variable set!")
	button.pressed.connect(open_menu)

func open_menu():
	next_menu.open()

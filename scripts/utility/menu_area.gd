@tool
extends Area3D

@export var menu : Menu

func _enter_tree() -> void:
	assert(menu != null, "Menu is null!")
	
	collision_layer = 0
	collision_mask = 2
	print("called")
	body_entered.connect(open_menu)
	body_exited.connect(close_menu)


func open_menu(body : Node3D):
	if (!body.is_in_group("Player")): return
	print("opening")
	menu.open()

func close_menu(body : Node3D):
	if (!body.is_in_group("Player")): return
	print("closing")
	menu.close()

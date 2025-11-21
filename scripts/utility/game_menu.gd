extends Menu

@export var overridable_menus : Array[Menu]

func _enter_tree() -> void:
	pass

func _exit_tree() -> void:
	pass

func _ready() -> void:
	for menu in overridable_menus:
		menu.menu_closed.connect(check_should_open)
		menu.menu_shown.connect(close_game_menu)

func close_game_menu():
	close.call_deferred()

func check_should_open():
	for menu in overridable_menus:
		if (menu.is_open):
			return
	
	open.call_deferred()

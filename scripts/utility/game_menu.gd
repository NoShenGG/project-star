class_name GameMenu extends Menu

@export var overridable_menus : Array[Menu]

static var game_menu : GameMenu

func _enter_tree() -> void:
	game_menu = self

func _exit_tree() -> void:
	game_menu = null

func add_menu(menu : Menu):
	overridable_menus.append(menu)
	menu.menu_closed.connect(check_should_open)
	menu.menu_shown.connect(close_game_menu)
func remove_menu(menu : Menu):
	if overridable_menus.has(menu):
		menu.menu_closed.disconnect(check_should_open)
		menu.menu_shown.disconnect(close_game_menu)
		overridable_menus.erase(menu)

func _ready() -> void:
	super()
	for menu in overridable_menus:
		menu.menu_closed.connect(check_should_open)
		menu.menu_shown.connect(close_game_menu)

func close_game_menu():
	close.call_deferred()

func check_should_open():
	## BECAUSE IM FUCKING LAZY AND HATE RACE CONDITIONS
	await get_tree().create_timer(0.25).timeout
	for menu in overridable_menus:
		if (menu.transitioning):
			if (menu.is_open):
				await menu.open_time
			else:
				await menu.close_time
		if (menu.is_open):
			
			print("return")
			return
	
	open.call_deferred()

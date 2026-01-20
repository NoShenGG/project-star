extends Menu

@onready var player_manager : PlayerManager = owner as PlayerManager
## how long to simmer in death before opening menu

var background_index : int = 0

@export var nova_menu : Control
@export var rene_menu : Control
@export var dawn_menu : Control
signal menu_swapped()

func _ready() -> void:
	(owner as PlayerManager).new_player.connect(swap_menu_background)
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu_shown.connect(pause_opened)
	menu_hidden.connect(pause_closed)
	menu_closed.connect(pause_closed)
	
	## annoying race condition stops from more customizable behaviour
	nova_menu.visible = true

func _process(delta: float) -> void:
	
	if (Input.is_action_just_pressed("pause_game")):
		if (is_open):
			close()
		else:
			open()
	
	if (is_visible_in_tree() and visible):
		if (Input.is_action_just_pressed("move_right")):
			increment_menu_background()
		elif (Input.is_action_just_pressed("move_left")):
			decrement_menu_background()



func decrement_menu_background():
	var index = player_manager.players.size() - 1 if (background_index - 1) < 0 else background_index - 1 
	if (index != background_index): swap_menu_background(player_manager.players[background_index])
	background_index = index

func increment_menu_background():
	var index = (background_index + 1) % (player_manager.players.size())
	if (index != background_index): swap_menu_background(player_manager.players[background_index])
	background_index = index

func swap_menu_background(player : Player):
	print("changed")
	nova_menu.visible = player.name == "Nova"
	rene_menu.visible = player.name == "Rene"
	dawn_menu.visible = player.name == "Dawn"
	menu_swapped.emit()


func _exit_tree() -> void:
	get_tree().paused = false

func pause_opened():
	print("test opened")
	get_tree().paused = true
func pause_closed():
	print("test closed")
	get_tree().paused = false

func restart_game():
	GameManager.reload_level()

func quit_to_main():
	GameManager.exit_to_main_menu()

func quit_game():
	GameManager.exit_game()

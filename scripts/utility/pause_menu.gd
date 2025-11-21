extends Menu

@onready var player_manager : PlayerManager = owner as PlayerManager
## how long to simmer in death before opening menu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu_shown.connect(pause_opened)
	menu_hidden.connect(pause_closed)
	menu_closed.connect(pause_closed)

func _process(delta: float) -> void:
	
	if (Input.is_action_just_pressed("pause_game")):
		if (is_open):
			close()
		else:
			open()

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

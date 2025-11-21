extends Menu

@onready var player_manager : PlayerManager = owner as PlayerManager
## how long to simmer in death before opening menu
@export var time_to_die : float = 0.25
func _ready() -> void:
	
	player_manager.game_over.connect(game_end)


func game_end():
	await get_tree().create_timer(time_to_die).timeout
	open()


func restart_game():
	GameManager.reload_level()

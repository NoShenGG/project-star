extends Area3D

func _ready() -> void:
	monitoring = false
	get_parent().hide()

func _enable_end() -> void:
	get_parent().show()
	monitoring = true

func _on_body_entered(body: CharacterBody3D) -> void:
	if (is_same(body, GameManager.curr_player)): #in case switching player
		GameManager.load_level("end_screen")

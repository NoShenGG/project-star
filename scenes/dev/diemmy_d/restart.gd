extends Area3D

var player: CharacterBody3D

func _ready() -> void:
	var player_manager = get_node("/root/Prototype/PlayerManager")
	player = player_manager.current_char


func _on_body_entered(body: CharacterBody3D) -> void:
	if (player == body) : #in case switching player
		# print("that's the player")
		# get_tree().reload_current_scene() 
		# load the loading scene
		get_tree().change_scene_to_file("res://scenes/dev/christian_d/LoadingScreen.tscn")
		
	
	

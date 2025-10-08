@tool
class_name PlayerManager
extends Node3D

@onready var current_char: Player

signal new_player(value : Player)


func _ready() -> void:
	# TODO: Should load or somehow maintain the character's selected char throughout scenes
	# e.g. if the player leaves scene1 and enters scene2, they should have the same selected character
	current_char = get_child(0)
	current_char.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	for c in get_children():
		if !(c is Player): 
			## yes, i know this is a return, i know what it does. no continue
			return
		
		if c.name != current_char.name:
			c.visible = false
			c.set_process_mode(Node.PROCESS_MODE_DISABLED)
		
		c.top_level = true
		c.global_position = global_position
		c.global_rotation = global_rotation
	

func _process(delta: float) -> void:
	if (Engine.is_editor_hint()):
		for c in get_children():
			if (c is Player):
				c.global_position = global_position
				c.global_rotation = global_rotation
		return
	
	if (Input.is_action_just_pressed("select_char1")):
		swap_char(0)
	elif (Input.is_action_just_pressed("select_char2")):
		swap_char(1)
	elif (Input.is_action_just_pressed("select_char3")):
		swap_char(2)
	
	## this line works because the players are top_level. 
	## allowing external code to be able to see the player still in edgecases
	global_position = current_char.global_position


'''
	Uses node hierarchy for character switching, assuming characters are the only direct children 
	under the player manager. If not, could just group characters under another child node
	e.g. get_node("characters").get_child(idx)
	- PlayerManager
	- - Characters
	- - - Player1
	- - - Player2
		  ...
'''
func swap_char(idx: int):
	if idx < get_child_count() and current_char.name != get_child(idx).name:
		var new_char: CharacterBody3D = get_child(idx)
		
		current_char.visible = false
		current_char.set_process_mode(Node.PROCESS_MODE_DISABLED) # disables all processing
		new_char.set_global_transform(current_char.get_global_transform())
		new_char.velocity = current_char.velocity
		new_char.reset_physics_interpolation()
		# TODO: Manage state
		# Could set the new character's state to the former selected character's through some sort of map
		# Could also just reset the state to some general one like idle or walk if the FSM is good enough
		
		current_char = new_char
		current_char.visible = true
		current_char.set_process_mode(Node.PROCESS_MODE_ALWAYS)
		
		new_player.emit(current_char)

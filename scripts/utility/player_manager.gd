@tool
class_name PlayerManager
extends Node3D

@onready var current_char: Player

signal new_player(value : Player)


func _init() -> void:
	GameManager.player_manager = self

func _ready() -> void:
	if (Engine.is_editor_hint()): return
	# TODO: Should load or somehow maintain the character's selected char throughout scenes
	# e.g. if the player leaves scene1 and enters scene2, they should have the same selected character
	current_char = get_child(0)
	for c in get_children():
		if !(c is Player): 
			## yes, i know this is a return, i know what it does. no continue
			return
		
		if c.name != current_char.name:
			c.visible = false
			(c as Player).state_machine.state = c.get_node("StateMachine/Sleeping")
			(c as Player).get_node("CollisionShape3D").disabled = true
		
		c.top_level = true
		c.global_position = global_position
		c.global_rotation = global_rotation
	

func _process(_delta: float) -> void:
	if (Engine.is_editor_hint()):
		for c in get_children():
			if (c is Player):
				c.global_position = global_position
				c.global_rotation = global_rotation
		return
	
	if current_char.can_swap():
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
		var new_char := get_child(idx) as Player
		new_player.emit(new_char)
		new_char.set_global_transform(current_char.get_global_transform())
		new_char.velocity = current_char.velocity
		new_char.reset_physics_interpolation()
		
		(current_char.state_machine as PlayerStateMachine).swap_out()
		(new_char.state_machine as PlayerStateMachine).swap_in()
		current_char = new_char

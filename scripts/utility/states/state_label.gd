"
state label
used to see what state a statemachine is currently in

can be put as a child of a player_manager or player

"
class_name StateLabel
extends Node

@export var debug : bool = true
var label : Label3D

@onready var character : Entity
@onready var player_manager : PlayerManager

var statemachine : StateMachine

func _ready() -> void:
	await get_parent().ready
	setup_debug()


## calling because exiting tree and being moved in the tree are the same thing
func _enter_tree() -> void:
	if (statemachine): statemachine.state_entered.disconnect(change_label)

func _exit_tree() -> void:
	statemachine.state_entered.disconnect(change_label)

func change_label(state_name : String):
	label.text = state_name

func swap_character(value : Entity):
	statemachine.state_entered.disconnect(change_label)
	
	statemachine = value.state_machine
	statemachine.state_entered.connect(change_label)
	label.text = statemachine.state.name

func setup_debug():
	character = get_parent() as Entity
	if (character):
		statemachine = character.state_machine
	player_manager = get_parent() as PlayerManager
	if (player_manager):
		statemachine = player_manager.current_char.state_machine
		player_manager.new_player.connect(swap_character)
	
	
	if (debug):
		statemachine.state_entered.connect(change_label)
		label = Label3D.new()
		label.name = "debug label"
		
		var parent : Node3D = player_manager if player_manager else character
		parent.add_child(label, true)
		
		label.text = statemachine.state.name
		label.modulate = Color.BLUE
		label.scale = Vector3.ONE * 7
		
		label.position = Vector3.UP * 4
		label.no_depth_test = true
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		label.fixed_size = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		# the scale is vastly different between vr and flatscreen when enabled :/
		label.fixed_size = false

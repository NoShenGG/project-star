@tool
@icon("res://addons/fmod/icons/c_parameter_icon.svg")
extends Node
class_name AnimationState

@export var return_to_reciever : bool = true
@export var play_on_start : bool = false

## what the name of the AnimationNodeAnimation we want to move to. may call errors during changing, error is only concerning if full name produced error
@export var state_name : String = "Set":
	set(value):
		if (!animation_tree):
			state_name = value
			return
		
		if ((animation_tree.tree_root as AnimationNodeStateMachine).has_node(value)):
			state_name = value
		else:
			printerr("State Name "+value+" does not exist in TreeRoot's Statemachine")
		
		# when actively editing a string variable in editor, 
		# it calls set every time a new letter is added. so cant handle edgecase safely
		state_name = value

@export_storage var animation_tree : AnimationTree

func _enter_tree() -> void:
	var value : AnimationTree = null
	
	value = get_parent() as AnimationTree
	if (value != null):
		animation_tree = value
		return
	
	for i in get_parent().get_children():
		if (i is AnimationTree):
			value = i
			animation_tree = i
			return
	assert(animation_tree != null, "Could not find AnimationTree!")


func enter():
	print(owner.name + " is swapping to "+ state_name + "!")
	(animation_tree["parameters/playback"] as AnimationNodeStateMachinePlayback).start(state_name)

func _ready() -> void:
	if (play_on_start):
		enter()

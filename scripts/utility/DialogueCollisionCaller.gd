@icon("uid://megolcw1kt24")
@tool
class_name DialogueCollisionCaller
extends Area3D

@export var dialogue : DialogueCaller
var called : bool = false
func _enter_tree() -> void:
	if (Engine.is_editor_hint()):
		return
	
	collision_layer = 0
	collision_mask = 2
	
	body_entered.connect(start_dialogue)

func _ready() -> void:
	if (dialogue == null):
		for i in get_children():
			if i is DialogueCaller:
				dialogue = i as DialogueCaller
	
	assert(dialogue != null, "Dialogue is Null in " + name)
	

func start_dialogue(body : Node3D):
	if (called): return
	called = true
	dialogue.activate_dialogue()

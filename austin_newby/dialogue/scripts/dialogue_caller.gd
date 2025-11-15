@icon("uid://bocihms1qsi20")
extends Node
class_name DialogueCaller

@export var dialogue : Array[DialogueResource]

func activate_dialogue() -> void:
	DialogueContainer.read(dialogue)

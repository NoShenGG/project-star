@icon("uid://bocihms1qsi20")
extends Node
class_name DialogueCaller

@export var dialogue : Array[DialogueResource]
signal dialogue_finished

func activate_dialogue() -> void:
	DialogueContainer.read(dialogue)
	await DialogueContainer.dialogue_finished
	dialogue_finished.emit()
